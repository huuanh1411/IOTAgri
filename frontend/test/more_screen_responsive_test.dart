import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/core/widgets/floating_pill_nav_bar.dart';
import 'package:iotagri_app/core/widgets/outline_danger_button.dart';
import 'package:iotagri_app/data/models.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:iotagri_app/providers/user_provider.dart';
import 'package:iotagri_app/screens/more_screen.dart';

Widget _buildMoreScreenInShell({
  Locale locale = const Locale('vi'),
  double textScaleFactor = 1.0,
}) {
  return ProviderScope(
    overrides: [
      userProfileProvider.overrideWithValue(
        const UserProfile(
          fullName: 'Nguyễn Văn A',
          email: 'test@example.com',
          plan: 'Pro',
        ),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            child: Scaffold(
              body: const MoreScreen(),
              bottomNavigationBar: FloatingPillNavBar(
                currentIndex: 4,
                onTap: (_) {},
              ),
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  testWidgets('MoreScreen in shell at 320x568 allows finding and tapping Logout via scrollUntilVisible (F-02 1)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildMoreScreenInShell());
    await tester.pumpAndSettle();

    final logoutButton = find.byType(OutlineDangerButton);
    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(logoutButton, 50, scrollable: scrollable);
    await tester.pumpAndSettle();

    expect(logoutButton, findsOneWidget);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Bạn có chắc muốn đăng xuất?'), findsOneWidget);
  });

  for (final scale in [1.5, 2.0]) {
    testWidgets('MoreScreen at 320x568 with textScaleFactor $scale allows scrolling to Logout (F-02 3)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildMoreScreenInShell(textScaleFactor: scale));
      await tester.pumpAndSettle();

      final logoutButton = find.byType(OutlineDangerButton);
      final scrollable = find.byType(Scrollable).first;

      await tester.scrollUntilVisible(logoutButton, 50, scrollable: scrollable);
      await tester.pumpAndSettle();

      expect(logoutButton, findsOneWidget);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  }

  testWidgets('MoreScreen at 568x320 landscape allows scrolling to Logout (F-02 3)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(568, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildMoreScreenInShell());
    await tester.pumpAndSettle();

    final logoutButton = find.byType(OutlineDangerButton);
    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(logoutButton, 50, scrollable: scrollable);
    await tester.pumpAndSettle();

    expect(logoutButton, findsOneWidget);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('MoreScreen at 390x844 allows finding and tapping Logout (F-02 4)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildMoreScreenInShell());
    await tester.pumpAndSettle();

    final logoutButton = find.byType(OutlineDangerButton);
    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(logoutButton, 50, scrollable: scrollable);
    await tester.pumpAndSettle();

    expect(logoutButton, findsOneWidget);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('MoreScreen at 1280x900 remains centered and width-constrained (F-02 4)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildMoreScreenInShell());
    await tester.pumpAndSettle();

    final logoutButton = find.byType(OutlineDangerButton);
    expect(logoutButton, findsOneWidget);

    final renderBox = tester.renderObject<RenderBox>(logoutButton);
    // On a 1280px screen, width should be constrained (e.g. <= 640), not stretched to full width
    expect(renderBox.size.width, lessThan(700));

    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
