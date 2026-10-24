import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/data/mock_data.dart';
import 'package:iotagri_app/data/models.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:iotagri_app/models/device_overview.dart';
import 'package:iotagri_app/providers/data_providers.dart';
import 'package:iotagri_app/providers/user_provider.dart';
import 'package:iotagri_app/screens/home_screen.dart';
import 'package:iotagri_app/screens/plant_picker_screen.dart';

class _MemoryActivePlantStore implements ActivePlantStore {
  ActivePlant? writtenPlant;

  @override
  Future<String?> readPlantId() async => null;

  @override
  Future<DateTime?> readStartDate() async => null;

  @override
  Future<void> write(ActivePlant activePlant) async {
    writtenPlant = activePlant;
  }
}

DeviceOverview _deviceWithReadings({
  required double water,
  required double tds,
  required double airTemperature,
  required double light,
  required double waterTemperature,
  required double humidity,
}) {
  return DeviceOverview.fromJson({
    'deviceId': 'device-1',
    'name': 'Aerogreen tower',
    'isOnline': true,
    'activeAlerts': const [],
    'latestReading': {
      'id': 'reading-1',
      'deviceId': 'device-1',
      'waterLevel': water,
      'tds': tds,
      'temperature': airTemperature,
      'lux': light,
      'solutionTemperature': waterTemperature,
      'humidity': humidity,
      'recordedAt': '2026-10-19T08:00:00Z',
    },
  });
}

void main() {
  for (final width in <double>[320, 360, 393, 430]) {
    testWidgets('plant cards fit at ${width.toInt()}px with larger text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = ActivePlantController(
        store: _MemoryActivePlantStore(),
        now: () => DateTime(2026, 10, 24, 8),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [currentPlantProvider.overrideWith((ref) => controller)],
          child: MaterialApp(
            locale: const Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: const PlantPickerScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      final startText = find.text('Bắt đầu trồng').first;
      expect(startText, findsOneWidget);
      expect(tester.widget<Text>(startText).textAlign, TextAlign.center);
    });
  }

  testWidgets('home sensor grid uses six equal-height responsive cells', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final readings = StreamController<List<DeviceOverview>>();
    addTearDown(readings.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardDevicesProvider.overrideWith((ref) => readings.stream),
          userProfileProvider.overrideWithValue(
            const UserProfile(
              fullName: 'Test',
              email: 'test@example.com',
              plan: 'Pro',
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );
    readings.add([
      _deviceWithReadings(
        water: 68,
        tds: 710,
        airTemperature: 23,
        light: 840,
        waterTemperature: 24,
        humidity: 62,
      ),
    ]);
    await tester.pump();

    final grid = tester.widget<GridView>(
      find.byKey(const ValueKey('home-sensor-grid')),
    );
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);
    expect(delegate.mainAxisExtent, 126);
    expect(grid.semanticChildCount, 6);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'start growing immediately selects the card without confirmation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final store = _MemoryActivePlantStore();
      final controller = ActivePlantController(
        store: store,
        now: () => DateTime(2026, 10, 19, 8),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [currentPlantProvider.overrideWith((ref) => controller)],
          child: const MaterialApp(
            locale: Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(0.8)),
              child: PlantPickerScreen(),
            ),
          ),
        ),
      );

      expect(find.text('Đang trồng'), findsOneWidget);
      expect(find.text('Xác nhận'), findsNothing);
      final currentButton = tester.widget<ElevatedButton>(
        find
            .ancestor(
              of: find.text('Đang trồng'),
              matching: find.byWidgetPredicate(
                (widget) => widget is ElevatedButton,
              ),
            )
            .first,
      );
      const disabledState = <WidgetState>{WidgetState.disabled};
      expect(
        currentButton.style?.backgroundColor?.resolve(disabledState),
        const Color(0xFFE3E5DF),
      );
      expect(
        currentButton.style?.foregroundColor?.resolve(disabledState),
        const Color(0xFF42614C),
      );

      await tester.tap(find.text('Bắt đầu trồng').first);
      await tester.pumpAndSettle();

      expect(find.text('Xác nhận'), findsNothing);
      expect(find.text('Đang trồng'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(controller.state.plant.id, mockPlants[1].id);
      expect(store.writtenPlant?.plant.id, mockPlants[1].id);
    },
  );

  testWidgets(
    'selected plant updates dashboard while live readings stay independent',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final readings = StreamController<List<DeviceOverview>>();
      addTearDown(readings.close);
      final controller = ActivePlantController(
        store: _MemoryActivePlantStore(),
        now: () => DateTime(2026, 10, 19, 8),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPlantProvider.overrideWith((ref) => controller),
            dashboardDevicesProvider.overrideWith((ref) => readings.stream),
            userProfileProvider.overrideWithValue(
              const UserProfile(
                fullName: 'Aerogreen User',
                email: 'user@example.com',
                plan: 'Pro',
              ),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(),
          ),
        ),
      );

      readings.add([
        _deviceWithReadings(
          water: 68,
          tds: 710,
          airTemperature: 23,
          light: 840,
          waterTemperature: 24,
          humidity: 62,
        ),
      ]);
      await tester.pump();

      expect(find.text('Xà lách'), findsWidgets);
      expect(find.textContaining('Butterhead'), findsOneWidget);
      expect(find.text('2 phút mỗi 15 phút'), findsOneWidget);
      expect(find.text('5 ml mỗi 3 ngày'), findsOneWidget);
      expect(find.text('18–22°C'), findsOneWidget);
      for (final reading in [
        '68%',
        '710ppm',
        '23°C',
        '840lux',
        '24°C',
        '62%',
      ]) {
        expect(find.text(reading), findsOneWidget);
      }

      await controller.startGrowing(mockPlants[1]);
      await tester.pump();

      expect(find.text('Húng quế'), findsWidgets);
      expect(find.textContaining('Genovese'), findsOneWidget);
      expect(find.text('3 phút mỗi 20 phút'), findsOneWidget);
      expect(find.text('7 ml mỗi 4 ngày'), findsOneWidget);
      expect(find.text('20–25°C'), findsOneWidget);
      for (final reading in [
        '68%',
        '710ppm',
        '23°C',
        '840lux',
        '24°C',
        '62%',
      ]) {
        expect(find.text(reading), findsOneWidget);
      }

      readings.add([
        _deviceWithReadings(
          water: 72,
          tds: 735,
          airTemperature: 25,
          light: 910,
          waterTemperature: 26,
          humidity: 65,
        ),
      ]);
      await tester.pump();

      expect(find.text('Húng quế'), findsWidgets);
      expect(find.textContaining('Genovese'), findsOneWidget);
      for (final reading in [
        '72%',
        '735ppm',
        '25°C',
        '910lux',
        '26°C',
        '65%',
      ]) {
        expect(find.text(reading), findsOneWidget);
      }
    },
  );
}
