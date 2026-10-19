// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/status_pill.dart';
import '../core/widgets/info_row.dart';
import '../core/widgets/gauge_ring.dart';
import '../core/widgets/page_header.dart';
import '../core/widgets/skeleton.dart'; // placeholder skeleton widget
import '../providers/data_providers.dart';
import '../providers/user_provider.dart';
import '../data/models.dart';
import '../models/device_overview.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/animation/app_motion.dart';
import '../utils/l10n.dart';

/// Home tab UI that matches the design (Phase 4).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.fixedClock});

  final DateTime? fixedClock;

  // Greeting based on hour of day.
  String _greeting(BuildContext context) {
    final hour = (fixedClock ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) return context.l10n.goodMorning;
    if (hour >= 12 && hour < 18) return context.l10n.goodAfternoon;
    if (hour >= 18 && hour < 22) return context.l10n.goodEvening;
    return context.l10n.goodNight;
  }

  String _gardenTitle(BuildContext context, String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return context.l10n.gardenTitle;
    final firstName = trimmed.split(' ').first;
    if (firstName.isEmpty) return context.l10n.gardenTitle;
    if (firstName.endsWith('s') || firstName.endsWith('S')) {
      return context.l10n.gardenOfEndingWithS(firstName);
    }
    return context.l10n.gardenOf(firstName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final activePlant = ref.watch(currentPlantProvider);

    return ColoredBox(
      color: AppColors.background,
      child: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      leadingContent: Text(
                        _greeting(context),
                        style: AppText.body(context, fontSize: 14).copyWith(
                          color: AppColors.mutedSage,
                        ),
                      ),
                      title: _gardenTitle(context, user.fullName),
                      subtitle: context.l10n.gardenSubtitle,
                      trailingAction: CircleAvatar(
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
                            user.fullName.trim().isEmpty
                                ? '?'
                                : user.fullName.trim()[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _HeroCard(activePlant: activePlant),
                    const SizedBox(height: 24),
                    // These gauges intentionally use persisted backend readings.
                    ref
                        .watch(dashboardDevicesProvider)
                        .when(
                          data: (devices) => AppMotionEntrance(
                            child: _LiveSensorCard(
                              device: devices.isEmpty ? null : devices.first,
                            ),
                          ),
                          loading: () =>
                              Skeleton(height: 180, borderRadius: 24),
                          error: (_, _) => Text(context.l10n.sensorLoadError),
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
// Hero card widget – shows plant progress.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.activePlant});

  final ActivePlant activePlant;

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
      child: Column(
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
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.growing,
                      style: const TextStyle(
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
                context.l10n.dayProgress(
                  plant.variety,
                  currentDay + 1,
                  activePlant.totalDays,
                ),
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
                children: [
                  Text(
                    context.l10n.germination,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    context.l10n.growth,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    context.l10n.harvest,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                Text(
                  context.l10n.liveSensors,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                StatusPill(
                  label: context.l10n.synced,
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
                    label: context.l10n.waterLevel,
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
                    label: context.l10n.airTemperature,
                    value: reading?.temperature,
                    unit: '°C',
                    color: const Color(0xFFCDB59A), // temp gauge tan
                    icon: Icons.thermostat,
                    onTap: () => context.push('/home/sensor/temperature'),
                  ),
                  GaugeRing(
                    label: context.l10n.light,
                    value: reading?.lux,
                    unit: 'lux',
                    color: const Color(0xFFE3A72F),
                    icon: Icons.wb_sunny_outlined,
                    onTap: () => context.push('/home/sensor/light'),
                  ),
                  GaugeRing(
                    label: context.l10n.waterTemperature,
                    value: reading?.solutionTemperature,
                    unit: '°C',
                    color: const Color(0xFFC86464),
                    icon: Icons.water,
                    onTap: () =>
                        context.push('/home/sensor/solutionTemperature'),
                  ),
                  GaugeRing(
                    label: context.l10n.airHumidity,
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
                Expanded(
                  child: Text(
                    context.l10n.careScheduleFor(plant.name),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusPill(
                  label: isSmart
                      ? context.l10n.automaticOptimized
                      : context.l10n.paused,
                  color: isSmart ? AppColors.forestGreen : AppColors.alertRed,
                ),
              ],
            ),
            const SizedBox(height: 12),
            InfoRow(
              label: context.l10n.wateringCycle,
              value: context.l10n.wateringCycleValue(
                plant.pumpMinutes,
                plant.pumpEveryMinutes,
              ),
            ),
            InfoRow(
              label: context.l10n.nutrientCycle,
              value: context.l10n.nutrientCycleValue(
                plant.nutrientMl,
                plant.nutrientEveryDays,
              ),
            ),
            InfoRow(
              label: context.l10n.idealTemperature,
              value: '${plant.tempMin.toInt()}–${plant.tempMax.toInt()}°C',
            ),
          ],
        ),
      ),
    );
  }
}
