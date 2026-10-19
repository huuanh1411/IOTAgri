import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/core/widgets/page_header.dart';

Widget _headerAtWidth(double width) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: const PageHeader(
            eyebrow: 'Greeting',
            title: 'Page title',
            subtitle: 'A descriptive subtitle that can wrap naturally.',
            trailingAction: SizedBox(
              width: 44,
              height: 44,
              child: IconButton(onPressed: null, icon: Icon(Icons.add)),
            ),
            bottomContent: Text('Filters'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('page header renders all supported content at desktop width', (
    tester,
  ) async {
    await tester.pumpWidget(_headerAtWidth(720));

    expect(find.text('Greeting'), findsOneWidget);
    expect(find.text('Page title'), findsOneWidget);
    expect(
      find.text('A descriptive subtitle that can wrap naturally.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Filters'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('page header avoids overflow at mobile width', (tester) async {
    await tester.pumpWidget(_headerAtWidth(280));

    expect(find.text('Page title'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
