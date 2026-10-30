import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web startup uses path URLs for direct public policy links', () {
    final main = File('lib/main.dart').readAsStringSync();

    expect(
      main,
      contains("import 'package:flutter_web_plugins/url_strategy.dart'"),
    );
    expect(main, contains('usePathUrlStrategy();'));
  });
}
