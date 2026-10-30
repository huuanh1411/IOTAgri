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
import 'package:iotagri_app/screens/auth/verify_email_screen.dart';
import 'package:iotagri_app/screens/auth_screen.dart';
import 'package:iotagri_app/screens/privacy_policy_screen.dart';

class _RejectedAuthRepository extends AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> login({required String email, required String password}) async {
    throw Exception('Email hoặc mật khẩu không đúng.');
  }

  @override
  Future<User?> loginWithGoogle() async => null;
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
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    throw Exception('Login failed: 401 Unauthorized');
  }
}

class _SuccessfulRegisterAuthRepository extends AuthRepository {
  var signUpCalls = 0;
  var loginCalls = 0;

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    signUpCalls++;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    loginCalls++;
    throw StateError('Registration must not log in before email confirmation.');
  }
}

class _UnverifiedEmailAuthRepository extends AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> login({required String email, required String password}) async {
    throw Exception('Email verification is required.');
  }
}

class _ExistingUnverifiedEmailAuthRepository extends AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    throw Exception('Email này đã được đăng ký.');
  }
}

class _DeletingRepository extends AuthRepository {
  @override
  Future<User?> getCurrentUser() async => const User(
    id: 'user-1',
    fullName: 'Deletion Tester',
    email: 'delete@example.com',
    role: 'user',
    plan: 'Pro',
  );

  @override
  Future<void> deleteAccount() async {}
}

class _FailingDeleteRepository extends _DeletingRepository {
  @override
  Future<void> deleteAccount() async {
    throw Exception('Account deletion failed.');
  }
}

Widget _buildAuthScreen(
  AuthRepository repo, {
  Locale locale = const Locale('vi'),
}) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AuthScreen(),
    ),
  );
}

void main() {
  test('deleteAccount clears auth state only after repository success', () async {
    final controller = AuthController(_DeletingRepository());
    await Future<void>.delayed(Duration.zero);

    final deleted = await controller.deleteAccount();

    expect(deleted, isTrue);
    expect(controller.state.user, isNull);
  });

  test('deleteAccount preserves auth state when repository fails', () async {
    final controller = AuthController(_FailingDeleteRepository());
    await Future<void>.delayed(Duration.zero);

    final deleted = await controller.deleteAccount();

    expect(deleted, isFalse);
    expect(controller.state.user?.id, 'user-1');
  });

  testWidgets('opens privacy policy from authentication notice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildAuthScreen(_RejectedAuthRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chính sách quyền riêng tư'));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
  });

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

  testWidgets(
    'HTTP 401 shows localized error message and stays on login screen (F-01 1a)',
    (tester) async {
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
      expect(
        find.text('Email hoặc mật khẩu không đúng.'),
        findsAtLeastNWidgets(1),
      );
      expect(find.textContaining('401 Unauthorized'), findsNothing);
      expect(find.textContaining('Exception:'), findsNothing);
    },
  );

  testWidgets(
    'HTTP 401 in English locale shows localized English error message',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildAuthScreen(_Http401AuthRepository(), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'wrong@example.com');
      await tester.enterText(fields.at(1), 'wrongpass');
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Incorrect email or password.'),
        findsAtLeastNWidgets(1),
      );
      expect(find.textContaining('401'), findsNothing);
    },
  );

  testWidgets(
    'Network failure (SocketException) shows distinct connection problem message (F-01 1b)',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildAuthScreen(_NetworkFailureAuthRepository()),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(1), 'password123');
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.'),
        findsAtLeastNWidgets(1),
      );
      expect(find.textContaining('SocketException'), findsNothing);
    },
  );

  testWidgets(
    'Network failure (ClientException) in English shows distinct connection message',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildAuthScreen(
          _ClientExceptionAuthRepository(),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(1), 'password123');
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Connection problem. Please try again.'),
        findsAtLeastNWidgets(1),
      );
      expect(find.textContaining('ClientException'), findsNothing);
    },
  );

  testWidgets(
    'Second login attempt clears previous error and isLoading returns to false (F-01 1c)',
    (tester) async {
      final flakyRepo = _FlakyAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(flakyRepo)],
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
    },
  );

  test(
    'successful sign up leaves the Riverpod controller unconfirmed and unauthenticated',
    () async {
      final repository = _SuccessfulRegisterAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container
          .read(authControllerProvider.notifier)
          .signUp(
            fullName: 'QA User',
            email: 'qa@example.test',
            password: 'QaPassword1!',
          );

      final state = container.read(authControllerProvider);
      expect(repository.signUpCalls, 1);
      expect(repository.loginCalls, isZero);
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    },
  );

  testWidgets(
    'successful AuthScreen registration routes to existing email verification UI',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = _SuccessfulRegisterAuthRepository();
      await tester.pumpWidget(_buildAuthScreen(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Đăng ký'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'QA User');
      await tester.enterText(fields.at(1), 'qa@example.test');
      await tester.enterText(fields.at(2), 'QaPassword1!');
      await tester.enterText(fields.at(3), 'QaPassword1!');
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      expect(repository.loginCalls, isZero);
    },
  );

  testWidgets('unverified login opens email verification screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildAuthScreen(_UnverifiedEmailAuthRepository()));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'unverified@example.test');
    await tester.enterText(fields.at(1), 'QaPassword1!');
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();

    expect(find.byType(VerifyEmailScreen), findsOneWidget);
    expect(find.textContaining('unverified@example.test'), findsOneWidget);
  });

  testWidgets('existing unverified registration offers verification action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _buildAuthScreen(_ExistingUnverifiedEmailAuthRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'QA User');
    await tester.enterText(fields.at(1), 'unverified@example.test');
    await tester.enterText(fields.at(2), 'QaPassword1!');
    await tester.enterText(fields.at(3), 'QaPassword1!');
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Verify email'));
    await tester.pumpAndSettle();

    expect(find.byType(VerifyEmailScreen), findsOneWidget);
    expect(find.textContaining('unverified@example.test'), findsOneWidget);
  });

  testWidgets(
    'Register tab failure displays localized error message without crashing (F-01 4)',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildAuthScreen(_FailingRegisterAuthRepository()),
      );
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
      expect(
        find.text('Email hoặc mật khẩu không đúng.'),
        findsAtLeastNWidgets(1),
      );
      expect(find.textContaining('Exception:'), findsNothing);
    },
  );

  testWidgets(
    'Google cancellation returns without social-unavailable feedback (F-01 4)',
    (tester) async {
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

      expect(
        find.text('Đăng nhập bằng mạng xã hội hiện chưa được hỗ trợ.'),
        findsNothing,
      );
    },
  );

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1280, 900),
  ]) {
    testWidgets(
      'auth error is visible at viewport size ${size.width}x${size.height} (F-01 5)',
      (tester) async {
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
      },
    );
  }
}
