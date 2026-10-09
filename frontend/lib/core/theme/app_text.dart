// lib/core/theme/app_text.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text styles for Aerogreen.
/// Headings use a serif font (Fraunces), body uses Plus Jakarta Sans.
class AppText {
  // Serif heading – semi‑bold, primary text colour.
  static final TextStyle heading = GoogleFonts.fraunces(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // Subtitle – smaller serif.
  static final TextStyle subtitle = GoogleFonts.fraunces(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );

  // Body – Plus Jakarta Sans.
  static final TextStyle body = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  // Caption – ALL‑CAPS style, small, letter‑spacing.
  static final TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: AppColors.secondaryText,
  );

  // Button text – white, bold.
  static final TextStyle button = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
