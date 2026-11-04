import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/services/session_timeout_manager.dart';

String _accessToken({required DateTime expiry}) {
  final payload = base64UrlEncode(
    utf8.encode(
      jsonEncode({
        'exp': expiry.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond,
      }),
    ),
  ).replaceAll('=', '');
  return 'header.$payload.signature';
}

class _TokenStorage extends FlutterSecureStorage {
  final String token;

  const _TokenStorage(this.token);

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => key == 'access_token' ? token : null;

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'mobile mode leaves an expired access token to refresh-token recovery',
    () async {
      var expired = false;
      final manager = SessionTimeoutManager(
        storage: _TokenStorage(
          _accessToken(
            expiry: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
        ),
        enforceSessionTimeout: false,
        onRefreshToken: () async {},
        onSessionExpired: () => expired = true,
        onSessionWarning: () {},
      );

      await manager.initialize();

      expect(expired, isFalse);
      expect(manager.getTimeUntilExpiry(), isNull);
      manager.dispose();
    },
  );

  test('web mode retains expiry enforcement', () async {
    var expired = false;
    final manager = SessionTimeoutManager(
      storage: _TokenStorage(
        _accessToken(
          expiry: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ),
      enforceSessionTimeout: true,
      onRefreshToken: () async {},
      onSessionExpired: () => expired = true,
      onSessionWarning: () {},
    );

    await manager.initialize();

    expect(expired, isTrue);
    manager.dispose();
  });
}
