import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _quizTimerDurationKey = 'quiz_timer_duration';
  static const int _defaultTimerDuration = 5; // seconds

  /// Get the quiz timer duration in seconds
  /// Returns the saved value or default (5 seconds)
  static Future<int> getQuizTimerDuration() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_quizTimerDurationKey)) {
      // If no value is saved, save the default
      await prefs.setInt(_quizTimerDurationKey, _defaultTimerDuration);
    }
    return prefs.getInt(_quizTimerDurationKey) ?? _defaultTimerDuration;
  }

  /// Set the quiz timer duration in seconds
  static Future<bool> setQuizTimerDuration(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(_quizTimerDurationKey, seconds);
  }
}

