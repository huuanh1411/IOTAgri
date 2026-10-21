import 'package:flutter/cupertino.dart';

class AerogreenCupertinoTheme {
  // ============================================================
  // ĐỒNG BỘ MÀU VỚI GIAO DIỆN USER MỚI (Material)
  // ============================================================

  // Màu chính (Primary) - lấy từ AppTheme.primaryGreen
  static const Color aerogreenPrimary = Color(0xFF4CAF50);
  static const Color aerogreenSecondary = Color(0xFF388E3C); // darkGreen
  static const Color aerogreenTertiary = Color(0xFFC8E6C9); // lightGreen

  // Màu nền (Background)
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFEF9);

  // Màu chữ (Text)
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // Màu trạng thái (Status)
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);

  // Màu phụ (Accent)
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color primaryTeal = Color(0xFF009688);

  // Màu cảm biến (Sensors)
  static const Color temperatureHot = Color(0xFFF44336);
  static const Color temperatureWarm = Color(0xFFFF9800);
  static const Color temperatureCool = Color(0xFF4CAF50);
  static const Color temperatureCold = Color(0xFF2196F3);

  static const Color waterLevelHigh = Color(0xFF4CAF50);
  static const Color waterLevelMedium = Color(0xFFFF9800);
  static const Color waterLevelLow = Color(0xFFF44336);

  static const Color phAcidic = Color(0xFFF44336);
  static const Color phNeutral = Color(0xFF4CAF50);
  static const Color phAlkaline = Color(0xFF2196F3);

  // ============================================================
  // LIGHT THEME
  // ============================================================
  static CupertinoThemeData get lightTheme {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: aerogreenPrimary, // Xanh lá mới
      scaffoldBackgroundColor: backgroundLight, // Nền xám nhạt
      barBackgroundColor: surfaceLight,
      textTheme: CupertinoTextThemeData(
        primaryColor: textPrimary,
        textStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          color: textPrimary,
        ),
      ),
    );
  }

  // ============================================================
  // DARK THEME (giữ nguyên cho tương lai)
  // ============================================================
  static CupertinoThemeData get darkTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: aerogreenPrimary,
      scaffoldBackgroundColor: CupertinoColors.systemBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.label,
        textStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          color: CupertinoColors.label,
        ),
      ),
    );
  }
}