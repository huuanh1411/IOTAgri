import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/cupertino/widgets/global_offline_banner.dart';
import 'package:iotagri_app/providers/app_settings_provider.dart';
import 'package:iotagri_app/services/connectivity_service.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 12: Global OfflineBanner Tests', () {
    testWidgets('Offline banner displays when connectivity is offline', (tester) async {
      final connectivity = ConnectivityService();
      connectivity.setOfflineForTesting(true);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityService>.value(
          value: connectivity,
          child: CupertinoApp(
            locale: const Locale('vi'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: GlobalOfflineBanner(
              child: CupertinoPageScaffold(
                child: Center(child: Text('Main Content')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsOneWidget);
      expect(
        find.text('Bạn đang offline. Hiển thị dữ liệu gần nhất.'),
        findsOneWidget,
      );
      expect(find.byIcon(CupertinoIcons.wifi_slash), findsOneWidget);
    });

    testWidgets('Offline banner is hidden when online', (tester) async {
      final connectivity = ConnectivityService();
      connectivity.setOfflineForTesting(false);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityService>.value(
          value: connectivity,
          child: CupertinoApp(
            locale: const Locale('vi'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: GlobalOfflineBanner(
              child: CupertinoPageScaffold(
                child: Center(child: Text('Main Content')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsOneWidget);
      expect(
        find.text('Bạn đang offline. Hiển thị dữ liệu gần nhất.'),
        findsNothing,
      );
    });
  });

  group('Generated localization and persistence', () {
    testWidgets('locale change rebuilds the whole localized app immediately', (tester) async {
      final settings = AppSettingsProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppSettingsProvider>.value(
          value: settings,
          child: Consumer<AppSettingsProvider>(
            builder: (context, currentSettings, _) => CupertinoApp(
              locale: currentSettings.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: Builder(
                builder: (context) => CupertinoPageScaffold(
                  child: Center(
                    child: Text(AppLocalizations.of(context)!.settings),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cài đặt'), findsOneWidget);

      await settings.setLocale(const Locale('en'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    test('locale survives a new settings provider instance', () async {
      final first = AppSettingsProvider();
      await first.setLocale(const Locale('en'));

      final restored = AppSettingsProvider();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(restored.locale, const Locale('en'));
    });
  });

  group('Phase 12: Accessibility and Scaling Audit', () {
    testWidgets('Text scaling at 1.5x does not cause overflow on banner', (tester) async {
      final connectivity = ConnectivityService();
      connectivity.setOfflineForTesting(true);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityService>.value(
          value: connectivity,
          child: CupertinoApp(
            locale: const Locale('vi'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
              child: GlobalOfflineBanner(
                child: CupertinoPageScaffold(
                  child: Center(child: Text('Content')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Bạn đang offline. Hiển thị dữ liệu gần nhất.'), findsOneWidget);
    });

    testWidgets('Offline banner includes Semantics label for screen readers', (tester) async {
      final connectivity = ConnectivityService();
      connectivity.setOfflineForTesting(true);

      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityService>.value(
          value: connectivity,
          child: CupertinoApp(
            locale: const Locale('vi'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: GlobalOfflineBanner(
              child: CupertinoPageScaffold(child: SizedBox()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label ==
                'Cảnh báo mất kết nối mạng. Bạn đang offline. Hiển thị dữ liệu gần nhất.',
      );
      expect(semantics, findsOneWidget);
    });
  });
}
