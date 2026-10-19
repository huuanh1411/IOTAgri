import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:iotagri_app/core/widgets/gradient_button.dart';
import 'package:iotagri_app/data/models/user.dart';
import 'package:iotagri_app/data/repositories/auth_repository.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:iotagri_app/providers/auth_controller.dart';
import 'package:iotagri_app/screens/auth_screen.dart';

class _RejectedAuthRepository extends AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> login({required String email, required String password}) async {
    throw Exception('Email hoặc mật khẩu không đúng.');
  }
}

class _Http401AuthRepository extends AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> login({required String email, required String password}) async {
    throw Exception('Login failed: 401 Unauthorized');
  }
}

class _NetworkFailureAuthRepository extends AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> login({required String email, required String password}) async {
    throw const SocketException('Failed host lookup: api.iotagri.internal');
  }
}

class _ClientExceptionAuthRepository extends AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> login({required String email, required String password}) async {
    throw http.ClientException('Connection refused');
  }
}

class _FlakyAuthRepository extends AuthRepository {
  int attempts = 0;
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> login({required String email, required String password}) async {
    attempts++;
    if (attempts == 1) {
      throw Exception('Login failed: 401 Unauthorized');
    }
    return const User(
      id: 'user-1',
      fullName: 'Aerogreen Tester',
      email: 'test@example.com',
      role: 'user',
      plan: 'Pro',
    );
  }
}

class _FailingRegisterAuthRepository extends AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    throw Exception('Login failed: 401 Unauthorized');
  }
}

Widget _buildAuthScreen(AuthRepository repo, {Locale locale = const Locale('vi')}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AuthScreen(),
    ),
  );
}

void main() {
  testWidgets('shows a clear inline message for invalid credentials', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildAuthScreen(_RejectedAuthRepository()));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'sai@example.com');
    await tester.enterText(fields.at(1), 'mat-khau-sai');
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-error-message')), findsOneWidget);
    expect(find.text('Email hoặc mật khẩu không đúng.'), findsOneWidget);
    expect(find.textContaining('Exception:'), findsNothing);
  });

  testWidgets('HTTP 401 shows localized error message and stays on login screen (F-01 1a)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildAuthScreen(_Http401AuthRepository()));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'wrong@example.com');
    await tester.enterText(fields.at(1), 'wrongpass');
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();

    // User stays on login screen
    expect(find.byType(AuthScreen), findsOneWidget);
    // Localized message appears (not raw exception text)
    expect(find.text('Email hoặc mật khẩu không đúng.'), findsAtLeastNWidgets(1));
    expect(find.textContaining('401 Unauthorized'), findsNothing);
    expect(find.textContaining('Exception:'), findsNothing);
  });

  testWidgets('HTTP 401 in English locale shows localized English error message', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildAuthScreen(_Http401AuthRepository(), locale: const Locale('en')));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'wrong@example.com');
    await tester.enterText(fields.at(1), 'wrongpass');
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password.'), findsAtLeastNWidgets(1));
    expect(find.textContaining('401'), findsNothing);
  });

  testWidgets('Network failure (SocketException) shows distinct connection problem message (F-01 1b)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildAuthScreen(_NetworkFailureAuthRepository()));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();

    expect(find.text('Lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.'), findsAtLeastNWidgets(1));
    expect(find.textContaining('SocketException'), findsNothing);
  });

  testWidgets('Network failure (ClientException) in English shows distinct connection message', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildAuthScreen(_ClientExceptionAuthRepository(), locale: const Locale('en')));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();

    expect(find.text('Connection problem. Please try again.'), findsAtLeastNWidgets(1));
    expect(find.textContaining('ClientException'), findsNothing);
  });

  testWidgets('Second login attempt clears previous error and isLoading returns to false (F-01 1c)', (
    tester,
  ) async {
    final flakyRepo = _FlakyAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(flakyRepo),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(authControllerProvider.notifier);

    // First attempt fails
    await controller.login(email: 'test@example.com', password: 'bad');
    var state = container.read(authControllerProvider);
    expect(state.isLoading, false);
    expect(state.error, isNotNull);

    // Controller clearError works
    controller.clearError();
    expect(container.read(authControllerProvider).error, isNull);

    // Trigger failure again
    flakyRepo.attempts = 0;
    await controller.login(email: 'test@example.com', password: 'bad');
    state = container.read(authControllerProvider);
    expect(state.isLoading, false);
    expect(state.error, isNotNull);

    // Second attempt succeeds: clears previous error
    await controller.login(email: 'test@example.com', password: 'good');
    state = container.read(authControllerProvider);
    expect(state.isLoading, false);
    expect(state.error, isNull);
    expect(state.user, isNotNull);
  });

  testWidgets('Register tab failure displays localized error message without crashing (F-01 4)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildAuthScreen(_FailingRegisterAuthRepository()));
    await tester.pumpAndSettle();

    // Switch to Register / Sign up tab
    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4)); // Name, Email, Password, Confirm
    await tester.enterText(fields.at(0), 'Nguyễn Văn A');
    await tester.enterText(fields.at(1), 'user@example.com');
    await tester.enterText(fields.at(2), 'Pass123@#');
    await tester.enterText(fields.at(3), 'Pass123@#');

    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-error-message')), findsOneWidget);
    expect(find.text('Email hoặc mật khẩu không đúng.'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Exception:'), findsNothing);
  });

  testWidgets('Social buttons (Google/Apple) show feedback when tapped (F-01 4)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildAuthScreen(_RejectedAuthRepository()));
    await tester.pumpAndSettle();

    final googleBtn = find.text('Google');
    expect(googleBtn, findsOneWidget);
    await tester.tap(googleBtn);
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập bằng mạng xã hội hiện chưa được hỗ trợ.'), findsOneWidget);
  });

  for (final size in [const Size(320, 568), const Size(390, 844), const Size(1280, 900)]) {
    testWidgets('auth error is visible at viewport size ${size.width}x${size.height} (F-01 5)', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildAuthScreen(_Http401AuthRepository()));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'wrong@example.com');
      await tester.enterText(fields.at(1), 'wrongpass');
      await tester.ensureVisible(find.byType(GradientButton));
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth-error-message')), findsOneWidget);
    });
  }
}
