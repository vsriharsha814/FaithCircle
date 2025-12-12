import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';
import '../services/settings_service.dart';

class QuizGameScreen extends StatefulWidget {
  final String category;

  const QuizGameScreen({super.key, required this.category});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;
  int _correctAnswers = 0;
  int _timerDuration = 5;
  int _remainingTime = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Load settings first, then load questions to avoid race condition
    _loadTimerSettings().then((_) {
      _loadQuestions();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTimerSettings() async {
    final duration = await SettingsService.getQuizTimerDuration();
    if (mounted) {
      setState(() {
        _timerDuration = duration;
        _remainingTime = duration;
      });
      // Cancel any existing timer if timer is disabled
      if (duration <= 0) {
        _timer?.cancel();
      }
      // Don't start timer here - it will be started in _loadQuestions() after settings are loaded
    }
  }

  void _startTimer() {
    if (_timerDuration <= 0) return;
    
    _timer?.cancel();
    setState(() {
      _remainingTime = _timerDuration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          // Auto-select first answer if no answer selected
          if (!_hasAnswered && _selectedAnswerIndex == null) {
            _selectAnswer(0);
          }
        }
      });
    });
  }

  void _loadQuestions() {
    setState(() {
      _questions = QuizService.getQuestionsByCategory(widget.category);
      _currentQuestionIndex = 0;
      _selectedAnswerIndex = null;
      _hasAnswered = false;
      _correctAnswers = 0;
    });
    if (_timerDuration > 0) {
      _startTimer();
    }
  }

  void _selectAnswer(int index) {
    if (_hasAnswered) return;

    _timer?.cancel();

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
      if (index == _questions[_currentQuestionIndex].correctAnswerIndex) {
        _correctAnswers++;
      }
    });

    // Auto-advance after showing feedback
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });
      if (_timerDuration > 0) {
        _startTimer();
      }
    } else {
      _showResults();
    }
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Exit Quiz?',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Your progress will be lost. Are you sure you want to exit?',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF121212),
              side: const BorderSide(color: Color(0xFF121212), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Exit',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Quiz Complete!',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You got $_correctAnswers out of ${_questions.length} correct!',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '${((_correctAnswers / _questions.length) * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.montserrat(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _correctAnswers == _questions.length
                    ? Colors.green
                    : _correctAnswers >= _questions.length / 2
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _loadQuestions(); // Restart same quiz
            },
            child: Text(
              'Try Again',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to menu
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF121212),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Back to Menu',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading quiz...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldExit = await _onWillPop();
        if (shouldExit && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              final shouldExit = await _onWillPop();
              if (shouldExit && mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicators
              Row(
                children: [
                  // Progress Circles
                  ...List.generate(
                    _questions.length,
                    (index) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: index < _currentQuestionIndex
                                ? Colors.green
                                : index == _currentQuestionIndex
                                    ? const Color(0xFF121212)
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_timerDuration > 0) ...[
                const SizedBox(height: 12),
                // Timer Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _remainingTime / _timerDuration,
                          minHeight: 4,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _remainingTime <= 2
                                ? Colors.red
                                : _remainingTime <= _timerDuration / 2
                                    ? Colors.orange
                                    : const Color(0xFF121212),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_remainingTime',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _remainingTime <= 2
                            ? Colors.red
                            : const Color(0xFF121212),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              // Category Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentQuestion.category,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Question Number and Text
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQuestion.question,
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),
                      if (currentQuestion.scriptureReference != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.book,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentQuestion.scriptureReference!,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      // Answer Options
                      ...List.generate(
                        currentQuestion.options.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildAnswerOption(
                            index,
                            currentQuestion.options[index],
                            currentQuestion.correctAnswerIndex,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildAnswerOption(
    int index,
    String option,
    int correctIndex,
  ) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == correctIndex;
    final showFeedback = _hasAnswered;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black;

    if (showFeedback) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red.shade900;
      } else {
        backgroundColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade300;
        textColor = Colors.grey.shade600;
      }
    } else if (isSelected) {
      backgroundColor = const Color(0xFF121212);
      borderColor = const Color(0xFF121212);
      textColor = Colors.white;
    }

    return InkWell(
      onTap: () => _selectAnswer(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: showFeedback && isCorrect
                    ? Colors.green
                    : showFeedback && isSelected && !isCorrect
                        ? Colors.red
                        : isSelected
                            ? Colors.white
                            : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: showFeedback
                      ? borderColor
                      : isSelected
                          ? Colors.white
                          : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: showFeedback
                  ? Icon(
                      isCorrect
                          ? Icons.check
                          : isSelected
                              ? Icons.close
                              : null,
                      color: Colors.white,
                      size: 20,
                    )
                  : isSelected
                      ? const Icon(
                          Icons.circle,
                          color: Color(0xFF121212),
                          size: 20,
                        )
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
