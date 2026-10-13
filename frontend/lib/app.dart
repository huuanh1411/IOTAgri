// lib/app.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'core/theme/app_theme.dart';

/// The root widget of the app. It reads the [goRouterProvider] which
/// contains the authentication‑aware routing configuration.
class AerogreenApp extends ConsumerWidget {
  const AerogreenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Aerogreen',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/foliage_background.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
          if (child != null)
            CupertinoTheme(
              data: const CupertinoThemeData(
                brightness: Brightness.light,
                primaryColor: AppTheme.cupertinoPrimary,
                scaffoldBackgroundColor: Colors.transparent,
                barBackgroundColor: Colors.transparent,
              ),
              child: child,
            ),
        ],
      ),
    );
  }
}
