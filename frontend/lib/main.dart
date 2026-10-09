// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/device.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme.dart'; // contains UIConsts and AppText
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/alert_center_provider.dart';
import 'services/notification_service.dart';
import 'screens/hello_screen.dart';
import 'screens/ui_showcase_screen.dart';

// Screens (still Cupertino‑styled, but will be displayed under MaterialApp)
import 'cupertino/auth/cupertino_login_screen.dart';
import 'cupertino/dashboard/cupertino_dashboard_screen.dart';
import 'cupertino/admin/cupertino_admin_dashboard_screen.dart';
import 'cupertino/devices/cupertino_device_detail_screen.dart';
import 'cupertino/notifications/notification_banner_host.dart';
import 'cupertino/responsive/responsive_layout.dart';

// ---------------------------------------------------------------------------
// 1️⃣ go_router configuration
// ---------------------------------------------------------------------------
final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    // Shell route containing the bottom navigation and preserving state per tab
    StatefulShellRoute.indexed(
      builder: (context, state, child) => ShellScaffold(child: child),
      branches: [
        // 0 – Home tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) => const MaterialPage(child: HomeTab()),
            ),
          ],
        ),
        // 1 – Plant picker tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/plants',
              name: 'plants',
              pageBuilder: (context, state) => const MaterialPage(child: PlantsTab()),
            ),
          ],
        ),
        // 2 – Control tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/control',
              name: 'control',
              pageBuilder: (context, state) => const MaterialPage(child: ControlTab()),
            ),
          ],
        ),
        // 3 – More tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              name: 'more',
              pageBuilder: (context, state) => const MaterialPage(child: MoreTab()),
            ),
            // Sub‑routes for More tab
            GoRoute(
              path: '/more/alerts',
              name: 'more_alerts',
              builder: (context, state) => const NotificationSettingsScreen(),
            ),
            GoRoute(
              path: '/more/settings',
              name: 'more_settings',
              builder: (context, state) => const CustomizationScreen(),
            ),
            GoRoute(
              path: '/more/history',
              name: 'more_history',
              builder: (context, state) => const HarvestHistoryScreen(),
            ),
            GoRoute(
              path: '/more/help',
              name: 'more_help',
              builder: (context, state) => const HelpSupportScreen(),
            ),
          ],
        ),
      ],
    ),
    // Auth flow (outside shell)
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    // UI showcase (optional)
    GoRoute(
      path: '/ui-showcase',
      builder: (context, state) => const UIShowcaseScreen(),
    ),
  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('Page not found')),
  ),
);

// ---------------------------------------------------------------------------
// 2️⃣ Riverpod providers (wrapping existing ChangeNotifiers for now)
// ---------------------------------------------------------------------------
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) => AuthProvider());
final notificationServiceProvider = Provider<NotificationService>((ref) => FakeNotificationService());
final alertCenterProvider = ChangeNotifierProvider<AlertCenterProvider>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return AlertCenterProvider(notificationService: service);
});

// ---------------------------------------------------------------------------
// 3️⃣ App entry point
// ---------------------------------------------------------------------------
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AerogreenApp()));
}

// ---------------------------------------------------------------------------
// 4️⃣ Root widget – MaterialApp with Material‑3 and theming
// ---------------------------------------------------------------------------
class AerogreenApp extends ConsumerWidget {
  const AerogreenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialise side‑effect providers
    ref.watch(authProvider);
    ref.watch(alertCenterProvider);

    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Aerogreen',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
      builder: (context, child) {
        return NotificationBannerHost(
          service: ref.read(notificationServiceProvider),
          onOpen: (message) {
            final device = message.device;
            if (device == null) return;
            context.go('/device/${device.id}');
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 5️⃣ AuthWrapper – decides which screen to show based on auth state
// ---------------------------------------------------------------------------
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState.isLoading && authState.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (authState.user != null) {
      // Navigate to home screen (non‑admin for now)
      return const HomeScreen();
    }
    return const AuthScreen();
  }
}
