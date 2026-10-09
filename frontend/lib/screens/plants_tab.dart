// lib/screens/plants_tab.dart
// Phase 5: Plant Picker Tab implementation
// This screen displays a grid of plant cards allowing the user to select a plant.
// Selecting a plant updates the currentPlantProvider, resets the day counter,
// shows a SnackBar, and triggers a confirmation dialog.
// The UI uses existing reusable widgets from the design system.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/app_card.dart';
import '../core/widgets/gradient_button.dart';
import '../core/widgets/info_row.dart';
import '../core/widgets/page_header.dart';
import '../core/widgets/section_chip.dart';
import '../models/plant.dart';
import '../providers/current_plant_provider.dart';
import '../providers/active_plant_provider.dart'; // assumed day provider

class PlantsTab extends ConsumerWidget {
  const PlantsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Retrieve the list of mock plants – assume a provider exposing them.
    final List<Plant> plants = ref.watch(mockPlantsProvider);
    // Current selected plant
    final Plant? selectedPlant = ref.watch(currentPlantProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: PageHeader(
                sectionLabel: SectionChip(label: 'Chọn Giống Cây'),
                title: 'Chọn Giống Cây',
                subtitle:
                    'Chọn cây — hệ thống sẽ tự động điều chỉnh ánh sáng, nước và dinh dưỡng.',
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final plant = plants[index];
                    final bool isSelected = plant.id == selectedPlant?.id;
                    return PlantCard(
                      plant: plant,
                      isSelected: isSelected,
                      onSelect: () async {
                        if (isSelected) return; // already selected
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xác nhận thay đổi cây trồng'),
                            content: const Text(
                                'Cây hiện tại sẽ bị thay thế. Bạn có chắc muốn trồng cây mới không?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Xác nhận'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // Update the current plant and reset day counter.
                          ref.read(currentPlantProvider.notifier).state = plant;
                          // Reset day counter – assuming an ActivePlant provider exists.
                          ref.read(activePlantProvider.notifier).state =
                              ActivePlant(plant: plant, startDate: DateTime.now(), currentDay: 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã cập nhật cây trồng mới.')),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Private widget representing a single plant card.
class PlantCard extends StatelessWidget {
  final Plant plant;
  final bool isSelected;
  final VoidCallback onSelect;

  const PlantCard({
    Key? key,
    required this.plant,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Colors defined in the theme's AppColors (assumed).
    final Color tint = Color(int.parse(plant.tintColor));
    return AppCard(
      child: InkWell(
        onTap: onSelect,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Illustration area
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              alignment: Alignment.center,
              child: Text(
                plant.illustration,
                style: const TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 8),
            // Plant name & variety
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: Theme.of(context).textTheme.headline6?.copyWith(fontFamily: 'serif'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plant.variety,
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Meta row (duration & difficulty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text('${plant.durationWeeks} tuần'),
                  const SizedBox(width: 12),
                  const Icon(Icons.sprout, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(plant.difficulty),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Three small info rows
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.opacity,
                    text: '${plant.pumpMinutes} phút mỗi ${plant.pumpEveryMinutes} phút',
                  ),
                  InfoRow(
                    icon: Icons.local_florist,
                    text: '${plant.nutrientMl}ml mỗi ${plant.nutrientEveryDays} ngày',
                  ),
                  InfoRow(
                    icon: Icons.thermostat_outlined,
                    text: '${plant.tempMin}–${plant.tempMax}°C',
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Action button
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: isSelected
                  ? ElevatedButton.icon(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green[800],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('✓ Đang trồng'),
                    )
                  : GradientButton(
                      onPressed: onSelect,
                      label: 'Bắt Đầu Trồng',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
