# Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project" or select an existing project
3. Follow the setup wizard

## Step 2: Enable Authentication

1. In your Firebase project, go to **Authentication**
2. Click **Get Started** (if first time)
3. Go to **Sign-in method** tab
4. Enable **Email/Password** provider
   - Click on Email/Password
   - Toggle "Enable"
   - Click "Save"

## Step 3: Create Firestore Database

1. In your Firebase project, go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
   - This allows read/write access for 30 days
   - You'll need to set up security rules later
4. Select a location for your database
5. Click **Enable**

## Step 4: Create Web App

1. In your Firebase project, go to **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Click the **Web** icon (`</>`)
4. Register your app with a nickname (e.g., "Faith Circle")
5. Copy the Firebase configuration object

## Step 5: Configure Your App

1. Open `src/utils/firebase.ts`
2. Replace the `firebaseConfig` object with your Firebase config:

```typescript
const firebaseConfig = {
  apiKey: "AIza...", // Your API key
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123..."
};
```

## Step 6: Test Authentication

1. Start your app: `npm start`
2. Try registering a new account
3. Check Firebase Console > Authentication > Users to see the new user

## Firestore Security Rules (Later)

For production, update your Firestore security rules in Firebase Console > Firestore Database > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Journal entries - users can only access their own
    match /journalEntries/{entryId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Similar rules for sermons, verses, groups, etc.
  }
}
```

## Troubleshooting

- **"Firebase not initialized"**: Make sure you've updated the config in `firebase.ts`
- **"Permission denied"**: Check Firestore security rules
- **"Auth domain not authorized"**: Make sure your app is registered in Firebase Console

