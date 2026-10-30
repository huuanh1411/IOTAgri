import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/data/models/user.dart';
import 'package:iotagri_app/data/repositories/auth_repository.dart';
import 'package:iotagri_app/providers/auth_controller.dart';
import 'package:iotagri_app/router.dart';
import 'package:iotagri_app/screens/delete_account_info_screen.dart';

import 'test_app.dart';

class _SignedOutRepository extends AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('delete account route is public without authentication', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_SignedOutRepository()),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(goRouterProvider);
    addTearDown(router.dispose);
    router.go('/delete-account');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(router.routeInformationProvider.value.uri.path, '/delete-account');
    expect(find.byType(DeleteAccountInfoScreen), findsOneWidget);
  });

  testWidgets('Vietnamese deletion page explains typed DELETE confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildLocalizedMaterialApp(home: const DeleteAccountInfoScreen()),
    );

    expect(find.text('Xóa tài khoản'), findsWidgets);
    expect(find.textContaining('DELETE'), findsWidgets);
    expect(find.textContaining('30 ngày'), findsOneWidget);
    expect(find.textContaining('xteam.aerogreen@gmail.com'), findsOneWidget);
  });
}
