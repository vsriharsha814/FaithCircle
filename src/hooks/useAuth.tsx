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
import * as WebBrowser from 'expo-web-browser';
import * as Crypto from 'expo-crypto';
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
    // Only listen for auth changes if Firebase is configured
    if (!auth || !isFirebaseConfigured()) {
      setLoading(false);
      return;
    }

    // Listen for auth state changes
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        const appUser = await convertFirebaseUser(firebaseUser);
        setUser(appUser);
      } else {
        setUser(null);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const signInWithGoogle = async () => {
    if (!auth || !db || !isFirebaseConfigured()) {
      throw new Error(
        'Firebase is not configured yet. Please set up Firebase following the instructions in FIREBASE_SETUP.md'
      );
    }

    try {
      const googleClientId = process.env.EXPO_PUBLIC_GOOGLE_CLIENT_ID || '';
      
      if (!googleClientId) {
        throw new Error(
          'Google Client ID not configured. Please set EXPO_PUBLIC_GOOGLE_CLIENT_ID in your environment variables or update useAuth.tsx directly.'
        );
      }

      // Generate random state for security
      const state = await Crypto.digestStringAsync(
        Crypto.CryptoDigestAlgorithm.SHA256,
        Math.random().toString() + Date.now().toString()
      );

      const redirectUri = AuthSession.makeRedirectUri({ useProxy: true });

      // Create OAuth request
      const request = new AuthSession.AuthRequest({
        clientId: googleClientId,
        scopes: ['openid', 'profile', 'email'],
        responseType: AuthSession.ResponseType.IdToken,
        redirectUri,
        state,
        extraParams: {},
        additionalParameters: {},
      });

      // Start authentication session
      const result = await request.promptAsync({
        authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
        useProxy: true,
      });

      if (result.type === 'success') {
        // Get the ID token from the result
        const { id_token } = result.params;
        
        if (!id_token) {
          throw new Error('No ID token received from Google');
        }

        // Create credential with Google ID token
        const credential = GoogleAuthProvider.credential(id_token);
        
        // Sign in with Firebase
        const userCredential = await signInWithCredential(auth, credential);
        
        // Get or create user document in Firestore
        const appUser = await convertFirebaseUser(userCredential.user);
        setUser(appUser);
      } else if (result.type === 'error') {
        const errorMsg = result.error?.message || result.error?.errorDescription || 'Google Sign-In failed';
        throw new Error(errorMsg);
      } else {
        // User cancelled (result.type === 'dismiss')
        throw new Error('Sign in cancelled');
      }
    } catch (error: any) {
      console.error('Google Sign-In error:', error);
      let errorMessage = 'Google Sign-In failed. Please try again.';
      
      if (error.message) {
        errorMessage = error.message;
      } else if (error.code) {
        if (error.code === 'auth/account-exists-with-different-credential') {
          errorMessage = 'An account already exists with this email.';
        } else if (error.code === 'auth/invalid-credential') {
          errorMessage = 'Invalid credentials. Please try again.';
        } else if (error.code === 'auth/popup-closed-by-user') {
          errorMessage = 'Sign in cancelled';
        }
      }
      
      throw new Error(errorMessage);
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

