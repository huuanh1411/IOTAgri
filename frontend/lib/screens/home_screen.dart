// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/status_pill.dart';
import '../core/widgets/info_row.dart';
import '../core/widgets/gauge_ring.dart';
import '../core/widgets/skeleton.dart'; // placeholder skeleton widget
import '../providers/data_providers.dart';
import '../providers/user_provider.dart';
import '../data/models.dart';
import '../models/device_overview.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/animation/app_motion.dart';

/// Home tab UI that matches the design (Phase 4).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Greeting based on hour of day.
  String _greeting(BuildContext context) {
    final hour = TimeOfDay.now().hour;
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';
    if (hour < 12) return isVietnamese ? 'Chào buổi sáng' : 'Good morning';
    if (hour < 18) return isVietnamese ? 'Chào buổi chiều' : 'Good afternoon';
    return isVietnamese ? 'Chào buổi tối' : 'Good evening';
  }

  // Compute health percent from sensor vs. plant ideal ranges.
  double _healthPercent(SensorReading reading, Plant plant) {
    double waterScore = (reading.waterLevel / 100).clamp(0.0, 1.0);
    double nutrientScore = (reading.nutrientLevel / 100).clamp(0.0, 1.0);
    double tempMid = (plant.tempMin + plant.tempMax) / 2;
    double tempRange = (plant.tempMax - plant.tempMin) / 2;
    double tempScore = 1 - ((reading.temperature - tempMid).abs() / tempRange);
    tempScore = tempScore.clamp(0.0, 1.0);
    return ((waterScore + nutrientScore + tempScore) / 3) * 100;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final activePlant = ref.watch(currentPlantProvider);
    final sensorAsync = ref.watch(sensorStreamProvider);

    return ColoredBox(
      color: AppColors.background,
      child: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with greeting and avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(context),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.secondaryText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Localizations.localeOf(context).languageCode == 'vi'
                                  ? 'Vườn của ${user.fullName.split(' ')[0]}'
                                  : "${user.fullName.split(' ')[0]}'s Garden",
                              style: AppText.heading(context, fontSize: 24),
                            ),
                          ],
                        ),
                        // Avatar with gradient and initial
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.transparent,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppColors.sage, AppColors.forestGreen],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              user.fullName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Hero card – loading skeleton while sensor data resolves
                    sensorAsync.when(
                      data: (sensor) {
                        final health = _healthPercent(
                          sensor,
                          activePlant.plant,
                        ).round();
                        return _HeroCard(
                          activePlant: activePlant,
                          sensor: sensor,
                          healthPercent: health,
                        );
                      },
                      loading: () => Skeleton(height: 180, borderRadius: 28),
                      error: (_, _) => const Text('Lỗi tải cảm biến'),
                    ),
                    const SizedBox(height: 24),
                    // These gauges intentionally use persisted backend readings.
                    ref.watch(dashboardDevicesProvider).when(
                      data: (devices) => AppMotionEntrance(
                        child: _LiveSensorCard(
                          device: devices.isEmpty ? null : devices.first,
                        ),
                      ),
                      loading: () => Skeleton(height: 180, borderRadius: 24),
                      error: (_, _) => const Text('Không thể tải cảm biến'),
                    ),
                    const SizedBox(height: 24),
                    // Care schedule card
                    _CareScheduleCard(activePlant: activePlant),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Hero card widget – shows plant progress & health.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.activePlant,
    required this.sensor,
    required this.healthPercent,
  });

  final ActivePlant activePlant;
  final SensorReading sensor;
  final int healthPercent;

  @override
  Widget build(BuildContext context) {
    final plant = activePlant.plant;
    final currentDay = activePlant.currentDay;
    final progress = activePlant.progressAt(DateTime.now());
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.sage, AppColors.forestGreen],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Top‑right health percent
          Positioned(
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$healthPercent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'KHỎE MẠNH',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Translucent chip
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_awesome, color: Colors.white70, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'ĐANG TRỒNG',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Plant name with leaf icon
              Row(
                children: [
                  const Icon(Icons.eco, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    plant.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${plant.variety} · Ngày ${currentDay + 1} / ${activePlant.totalDays}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Nảy mầm',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'Sinh trưởng',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'Thu hoạch',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sensor card widget with three gauge rings.
class _LiveSensorCard extends StatelessWidget {
  const _LiveSensorCard({required this.device});

  final DeviceOverview? device;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cảm biến Trực tiếp',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const StatusPill(
                  label: '● Đã đồng bộ',
                  color: AppColors.primaryText,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final reading = device?.latestReading;
                final gauges = [
                  GaugeRing(
                    label: 'MỨC NƯỚC',
                    value: reading?.waterLevel,
                    unit: '%',
                    color: AppColors.forestGreen,
                    icon: Icons.opacity,
                    onTap: () => context.push('/home/sensor/water'),
                  ),
                  GaugeRing(
                    label: 'TDS',
                    value: reading?.tds,
                    unit: 'ppm',
                    color: const Color(0xFFF2A93B), // nutrient gauge orange
                    icon: Icons.science,
                    onTap: () => context.push('/home/sensor/nutrient'),
                  ),
                  GaugeRing(
                    label: 'NHIỆT ĐỘ KK',
                    value: reading?.temperature,
                    unit: '°C',
                    color: const Color(0xFFCDB59A), // temp gauge tan
                    icon: Icons.thermostat,
                    onTap: () => context.push('/home/sensor/temperature'),
                  ),
                  GaugeRing(
                    label: 'ÁNH SÁNG',
                    value: reading?.lux,
                    unit: 'lux',
                    color: const Color(0xFFE3A72F),
                    icon: Icons.wb_sunny_outlined,
                    onTap: () => context.push('/home/sensor/light'),
                  ),
                  GaugeRing(
                    label: 'NHIỆT ĐỘ NƯỚC',
                    value: reading?.solutionTemperature,
                    unit: '°C',
                    color: const Color(0xFFC86464),
                    icon: Icons.water,
                    onTap: () => context.push('/home/sensor/solutionTemperature'),
                  ),
                  GaugeRing(
                    label: 'ĐỘ ẨM KHÔNG KHÍ',
                    value: reading?.humidity,
                    unit: '%',
                    color: const Color(0xFF4D94C7),
                    icon: Icons.water_drop_outlined,
                    onTap: () => context.push('/home/sensor/humidity'),
                  ),
                ];
                if (constraints.maxWidth >= 680) {
                  return Row(
                    children: [
                      for (final gauge in gauges)
                        Expanded(child: Center(child: gauge)),
                    ],
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 12,
                    runSpacing: 14,
                    children: gauges,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Care schedule card – reflects current control mode.
class _CareScheduleCard extends ConsumerWidget {
  const _CareScheduleCard({required this.activePlant});

  final ActivePlant activePlant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plant = activePlant.plant;
    final mode = ref.watch(controlModeProvider);
    final isSmart = mode == 'smart';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lịch chăm sóc ${plant.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                StatusPill(
                  label: isSmart ? 'Tự động tối ưu' : 'Đã tạm dừng',
                  color: isSmart ? AppColors.forestGreen : AppColors.alertRed,
                ),
              ],
            ),
            const SizedBox(height: 12),
            InfoRow(
              label: 'CHU KỲ TƯỚI',
              value:
                  '${plant.pumpMinutes} phút mỗi ${plant.pumpEveryMinutes} phút',
            ),
            InfoRow(
              label: 'CHU KỲ DINH DƯỠNG',
              value:
                  '${plant.nutrientMl}ml mỗi ${plant.nutrientEveryDays} ngày',
            ),
            InfoRow(
              label: 'NHIỆT ĐỘ LÝ TƯỞNG',
              value: '${plant.tempMin.toInt()}–${plant.tempMax.toInt()}°C',
            ),
          ],
        ),
      ),
    );
  }
}
