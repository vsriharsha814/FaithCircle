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

### Important: OAuth Client Types

**For Expo Go (Development):**
- Using a **Web client ID** with Expo's OAuth proxy (`useProxy: true`) is acceptable for development
- Expo's proxy uses secure HTTPS redirect URIs (e.g., `https://auth.expo.io/@username/project`)
- This complies with Google's OAuth 2.0 policies for secure redirect URIs

**For Production Builds (EAS Build / Standalone):**
- You'll need to create separate OAuth clients for iOS and Android in Google Cloud Console
- According to [Google's OAuth 2.0 policies](https://developers.google.com/identity/protocols/oauth2/policies#secure-response-handling), you should NOT use a "web" client type for native apps in production
- Create iOS and Android OAuth clients and configure them properly before building production apps

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
   - Copy the sample environment file: `cp env.sample .env`
   - Open `.env` and replace `your-google-web-client-id.apps.googleusercontent.com` with your actual Google Web Client ID
   - **Or** create a `.env` file manually and add:
     ```
     EXPO_PUBLIC_GOOGLE_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
     ```
   - **Note**: The Google Web Client ID is shown when you enable Google Sign-In in Firebase Console

3. **Configure OAuth Client in Google Cloud Console (CRITICAL):**
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Select your Firebase project
   - Navigate to **APIs & Services** → **Credentials**
   - Find your **Web client ID** (the one you copied from Firebase Console)
   - Click on the client ID to edit it
   - Scroll down to **Authorized redirect URIs** (if using a Web client)
   - **For Expo Go with expo-google-app-auth**: The library handles redirect URIs automatically, but you may need to configure iOS/Android OAuth clients in Google Cloud Console
   - **Important**: When creating iOS/Android OAuth clients, use `host.expo.exponent` as:
     - iOS Bundle Identifier: `host.expo.exponent`
     - Android Package Name: `host.expo.exponent`
   - Click **Save**
   - **Note**: The app now uses `expo-google-app-auth` which is simpler and more reliable for Expo Go development

4. **Alternative (if .env doesn't work):**
   - You can hardcode the Google Client ID temporarily in `src/hooks/useAuth.tsx`:
     ```typescript
     clientId: "your-google-web-client-id.apps.googleusercontent.com"
     ```

## Step 6: Find Your Redirect URI

**Before testing, you need to know your exact redirect URI:**

1. Start your app: `npm start`
2. Open Expo Go and connect to your app
3. Try to sign in (click "Continue with Google")
4. Check the console/terminal - you'll see a log message like:
   ```
   🔗 Redirect URI: https://auth.expo.io/@your-username/faith-circle
   ```
5. **Copy this exact URI** - you'll need it for Step 5

**If you're not sure of your redirect URI, you can also construct it manually:**
- Format: `https://auth.expo.io/@your-expo-username/faith-circle`
- Replace `your-expo-username` with your Expo account username
- Replace `faith-circle` with your app's slug (from `app.json`, currently `"faith-circle"`)

## Step 7: Test Authentication

**Make sure you've completed Step 5 (Configure OAuth Client) before testing!**

1. Start your app: `npm start`
2. Open Expo Go and connect to your app
3. Click "Continue with Google"
4. Sign in with your Google account
5. Check Firebase Console > Authentication > Users to see your new user

**If you get an OAuth 2.0 compliance error:**
- Double-check that you added the redirect URI to Google Cloud Console (Step 5)
- Make sure the redirect URI in Google Cloud Console **exactly matches** the one logged in the console
- Wait a few minutes for Google's changes to propagate

## Step 8: Production OAuth Clients (For Production Builds)

**Important**: Before building production apps, you must create proper OAuth clients according to [Google's OAuth 2.0 policies](https://developers.google.com/identity/protocols/oauth2/policies#secure-response-handling).

1. **Go to Google Cloud Console** → APIs & Services → Credentials
2. **Create OAuth 2.0 Client ID for iOS**:
   - Click "Create Credentials" → "OAuth client ID"
   - Application type: **iOS**
   - Bundle ID: Your iOS bundle identifier (e.g., `com.faithcircle.app`)
   - Save the Client ID

3. **Create OAuth 2.0 Client ID for Android**:
   - Click "Create Credentials" → "OAuth client ID"
   - Application type: **Android**
   - Package name: Your Android package name (e.g., `com.faithcircle.app`)
   - SHA-1 certificate fingerprint: Get from `expo credentials:manager`
   - Save the Client ID

4. **Update your app configuration**:
   - In `app.json`, add the iOS and Android client IDs to `extra`:
     ```json
     "extra": {
       "expoGo": {
         "googleClientId": "your-web-client-id.apps.googleusercontent.com"
       },
       "ios": {
         "googleClientId": "your-ios-client-id.apps.googleusercontent.com"
       },
       "android": {
         "googleClientId": "your-android-client-id.apps.googleusercontent.com"
       }
     }
     ```
   - Update `useAuth.tsx` to use platform-specific client IDs

5. **For Expo Go Development**:
   - Use `host.expo.exponent` as the bundle identifier/package name when creating iOS/Android OAuth clients
   - The `expo-google-app-auth` library handles redirect URIs automatically

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

