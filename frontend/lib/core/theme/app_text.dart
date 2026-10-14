import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  static const List<Shadow> photoTextShadows = [
    Shadow(color: AppColors.photoTextGlow, blurRadius: 8),
    Shadow(
      color: AppColors.photoTextShadow,
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Use for headings that sit directly over the foliage background.
  static TextStyle photoTitle({double fontSize = 24, FontWeight fontWeight = FontWeight.w600}) =>
      GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppColors.primaryText,
        shadows: photoTextShadows,
      );

  /// Use for a light greeting directly over the foliage background.
  static TextStyle photoGreeting({double fontSize = 24, FontWeight fontWeight = FontWeight.w600}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppColors.lightGreetingText,
        shadows: photoTextShadows,
      );

  // Heading – 24px, weight 600, primary text color
  static TextStyle heading(BuildContext context, {FontWeight fontWeight = FontWeight.w600, double fontSize = 24}) {
    return photoTitle(fontSize: fontSize, fontWeight: fontWeight);
  }

  // Body – 14px, weight 400, primary text color
  static TextStyle body(BuildContext context, {FontWeight fontWeight = FontWeight.w400, double fontSize = 14}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: AppColors.primaryText,
    );
  }

  // Label – 12px, weight 500, letter spacing 1.2, secondary text color, uppercase
  static TextStyle label(BuildContext context, {double fontSize = 12, FontWeight fontWeight = FontWeight.w500}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 1.2,
      color: AppColors.secondaryText,
    );
  }
}
