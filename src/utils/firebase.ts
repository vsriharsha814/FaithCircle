// Firebase configuration
// TODO: Add your Firebase credentials here
// 
// 1. Create a Firebase project at https://console.firebase.google.com
// 2. Enable Authentication > Google sign-in method
// 3. Create a Firestore database
// 4. Create a web app in your Firebase project
// 5. Get your Firebase config from Project Settings > General > Your apps > Web app
// 6. Replace the firebaseConfig object below with your config
// 7. Get your Google Web Client ID from Authentication > Sign-in method > Google

import { initializeApp, getApps, FirebaseApp } from 'firebase/app';
import { getAuth, Auth, initializeAuth } from 'firebase/auth';
import { getFirestore, Firestore } from 'firebase/firestore';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Try to import ReactNativePersistence - it might not be available in all Firebase versions
let getReactNativePersistence: any;
try {
  const authModule = require('firebase/auth');
  getReactNativePersistence = authModule.getReactNativePersistence;
} catch (e) {
  // Fallback - will use getAuth instead
  getReactNativePersistence = null;
}

// Firebase config - Replace with your own config from Firebase Console
const firebaseConfig = {
  apiKey: "AIzaSyBI9wdROlWVc0ONnyDNshpW_XDygLfQ-zg",
  authDomain: "faithcircle-13a61.firebaseapp.com",
  projectId: "faithcircle-13a61",
  storageBucket: "faithcircle-13a61.firebasestorage.app",
  messagingSenderId: "116489116894",
  appId: "1:116489116894:web:d28736788cd3780d65764f",
  measurementId: "G-ZC7KTNKTWD"
};

// Check if Firebase is configured (not using placeholder values)
const isFirebaseConfigured = () => {
  const isConfigured = (
    firebaseConfig.apiKey !== "your-api-key-here" &&
    firebaseConfig.projectId !== "your-project-id" &&
    firebaseConfig.apiKey.length > 0 &&
    firebaseConfig.projectId.length > 0 &&
    !firebaseConfig.apiKey.includes("your-") &&
    !firebaseConfig.projectId.includes("your-")
  );
  
  if (!isConfigured) {
    console.log('Firebase config check failed:', {
      apiKey: firebaseConfig.apiKey.substring(0, 20) + '...',
      projectId: firebaseConfig.projectId,
      apiKeyLength: firebaseConfig.apiKey.length,
      projectIdLength: firebaseConfig.projectId.length,
    });
  }
  
  return isConfigured;
};

// Initialize Firebase only if properly configured
let app: FirebaseApp | null = null;
let auth: Auth | null = null;
let db: Firestore | null = null;

const configured = isFirebaseConfigured();

if (configured) {
  try {
    if (getApps().length === 0) {
      console.log('🔥 Initializing Firebase...');
      app = initializeApp(firebaseConfig);
      
      // Try to initialize Auth with persistence if available, otherwise use getAuth
      try {
        if (getReactNativePersistence) {
          auth = initializeAuth(app, {
            persistence: getReactNativePersistence(AsyncStorage),
          });
          console.log('✅ Firebase Auth initialized with persistence');
        } else {
          // Fallback to getAuth if ReactNativePersistence is not available
          auth = getAuth(app);
          console.log('✅ Firebase Auth initialized (using getAuth)');
        }
      } catch (authError: any) {
        // If auth is already initialized, just get the existing instance
        if (authError.message?.includes('already been initialized') || 
            authError.message?.includes('already initialized') ||
            authError.message?.includes('has not been registered')) {
          console.log('⚠️ Auth initialization issue, using getAuth instead...');
          auth = getAuth(app);
          console.log('✅ Firebase Auth initialized with getAuth');
        } else {
          // Try using getAuth as fallback
          console.log('⚠️ initializeAuth failed, trying getAuth...');
          auth = getAuth(app);
          console.log('✅ Firebase Auth initialized with getAuth');
        }
      }
      
      db = getFirestore(app);
      console.log('✅ Firebase initialized successfully');
    } else {
      app = getApps()[0];
      auth = getAuth(app);
      db = getFirestore(app);
      console.log('✅ Firebase already initialized');
    }
  } catch (error: any) {
    console.error('❌ Firebase initialization error:', error);
    console.error('Error details:', error.message, error.code);
    
    // Try to recover by using getAuth directly
    try {
      if (app) {
        console.log('🔄 Attempting recovery with getAuth...');
        auth = getAuth(app);
        db = getFirestore(app);
        console.log('✅ Firebase recovered successfully');
      }
    } catch (recoveryError) {
      console.warn('Please check your Firebase configuration in src/utils/firebase.ts');
    }
  }
} else {
  console.warn(
    '⚠️ Firebase is not configured yet. ' +
    'Please update the firebaseConfig in src/utils/firebase.ts with your Firebase credentials.'
  );
  console.warn('Current config:', {
    apiKey: firebaseConfig.apiKey.substring(0, 30) + '...',
    projectId: firebaseConfig.projectId,
  });
}

export { app, auth, db, isFirebaseConfigured };

