import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iotagri_app/data/models.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:iotagri_app/providers/app_settings_provider.dart';
import 'package:iotagri_app/providers/user_provider.dart';
import 'package:iotagri_app/screens/home_screen.dart';

Widget _buildHomeWithSettings({
  required AppSettingsProvider settingsProvider,
  String userFullName = 'UI',
  DateTime? fixedClock,
}) {
  return provider.ChangeNotifierProvider<AppSettingsProvider>.value(
    value: settingsProvider,
    child: ProviderScope(
      overrides: [
        userProfileProvider.overrideWithValue(
          UserProfile(
            fullName: userFullName,
            email: 'ui@example.com',
            plan: 'Pro',
          ),
        ),
      ],
      child: provider.Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(
              body: HomeScreen(fixedClock: fixedClock),
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home displays Vietnamese greeting and parameterized garden title (F-03 1 & 2)', (
    tester,
  ) async {
    final settings = AppSettingsProvider();
    // Morning in Vietnam
    final morningClock = DateTime(2026, 10, 19, 8, 30);

    await tester.pumpWidget(
      _buildHomeWithSettings(
        settingsProvider: settings,
        userFullName: 'UI',
        fixedClock: morningClock,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chào buổi sáng'), findsOneWidget);
    expect(find.text('Vườn của UI'), findsOneWidget);
  });

  testWidgets('Language switch from vi to en updates Home immediately without restart (F-03 3)', (
    tester,
  ) async {
    final settings = AppSettingsProvider();
    final morningClock = DateTime(2026, 10, 19, 8, 30);

    await tester.pumpWidget(
      _buildHomeWithSettings(
        settingsProvider: settings,
        userFullName: 'UI',
        fixedClock: morningClock,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chào buổi sáng'), findsOneWidget);
    expect(find.text('Vườn của UI'), findsOneWidget);

    // Switch to English
    await settings.setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text("UI's Garden"), findsOneWidget);
    expect(find.text('Chào buổi sáng'), findsNothing);
    expect(find.text('Vườn của UI'), findsNothing);

    // Switch back to Vietnamese
    await settings.setLocale(const Locale('vi'));
    await tester.pumpAndSettle();

    expect(find.text('Chào buổi sáng'), findsOneWidget);
    expect(find.text('Vườn của UI'), findsOneWidget);
  });

  testWidgets('Handles names ending in s and empty names gracefully (F-03 2)', (
    tester,
  ) async {
    final settings = AppSettingsProvider();
    await settings.setLocale(const Locale('en'));

    // Name ending in s: James -> James' Garden
    await tester.pumpWidget(
      _buildHomeWithSettings(
        settingsProvider: settings,
        userFullName: 'James Bond',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("James' Garden"), findsOneWidget);

    // Empty name: fallback to gardenTitle ("Your garden" in en)
    await tester.pumpWidget(
      _buildHomeWithSettings(
        settingsProvider: settings,
        userFullName: '   ',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your garden'), findsOneWidget);

    // Empty name in Vietnamese: "Vườn của bạn"
    await settings.setLocale(const Locale('vi'));
    await tester.pumpAndSettle();

    expect(find.text('Vườn của bạn'), findsOneWidget);
  });

  testWidgets('Time-of-day greetings work properly across hours (F-03 2)', (
    tester,
  ) async {
    final settings = AppSettingsProvider();
    await settings.setLocale(const Locale('en'));

    final hoursAndExpected = <int, String>{
      8: 'Good morning',
      14: 'Good afternoon',
      19: 'Good evening',
      23: 'Good night',
    };

    for (final entry in hoursAndExpected.entries) {
      final clock = DateTime(2026, 10, 19, entry.key, 0);
      await tester.pumpWidget(
        _buildHomeWithSettings(
          settingsProvider: settings,
          fixedClock: clock,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  test('Language selection persists via SharedPreferences across restart (F-03 3)', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettingsProvider();
    await settings.setLocale(const Locale('en'));

    // Simulate restart with a new AppSettingsProvider instance
    final restartedSettings = AppSettingsProvider();
    // Allow asynchronous _loadSettings to complete
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(restartedSettings.locale.languageCode, 'en');
  });
}
