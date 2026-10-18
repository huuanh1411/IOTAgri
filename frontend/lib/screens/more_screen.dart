// lib/screens/more_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/page_header.dart';
import '../core/widgets/outline_danger_button.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../providers/auth_controller.dart';
import '../providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/l10n.dart';

/// "More" / "Khác" tab – profile and navigable rows.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final avatarInitial = user.fullName.trim().isEmpty
        ? '?'
        : user.fullName.trim()[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: context.l10n.more,
                subtitle: context.l10n.moreSubtitle,
              ),
              const SizedBox(height: 28),
              // Profile card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Gradient avatar with the current user's initial.
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.forestGreen, AppColors.sage],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          avatarInitial,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: AppText.heading(context, fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(
                                color: AppColors.forestGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Plan pill "Pro"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mint.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Pro',
                          style: TextStyle(
                            color: AppColors.mint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // List of rows
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
                child: Column(
                  children: [
                    _ListRow(
                      icon: Icons.settings, // gear
                      title: context.l10n.customization,
                      subtitle: context.l10n.languageAndNotifications,
                      onTap: () => context.push('/other/settings'),
                    ),
                    const Divider(height: 1),
                    _ListRow(
                      icon: Icons.eco, // leaf
                      title: context.l10n.harvestHistory,
                      subtitle: context.l10n.plantsGrown,
                      onTap: () => context.push('/other/harvest'),
                    ),
                    const Divider(height: 1),
                    _ListRow(
                      icon: Icons.help_center, // help circle
                      title: context.l10n.helpAndSupport,
                      subtitle: context.l10n.faqAndChat,
                      onTap: () => context.push('/other/help'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Logout button
              OutlineDangerButton(
                label: context.l10n.logOut,
                icon: Icons.logout,
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(c.l10n.confirm),
                      content: Text(c.l10n.logoutConfirmation),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: Text(c.l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: Text(c.l10n.logOut),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (!context.mounted) return;
                    context.go('/auth');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.mint.withValues(alpha: 0.2),
        child: Icon(icon, color: AppColors.mint),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
    );
  }
}
