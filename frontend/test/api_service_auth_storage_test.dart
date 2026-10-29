import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iotagri_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _UnavailableSecureStorage extends FlutterSecureStorage {
  const _UnavailableSecureStorage();

  Never _unavailable() => throw StateError('Web Crypto is unavailable');

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _unavailable();

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
  }) async => _unavailable();

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _unavailable();
}

String _accessToken({int expiresInHours = 1}) {
  final payload = base64UrlEncode(
    utf8.encode(
      jsonEncode({
        'sub': 'user-1',
        'email': 'user@example.com',
        'fullName': 'Test User',
        'exp':
            DateTime.now()
                .add(Duration(hours: expiresInHours))
                .millisecondsSinceEpoch ~/
            1000,
      }),
    ),
  ).replaceAll('=', '');
  return 'header.$payload.signature';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'login falls back when secure storage is unavailable on LAN web',
    () async {
      final token = _accessToken();
      final service = ApiService(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'accessToken': token, 'refreshToken': 'refresh-1'}),
            200,
          ),
        ),
        storage: const _UnavailableSecureStorage(),
        allowWebStorageFallback: true,
      );

      final result = await service.login('user@example.com', 'Password123');
      final restored = await service.restoreSession();

      expect(result['accessToken'], token);
      expect(restored?.id, 'user-1');
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('iotagri.auth.access_token'), token);
      expect(preferences.getString('iotagri.auth.refresh_token'), 'refresh-1');
    },
  );

  test('login preserves email-verification-required response', () async {
    final service = ApiService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'error': 'Email verification is required.'}),
          403,
        ),
      ),
    );

    await expectLater(
      service.login('user@example.com', 'Password123'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Email verification is required.'),
        ),
      ),
    );
  });

  test('register accepts the backend 201 response', () async {
    final service = ApiService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'id': 'user-1',
            'email': 'user@example.com',
            'fullName': 'Test User',
          }),
          201,
        ),
      ),
    );

    final result = await service.register(
      'user@example.com',
      'Password123',
      'Test User',
    );

    expect(result['id'], 'user-1');
  });

  test('verify email posts expected path and JSON payload on 204', () async {
    late http.Request request;
    final service = ApiService(
      client: MockClient((received) async {
        request = received;
        return http.Response('', 204);
      }),
    );

    await service.verifyEmail('user@example.com', '123456');

    expect(request.method, 'POST');
    expect(request.url.path, '/api/auth/verify-email');
    expect(jsonDecode(request.body), {
      'email': 'user@example.com',
      'code': '123456',
    });
  });

  test(
    'resend verification posts expected path and JSON payload on 202',
    () async {
      late http.Request request;
      final service = ApiService(
        client: MockClient((received) async {
          request = received;
          return http.Response('', 202);
        }),
      );

      await service.resendVerificationCode('user@example.com');

      expect(request.method, 'POST');
      expect(request.url.path, '/api/auth/resend-verification-code');
      expect(jsonDecode(request.body), {'email': 'user@example.com'});
    },
  );

  test('verification endpoints reject unexpected response statuses', () async {
    final service = ApiService(
      client: MockClient((_) async => http.Response('', 400)),
    );

    await expectLater(
      service.verifyEmail('user@example.com', '123456'),
      throwsA(isA<Exception>()),
    );
    await expectLater(
      service.resendVerificationCode('user@example.com'),
      throwsA(isA<Exception>()),
    );
  });

  test('refresh accepts 200 and retries an authenticated request', () async {
    SharedPreferences.setMockInitialValues({
      'iotagri.auth.access_token': _accessToken(expiresInHours: -1),
      'iotagri.auth.refresh_token': 'refresh-1',
    });
    var deviceRequests = 0;
    final service = ApiService(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/api/auth/refresh')) {
          return http.Response(
            jsonEncode({
              'accessToken': _accessToken(),
              'refreshToken': 'refresh-2',
            }),
            200,
          );
        }
        deviceRequests++;
        return deviceRequests == 1
            ? http.Response('', 401)
            : http.Response('[]', 200);
      }),
      storage: const _UnavailableSecureStorage(),
      allowWebStorageFallback: true,
    );

    expect(await service.getDevices(), isEmpty);
    expect(deviceRequests, 2);
  });
}
