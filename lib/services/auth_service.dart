import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // Read Google Client ID from .env file
  static String? get _serverClientId {
    // Try reading from .env file first
    String? clientId = dotenv.env['GOOGLE_CLIENT_ID'];
    
    // Remove quotes if present (common in .env files)
    if (clientId != null) {
      clientId = clientId.trim().replaceAll('"', '').replaceAll("'", '');
    }
    
    if (clientId != null && clientId.isNotEmpty) {
      return clientId;
    }
    return null;
  }

  late final GoogleSignIn _googleSignIn;

  AuthService() {
    final clientId = _serverClientId;
    if (clientId == null || clientId.isEmpty) {
      print('❌ Client ID from .env: NOT FOUND or EMPTY');
      print('   Make sure GOOGLE_CLIENT_ID is set in your .env file');
      print('   Format: GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com');
    }
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      // Use client ID from .env file if available
      serverClientId: clientId,
    );
  }

  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;

  Stream<GoogleSignInAccount?> get authStateChanges => _googleSignIn.onCurrentUserChanged;

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final currentClientId = _serverClientId;
      if (currentClientId == null || currentClientId.isEmpty) {
        print('❌ Client ID is NULL - cannot proceed with sign-in');
        return null;
      }
      
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      _currentUser = user;
      return user;
    } catch (error) {
      print('❌ Error signing in with Google: $error');
      // Error code 10 means DEVELOPER_ERROR - OAuth client ID not configured
      if (error.toString().contains('ApiException: 10')) {
        print('⚠️  DEVELOPER_ERROR (Code 10) - This usually means:');
        print('   1. OAuth Client ID not configured correctly in Google Cloud Console');
        print('   2. For Android: Package name or SHA-1 fingerprint mismatch');
        print('   3. Client ID might be incorrect or not enabled');
        print('');
        print('📋 Current configuration:');
        final clientId = _serverClientId;
        print('   - Client ID from .env: ${clientId != null ? "✅ Loaded" : "❌ Not loaded"}');
        print('');
        print('💡 Solutions:');
        print('   - Verify your OAuth Client ID in Google Cloud Console');
        print('   - For Android: Make sure you created an ANDROID OAuth Client (not just Web)');
        print('   - Check package name matches exactly: com.faithcircle.faith_circle');
        print('   - Check SHA-1 matches exactly: 6B:40:47:0C:6D:57:2E:ED:AF:A8:20:0B:EA:07:E6:BC:A0:4D:9D:E9');
        print('   - Wait a few minutes after creating the OAuth client');
        print('   - See GOOGLE_SIGNIN_SETUP.md for detailed instructions');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      return _currentUser;
    } catch (error) {
      print('Error getting current user: $error');
      return null;
    }
  }
}

