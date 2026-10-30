import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:iotagri_app/data/models/user.dart';
import 'package:iotagri_app/data/repositories/auth_repository.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:iotagri_app/providers/auth_controller.dart';
import 'package:iotagri_app/screens/delete_account_screen.dart';

class _SuccessfulDeleteRepository extends AuthRepository {
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

class _FailingDeleteRepository extends _SuccessfulDeleteRepository {
  @override
  Future<void> deleteAccount() async => throw Exception('Deletion failed.');
}

Widget buildDeleteAccountApp({AuthRepository? repository}) {
  final router = GoRouter(
    initialLocation: '/settings/delete-account',
    routes: [
      GoRoute(
        path: '/settings/delete-account',
        builder: (_, _) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, _) => const Scaffold(body: Text('Authentication')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        repository ?? _SuccessfulDeleteRepository(),
      ),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('delete confirmation remains disabled until DELETE is typed', (
    tester,
  ) async {
    await tester.pumpWidget(buildDeleteAccountApp());
    await tester.pumpAndSettle();

    final confirm = find.widgetWithText(FilledButton, 'Delete account');
    for (final confirmation in ['delete', 'Delete', 'DELETE ']) {
      await tester.enterText(find.byType(TextField), confirmation);
      await tester.pump();
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    }

    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();

    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
  });

  testWidgets('successful deletion returns user to authentication', (
    tester,
  ) async {
    await tester.pumpWidget(buildDeleteAccountApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();
    final confirm = find.widgetWithText(FilledButton, 'Delete account');
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(find.text('Authentication'), findsOneWidget);
  });

  testWidgets('failed deletion remains on confirmation screen and shows error', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildDeleteAccountApp(repository: _FailingDeleteRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();
    final confirm = find.widgetWithText(FilledButton, 'Delete account');
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(find.byType(DeleteAccountScreen), findsOneWidget);
    expect(find.text('Unable to delete account. Please try again.'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Unable to delete account. Please try again.')),
      matchesSemantics(isLiveRegion: true),
    );
  });
}
