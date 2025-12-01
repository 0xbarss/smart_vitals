import 'package:flutter/material.dart';

class AppColors {
  // --- STANDARD PALETTE ---
  static const Color primaryBlue = Color(0xFF2563EB); // blue-600
  static const Color primaryPurple = Color(0xFF9333EA); // purple-600
  static const Color primaryOrange = Color(0xFFEA580C); // orange-600
  static const Color primaryGreen = Color(0xFF16A34A); // green-600

  static const Color backgroundLight = Color(0xFFF9FAFB); // gray-50
  static const Color surfaceWhite = Colors.white;
  static const Color textDark = Color(0xFF1F2937); // gray-800
  static const Color textGrey = Color(0xFF6B7280); // gray-500

  static const Color riskLow = Color(0xFF22C55E); // green-500
  static const Color riskModerate = Color(0xFFEAB308); // yellow-500
  static const Color riskHigh = Color(0xFFEF4444); // red-500

  // --- HIGH CONTRAST PALETTE ---
  static const Color hcBackground = Colors.black;
  static const Color hcSurface = Color(0xFF121212); // Slightly lighter black
  static const Color hcTextPrimary = Color(0xFFFACC15); // yellow-400 (Very readable on black)
  static const Color hcTextSecondary = Colors.white;
  static const Color hcBorder = Colors.white;

  static const Color hcAccent = Color(0xFFFFFF00); // Pure Yellow
}