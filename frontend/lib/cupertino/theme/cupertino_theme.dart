import 'package:flutter/cupertino.dart';

class AerogreenCupertinoTheme {
  static CupertinoThemeData get lightTheme {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: CupertinoColors.systemGreen,
      scaffoldBackgroundColor: CupertinoColors.systemBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.label,
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          color: CupertinoColors.label,
        ),
      ),
    );
  }

  static CupertinoThemeData get darkTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: CupertinoColors.systemGreen,
      scaffoldBackgroundColor: CupertinoColors.systemBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.label,
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          color: CupertinoColors.label,
        ),
      ),
    );
  }

  // Custom colors for Aerogreen
  static const Color aerogreenPrimary = Color(0xFF34C759);
  static const Color aerogreenSecondary = Color(0xFF30D158);
  static const Color aerogreenTertiary = Color(0xFF32ADE6);
  
  static const Color temperatureHot = Color(0xFFFF453A);
  static const Color temperatureWarm = Color(0xFFFF9F0A);
  static const Color temperatureCool = Color(0xFF30D158);
  static const Color temperatureCold = Color(0xFF0A84FF);
  
  static const Color waterLevelHigh = Color(0xFF30D158);
  static const Color waterLevelMedium = Color(0xFFFF9F0A);
  static const Color waterLevelLow = Color(0xFFFF453A);
  
  static const Color phAcidic = Color(0xFFFF3B30);
  static const Color phNeutral = Color(0xFF30D158);
  static const Color phAlkaline = Color(0xFF0A84FF);
}