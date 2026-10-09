// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text.dart';
import 'ui_consts.dart';

/// Light theme for Aerogreen – uses the warm cream background and the defined color palette.
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  useMaterial3: true,
  fontFamily: 'PlusJakartaSans',
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: AppColors.primaryText,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UIConsts.cardRadius),
    ),
    shadowColor: Colors.black12,
  ),
  buttonTheme: const ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(UIConsts.buttonRadius))),
    buttonColor: AppColors.forest,
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: TextTheme(
    headlineMedium: AppText.heading,
    titleMedium: AppText.subtitle,
    bodyMedium: AppText.body,
    labelSmall: AppText.caption,
    labelLarge: AppText.button,
  ),
);
