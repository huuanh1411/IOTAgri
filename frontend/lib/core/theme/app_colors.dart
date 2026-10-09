// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Centralised colour palette for Aerogreen.
class AppColors {
  // Backgrounds
  static const Color background = Color(0xFFFAF8F2);
  static const Color mintChip = Color(0xFFDDEFE0);
  static const Color softSageRow = Color(0xFFF1F2E8);

  // Primary palette
  static const Color forest = Color(0xFF2F5D3F);
  static const Color sage = Color(0xFF8FAF94);
  static const Color gradientStart = sage; // for gradient button
  static const Color gradientEnd = forest;

  // Text
  static const Color primaryText = Color(0xFF1F2A22);
  static const Color secondaryText = Color(0xFF6B7280);

  // Gauges / alerts
  static const Color nutrientOrange = Color(0xFFF2A93B);
  static const Color temperatureTan = Color(0xFFCDB59A);
  static const Color alertPeach = Color(0xFFFDE7DC);

  // Danger / logout
  static const Color dangerRed = Color(0xFFD9534F);
  static const Color dangerRedBorder = Color(0xFFF8D7DA);
}
