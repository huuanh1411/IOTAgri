// lib/app.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as provider;
import 'router.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_settings_provider.dart';

/// The root widget of the app. It reads the [goRouterProvider] which
/// contains the authentication‑aware routing configuration.
class AerogreenApp extends ConsumerWidget {
  const AerogreenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = provider.Provider.of<AppSettingsProvider>(context).locale;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Aerogreen',
      theme: AppTheme.lightTheme,
      locale: locale,
      routerConfig: router,
      builder: (context, child) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: AppTheme.cupertinoPrimary,
          scaffoldBackgroundColor: AppTheme.canvas,
          barBackgroundColor: AppTheme.canvas,
          textTheme: CupertinoTextThemeData(
            textStyle: GoogleFonts.inter(),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
