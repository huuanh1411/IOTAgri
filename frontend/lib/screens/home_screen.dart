// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../models/user.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = ref.watch(authControllerProvider).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aerogreen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              // Return to auth flow
              if (context.mounted) {
                context.go('/auth');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          user != null ? 'Chào, ${user.fullName}!' : 'Chào!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
