import { useState, useEffect, createContext, useContext, ReactNode } from 'react';
import { 
  signInWithCredential,
  GoogleAuthProvider,
  signOut,
  onAuthStateChanged,
  User as FirebaseUser
} from 'firebase/auth';
import { doc, setDoc, getDoc } from 'firebase/firestore';
import * as AuthSession from 'expo-auth-session';
import { AccessTokenRequest } from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';
import { auth, db, isFirebaseConfigured } from '../utils/firebase';
import { User } from '../types';

// Complete the browser-based authentication session
WebBrowser.maybeCompleteAuthSession();

// Check Firebase configuration
if (!isFirebaseConfigured() || !auth || !db) {
  console.warn(
    '⚠️ Firebase is not configured. Authentication features will not work. ' +
    'Please set up Firebase following the instructions in FIREBASE_SETUP.md'
  );
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  signInWithGoogle: () => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

// Convert Firebase user to our User type
const convertFirebaseUser = async (firebaseUser: FirebaseUser): Promise<User | null> => {
  if (!db) {
    // Fallback if Firestore is not available
    return {
      id: firebaseUser.uid,
      email: firebaseUser.email || '',
      name: firebaseUser.displayName || firebaseUser.email?.split('@')[0] || '',
      createdAt: firebaseUser.metadata.creationTime || new Date().toISOString(),
    };
  }

  try {
    // Get user document from Firestore
    const userDocRef = doc(db, 'users', firebaseUser.uid);
    const userDoc = await getDoc(userDocRef);
    
    if (userDoc.exists()) {
      const userData = userDoc.data();
      return {
        id: firebaseUser.uid,
        email: firebaseUser.email || '',
        name: userData.name || '',
        church: userData.church || undefined,
        createdAt: userData.createdAt || firebaseUser.metadata.creationTime || new Date().toISOString(),
      };
    } else {
      // Create user document if it doesn't exist
      const newUser: User = {
        id: firebaseUser.uid,
        email: firebaseUser.email || '',
        name: firebaseUser.displayName || firebaseUser.email?.split('@')[0] || '',
        createdAt: firebaseUser.metadata.creationTime || new Date().toISOString(),
      };
      await setDoc(userDocRef, {
        name: newUser.name,
        email: newUser.email,
        createdAt: newUser.createdAt,
      });
      return newUser;
    }
  } catch (error) {
    console.error('Error converting Firebase user:', error);
    // Fallback to basic user data
    return {
      id: firebaseUser.uid,
      email: firebaseUser.email || '',
      name: firebaseUser.displayName || firebaseUser.email?.split('@')[0] || '',
      createdAt: firebaseUser.metadata.creationTime || new Date().toISOString(),
    };
  }
};

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    console.log('🔍 Checking Firebase configuration...', {
      isConfigured: isFirebaseConfigured(),
      hasAuth: !!auth,
      authValue: auth ? 'exists' : 'null'
    });

    // Set a timeout to ensure loading doesn't hang forever
    const loadingTimeout = setTimeout(() => {
      console.log('⚠️ Auth loading timeout after 1.5s - forcing loading to false');
      setLoading(false);
    }, 1500); // 1.5 second timeout

    // Check immediately if Firebase is not configured
    if (!isFirebaseConfigured() || !auth) {
      console.log('⚠️ Firebase not configured or auth is null - setting loading to false immediately');
      clearTimeout(loadingTimeout);
      setLoading(false);
      return () => clearTimeout(loadingTimeout);
    }

    // Listen for auth state changes
    console.log('👂 Setting up Firebase auth state listener...');
    try {
      const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
        clearTimeout(loadingTimeout);
        console.log('🔔 Auth state changed:', firebaseUser ? 'User logged in' : 'No user');
        
        try {
          if (firebaseUser) {
            const appUser = await convertFirebaseUser(firebaseUser);
            setUser(appUser);
          } else {
            setUser(null);
          }
        } catch (error) {
          console.error('Error converting Firebase user:', error);
          setUser(null);
        } finally {
          setLoading(false);
        }
      });

      return () => {
        clearTimeout(loadingTimeout);
        unsubscribe();
      };
    } catch (error: any) {
      // Handle auth state listener setup errors
      clearTimeout(loadingTimeout);
      console.error('❌ Auth state listener setup error:', error);
      setLoading(false);
      setUser(null);
      return () => clearTimeout(loadingTimeout);
    }
  }, []);

  const signInWithGoogle = async () => {
    console.log('🎯 signInWithGoogle called');
    console.log('   Auth:', !!auth);
    console.log('   DB:', !!db);
    console.log('   Firebase configured:', isFirebaseConfigured());
    
    if (!auth || !db || !isFirebaseConfigured()) {
      const error = 'Firebase is not configured yet. Please set up Firebase following the instructions in FIREBASE_SETUP.md';
      console.error('❌', error);
      throw new Error(error);
    }

    try {
      console.log('✅ Pre-flight checks passed, starting Google Sign-In...');
      const googleClientId = process.env.EXPO_PUBLIC_GOOGLE_CLIENT_ID || '';
      
      if (!googleClientId) {
        throw new Error(
          'Google Client ID not configured. Please set EXPO_PUBLIC_GOOGLE_CLIENT_ID in your environment variables or update useAuth.tsx directly.'
        );
      }

      console.log('📱 Using expo-auth-session with Google OAuth');
      console.log('   Setting up OAuth flow...');
      
      // Generate redirect URI - automatically uses proxy in Expo Go
      let redirectUri = AuthSession.makeRedirectUri({
        scheme: 'faithcircle',
      });
      
      // If we got a local IP (exp://), use the HTTPS proxy URI instead
      // This happens when not logged into Expo CLI or proxy is unavailable
      if (redirectUri.startsWith('exp://') && redirectUri.includes(':')) {
        console.warn('⚠️  Got local IP redirect URI:', redirectUri);
        console.warn('   Switching to HTTPS proxy URI for Google OAuth compatibility...');
        
        // Construct the HTTPS proxy URI
        // Format: https://auth.expo.io/@username/project-slug
        // From app.json: slug is "faith-circle"
        // Username: @vsriharsha814 (from previous attempts)
        redirectUri = 'https://auth.expo.io/@vsriharsha814/faith-circle';
        
        console.warn('   Using HTTPS proxy URI:', redirectUri);
        console.warn('');
        console.warn('💡 Tip: To enable automatic proxy URI, log into Expo CLI:');
        console.warn('      npx expo login');
        console.warn('');
      }
      
      console.log('✅ Redirect URI:', redirectUri);
      console.log('');
      console.log('⚠️  IMPORTANT: Add this Redirect URI to Google Cloud Console:');
      console.log('   ' + redirectUri);
      console.log('');
      console.log('1. Go to: https://console.cloud.google.com/apis/credentials');
      console.log('2. Select your Web client ID');
      console.log('3. Add the redirect URI above to "Authorized redirect URIs"');
      console.log('4. Save and wait 1-2 minutes');
      console.log('');
      
      // Create the OAuth request - use Code flow for mobile apps
      const request = new AuthSession.AuthRequest({
        clientId: googleClientId,
        scopes: ['openid', 'profile', 'email'],
        responseType: AuthSession.ResponseType.Code,
        redirectUri,
        usePKCE: true, // Required for mobile OAuth
      });
      
      console.log('✅ AuthRequest created');
      console.log('   Starting OAuth prompt...');
      
      // Discovery document for Google
      const discovery = {
        authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
        tokenEndpoint: 'https://oauth2.googleapis.com/token',
        revocationEndpoint: 'https://oauth2.googleapis.com/revoke',
      };
      
      // Start the OAuth flow
      const result = await request.promptAsync(discovery);

      console.log('📥 OAuth result received');
      console.log('   Type:', result?.type);
      
      if (result.type === 'success') {
        const { code, id_token, access_token } = result.params;
        
        console.log('✅ OAuth successful');
        console.log('   Code:', code ? 'Present' : 'Missing');
        console.log('   ID token:', id_token ? 'Present' : 'Missing');
        
        // If we have an id_token directly (web flow), use it
        // Otherwise, exchange the code for tokens
        let idToken = id_token;
        let accessToken = access_token;
        
        if (!idToken && code) {
          console.log('🔄 Exchanging code for tokens...');
          
          // Exchange code for tokens using PKCE
          const tokenRequest = new AccessTokenRequest({
            clientId: googleClientId,
            code,
            redirectUri,
            scopes: ['openid', 'profile', 'email'],
            extraParams: {
              code_verifier: request.codeVerifier || '',
            },
          });
          
          const tokenResponse = await tokenRequest.performAsync(discovery);
          
          if (!tokenResponse || !tokenResponse.idToken) {
            throw new Error('Failed to exchange code for ID token');
          }
          
          idToken = tokenResponse.idToken;
          accessToken = tokenResponse.accessToken || '';
          
          console.log('✅ Token exchange successful');
        }
        
        if (!idToken) {
          throw new Error('No ID token received from Google Sign-In');
        }
        
        console.log('✅ Received ID token from Google');
        console.log('   ID token length:', idToken.length);
        
        // Create credential with Google ID token
        console.log('🔐 Creating Firebase credential...');
        const credential = GoogleAuthProvider.credential(idToken, accessToken);
        
        if (!credential) {
          throw new Error('Failed to create Firebase credential from ID token');
        }
        
        console.log('✅ Credential created');
        
        // Sign in with Firebase
        console.log('🔥 Signing in to Firebase...');
        const userCredential = await signInWithCredential(auth, credential);
        
        if (!userCredential || !userCredential.user) {
          throw new Error('Firebase sign-in failed - no user returned');
        }
        
        console.log('✅ Signed in to Firebase');
        console.log('   User ID:', userCredential.user.uid);
        console.log('   Email:', userCredential.user.email);
        
        // Get or create user document in Firestore
        console.log('📄 Getting/creating user document in Firestore...');
        const appUser = await convertFirebaseUser(userCredential.user);
        
        if (!appUser) {
          throw new Error('Failed to convert Firebase user to app user');
        }
        
        console.log('✅ User document ready');
        setUser(appUser);
        console.log('🎉 Sign-in complete!');
      } else {
        // Sign-in failed or cancelled
        console.log('⚠️ Google Sign-In failed or cancelled');
        console.log('   Result type:', result?.type);
        throw new Error('Google Sign-In failed or was cancelled. Please try again.');
      }
    } catch (error: any) {
      console.error('');
      console.error('═══════════════════════════════════════════════════════');
      console.error('❌ Google Sign-In Error Caught:');
      console.error('');
      console.error('Error object:', error);
      console.error('Error message:', error?.message);
      console.error('Error code:', error?.code);
      console.error('Error name:', error?.name);
      console.error('Error stack:', error?.stack);
      console.error('Full error:', JSON.stringify(error, null, 2));
      console.error('═══════════════════════════════════════════════════════');
      console.error('');
      
      let errorMessage = 'Google Sign-In failed. Please try again.';
      
      if (error?.message) {
        errorMessage = error.message;
      } else if (error?.code) {
        if (error.code === 'auth/account-exists-with-different-credential') {
          errorMessage = 'An account already exists with this email.';
        } else if (error.code === 'auth/invalid-credential') {
          errorMessage = 'Invalid credentials. Please try again.';
        } else if (error.code === 'auth/popup-closed-by-user') {
          errorMessage = 'Sign in cancelled';
        } else {
          errorMessage = `Error: ${error.code} - ${error.message || 'Unknown error'}`;
        }
      }
      
      // Make sure the error message is user-friendly but informative
      const finalError = new Error(errorMessage);
      (finalError as any).originalError = error;
      throw finalError;
    }
  };

  const logout = async () => {
    if (!auth || !isFirebaseConfigured()) {
      setUser(null);
      return;
    }

    try {
      await signOut(auth);
      setUser(null);
    } catch (error) {
      console.error('Error signing out:', error);
      throw new Error('Failed to sign out. Please try again.');
    }
  };

  return (
    <AuthContext.Provider value={{ user, loading, signInWithGoogle, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

