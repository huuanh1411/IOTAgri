// lib/core/theme/ui_consts.dart
import 'package:flutter/material.dart';

/// UI constants used throughout the design system.
class UIConsts {
  static const double cardRadius = 24.0;
  static const double buttonRadius = 30.0; // pill shape
  static const double chipRadius = 20.0;
  static const double navBarRadius = 30.0;
  static const double iconTileSize = 48.0;
  static const double gaugeSize = 120.0;

  static const BoxShadow softShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 8,
    offset: Offset(0, 2),
  );
}
