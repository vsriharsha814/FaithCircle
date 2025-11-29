# Google Sign-In Setup Instructions

## Error Explanation
Error code 10 (`DEVELOPER_ERROR`) means Google Sign-In is not properly configured with an OAuth client ID.

When you see this error:
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)
```

It means the app cannot find the Google OAuth Client ID to authenticate users.

## Quick Answer: Do You Need Two Client IDs?

**Short answer:** You need to create **3 OAuth clients** in Google Cloud Console, but only **1 goes in your `.env` file**:

1. **One Web Client ID** → Put this in your `.env` file (works for both Android & iOS)
2. **One Android OAuth Client** → Configure in Google Cloud Console with package name + SHA-1
3. **One iOS OAuth Client** → Configure in Google Cloud Console with bundle ID

**Why?** The Web Client ID in your `.env` file is used as `serverClientId` and works for both platforms. However, Google still requires platform-specific OAuth clients to be configured in Google Cloud Console to verify your app's identity for each platform.

## Setup Steps

### 1. Create OAuth Client ID in Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Google Sign-In API**:
   - Go to "APIs & Services" > "Library"
   - Search for "Google Sign-In API"
   - Click "Enable"

### 2. Create OAuth 2.0 Client IDs

**Important:** You need to create **platform-specific OAuth clients** for each platform you're supporting. The app uses a **Web Client ID** as `serverClientId` which works for both platforms, but you still need to configure platform-specific clients for proper authentication.

#### Step 1: Create Web Client ID (Used for both Android & iOS)
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Select application type: **Web application**
4. Give it a name: "FaithCircle Web Client"
5. Click "Create"
6. **Copy the Client ID** - This is what you'll put in your `.env` file
   - Looks like: `123456789-abcdefghijklmnop.apps.googleusercontent.com`

#### Step 2: Create Android OAuth Client (Required for Android app)
**Required if you're building for Android:**
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Select application type: **Android**
4. Fill in the details:
   - **Name**: FaithCircle Android (or any name you prefer)
   - **Package name**: `com.faithcircle.faith_circle` (must match your app's package name exactly)
   - **SHA-1 certificate fingerprint**: `6B:40:47:0C:6D:57:2E:ED:AF:A8:20:0B:EA:07:E6:BC:A0:4D:9D:E9`
5. Click "Create"
6. **Note:** You don't need to copy this Client ID - it's configured automatically based on package name and SHA-1

#### Step 3: Create iOS OAuth Client (Required for iOS app)
**Required if you're building for iOS:**
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Select application type: **iOS**
4. Fill in the details:
   - **Name**: FaithCircle iOS (or any name you prefer)
   - **Bundle ID**: `com.faithcircle.faithCircle` (must match your iOS app's bundle identifier exactly)
5. Click "Create"
6. **Note:** You don't need to copy this Client ID - it's configured automatically based on bundle ID

**Summary:**
- **One Web Client ID** → Goes in your `.env` file (works for both platforms)
- **One Android Client** → Configured in Google Cloud Console (package name + SHA-1)
- **One iOS Client** → Configured in Google Cloud Console (bundle ID)

### 3. Create .env File

The app is configured to read the Client ID from a `.env` file in the project root.

1. **Create a `.env` file** in the root of your project (same level as `pubspec.yaml`)

2. **Add your Google Client ID** to the `.env` file:
   ```
   GOOGLE_CLIENT_ID=your-client-id-here.apps.googleusercontent.com
   ```

   Or with quotes (they'll be automatically removed):
   ```
   GOOGLE_CLIENT_ID="your-client-id-here.apps.googleusercontent.com"
   ```

3. **Make sure `.env` is in `.gitignore`** (it should already be added) - never commit your `.env` file to version control!

**Example `.env` file:**
```
GOOGLE_CLIENT_ID=123456789-abcdefghijklmnop.apps.googleusercontent.com
```

### 4. Run the App

Simply run the app as normal - it will automatically load the `.env` file:

```bash
flutter run
```

When the app initializes, you should see in the console:
- ✅ `.env file loaded successfully`
- ✅ `Client ID from .env: Found (...)` if it's loaded correctly
- ❌ `Client ID from .env: NOT FOUND or EMPTY` if the file or variable is missing

## After Configuration

1. Make sure your `.env` file exists in the project root with `GOOGLE_CLIENT_ID` set
2. Stop the current app if it's running (press `q` in the Flutter console)
3. Restart the app:
   ```bash
   flutter run
   ```
4. Check the console logs - you should see:
   - ✅ `.env file loaded successfully`
   - ✅ `Client ID from .env: Found (...)`
5. Try signing in with Google - the error should be resolved!

## Troubleshooting

### Error Code 10 (DEVELOPER_ERROR)

If you still see error code 10 after setting up the `.env` file:

1. **Verify the `.env` file exists:**
   - Make sure `.env` is in the project root (same directory as `pubspec.yaml`)
   - Check the file name - it should be exactly `.env` (not `.env.txt` or anything else)

2. **Check the `.env` file format:**
   - Should contain: `GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com`
   - No spaces around the `=` sign
   - Quotes are optional: `GOOGLE_CLIENT_ID="..."` or `GOOGLE_CLIENT_ID=...`

3. **Check if the app can read it:**
   - Look for the initialization logs when the app starts
   - You should see: `✅ .env file loaded successfully`
   - You should see: `✅ Client ID from .env: Found (...)`
   - If you see `❌ NOT FOUND`, check your `.env` file

4. **Verify `.env` is in assets:**
   - Check `pubspec.yaml` - it should have `.env` listed under `assets:`
   - Run `flutter pub get` to refresh assets

5. **Restart the app properly:**
   - Stop the app completely (press `q` in the terminal)
   - Make sure the `.env` file is correct
   - Start fresh: `flutter run`

6. **Verify the Client ID format:**
   - Should end with `.apps.googleusercontent.com`
   - Should look like: `123456789-abcdefghijklmnop.apps.googleusercontent.com`

7. **For Android Client ID:**
   - Make sure the package name matches exactly: `com.faithcircle.faith_circle`
   - Ensure SHA-1 fingerprint is correct: `6B:40:47:0C:6D:57:2E:ED:AF:A8:20:0B:EA:07:E6:BC:A0:4D:9D:E9`
   - Wait a few minutes after creating the OAuth client for it to propagate

8. **For iOS Client ID:**
   - Make sure the bundle ID matches exactly: `com.faithcircle.faithCircle`
   - Wait a few minutes after creating the OAuth client for it to propagate

8. **Clean build (if needed):**
   ```bash
   flutter clean && flutter pub get && flutter run
   ```

## Your App Details:

### Android:
- **Package Name**: `com.faithcircle.faith_circle`
- **SHA-1 Fingerprint**: `6B:40:47:0C:6D:57:2E:ED:AF:A8:20:0B:EA:07:E6:BC:A0:4D:9D:E9`

### iOS:
- **Bundle ID**: `com.faithcircle.faithCircle`

## How It Works

The app uses:
1. **`flutter_dotenv` package** - loads the `.env` file when the app starts
2. **`lib/main.dart`** - loads the `.env` file in the `main()` function before running the app
3. **`lib/services/auth_service.dart`** - reads `GOOGLE_CLIENT_ID` from the loaded `.env` file using `dotenv.env['GOOGLE_CLIENT_ID']`
4. Passes it to Google Sign-In as the `serverClientId`
5. Logs whether the client ID was found during initialization

You can verify it's working by checking the console output when the app starts:
- `✅ .env file loaded successfully`
- `✅ Client ID from .env: Found (...)`

## Quick Setup Checklist

- [ ] Created OAuth Client ID in Google Cloud Console
- [ ] Copied the Client ID
- [ ] Created `.env` file in project root
- [ ] Added `GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com` to `.env`
- [ ] Verified `.env` is in `.gitignore`
- [ ] Ran `flutter pub get` to install dependencies
- [ ] Restarted the app with `flutter run`
- [ ] Checked console logs for successful `.env` loading

