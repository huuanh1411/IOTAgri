import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web server falls back to Flutter entrypoint for public routes', () {
    final config = File('nginx.conf').readAsStringSync();

    expect(config, contains(r'try_files $uri $uri/ /index.html;'));
  });
}
