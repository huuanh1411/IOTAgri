import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/cupertino/devices/cupertino_device_detail_screen.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';

/// Flushes immediate API futures and completes device-detail entrance motion
/// without advancing fake time far enough to trigger its 20-second refresh.
Future<void> pumpDeviceDetail(WidgetTester tester) async {
  await tester.pump();
  for (var frame = 0; frame < 10; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Scrolls the lazily built detail content until the real pump controls exist.
Future<void> scrollToPumpControl(WidgetTester tester) async {
  final detailScrollable = find.descendant(
    of: find.byType(CustomScrollView),
    matching: find.byType(Scrollable),
  );
  await tester.scrollUntilVisible(
    find.byType(PumpControlCard),
    400,
    scrollable: detailScrollable.first,
  );
  await pumpDeviceDetail(tester);
}

Widget buildLocalizedCupertinoApp({required Widget home}) => CupertinoApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('vi'),
  home: home,
);

Widget buildLocalizedMaterialApp({required Widget home}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('vi'),
  home: home,
);
