// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text.dart';

class AppTheme {
  static const Color canvas = AppColors.background;
  static const Color cupertinoPrimary = AppColors.forestGreen;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: canvas,
    primaryColor: AppColors.forestGreen,
    colorScheme: const ColorScheme.light(
      primary: AppColors.forestGreen,
      secondary: AppColors.sage,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.primaryText,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      // Heading – 24px, weight 600
      headlineSmall: AppText.photoTitle(fontSize: 24),
      // Body – 14px, weight 400
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.primaryText),
      // Label – 12px, weight 500, letter spacing 1.2
      titleSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.2, color: AppColors.secondaryText),
      // Card titles – 18px, weight 600
      titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryText),
      // Hero numbers – 32px bold
      displaySmall: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryText),
      // Hero titles – 28px, weight 600
      displayMedium: AppText.photoTitle(fontSize: 28),
    ),
  );
}
