// lib/screens/plant_picker_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/page_header.dart';
import '../core/widgets/gradient_button.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../providers/data_providers.dart';
import '../utils/l10n.dart';

const _plantImageAssets = <String, String>{
  '1': 'assets/images/plants/lettuce.png',
  '2': 'assets/images/plants/basil.png',
  '3': 'assets/images/plants/spinach.png',
  '4': 'assets/images/plants/mint.png',
  '5': 'assets/images/plants/kale.png',
  '6': 'assets/images/plants/coriander.png',
};

/// Plant Picker tab – matches the design in Phase 5.
class PlantPickerScreen extends ConsumerWidget {
  const PlantPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlant = ref.watch(currentPlantProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page header
              PageHeader(
                title: context.l10n.choosePlantTitle,
                subtitle: context.l10n.choosePlantSubtitle,
              ),
              const SizedBox(height: 28),
              // 2‑column grid of plant cards
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 320,
                  ),
                  itemCount: mockPlants.length,
                  itemBuilder: (context, index) {
                    final plant = mockPlants[index];
                    final isCurrent = plant.id == activePlant.plant.id;
                    return _PlantCard(
                      plant: plant,
                      isCurrent: isCurrent,
                      onStart: isCurrent
                          ? null
                          : () async {
                              await ref
                                  .read(currentPlantProvider.notifier)
                                  .startGrowing(plant);
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Individual plant card widget.
class _PlantCard extends StatelessWidget {
  const _PlantCard({
    required this.plant,
    required this.isCurrent,
    this.onStart,
  });

  final Plant plant;
  final bool isCurrent;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transparent plant photography on the existing pastel tint.
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: plant.tintColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  _plantImageAssets[plant.id]!,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  semanticLabel: plant.name,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Plant name and variety.
            Text(plant.name, style: AppText.heading(context, fontSize: 18)),
            Text(
              plant.variety,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // Meta row – duration & difficulty.
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  context.l10n.weeks(plant.durationWeeks),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.emoji_nature, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  plant.difficulty,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Scheduling lines.
            Row(
              children: [
                const Icon(
                  Icons.opacity,
                  size: 16,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    context.l10n.pumpCycle(
                      plant.pumpMinutes,
                      plant.pumpEveryMinutes,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.science, size: 16, color: Color(0xFFF2A93B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    context.l10n.nutrientCycleShort(
                      plant.nutrientMl,
                      plant.nutrientEveryDays,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.thermostat,
                  size: 16,
                  color: Color(0xFFCDB59A),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${plant.tempMin}–${plant.tempMax}°C',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Action button.
            SizedBox(
              width: double.infinity,
              child: isCurrent
                  ? ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check),
                      label: Text(context.l10n.currentlyGrowing),
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor:
                            AppColors.growingDisabledBackground,
                        disabledForegroundColor:
                            AppColors.growingDisabledForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )
                  : GradientButton(
                      label: context.l10n.startGrowing,
                      onPressed: onStart,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
