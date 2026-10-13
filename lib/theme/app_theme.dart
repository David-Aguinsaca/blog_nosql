import 'package:flutter/material.dart';

class AppColors {
  // Paleta requerida
  static const Color primaryTeal = Color(0xFF35858E);
  static const Color sageGreen = Color(0xFF7DA78C);
  static const Color softOlive = Color(0xFFC2D099);
  static const Color paleLime = Color(0xFFE6EEC9);

  // Colores de soporte y contraste minimalista
  static const Color background = Color(0xFFFAFBF7);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1E2D27);
  static const Color textMuted = Color(0xFF5E7168);
  static const Color textLight = Color(0xFF8C9E95);
  static const Color borderLight = Color(0xFFE2E8D8);
  static const Color danger = Color(0xFFD34545);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryTeal,
        onPrimary: Colors.white,
        secondary: AppColors.sageGreen,
        onSecondary: Colors.white,
        tertiary: AppColors.softOlive,
        onTertiary: AppColors.textDark,
        surface: AppColors.surface,
        onSurface: AppColors.textDark,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primaryTeal),
        titleTextStyle: TextStyle(
          color: AppColors.primaryTeal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          side: const BorderSide(color: AppColors.primaryTeal),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),
    );
  }
}
