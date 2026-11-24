import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:iotagri_app/screens/subscription_screen.dart';

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('vi'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: child,
);

void main() {
  const plan = SubscriptionPlan(
    id: 'plan-1',
    name: 'Pro',
    description: 'Gói từ Backend',
    benefits: ['Quyền lợi từ Backend'],
    formattedPrice: '100.000 đ',
  );

  testWidgets(
    'selects multiple plants and updates one-tower-per-plant summary',
    (tester) async {
      await tester.pumpWidget(_app(const SubscriptionScreen(plans: [plan])));

      await tester.tap(find.text('Pro'));
      await tester.tap(find.text('Xà lách'));
      await tester.tap(find.text('Húng quế'));
      await tester.pump();

      expect(find.text('Cây đã chọn: 2'), findsOneWidget);
      expect(find.text('Tháp trồng: 2'), findsOneWidget);
    },
  );

  testWidgets('shows waiting state instead of making a QR code', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const SubscriptionScreen(plans: [plan])));
    await tester.tap(find.byType(Radio<String>));
    await tester.pump();
    final continueButton = find.byType(FilledButton);
    await tester.scrollUntilVisible(
      continueButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Đang chờ thông tin thanh toán'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
