import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sermon_notes_screen.dart';
import 'verse_locker_screen.dart';
import 'quiz_game_screen.dart';
import 'streak_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const SermonNotesScreen(key: ValueKey('sermon_notes'));
      case 1:
        return const VerseLockerScreen(key: ValueKey('verse_locker'));
      case 2:
        return const QuizGameScreen(key: ValueKey('quiz_game'));
      case 3:
        return const StreakScreen(key: ValueKey('streak'));
      case 4:
        return const ProfileScreen(key: ValueKey('profile'));
      default:
        return const SermonNotesScreen(key: ValueKey('sermon_notes'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure currentIndex is within bounds
    if (_currentIndex < 0 || _currentIndex > 4) {
      _currentIndex = 0;
    }
    
    print('Building with currentIndex: $_currentIndex');
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF121212),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _getScreen(_currentIndex),
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
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 5;
                  return Row(
                    children: [
                      _buildNavItem(0, Icons.menu_book, itemWidth),
                      _buildNavItem(1, Icons.lock, itemWidth),
                      _buildNavItem(2, Icons.quiz, itemWidth),
                      _buildNavItem(3, Icons.local_fire_department, itemWidth),
                      _buildNavItem(4, Icons.person, itemWidth),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, double width) {
    final isSelected = _currentIndex == index;
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('Tapped index: $index, width: $width, currentIndex before: $_currentIndex'); // Debug print
            if (mounted) {
              setState(() {
                _currentIndex = index;
                print('Set currentIndex to: $_currentIndex');
              });
            }
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

