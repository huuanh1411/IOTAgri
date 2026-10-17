import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/data/mock_data.dart';
import 'package:iotagri_app/data/models.dart';
import 'package:iotagri_app/providers/data_providers.dart';

class _MemoryActivePlantStore implements ActivePlantStore {
  String? plantId;
  DateTime? startDate;

  @override
  Future<String?> readPlantId() async => plantId;

  @override
  Future<DateTime?> readStartDate() async => startDate;

  @override
  Future<void> write(ActivePlant activePlant) async {
    plantId = activePlant.plant.id;
    startDate = activePlant.startDate;
  }
}

void main() {
  final now = DateTime(2026, 10, 17, 14, 30);

  test('each plant replaces the active cycle with configured data', () async {
    final store = _MemoryActivePlantStore();
    final controller = ActivePlantController(store: store, now: () => now);

    for (final plant in mockPlants) {
      await controller.startGrowing(plant);
      expect(controller.state.plant, same(plant));
      expect(controller.state.startDate, now);
      expect(controller.state.currentDayAt(now), 0);
      expect(controller.state.progressAt(now), 1 / (plant.durationWeeks * 7));
      expect(store.plantId, plant.id);
      expect(store.startDate, now);
    }
  });

  test('restores the persisted plant and original growing date', () async {
    final store = _MemoryActivePlantStore()
      ..plantId = mockPlants[4].id
      ..startDate = DateTime(2026, 10, 10);

    final controller = ActivePlantController(store: store, now: () => now);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.plant, same(mockPlants[4]));
    expect(controller.state.startDate, DateTime(2026, 10, 10));
    expect(controller.state.currentDayAt(now), 7);
  });

  test('growth progress is capped at harvest and never becomes negative', () {
    final future = ActivePlant(
      plant: mockPlants.first,
      startDate: DateTime(2026, 10, 20),
    );
    final harvested = ActivePlant(
      plant: mockPlants.first,
      startDate: DateTime(2026, 1, 1),
    );

    expect(future.currentDayAt(now), 0);
    expect(harvested.progressAt(now), 1);
  });
}
