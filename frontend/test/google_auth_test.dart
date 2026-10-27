import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iotagri_app/data/models/user.dart';
import 'package:iotagri_app/data/repositories/auth_repository.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:iotagri_app/providers/auth_controller.dart';
import 'package:iotagri_app/screens/auth_screen.dart';
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

String _accessToken() {
  final payload = base64UrlEncode(
    utf8.encode(
      jsonEncode({
        'sub': 'google-user-1',
        'email': 'google@example.com',
        'fullName': 'Google User',
        'exp':
            DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      }),
    ),
  ).replaceAll('=', '');
  return 'header.$payload.signature';
}

class _CancelledGoogleAuthRepository extends AuthRepository {
  var googleLoginCalls = 0;

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User?> loginWithGoogle() async {
    googleLoginCalls++;
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'Google sign-in exchanges ID token with API and stores returned IOTAgri tokens',
    () async {
      late http.Request request;
      final token = _accessToken();
      final service = ApiService(
        client: MockClient((received) async {
          request = received;
          return http.Response(
            jsonEncode({'accessToken': token, 'refreshToken': 'refresh-1'}),
            200,
          );
        }),
        storage: const _UnavailableSecureStorage(),
        allowWebStorageFallback: true,
      );

      final result = await service.loginWithGoogleIdToken('google-id-token');
      final restored = await service.restoreSession();

      expect(request.method, 'POST');
      expect(request.url.path, '/api/auth/google');
      expect(jsonDecode(request.body), {'idToken': 'google-id-token'});
      expect(result['accessToken'], token);
      expect(restored?.email, 'google@example.com');
    },
  );

  testWidgets(
    'existing Google button delegates cancellation to auth provider without error',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = _CancelledGoogleAuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const AuthScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Google'));
      await tester.pumpAndSettle();

      expect(repository.googleLoginCalls, 1);
      expect(
        find.text('Tính năng đăng nhập mạng xã hội chưa khả dụng.'),
        findsNothing,
      );
    },
  );
}
