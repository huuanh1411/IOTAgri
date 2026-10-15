// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;

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
                chip: const SectionChip(label: 'Tùy chỉnh'),
                title: settings.isVietnamese ? 'Cài đặt' : 'Settings',
                subtitle: '',
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('language'),
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
              Text('Thông báo', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Cảnh báo nước thấp'),
                      value: alertSettings.lowWaterAlert,
                      onChanged: (value) =>
                          alertNotifier.update(lowWaterAlert: value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Cảnh báo dinh dưỡng thấp'),
                      value: alertSettings.lowNutrientAlert,
                      onChanged: (value) =>
                          alertNotifier.update(lowNutrientAlert: value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Cảnh báo nhiệt độ'),
                      value: alertSettings.temperatureAlert,
                      onChanged: (value) =>
                          alertNotifier.update(temperatureAlert: value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Nhắc nhở thu hoạch'),
                      value: alertSettings.harvestReminder,
                      onChanged: (value) =>
                          alertNotifier.update(harvestReminder: value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
