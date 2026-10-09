// lib/screens/ui_showcase_screen.dart
import 'package:flutter/material.dart';
import '../core/widgets/section_chip.dart';
import '../core/widgets/page_header.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/gradient_button.dart';
import '../core/widgets/outline_danger_button.dart';
import '../core/widgets/status_pill.dart';
import '../core/widgets/info_row.dart';
import '../core/widgets/gauge_ring.dart';
import '../core/widgets/floating_pill_nav_bar.dart';
import '../core/theme/app_text.dart';
import '../core/theme/app_colors.dart';

/// Temporary screen that showcases every shared widget for visual verification.
class UIShowcaseScreen extends StatelessWidget {
  const UIShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Showcase'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionChip(label: 'PHẦN ĐẦU'),
            const SizedBox(height: 12),
            const PageHeader(
              sectionLabel: 'GIỚI THIỆU',
              title: 'Aerogreen',
              subtitle: 'Trồng Rau Đô Thị Nhàn Tênh',
            ),
            const SizedBox(height: 24),
            const AppCard(
              child: Text('Nội dung thẻ mẫu', style: AppText.body),
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                GradientButton(label: 'Bắt đầu', onPressed: null),
                SizedBox(width: 12),
                OutlineDangerButton(label: 'Đăng xuất', onPressed: null),
              ],
            ),
            const SizedBox(height: 24),
            const StatusPill(label: 'Đã đồng bộ', dotColor: Colors.green),
            const SizedBox(height: 24),
            const InfoRow(
              icon: Icons.opacity,
              label: 'MỨC NƯỚC',
              value: '68%',
            ),
            const SizedBox(height: 24),
            const GaugeRing(
              value: 0.74,
              label: 'NƯỚC',
              icon: Icons.water,
            ),
            const SizedBox(height: 80), // leave space for nav bar
          ],
        ),
      ),
      // Floating navigation at the bottom
      bottomNavigationBar: const FloatingPillNavBar(),
    );
  }
}
