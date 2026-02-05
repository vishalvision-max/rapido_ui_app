import 'package:flutter/material.dart';

/// Rapido app color scheme - Yellow & Black theme
class AppColors {
  // Primary colors
  static const Color primaryYellow = Color(0xFFFDD835);
  static const Color primaryBlack = Color(0xFF1D1D1D);
  static const Color secondaryYellow = Color(0xFFFFEB3B);
  static const Color accentYellow = Color(
    0xFFFF7043,
  ); // For small alerts like "Hurry"

  // Gradients
  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFDD835), Color(0xFFFFEE58)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1D1D1D), Color(0xFF333333)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color darkBackground = Color(0xFF121212);

  // Text colors
  static const Color textPrimary = Color(0xFF1D1D1D);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textWhite = Colors.white;

  // Status colors
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);

  // Utils
  static const Color shadow = Color(0x1A000000);
  static const Color border = Color(0xFFE9ECEF);
  static const Color divider = Color(0xFFDEE2E6);

  // Rapido specific
  static const Color bikeColor = Color(0xFFFDD835);
  static const Color autoColor = Color(0xFF4CAF50);
  static const Color cabColor = Color(0xFF2196F3);
}
