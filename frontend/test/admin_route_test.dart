import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iotagri_app/cupertino/admin/cupertino_admin_dashboard_screen.dart';
import 'package:iotagri_app/data/models/user.dart';
import 'package:iotagri_app/data/repositories/auth_repository.dart';
import 'package:iotagri_app/providers/auth_controller.dart';
import 'package:iotagri_app/router.dart';
import 'package:iotagri_app/services/api_service.dart';

class _CurrentUserRepository extends AuthRepository {
  _CurrentUserRepository(this.currentUser);

  final User? currentUser;

  @override
  Future<User?> getCurrentUser() async => currentUser;
}

class _LogoutFailureRepository extends _CurrentUserRepository {
  _LogoutFailureRepository(super.currentUser);

  @override
  Future<void> logout() async => throw Exception('offline');
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  Future<String> redirectedLocation(
    WidgetTester tester,
    User? user, {
    String from = '/auth',
  }) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_CurrentUserRepository(user)),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(goRouterProvider);
    addTearDown(router.dispose);
    router.go(from);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump();
    return router.routeInformationProvider.value.uri.path;
  }

  testWidgets('authenticated admin is redirected to admin dashboard', (
    tester,
  ) async {
    final location = await redirectedLocation(
      tester,
      const User(
        id: 'admin-1',
        fullName: 'Admin',
        email: 'admin@example.com',
        role: 'admin',
        plan: 'Pro',
      ),
    );

    expect(location, '/admin');
  });

  testWidgets('authenticated regular user is redirected to home', (
    tester,
  ) async {
    final location = await redirectedLocation(
      tester,
      const User(
        id: 'user-1',
        fullName: 'User',
        email: 'user@example.com',
        role: 'user',
        plan: 'Free',
      ),
    );

    expect(location, '/home');
  });

  testWidgets('regular user cannot open admin dashboard directly', (
    tester,
  ) async {
    final location = await redirectedLocation(
      tester,
      const User(
        id: 'user-1',
        fullName: 'User',
        email: 'user@example.com',
        role: 'user',
        plan: 'Free',
      ),
      from: '/admin',
    );

    expect(location, '/home');
  });

  testWidgets('expired admin session redirects to authentication', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _CurrentUserRepository(
            const User(
              id: 'admin-1',
              fullName: 'Admin',
              email: 'admin@example.com',
              role: 'admin',
              plan: 'Pro',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(goRouterProvider);
    addTearDown(router.dispose);
    router.go('/admin');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(router.routeInformationProvider.value.uri.path, '/admin');
    expect(find.byType(CupertinoAdminDashboardScreen), findsOneWidget);
    expect(ApiService.onSessionExpired, isNotNull);
    ApiService.onSessionExpired?.call();
    await tester.pump();
    await tester.pump();

    expect(router.routeInformationProvider.value.uri.path, '/auth');
  });

  test('logout clears Riverpod auth state when server logout fails', () async {
    final controller = AuthController(
      _LogoutFailureRepository(
        const User(
          id: 'admin-1',
          fullName: 'Admin',
          email: 'admin@example.com',
          role: 'admin',
          plan: 'Pro',
        ),
      ),
    );
    addTearDown(controller.dispose);
    await Future<void>.delayed(Duration.zero);

    await controller.logout();

    expect(controller.state.user, isNull);
  });
}
