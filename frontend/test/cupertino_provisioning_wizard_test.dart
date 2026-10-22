import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:iotagri_app/cupertino/devices/cupertino_provisioning_code_screen.dart';
import 'package:iotagri_app/models/device.dart';
import 'package:iotagri_app/services/api_service.dart';
import 'package:iotagri_app/services/esp_provisioning_service.dart';

import 'test_app.dart';

class _FakeApiService extends ApiService {
  int createCodeCalls = 0;

  @override
  Future<Map<String, dynamic>> createProvisioningCode(String deviceId) async {
    createCodeCalls++;
    return {'code': 'SECRET-CODE', 'expiresAt': '2099-01-01T00:00:00Z'};
  }

  @override
  Future<Map<String, dynamic>> getDevice(String id) async => {
    'id': id,
    'isOnline': true,
  };

  @override
  Future<List<dynamic>> getDeviceReadings(
    String deviceId, {
    int? limit,
  }) async => [
    {'temperature': 24},
  ];
}

class _FakeEspService extends EspProvisioningService {
  _FakeEspService()
    : super(client: MockClient((_) async => throw UnimplementedError()));

  String? provisionedSsid;
  String? provisionedPassword;

  @override
  Future<EspDeviceStatus> getStatus() async =>
      const EspDeviceStatus(hardwareId: 'AGRI-12F4', setupMode: true);

  @override
  Future<List<EspWifiNetwork>> scanNetworks() async => const [
    EspWifiNetwork(ssid: 'BETEA', rssi: -42),
    EspWifiNetwork(ssid: 'Home 2.4G', rssi: -67),
  ];

  @override
  Future<void> provision({
    required String ssid,
    required String password,
    required String backendUrl,
    required String claimCode,
  }) async {
    provisionedSsid = ssid;
    provisionedPassword = password;
    expect(claimCode, 'SECRET-CODE');
  }

  @override
  void close() {}
}

void main() {
  final device = Device(
    id: 'device-42',
    name: 'Tower A',
    isOnline: false,
    createdAt: '2026-10-22T00:00:00Z',
  );

  testWidgets('guides the user through the five-step provisioning wizard', (
    tester,
  ) async {
    final api = _FakeApiService();
    final esp = _FakeEspService();
    await tester.pumpWidget(
      buildLocalizedCupertinoApp(
        home: CupertinoProvisioningCodeScreen(
          device: device,
          apiService: api,
          espProvisioningService: esp,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Bước 1/5'), findsOneWidget);
    expect(find.text('Thiết bị đã sẵn sàng'), findsOneWidget);
    expect(find.text('SECRET-CODE'), findsNothing);

    await tester.tap(find.text('Thiết bị đã sẵn sàng'));
    await tester.pumpAndSettle();
    expect(find.text('Bước 2/5'), findsOneWidget);
    expect(find.text('Kết nối với ESP'), findsWidgets);

    await tester.tap(find.text('Kết nối với ESP').last);
    await tester.pumpAndSettle();
    expect(find.text('Bước 3/5'), findsOneWidget);
    expect(find.text('BETEA'), findsOneWidget);
    expect(find.textContaining('…12F4'), findsOneWidget);

    await tester.tap(find.text('BETEA'));
    await tester.enterText(find.byType(CupertinoTextField), 'wifi-secret');
    await tester.tap(
      find.widgetWithText(CupertinoButton, 'Thiết lập thiết bị'),
    );
    await tester.pump();
    expect(find.text('Bước 4/5'), findsOneWidget);
    expect(esp.provisionedSsid, 'BETEA');
    expect(esp.provisionedPassword, 'wifi-secret');

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Bước 5/5'), findsOneWidget);
    expect(find.text('ESP đã kết nối thành công'), findsOneWidget);
    expect(find.text('Đã nhận'), findsOneWidget);
    expect(find.text('Xem thiết bị'), findsOneWidget);
  });

  testWidgets('keeps setup code under technical information', (tester) async {
    final api = _FakeApiService();
    await tester.pumpWidget(
      buildLocalizedCupertinoApp(
        home: CupertinoProvisioningCodeScreen(
          device: device,
          apiService: api,
          espProvisioningService: _FakeEspService(),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Thiết bị đã sẵn sàng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kết nối với ESP').last);
    await tester.pumpAndSettle();

    expect(find.text('SECRET-CODE'), findsNothing);
    await tester.ensureVisible(find.text('Thông tin kỹ thuật'));
    await tester.tap(find.text('Thông tin kỹ thuật'));
    await tester.pumpAndSettle();
    expect(find.textContaining('SECRET-CODE'), findsOneWidget);
  });
}
