// lib/providers/theme_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// Simple theme provider to toggle light/dark mode.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
