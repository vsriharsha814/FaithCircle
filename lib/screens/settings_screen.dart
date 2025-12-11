import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _quizTimerDuration = 5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final duration = await SettingsService.getQuizTimerDuration();
    if (mounted) {
      setState(() {
        _quizTimerDuration = duration;
      });
    }
  }

  Future<void> _saveQuizTimerDuration(int seconds) async {
    await SettingsService.setQuizTimerDuration(seconds);
    if (mounted) {
      setState(() {
        _quizTimerDuration = seconds;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Timer duration set to $seconds seconds'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz Section
              _buildSectionHeader('Quiz'),
              const SizedBox(height: 16),
              _buildQuizTimerSetting(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildQuizTimerSetting() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question Timer Duration',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set how long each question timer lasts (in seconds)',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$_quizTimerDuration seconds',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF121212),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _quizTimerDuration > 1
                        ? () => _saveQuizTimerDuration(_quizTimerDuration - 1)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: _quizTimerDuration > 1
                        ? const Color(0xFF121212)
                        : Colors.grey,
                  ),
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: Text(
                      '$_quizTimerDuration',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF121212),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _quizTimerDuration < 60
                        ? () => _saveQuizTimerDuration(_quizTimerDuration + 1)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: _quizTimerDuration < 60
                        ? const Color(0xFF121212)
                        : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

