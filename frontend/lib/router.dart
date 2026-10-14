// lib/router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/auth_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/harvest_screen.dart';
import 'screens/help_screen.dart';
import 'screens/home_screen.dart';
import 'screens/plant_picker_screen.dart';
import 'screens/more_screen.dart';
import 'screens/sensor_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/auth_controller.dart';
import 'core/widgets/floating_pill_nav_bar.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.user != null;
      final isOnAuth = state.matchedLocation == '/auth';
      if (!isLoggedIn && !isOnAuth) return '/auth';
      if (isLoggedIn && isOnAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/auth'),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      // Shell route that holds the bottom navigation and preserves tab state.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: navigationShell,
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
                    builder: (context, state) => SensorDetailScreen(
                      metric: state.pathParameters['metric'] ?? 'light',
                    ),
                  ),
                ],
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
                    path: 'alerts',
                    builder: (context, state) => const AlertsScreen(),
                  ),
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
