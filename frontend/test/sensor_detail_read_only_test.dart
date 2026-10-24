import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/providers/data_providers.dart';
import 'package:iotagri_app/screens/sensor_detail_screen.dart';

import 'test_app.dart';

void main() {
  for (final width in <double>[320, 1024]) {
    for (final metric in <String>['water', 'light']) {
      testWidgets('$metric detail is chart-only at ${width.toInt()}px', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              dashboardDevicesProvider.overrideWith(
                (ref) => Stream.value(const []),
              ),
            ],
            child: buildLocalizedMaterialApp(
              home: SensorDetailScreen(metric: metric),
            ),
          ),
        );
        await tester.pump();

        expect(
          find.byKey(const ValueKey('sensor-history-card')),
          findsOneWidget,
        );
        expect(find.byType(WaterPumpControlPanel), findsNothing);
        expect(find.byType(LightControlPanel), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
