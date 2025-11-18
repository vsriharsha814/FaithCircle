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
import { getAuth, Auth, initializeAuth, getReactNativePersistence } from 'firebase/auth';
import { getFirestore, Firestore } from 'firebase/firestore';
import AsyncStorage from '@react-native-async-storage/async-storage';

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
  return (
    firebaseConfig.apiKey !== "AIzaSyBI9wdROlWVc0ONnyDNshpW_XDygLfQ" &&
    firebaseConfig.projectId !== "faithcircle-13a61" &&
    firebaseConfig.apiKey.length > 0 &&
    firebaseConfig.projectId.length > 0
  );
};

// Initialize Firebase only if properly configured
let app: FirebaseApp | null = null;
let auth: Auth | null = null;
let db: Firestore | null = null;

if (isFirebaseConfigured()) {
  try {
    if (getApps().length === 0) {
      app = initializeApp(firebaseConfig);
      // Initialize Auth with AsyncStorage persistence for React Native
      auth = initializeAuth(app, {
        persistence: getReactNativePersistence(AsyncStorage),
      });
      db = getFirestore(app);
    } else {
      app = getApps()[0];
      auth = getAuth(app);
      db = getFirestore(app);
    }
  } catch (error) {
    console.warn('Firebase initialization error:', error);
    console.warn('Please configure Firebase in src/utils/firebase.ts');
  }
} else {
  console.warn(
    '⚠️ Firebase is not configured yet. ' +
    'Please update the firebaseConfig in src/utils/firebase.ts with your Firebase credentials.'
  );
}

export { app, auth, db, isFirebaseConfigured };

