// lib/providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';
import 'auth_controller.dart';

/// Adapts the authenticated session for legacy profile widgets.
final userProfileProvider = Provider<UserProfile>((ref) {
  final user = ref.watch(authControllerProvider).user;
  final fullName = user?.fullName.trim();

  return UserProfile(
    fullName: fullName?.isNotEmpty == true ? fullName! : 'Người dùng',
    email: user?.email ?? '',
    plan: user?.plan ?? 'Pro',
  );
});
