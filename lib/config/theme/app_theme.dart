import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  /// Returns the Standard Theme
  static ThemeData getLightScene({double fontSizeScale = 1.0}) {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // Scale text based on user preference
      textTheme: _scaleTextTheme(baseTextTheme, fontSizeScale).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
        surface: AppColors.surfaceWhite,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }

  /// Returns the High Contrast Theme
  static ThemeData getHighContrastTheme({double fontSizeScale = 1.0}) {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Important for native widgets
      primaryColor: AppColors.hcTextPrimary,
      scaffoldBackgroundColor: AppColors.hcBackground,

      textTheme: _scaleTextTheme(baseTextTheme, fontSizeScale).apply(
        bodyColor: AppColors.hcTextPrimary,
        displayColor: AppColors.hcTextPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.hcSurface,
        foregroundColor: AppColors.hcTextPrimary,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: AppColors.hcBorder, width: 2)),
      ),

      colorScheme: const ColorScheme.dark(
        primary: AppColors.hcTextPrimary,
        surface: AppColors.hcSurface,
        onSurface: AppColors.hcTextPrimary,
        error: Color(0xFFFF5555),
      ),

      // High Contrast Card: Black background with White border
      cardTheme: CardThemeData(
        color: AppColors.hcSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.hcBorder, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.hcBackground,
          foregroundColor: AppColors.hcTextPrimary,
          elevation: 0,
          side: const BorderSide(color: AppColors.hcTextPrimary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      iconTheme: const IconThemeData(
        color: AppColors.hcTextPrimary,
        size: 24,
      ),
    );
  }

  /// Helper to scale the font sizes based on user preference (A, A+, A++)
  static TextTheme _scaleTextTheme(TextTheme base, double scale) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: (base.displayLarge?.fontSize ?? 57) * scale),
      displayMedium: base.displayMedium?.copyWith(fontSize: (base.displayMedium?.fontSize ?? 45) * scale),
      displaySmall: base.displaySmall?.copyWith(fontSize: (base.displaySmall?.fontSize ?? 36) * scale),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: (base.headlineLarge?.fontSize ?? 32) * scale),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: (base.headlineMedium?.fontSize ?? 28) * scale),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: (base.headlineSmall?.fontSize ?? 24) * scale),
      titleLarge: base.titleLarge?.copyWith(fontSize: (base.titleLarge?.fontSize ?? 22) * scale),
      titleMedium: base.titleMedium?.copyWith(fontSize: (base.titleMedium?.fontSize ?? 16) * scale),
      titleSmall: base.titleSmall?.copyWith(fontSize: (base.titleSmall?.fontSize ?? 14) * scale),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: (base.bodyLarge?.fontSize ?? 16) * scale),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: (base.bodyMedium?.fontSize ?? 14) * scale),
      bodySmall: base.bodySmall?.copyWith(fontSize: (base.bodySmall?.fontSize ?? 12) * scale),
    );
  }
}