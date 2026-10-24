import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/screens/sensor_detail_screen.dart';

import 'test_app.dart';

void main() {
  Widget buildPanel(double waterLevel) => buildLocalizedMaterialApp(
    home: Scaffold(body: WaterPumpControlPanel(waterLevel: waterLevel)),
  );

  testWidgets('toggles the manual pump state locally', (tester) async {
    await tester.pumpWidget(buildPanel(65));

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(find.text('Bơm đang bật'), findsOneWidget);
    expect(find.text('Chỉ mô phỏng trên giao diện frontend'), findsOneWidget);
  });

  testWidgets('blocks starting the pump when water is below 30 percent', (
    tester,
  ) async {
    await tester.pumpWidget(buildPanel(20));

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(find.text('Bơm đang tắt'), findsOneWidget);
    expect(find.text('Không thể bật bơm khi mực nước thấp.'), findsOneWidget);
  });

  testWidgets('shows the full Vietnam-time schedule form locally', (
    tester,
  ) async {
    await tester.pumpWidget(buildPanel(65));

    await tester.tap(find.text('Thêm lịch'));
    await tester.pumpAndSettle();

    expect(find.text('Thời gian phun (giây)'), findsOneWidget);
    expect(find.text('Khoảng cách (phút)'), findsOneWidget);
    expect(find.text('Khung giờ hoạt động'), findsOneWidget);
    expect(find.text('Múi giờ'), findsOneWidget);
    expect(find.text('Việt Nam · GMT+07:00'), findsOneWidget);
  });

  for (final width in <double>[320, 340, 360, 393, 430]) {
    testWidgets('schedule action fits at ${width.toInt()}px with larger text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: buildPanel(65),
        ),
      );

      expect(find.text('Thêm lịch'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
