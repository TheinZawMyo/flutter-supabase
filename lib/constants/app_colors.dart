import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // New Brand Palette
  static const Color deepestGreen = Color(0xFF0F2A1D);
  static const Color forestGreen = Color(0xFF375534);
  static const Color sageGreen = Color(0xFF6B9071);
  static const Color dustyGreen = Color(0xFFAEC3B0);
  static const Color paleGreen = Color(0xFFE3EED4);

  // Gradient definitions
  static const Color gradientStart = deepestGreen;
  static const Color gradientEnd = forestGreen;

  // Semantic Colors (Adjusted to match earthy palette)
  static const Color income = forestGreen;
  static const Color expense = Color(
    0xFF8B4513,
  ); // Saddle Brown (Earthy matching) or keep red
  static const Color expenseAlt = Color(0xFFBC4B51); // Muted red-earth

  // UI Colors
  static const Color background = Color(0xFFF8F9F8); // Very light grey-green
  static const Color surface = Colors.white;
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Color(0xFFAEC3B0); // Dusty Green
  static const Color contentText = Color(0xFF0F2A1D); // Deepest Green

  static const Color divider = Color(0xFFE3EED4); // Pale Green

  static final Color inputFieldBackground = Colors.white.withValues(alpha: 0.1);
  static const Color buttonForeground = Colors.white;
  static const Color buttonBackground = forestGreen;
  static const Color accentButtonBackground = sageGreen;
}
