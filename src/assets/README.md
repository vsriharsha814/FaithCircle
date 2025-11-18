# Assets Directory

## Required Assets

### App Icons & Splash Screens

1. **App Icon** (`icon.png`)
   - Size: 1024x1024 pixels
   - Format: PNG
   - Use: https://www.appicon.co/ or https://www.canva.com/ to create

2. **Splash Screen** (`splash.png`)
   - Size: 1242x2436 pixels (iPhone) or 1242x2208 pixels
   - Format: PNG
   - Background color: white or theme color
   - Should include app name/logo centered

3. **Android Adaptive Icon** (`adaptive-icon.png`)
   - Size: 1024x1024 pixels
   - Format: PNG with transparent background
   - Foreground image: Your app icon/logo

4. **Web Favicon** (`favicon.png`)
   - Size: 48x48 or 512x512 pixels
   - Format: PNG

### Google Sign-In Button

For the Google Sign-In button icon, you can:

**Option 1: Download Google's official icon**
- Download from: https://developers.google.com/identity/branding-guidelines
- Save as `assets/google-icon.png`
- Update `LoginScreen.tsx` to use local image

**Option 2: Use SVG (better quality)**
- Download Google logo SVG from Google's branding guidelines
- Use `react-native-svg` to render it

**Option 3: Use text-based button**
- Current implementation uses a simple button with Google favicon
- Can be replaced with a more styled button

## Quick Setup

1. **Generate app icons:**
   - Go to https://www.appicon.co/
   - Upload a 1024x1024 logo/icon
   - Download for iOS/Android
   - Extract and place in `assets/` directory

2. **Create splash screen:**
   - Design in Figma, Canva, or similar
   - Export as PNG at 1242x2436
   - Save as `assets/splash.png`

3. **Get Google icon:**
   - Visit https://developers.google.com/identity/branding-guidelines
   - Download "Google G" logo (color version)
   - Save as `assets/google-icon.png`

## Temporary Solution

For development, you can use placeholder images or simple colored squares. The app will work fine without proper assets during development.

