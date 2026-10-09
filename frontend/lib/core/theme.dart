import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ------------------------------
///   Color palette (hex → Color)
/// ------------------------------
class AppColors {
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color heading = Color(0xFF14532D);
  static const Color secondary = Color(0xFF6B7280);
  static const Color background = Color(0xFFF0FDF4);
  static const Color warning = Color(0xFFF97316);
  static const Color error = Color(0xFFEF4444);
  static const Color water = Color(0xFF0EA5E9);
  static const Color ph = Color(0xFF8B5CF6);
}

/// ------------------------------
///   Text styles – all Vietnamese
/// ------------------------------
class AppText {
  static final TextStyle heading = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.heading,
  );

  static final TextStyle body = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.secondary,
  );

  static final TextStyle button = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static final TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondary,
  );
}

/// ------------------------------
///   General UI constants
/// ------------------------------
class UIConsts {
  // Radii
  static const double cardRadius = 22.0; // 20‑24 as requested
  static const double buttonRadius = 15.0; // 14‑16 as requested
  static const double inputHeight = 50.0; // 48‑52 as requested

  // Shadows (soft, subtle)
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
}
