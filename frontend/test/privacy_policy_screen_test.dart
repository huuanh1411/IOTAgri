import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:iotagri_app/screens/privacy_policy_screen.dart';

Widget _app(Locale locale) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const PrivacyPolicyScreen(),
);

void main() {
  testWidgets('shows English privacy policy', (tester) async {
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.text('Data we collect'), findsOneWidget);
    expect(find.textContaining('xteam.aerogreen@gmail.com'), findsOneWidget);
  });

  testWidgets('shows Vietnamese privacy policy', (tester) async {
    await tester.pumpWidget(_app(const Locale('vi')));
    await tester.pumpAndSettle();

    expect(find.text('Chính sách quyền riêng tư'), findsWidgets);
    expect(find.text('Dữ liệu chúng tôi thu thập'), findsOneWidget);
    expect(find.textContaining('xteam.aerogreen@gmail.com'), findsOneWidget);
  });
}
