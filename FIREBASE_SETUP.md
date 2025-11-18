# Firebase Setup Guide

## Step 1: Create Firebase Project

<!-- 1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project" or select an existing project
3. Follow the setup wizard -->

## Step 2: Enable Authentication

1. In your Firebase project, go to **Authentication**
2. Click **Get Started** (if first time)
3. Go to **Sign-in method** tab
4. Enable **Google** provider
   - Click on "Google"
   - Toggle "Enable"
   - Enter your project support email (or use the default)
   - Click "Save"
   - **Important**: Copy the **Web client ID** shown in the configuration - you'll need this!

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

1. **Set up Firebase config:**
   - Open `src/utils/firebase.ts`
   - Replace the `firebaseConfig` object with your Firebase config from Step 4

2. **Set up Google OAuth Client ID:**
   - Create a `.env` file in the root directory (or use `app.json` extra config)
   - Add your Google Web Client ID (from Step 2):
     ```
     EXPO_PUBLIC_GOOGLE_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
     ```
   - **Note**: The Google Web Client ID is shown when you enable Google Sign-In in Firebase Console

3. **Alternative (if .env doesn't work):**
   - You can hardcode the Google Client ID temporarily in `src/hooks/useAuth.ts`:
     ```typescript
     clientId: "your-google-web-client-id.apps.googleusercontent.com"
     ```

## Step 6: Test Authentication

1. Start your app: `npm start`
2. Click "Continue with Google"
3. Sign in with your Google account
4. Check Firebase Console > Authentication > Users to see your new user

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

