import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web startup keeps direct public policy URLs', () {
    final main = File('lib/main.dart').readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final router = File('lib/router.dart').readAsStringSync();

    expect(
      main,
      contains("import 'package:flutter_web_plugins/url_strategy.dart'"),
    );
    expect(main, contains('usePathUrlStrategy();'));
    expect(
      RegExp(r'flutter_web_plugins:\s+sdk: flutter').hasMatch(pubspec),
      isTrue,
    );
    expect(router, isNot(contains('overridePlatformDefaultLocation: true')));
  });
}
