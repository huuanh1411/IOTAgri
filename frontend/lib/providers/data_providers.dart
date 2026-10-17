// lib/providers/data_providers.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../models/device_overview.dart';
import '../repositories/plant_repository.dart';
import '../services/api_service.dart';

/// Persisted device readings used by the live gauge dashboard.
/// Errors stay visible to the UI; this provider deliberately has no mock fallback.
final dashboardDevicesProvider = StreamProvider<List<DeviceOverview>>((ref) {
  final api = ApiService();
  return (() async* {
    while (true) {
      final data = await api.getDashboardOverview();
      yield data
          .whereType<Map<String, dynamic>>()
          .map(DeviceOverview.fromJson)
          .toList(growable: false);
      await Future<void>.delayed(const Duration(seconds: 10));
    }
  })();
});

abstract class ActivePlantStore {
  Future<String?> readPlantId();
  Future<DateTime?> readStartDate();
  Future<void> write(ActivePlant activePlant);
}

class SharedPreferencesActivePlantStore implements ActivePlantStore {
  static const _plantIdKey = 'active_plant_id';
  static const _startDateKey = 'active_plant_start_date';

  @override
  Future<String?> readPlantId() async =>
      (await SharedPreferences.getInstance()).getString(_plantIdKey);

  @override
  Future<DateTime?> readStartDate() async {
    final value = (await SharedPreferences.getInstance()).getString(
      _startDateKey,
    );
    return value == null ? null : DateTime.tryParse(value);
  }

  @override
  Future<void> write(ActivePlant activePlant) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_plantIdKey, activePlant.plant.id);
    await preferences.setString(
      _startDateKey,
      activePlant.startDate.toIso8601String(),
    );
  }
}

class ActivePlantController extends StateNotifier<ActivePlant> {
  ActivePlantController({ActivePlantStore? store, DateTime Function()? now})
    : _store = store ?? SharedPreferencesActivePlantStore(),
      _now = now ?? DateTime.now,
      super(defaultActivePlant) {
    restored = _restore();
  }

  final ActivePlantStore _store;
  final DateTime Function() _now;
  late final Future<void> restored;

  Future<void> _restore() async {
    try {
      final plantId = await _store.readPlantId();
      final startDate = await _store.readStartDate();
      if (plantId == null || startDate == null) return;
      final plant = mockPlants.where((item) => item.id == plantId).firstOrNull;
      if (plant != null) {
        state = ActivePlant(plant: plant, startDate: startDate);
      }
    } catch (_) {
      // Keep the existing default when local persistence is unavailable.
    }
  }

  Future<void> startGrowing(Plant plant) async {
    await restored;
    final activePlant = ActivePlant(plant: plant, startDate: _now());
    await _store.write(activePlant);
    state = activePlant;
  }
}

// Single source of truth shared by Plant Selection and Home Dashboard.
final currentPlantProvider =
    StateNotifierProvider<ActivePlantController, ActivePlant>((ref) {
      return ActivePlantController();
    });

// Stream of sensor readings that fetch from the backend API every few seconds.
final sensorStreamProvider = StreamProvider<SensorReading>((ref) {
  final repo = ref.read(plantRepositoryProvider);
  // Emit the initial reading (fallback to mock default).
  return Stream.periodic(const Duration(seconds: 3)).asyncMap((_) async {
    try {
      return await repo.getLatestSensor();
    } catch (e) {
      // If the backend call fails, fall back to the mock default reading.
      return defaultSensorReading;
    }
  });
});

// List of alerts generated from the latest sensor reading.
final alertsProvider = Provider<List<AppAlert>>((ref) {
  final sensor = ref.watch(sensorStreamProvider).valueOrNull ?? defaultSensorReading;
  final List<AppAlert> alerts = [];
  if (sensor.waterLevel < 30) {
    alerts.add(const AppAlert(
      id: 'water_low',
      title: 'Nước thấp',
      message: 'Nước mức đang dưới 30% – cần nạp thêm nước.',
      actionLabel: 'Nạp nước',
      type: 'warning',
    ));
  }
  if (sensor.nutrientLevel < 45) {
    alerts.add(const AppAlert(
      id: 'nutrient_low',
      title: 'Dinh dưỡng thấp',
      message: 'Mức dinh dưỡng dưới 45% – cần bón thêm.',
      actionLabel: 'Bổ dinh dưỡng',
      type: 'warning',
    ));
  }
  return alerts;
});

// Control mode (smart or manual).
final controlModeProvider = StateProvider<String>((ref) => 'smart'); // could be an enum later

// Provider to track pump running state.
final pumpRunningProvider = StateProvider<bool>((ref) => false);

// Provider for nutrient spray duration (seconds).
final nutrientDurationProvider = StateProvider<double>((ref) => 30.0);
