// lib/screens/more_tab.dart
// Phase 7: More (Account) tab implementation with navigation to sub‑screens.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/gradient_button.dart';
import '../core/widgets/info_row.dart';
import '../core/widgets/outline_danger_button.dart';
import '../core/widgets/page_header.dart';
import '../core/widgets/section_chip.dart';
import '../core/widgets/status_pill.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

import '../providers/settings_provider.dart';

class MoreTab extends ConsumerWidget {
  const MoreTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    final user = ref.watch(authProvider).user;
    // No plant provider; using static plan label

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: PageHeader(
                sectionLabel: SectionChip(label: 'Tài khoản'),
                title: 'Khác',
                subtitle: 'Để Aerogreen tự động vận hành, hoặc tự tay điều chỉnh.',
              ),
            ),
            // Profile card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppCard(
                borderRadius: 24,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          gradient: LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text('M', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      // Name & email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.fullName ?? 'Mira Patel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(user?.email ?? 'mira@aerogreen.app', style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                      // Plan pill
                      StatusPill(label: plant?.plan ?? 'Pro', color: AppColors.mintChip),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // List of navigation rows
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppCard(
                borderRadius: 24,
                child: Column(
                  children: [
                    _NavRow(
                      icon: Icons.notifications,
                      title: 'Thông báo',
                      subtitle: 'Quản lý cảnh báo',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
                    ),
                    const Divider(height: 1),
                    _NavRow(
                      icon: Icons.settings,
                      title: 'Tùy chỉnh',
                      subtitle: 'Đơn vị, ngôn ngữ',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomizationScreen())),
                    ),
                    const Divider(height: 1),
                    _NavRow(
                      icon: Icons.local_florist,
                      title: 'Lịch sử thu hoạch',
                      subtitle: 'Đã trồng 32 cây',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HarvestHistoryScreen())),
                    ),
                    const Divider(height: 1),
                    _NavRow(
                      icon: Icons.help_center,
                      title: 'Trợ giúp & Hỗ trợ',
                      subtitle: 'Câu hỏi thường gặp và chat',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Logout button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: OutlineDangerButton(
                label: 'Đăng xuất',
                icon: Icons.logout,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Xác nhận đăng xuất'),
                      content: const Text('Bạn có chắc muốn đăng xuất không?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Hủy')),
                        ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Đăng xuất')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(authProvider).logout();
                    // Navigate to auth screen (outside shell)
                    if (context.mounted) {
                      context.go('/auth');
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _NavRow({required this.icon, required this.title, required this.subtitle, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: AppColors.mintChip, child: Icon(icon, color: Colors.white)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// Sub‑screens
// ---------------------------------------------------------------------------

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool lowWater = true;
  bool lowNutrient = true;
  bool tempOutOfRange = true;
  bool harvestReminder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('Thông báo'),
      ),
      body: ListView(
        children: [
          SwitchListTile(value: lowWater, onChanged: (v) => setState(() => lowWater = v), title: const Text('Cảnh báo mức nước thấp')),
          SwitchListTile(value: lowNutrient, onChanged: (v) => setState(() => lowNutrient = v), title: const Text('Cảnh báo dinh dưỡng thấp')),
          SwitchListTile(value: tempOutOfRange, onChanged: (v) => setState(() => tempOutOfRange = v), title: const Text('Cảnh báo nhiệt độ ngoài phạm vi')),
          SwitchListTile(value: harvestReminder, onChanged: (v) => setState(() => harvestReminder = v), title: const Text('Nhắc nhở thu hoạch')),
        ],
      ),
    );
  }
}

class CustomizationScreen extends ConsumerWidget {
  const CustomizationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Tùy chỉnh')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Đơn vị nhiệt độ'),
            trailing: DropdownButton<TemperatureUnit>(
              value: settings.temperatureUnit,
              items: const [
                DropdownMenuItem(value: TemperatureUnit.celsius, child: Text('°C')),
                DropdownMenuItem(value: TemperatureUnit.fahrenheit, child: Text('°F')),
              ],
              onChanged: (v) => v != null ? ref.read(settingsProvider.notifier).setTemperatureUnit(v) : null,
            ),
          ),
          ListTile(
            title: const Text('Đơn vị thể tích'),
            trailing: DropdownButton<VolumeUnit>(
              value: settings.volumeUnit,
              items: const [
                DropdownMenuItem(value: VolumeUnit.ml, child: Text('ml')),
                DropdownMenuItem(value: VolumeUnit.oz, child: Text('oz')),
              ],
              onChanged: (v) => v != null ? ref.read(settingsProvider.notifier).setVolumeUnit(v) : null,
            ),
          ),
          ListTile(
            title: const Text('Ngôn ngữ'),
            trailing: DropdownButton<String>(
              value: settings.language,
              items: const [
                DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) => v != null ? ref.read(settingsProvider.notifier).setLanguage(v) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class HarvestHistoryScreen extends StatelessWidget {
  const HarvestHistoryScreen({Key? key}) : super(key: key);

  // Simple mock record
  List<Map<String, String>> get _mockData => const [
    {'plant': 'Xà lách', 'date': '2023‑04‑12', 'yield': '1.2 kg'},
    {'plant': 'Húng quế', 'date': '2023‑03‑20', 'yield': '0.8 kg'},
    {'plant': 'Rau chân vịt', 'date': '2023‑02‑15', 'yield': '1.5 kg'},
    {'plant': 'Bạc hà', 'date': '2023‑01‑10', 'yield': '0.9 kg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Lịch sử thu hoạch')),
      body: ListView.separated(
        itemCount: _mockData.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (c, i) {
          final item = _mockData[i];
          return ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(item['plant']!),
            subtitle: Text('Ngày: ${item['date']} — Thu hoạch: ${item['yield']}'),
          );
        },
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Trợ giúp & Hỗ trợ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Simple FAQ accordion
            ExpansionTile(title: const Text('Cách thiết lập plant?'), children: const [Padding(padding: EdgeInsets.all(8.0), child: Text('Chọn plant trong mục "Chọn Giống Cây"...'))]),
            ExpansionTile(title: const Text('Làm sao để tắt chế độ tự động?'), children: const [Padding(padding: EdgeInsets.all(8.0), child: Text('Vào tab "Điều khiển" và chuyển sang chế độ "Thủ công".'))]),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Chat với chúng tôi',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat placeholder – sẽ mở cửa sổ chat khi có backend.')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
