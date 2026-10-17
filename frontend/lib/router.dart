// lib/router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/alert_center_tab_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/harvest_screen.dart';
import 'screens/help_screen.dart';
import 'screens/home_screen.dart';
import 'screens/plant_picker_screen.dart';
import 'screens/more_screen.dart';
import 'screens/sensor_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_controller.dart';
import 'core/animation/app_motion.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/floating_pill_nav_bar.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // Keep the router instance stable. Recreating it after every auth update
  // restarts `initialLocation` at /splash instead of applying the redirect.
  final authRefresh = ValueNotifier<AuthState>(
    ref.read(authControllerProvider),
  );
  ref.listen<AuthState>(authControllerProvider, (_, next) {
    authRefresh.value = next;
  });
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authRefresh,
    // On the web, refresh normally preserves the current hash (such as /auth).
    // The startup flow must begin with the Flutter animated splash instead.
    overridePlatformDefaultLocation: true,
    redirect: (BuildContext context, GoRouterState state) {
      if (state.matchedLocation == '/splash') return null;
      final isLoggedIn = ref.read(authControllerProvider).user != null;
      final isOnAuth = state.matchedLocation == '/auth';
      if (!isLoggedIn && !isOnAuth) return '/auth';
      if (isLoggedIn && isOnAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      // Shell route that holds the bottom navigation and preserves tab state.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppMotionTabTransition(
              index: navigationShell.currentIndex,
              child: navigationShell,
            ),
            bottomNavigationBar: FloatingPillNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: navigationShell.goBranch,
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'sensor/:metric',
                    name: 'sensor-detail',
                    pageBuilder: (context, state) => CustomTransitionPage<void>(
                      transitionDuration: AppMotion.duration(
                        context,
                        AppMotion.detailOpen,
                      ),
                      reverseTransitionDuration: AppMotion.duration(
                        context,
                        AppMotion.detailOpen,
                      ),
                      child: SensorDetailScreen(
                        metric: state.pathParameters['metric'] ?? 'light',
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            final curved = CurvedAnimation(
                              parent: animation,
                              curve: AppMotion.easeOut,
                            );
                            return FadeTransition(
                              opacity: curved,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.045, 0),
                                  end: Offset.zero,
                                ).animate(curved),
                                child: child,
                              ),
                            );
                          },
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                name: 'alerts',
                builder: (context, state) => const AlertCenterTabScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pick',
                name: 'pick',
                builder: (context, state) => const PlantPickerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/other',
                name: 'other',
                builder: (context, state) => const MoreScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'harvest',
                    builder: (context, state) => const HarvestScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    builder: (context, state) => const HelpScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text(state.error.toString()))),
  );
});
