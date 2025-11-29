import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  GoogleSignInAccount? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _authService.authStateChanges.listen((GoogleSignInAccount? user) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    });
  }

  Future<void> _checkAuthState() async {
    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully signed out'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      );
    }

    // If not logged in, show login screen
    if (_currentUser == null) {
      return const LoginScreen();
    }

    // If logged in, show profile information
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // User Avatar
              CircleAvatar(
                radius: 60,
                backgroundImage: _currentUser!.photoUrl != null
                    ? NetworkImage(_currentUser!.photoUrl!)
                    : null,
                child: _currentUser!.photoUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.black,
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              
              // User Name
              Text(
                _currentUser!.displayName ?? 'User',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // User Email
              Text(
                _currentUser!.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Sign Out Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleSignOut,
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

