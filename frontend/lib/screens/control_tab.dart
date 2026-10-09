// lib/screens/control_tab.dart
// Phase 6: Control Center tab implementation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/app_card.dart';
import '../core/widgets/gradient_button.dart';
import '../core/widgets/info_row.dart';
import '../core/widgets/section_chip.dart';
import '../core/widgets/page_header.dart';
import '../core/widgets/status_pill.dart';
import '../models/plant.dart';
import '../providers/current_plant_provider.dart';
import '../providers/control_center_provider.dart';

class ControlTab extends ConsumerWidget {
  const ControlTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantAsync = ref.watch(currentPlantProvider);
    final mode = ref.watch(controlModeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: PageHeader(
                sectionLabel: SectionChip(label: 'Thiết bị'),
                title: 'Trung tâm Điều khiển',
                subtitle:
                    'Để Aerogreen tự động vận hành, hoặc tự tay điều chỉnh.',
              ),
            ),
            // Segmented control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _ModeSelector(),
            ),
            const SizedBox(height: 12),
            // Content based on mode
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: mode == ControlMode.smart
                    ? _SmartModeCard(plantAsync: plantAsync)
                    : _ManualModeContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented control for Smart / Manual mode.
class _ModeSelector extends ConsumerWidget {
  const _ModeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(controlModeProvider);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC), // beige track
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Thông minh',
            icon: Icons.auto_awesome,
            selected: mode == ControlMode.smart,
            onTap: () => ref.read(controlModeProvider.notifier).state = ControlMode.smart,
          ),
          _Segment(
            label: 'Thủ công',
            icon: Icons.chip,
            selected: mode == ControlMode.manual,
            onTap: () => ref.read(controlModeProvider.notifier).state = ControlMode.manual,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _Segment({required this.label, required this.icon, required this.selected, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Colors.white : Colors.transparent;
    final txt = selected ? Colors.black : Colors.black54;
    final shadow = selected ? [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))] : null;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: shadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: txt),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: txt)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Smart mode card – shows automatic cycle information.
class _SmartModeCard extends ConsumerWidget {
  final AsyncValue<Plant?> plantAsync;
  const _SmartModeCard({required this.plantAsync, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return plantAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (plant) {
        if (plant == null) return const SizedBox.shrink();
        return AppCard(
          borderRadius: 24,
          gradient: const LinearGradient(
            colors: [Color(0xFFB2F5EA), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SectionChip(label: 'Đang chạy chu kỳ thông minh cho'),
                const SizedBox(height: 8),
                // Icon tile
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome, size: 36, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Đang chạy chu kỳ thông minh cho ${plant.name}',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.copyWith(fontFamily: 'serif'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aerogreen đang tự động chăm sóc cây theo chu kỳ được tối ưu cho butterhead xà lách.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Info rows from the plant
                InfoRow(label: 'CHU KỲ TƯỚI', value: '${plant.pumpMinutes} phút mỗi ${plant.pumpEveryMinutes} phút'),
                InfoRow(label: 'CHU KỲ DINH DƯỠNG', value: '${plant.nutrientMl}ml mỗi ${plant.nutrientEveryDays} ngày'),
                InfoRow(label: 'NHIỆT ĐỘ LÝ TƯỞNG', value: '${plant.tempMin}–${plant.tempMax}°C'),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Manual mode UI – pump, spray, footnote.
class _ManualModeContent extends ConsumerWidget {
  const _ManualModeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pumpRunning = ref.watch(pumpRunningProvider);
    final sprayDuration = ref.watch(sprayDurationProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Pump card
          AppCard(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent,
                    ),
                    child: const Icon(Icons.opacity, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Máy Bơm Nước', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Status:') // placeholder, real status below
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(pumpRunning ? 'Đang chạy' : 'Chờ', style: const TextStyle(color: Colors.green)),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pumpRunning ? Colors.red : Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      ref.read(pumpRunningProvider.notifier).state = !pumpRunning;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(pumpRunning ? 'Dừng bơm' : 'Bắt đầu bơm')),
                      );
                    },
                    child: Text(pumpRunning ? 'Dừng' : '⏻ Bắt đầu'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Spray card
          AppCard(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5DC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.science, color: Colors.brown),
                      ),
                      const SizedBox(width: 12),
                      const Text('Phun Dinh Dưỡng', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('\$sprayDuration s', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Điều chỉnh thời gian phun sương'),
                  Slider(
                    min: 5,
                    max: 90,
                    divisions: 85,
                    value: sprayDuration.toDouble(),
                    activeColor: Colors.green,
                    label: '\$sprayDuration s',
                    onChanged: (val) => ref.read(sprayDurationProvider.notifier).state = val.round(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('5 giây'),
                      Text('Khuyến nghị 30 giây'),
                      Text('90 giây'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GradientButton(
                    label: 'Phun Ngay',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phun dinh dưỡng...')));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Footnote
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Chế độ thủ công sẽ tạm dừng chu kỳ Thông minh. Bạn có thể chuyển lại bất cứ lúc nào.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
