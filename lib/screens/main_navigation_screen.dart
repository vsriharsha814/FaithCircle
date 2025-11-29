import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF121212),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _screens[_currentIndex],
        bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: const Color(0xFF121212),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey.shade600,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

