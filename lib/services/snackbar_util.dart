import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Utility class for showing SnackBars consistently across the app
/// Automatically clears any existing SnackBar before showing a new one
class SnackbarUtil {
  /// Show a success message (green background)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  /// Show an error message (red background)
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  /// Show an info message (default background)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    _showSnackBar(
      context,
      message,
      duration: duration,
    );
  }

  /// Internal method to show SnackBar with consistent styling
  static void _showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    // Clear any existing SnackBar first
    ScaffoldMessenger.of(context).clearSnackBars();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: backgroundColor ?? const Color(0xFF121212),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

