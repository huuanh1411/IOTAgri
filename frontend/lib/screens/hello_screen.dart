// lib/screens/hello_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme.dart'; // contains UIConsts and AppText
import '../providers/theme_provider.dart';
import '../core/widgets/app_button.dart';

/// Simple screen to verify the design system.
class HelloScreen extends ConsumerWidget {
  const HelloScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aerogreen'),
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hello Aerogreen', style: AppText.heading),
            SizedBox(height: 24),
            // Using the shared button widget
            AppButton(
              child: Text('Press me'),
              onPressed: _dummy,
            ),
          ],
        ),
      ),
    );
  }
}

void _dummy() {}
