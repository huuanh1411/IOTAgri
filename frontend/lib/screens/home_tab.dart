// lib/screens/home_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/theme/ui_consts.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/gauge_ring.dart';
import '../core/widgets/info_row.dart';
import '../core/widgets/status_pill.dart';
import '../core/widgets/section_chip.dart';
import '../core/widgets/skeleton_box.dart';
import '../models/plant.dart';
import '../models/sensor_reading.dart';
import '../models/app_alert.dart';
import '../providers/current_plant_provider.dart';
import '../providers/sensor_stream_provider.dart';
import '../providers/alerts_provider.dart';
import '../providers/navigation_provider.dart';

/// Home tab that displays the garden overview.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  // Helper to get a time‑of‑day greeting in Vietnamese.
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  // Compute a simple health percentage based on sensor values and ideal temperature.
  double _healthPercentage(
      SensorReading sensor, Plant plant) {
    final waterScore = sensor.waterLevel / 100.0;
    final nutrientScore = sensor.nutrientLevel / 100.0;
    // Temperature ideal center and allowable range.
    final idealMid = (plant.tempMin + plant.tempMax) / 2.0;
    final range = (plant.tempMax - plant.tempMin) / 2.0;
    final tempDiff = (sensor.temperature - idealMid).abs();
    final tempScore = (tempDiff <= range)
        ? 1.0 - (tempDiff / range)
        : 0.0;
    final health = ((waterScore + nutrientScore + tempScore) / 3.0) * 100.0;
    return health.clamp(0.0, 100.0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlant = ref.watch(currentPlantProvider);
    final asyncSensor = ref.watch(sensorStreamProvider);
    final asyncAlerts = ref.watch(alertsProvider);

    // Pull‑to‑refresh handler.
    Future<void> _refresh() async {
      ref.invalidate(sensorStreamProvider);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== Header ====================
              asyncPlant.when(
                loading: () => const SkeletonBox(height: 80),
                error: (_, __) => const SizedBox.shrink(),
                data: (plant) {
                  final firstName = ref
                          .watch(authControllerProvider)
                          .user
                          ?.fullName
                          .split(' ')
                          .first ?? '';
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.secondaryText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vườn của $firstName',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(fontFamily: AppText.serifFamily),
                            ),
                          ],
                        ),
                      ),
                      // Avatar with gradient background and initial.
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.mintChip,
                        child: Text(
                          firstName.isNotEmpty ? firstName[0] : '?',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // ==================== Hero Card ====================
              asyncPlant.when(
                loading: () => const SkeletonBox(height: 180),
                error: (_, __) => const SizedBox.shrink(),
                data: (plant) => asyncSensor.when(
                  loading: () => const SkeletonBox(height: 180),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (sensor) {
                    final health = _healthPercentage(sensor, plant).toInt();
                    final dayProgress = (plant.durationWeeks * 7);
                    final currentDay = 14; // placeholder – you can replace with actual state.
                    final progressRatio = currentDay / dayProgress;
                    return AppCard(
                      borderRadius: 28,
                      gradient: const LinearGradient(
                        colors: [AppColors.sage, AppColors.forest],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: chip and health %
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SectionChip(
                                  label: 'ĐANG TRỒNG',
                                  icon: Icons.auto_awesome,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$health%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(color: Colors.white),
                                    ),
                                    const Text(
                                      'KHỎE MẠNH',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Plant name & icon
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white24,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.eco,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  plant.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontFamily: AppText.serifFamily,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${plant.variety} · Ngày $currentDay / ${dayProgress}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Progress bar
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: progressRatio,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Nảy mầm',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    )),
                                Text('Sinh trưởng',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    )),
                                Text('Thu hoạch',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // ==================== Sensor Card ====================
              asyncSensor.when(
                loading: () => const SkeletonBox(height: 120),
                error: (_, __) => const SizedBox.shrink(),
                data: (sensor) => asyncPlant.when(
                  loading: () => const SkeletonBox(height: 120),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (plant) {
                    return AppCard(
                      borderRadius: 24,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cảm biến Trực tiếp',
                              style: TextStyle(fontFamily: AppText.serifFamily, fontSize: 18),
                            ),
                            const StatusPill(
                              label: '● Đã đồng bộ',
                              color: AppColors.forest,
                            ),
                            const SizedBox(width: 8),
                            // Gauge rings
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GaugeRing(
                                    value: sensor.waterLevel,
                                    label: 'MỨC NƯỚC',
                                    icon: Icons.opacity,
                                    color: AppColors.forest,
                                  ),
                                  GaugeRing(
                                    value: sensor.nutrientLevel,
                                    label: 'MỨC DINH DƯỠNG',
                                    icon: Icons.science,
                                    color: AppColors.orange,
                                  ),
                                  GaugeRing(
                                    value: sensor.temperature,
                                    label: 'NHIỆT ĐỘ',
                                    icon: Icons.thermostat,
                                    color: AppColors.tan,
                                    suffix: '°',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // ==================== Schedule Card ====================
              asyncPlant.when(
                loading: () => const SkeletonBox(height: 120),
                error: (_, __) => const SizedBox.shrink(),
                data: (plant) {
                  return AppCard(
                    borderRadius: 24,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lịch chăm sóc ${plant.name}',
                            style: const TextStyle(
                              fontFamily: AppText.serifFamily,
                              fontSize: 18,
                            ),
                          ),
                          const StatusPill(
                            label: 'Tự động tối ưu',
                            color: AppColors.forest,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Info rows under schedule card
              asyncPlant.when(
                loading: () => const SkeletonBox(height: 80),
                error: (_, __) => const SizedBox.shrink(),
                data: (plant) {
                  return Column(
                    children: [
                      InfoRow(
                        label: 'CHU KỲ TƯỚI',
                        value: '${plant.pumpMinutes} phút mỗi ${plant.pumpEveryMinutes} phút',
                      ),
                      InfoRow(
                        label: 'CHU KỲ DINH DƯỠNG',
                        value: '${plant.nutrientMl}ml mỗi ${plant.nutrientEveryDays} ngày',
                      ),
                      InfoRow(
                        label: 'NHIỆT ĐỘ LÝ TƯỞNG',
                        value: '${plant.tempMin}–${plant.tempMax}°C',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // ==================== Alerts Card ====================
              asyncAlerts.when(
                loading: () => const SkeletonBox(height: 100),
                error: (_, __) => const SizedBox.shrink(),
                data: (alerts) {
                  if (alerts.isEmpty) {
                    return Center(
                      child: Text(
                        'Mọi thứ đều ổn 🌿',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    );
                  }
                  return AppCard(
                    borderRadius: 24,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Cảnh Báo / Thông Báo',
                                style: TextStyle(
                                  fontFamily: AppText.serifFamily,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '${alerts.length} đang hoạt động',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...alerts.map((alert) => _AlertRow(alert: alert, ref: ref)).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual alert row with action button.
class _AlertRow extends ConsumerWidget {
  final AppAlert alert;
  final WidgetRef ref;
  const _AlertRow({required this.alert, required this.ref, super.key});

  void _handleAction(BuildContext context) async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Xác nhận xử lý "${alert.title}"?'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Xác nhận'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirm == true) {
      // Simple resolution: remove alert and bump sensor value.
      ref.read(alertsProvider.notifier).remove(alert.id);
      // Example: increase related sensor value by a small amount.
      if (alert.type == AlertType.water) {
        ref.read(sensorStreamProvider.notifier).update((state) => state?.copyWith(
          waterLevel: (state?.waterLevel ?? 0) + 5,
        ));
      } else if (alert.type == AlertType.nutrient) {
        ref.read(sensorStreamProvider.notifier).update((state) => state?.copyWith(
          nutrientLevel: (state?.nutrientLevel ?? 0) + 5,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrgent = alert.type == AlertType.water && alert.title.contains('Nước');
    final chipColor = isUrgent ? AppColors.peach : AppColors.mintChip;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: chipColor,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.notifications,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.forest,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => _handleAction(context),
            child: const Text('Xử lý ngay'),
          ),
        ],
      ),
    );
  }
}
