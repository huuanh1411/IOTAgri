import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:iotagri_app/screens/subscription_screen.dart';

Widget _app() => const MaterialApp(
  locale: Locale('vi'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: SubscriptionScreen(),
);

void main() {
  testWidgets('shows demo plans and reveals plants after plan selection', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('Khởi đầu'), findsOneWidget);
    expect(find.text('Vườn nhà'), findsOneWidget);
    expect(find.text('Chuyên nghiệp'), findsOneWidget);
    expect(find.text('Xà lách'), findsNothing);

    await tester.tap(find.text('Vườn nhà'));
    await tester.pumpAndSettle();

    expect(find.text('Xà lách'), findsOneWidget);
    expect(find.text('Rau mùi'), findsOneWidget);
  });

  testWidgets('selects multiple plants and updates demo quantities', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Khởi đầu'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Xà lách'));
    await tester.tap(find.text('Xà lách'));
    await tester.ensureVisible(find.text('Húng quế'));
    await tester.tap(find.text('Húng quế'));
    await tester.pumpAndSettle();

    expect(find.text('Cây đã chọn'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('500 ml'), findsOneWidget);
  });

  testWidgets('opens a test QR and lets the user try non-transactional states', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Khởi đầu'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Mở QR minh họa'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Mở QR minh họa'));
    await tester.pumpAndSettle();

    expect(find.text('QR thử nghiệm. Không sử dụng để thanh toán thật.'), findsOneWidget);
    expect(find.text('Thành công (minh họa)'), findsOneWidget);
    await tester.tap(find.text('Thành công (minh họa)'));
    await tester.pumpAndSettle();
    expect(find.text('Thanh toán minh họa thành công — không có giao dịch thật'), findsOneWidget);
  });
}
