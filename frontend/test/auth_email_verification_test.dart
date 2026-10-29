import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/models/user.dart';
import 'package:iotagri_app/providers/auth_provider.dart';
import 'package:iotagri_app/screens/auth/login_screen.dart';
import 'package:iotagri_app/screens/auth/register_screen.dart';
import 'package:iotagri_app/screens/auth/verify_email_screen.dart';
import 'package:iotagri_app/screens/auth_screen.dart';
import 'package:iotagri_app/services/api_service.dart';
import 'package:provider/provider.dart';

class _RegistrationApiService extends ApiService {
  var loginCalls = 0;
  var verifyCalls = 0;
  var resendCalls = 0;
  String? verifiedCode;
  Future<void> Function()? onVerify;

  bool verificationSucceeds = true;

  @override
  Future<User?> restoreSession() async => null;

  @override
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName,
  ) async => {'email': email};

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    loginCalls++;
    return {'accessToken': 'token'};
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    verifyCalls++;
    verifiedCode = code;
    await onVerify?.call();
    if (!verificationSucceeds) {
      throw Exception('Mã xác minh không hợp lệ.');
    }
  }

  @override
  Future<void> resendVerificationCode(String email) async {
    resendCalls++;
  }

  @override
  User? userFromAccessToken(String token) => User(
    id: 'user-1',
    email: 'qa@example.test',
    fullName: 'QA',
    role: 'user',
  );
}

Widget _verificationApp(_RegistrationApiService api) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(apiService: api),
    child: const MaterialApp(home: VerifyEmailScreen(email: 'qa@example.test')),
  );
}

Widget _verificationAppWithCanonicalAuth(_RegistrationApiService api) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(apiService: api),
    child: const ProviderScope(
      child: MaterialApp(home: VerifyEmailScreen(email: 'qa@example.test')),
    ),
  );
}

Widget _registerApp(_RegistrationApiService api) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(apiService: api),
    child: const MaterialApp(home: RegisterScreen()),
  );
}

class _RouteScopedVerificationApp extends StatefulWidget {
  const _RouteScopedVerificationApp({required this.api});

  final _RegistrationApiService api;

  @override
  State<_RouteScopedVerificationApp> createState() =>
      _RouteScopedVerificationAppState();
}

class _RouteScopedVerificationAppState
    extends State<_RouteScopedVerificationApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => AuthProvider(apiService: widget.api),
            child: const VerifyEmailScreen(email: 'qa@example.test'),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const LoginScreen();
}

void main() {
  test(
    'register does not create a session before email confirmation',
    () async {
      final api = _RegistrationApiService();
      final provider = AuthProvider(apiService: api);
      addTearDown(provider.dispose);

      final success = await provider.register(
        'qa@example.test',
        'QaPassword1!',
        'QA',
      );

      expect(success, isTrue);
      expect(api.loginCalls, isZero);
      expect(provider.isAuthenticated, isFalse);
    },
  );

  testWidgets('verification submits six-digit code and returns to login', (
    tester,
  ) async {
    final api = _RegistrationApiService();
    await tester.pumpWidget(_verificationAppWithCanonicalAuth(api));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Xác Minh'));
    await tester.pumpAndSettle();

    expect(api.verifyCalls, 1);
    expect(api.verifiedCode, '123456');
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'registration replaces register screen with verification screen',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final api = _RegistrationApiService();
      await tester.pumpWidget(_registerApp(api));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'QA Tester');
      await tester.enterText(fields.at(1), 'qa@example.test');
      await tester.enterText(fields.at(2), 'QaPassword1!');
      await tester.enterText(fields.at(3), 'QaPassword1!');
      await tester.tap(
        find.ancestor(
          of: find.text('Đăng Ký').first,
          matching: find.byType(ElevatedButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      expect(find.byType(RegisterScreen), findsNothing);
    },
  );

  testWidgets('verification return route retains an AuthProvider', (
    tester,
  ) async {
    final api = _RegistrationApiService();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(apiService: api),
        child: ProviderScope(
          child: MaterialApp(home: _RouteScopedVerificationApp(api: api)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Xác Minh'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('verification requires exactly six digits', (tester) async {
    final api = _RegistrationApiService();
    await tester.pumpWidget(_verificationApp(api));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '12345');
    await tester.tap(find.text('Xác Minh'));
    await tester.pumpAndSettle();

    expect(api.verifyCalls, isZero);
    expect(find.text('Vui lòng nhập mã xác minh gồm 6 chữ số'), findsOneWidget);
  });

  testWidgets('field submission does not verify while request is loading', (
    tester,
  ) async {
    final api = _RegistrationApiService();
    final verification = Completer<void>();
    api.onVerify = () => verification.future;
    await tester.pumpWidget(_verificationApp(api));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Xác Minh'));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(api.verifyCalls, 1);
    verification.complete();
  });

  testWidgets('verification shows provider error and resends code', (
    tester,
  ) async {
    final api = _RegistrationApiService()..verificationSucceeds = false;
    await tester.pumpWidget(_verificationApp(api));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Xác Minh'));
    await tester.pumpAndSettle();

    expect(find.text('Mã xác minh không hợp lệ.'), findsOneWidget);

    await tester.tap(find.text('Gửi lại mã'));
    await tester.pump();

    expect(api.resendCalls, 1);
  });
}
