import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/core/widgets/floating_pill_nav_bar.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';

void main() {
  testWidgets('shows an independent device tab at index 3', (tester) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          bottomNavigationBar: FloatingPillNavBar(
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Thiết bị'), findsOneWidget);
    expect(find.byIcon(Icons.devices_other_outlined), findsOneWidget);

    await tester.tap(find.text('Thiết bị'));

    expect(tappedIndex, 3);
  });
}
