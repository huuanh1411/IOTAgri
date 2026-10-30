// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;

import '../cupertino/profile/cupertino_change_password_screen.dart';
import '../core/animation/app_motion.dart';
import 'delete_account_screen.dart';
import '../core/widgets/page_header.dart';
import '../core/widgets/section_chip.dart';
import '../providers/app_settings_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/l10n.dart';

/// Settings screen – unit/language selection and alert toggles.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = provider.Provider.of<AppSettingsProvider>(context);
    final alertSettings = ref.watch(settingsProvider);
    final alertNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                chip: SectionChip(label: context.l10n.customize),
                title: context.l10n.settings,
                subtitle: '',
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.language,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: RadioGroup<String>(
                  groupValue: settings.locale.languageCode,
                  onChanged: (value) {
                    if (value != null) settings.setLocale(Locale(value));
                  },
                  child: const Column(
                    children: [
                      RadioListTile<String>(
                        value: 'vi',
                        title: Text('Tiếng Việt'),
                      ),
                      Divider(height: 1),
                      RadioListTile<String>(
                        value: 'en',
                        title: Text('English'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.notifications,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(context.l10n.lowWaterAlert),
                      value: alertSettings.lowWaterAlert,
                      onChanged: (value) =>
                          alertNotifier.update(lowWaterAlert: value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(context.l10n.lowNutrientAlert),
                      value: alertSettings.lowNutrientAlert,
                      onChanged: (value) =>
                          alertNotifier.update(lowNutrientAlert: value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(context.l10n.temperatureAlert),
                      value: alertSettings.temperatureAlert,
                      onChanged: (value) =>
                          alertNotifier.update(temperatureAlert: value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(context.l10n.harvestReminder),
                      value: alertSettings.harvestReminder,
                      onChanged: (value) =>
                          alertNotifier.update(harvestReminder: value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(
                    settings.locale.languageCode == 'en'
                        ? 'Change password'
                        : 'Đổi mật khẩu',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push<void>(
                    AppMotion.detailRoute<void>(
                      context: context,
                      builder: (_) => const CupertinoChangePasswordScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red,
                  ),
                  title: Text(context.l10n.deleteAccountTitle),
                  subtitle: Text(context.l10n.deleteAccountSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push<void>(
                    AppMotion.detailRoute<void>(
                      context: context,
                      builder: (_) => const DeleteAccountScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
