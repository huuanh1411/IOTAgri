import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  testWidgets('shows a clear inline message for invalid credentials', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_RejectedAuthRepository()),
        ],
        child: const MaterialApp(
          locale: Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: AuthScreen(),
        ),
      ),
    );
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
}
