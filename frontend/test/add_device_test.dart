import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/cupertino/devices/add_device_screen.dart';
import 'package:iotagri_app/services/api_error.dart';
import 'package:iotagri_app/services/api_service.dart';

import 'test_app.dart';

class _FakeApiService extends ApiService {
  _FakeApiService(this.create);

  final Future<Map<String, dynamic>> Function(String name) create;
  int calls = 0;

  @override
  Future<Map<String, dynamic>> createDevice(String name) {
    calls++;
    return create(name);
  }
}

void main() {
  testWidgets('creates once from the real response shape', (tester) async {
    final api = _FakeApiService(
      (name) async => {
        'id': 'device-42',
        'name': name,
        'deviceKey': 'preserved-key',
        'createdAt': '2026-10-20T00:00:00Z',
      },
    );
    await tester.pumpWidget(
      buildLocalizedCupertinoApp(home: AddDeviceScreen(apiService: api)),
    );
    await tester.enterText(find.byType(CupertinoTextField), 'Tower A');
    await tester.tap(find.text('Tạo và tiếp tục'));
    await tester.pumpAndSettle();
    expect(api.calls, 1);
  });

  testWidgets('disables duplicate submission while creation is pending', (
    tester,
  ) async {
    final pending = Completer<Map<String, dynamic>>();
    final api = _FakeApiService((_) => pending.future);
    await tester.pumpWidget(
      buildLocalizedCupertinoApp(home: AddDeviceScreen(apiService: api)),
    );
    await tester.enterText(find.byType(CupertinoTextField), 'Tower A');
    await tester.tap(find.text('Tạo và tiếp tục'));
    await tester.pump();
    final button = tester.widget<CupertinoButton>(
      find.byType(CupertinoButton).last,
    );
    expect(button.onPressed, isNull);
    expect(api.calls, 1);
    pending.completeError(
      const ApiError(kind: ApiErrorKind.server, message: 'failed'),
    );
    await tester.pump();
  });

  testWidgets('blocks blind retry after an uncertain timeout', (tester) async {
    final api = _FakeApiService((_) => throw TimeoutException('timeout'));
    await tester.pumpWidget(
      buildLocalizedCupertinoApp(home: AddDeviceScreen(apiService: api)),
    );
    await tester.enterText(find.byType(CupertinoTextField), 'Tower A');
    await tester.tap(find.text('Tạo và tiếp tục'));
    await tester.pump();
    expect(find.text('Về danh sách thiết bị'), findsOneWidget);
    expect(api.calls, 1);
  });
}
