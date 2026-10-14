// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'app.dart';
import 'providers/app_settings_provider.dart';

void main() {
  runApp(
    provider.ChangeNotifierProvider(
      create: (_) => AppSettingsProvider(),
      child: const ProviderScope(child: AerogreenApp()),
    ),
  );
}
