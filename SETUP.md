# Faith Circle - Setup Instructions

## Quick Start

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start the development server:**
   ```bash
   npm start
   ```

3. **Run on your device:**
   - Press `i` for iOS simulator
   - Press `a` for Android emulator
   - Scan QR code with Expo Go app on your phone

## Backend Setup (Firebase)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication:
   - Go to Authentication > Sign-in method
   - Enable Email/Password provider
3. Create a Firestore database:
   - Go to Firestore Database > Create database
   - Start in test mode (you can secure it later)
4. Create a Web app in your Firebase project:
   - Go to Project Settings > General
   - Under "Your apps", click the Web icon (</>)
   - Register your app and copy the Firebase config object
5. Update Firebase configuration:
   - Open `src/utils/firebase.ts`
   - Replace the `firebaseConfig` object with your Firebase config
   - Or use environment variables (see `.env.example`)

## Project Structure

```
src/
├── components/       # Reusable components
│   └── shared/      # Base UI components
├── screens/         # Screen components
│   ├── auth/        # Login, Register
│   ├── journal/     # Bible journal screens
│   ├── sermons/     # Sermon notes screens
│   ├── verses/      # Verse locker screens
│   └── groups/      # Group/feed screens
├── navigation/      # Navigation setup
├── hooks/           # Custom React hooks
├── types/           # TypeScript types
├── constants/       # Theme, colors, etc.
└── utils/           # Utility functions
```

## Development Phases

- ✅ **Phase 0**: Project setup (COMPLETE)
- ⏳ **Phase 1**: Authentication (UI ready, needs backend connection)
- ⏳ **Phase 2**: Journal feature
- ⏳ **Phase 3**: Sermon Notes
- ⏳ **Phase 4**: Verse Locker
- ⏳ **Phase 5**: Groups & Feed
- ⏳ **Phase 6**: Polish & enhancements

## Next Steps

1. ✅ Connect authentication to Firebase (COMPLETE - just add your Firebase config)
2. Build Journal Today screen with form
3. Implement CRUD operations for journal entries
4. Add calendar view for journal history
5. Continue with remaining features per PLAN.md

