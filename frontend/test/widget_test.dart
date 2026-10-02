// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:iotagri_app/cupertino/dashboard/farm_health_card.dart';
import 'package:iotagri_app/cupertino/devices/cupertino_device_detail_screen.dart';
import 'package:iotagri_app/models/device.dart';
import 'package:iotagri_app/models/device_alert.dart';
import 'package:iotagri_app/models/device_overview.dart';
import 'package:iotagri_app/models/sensor_reading.dart';
import 'package:iotagri_app/cupertino/devices/cupertino_devices_screen.dart';
import 'package:iotagri_app/providers/auth_provider.dart';
import 'package:iotagri_app/screens/dashboard/dashboard_screen.dart';
import 'package:iotagri_app/services/api_service.dart';

class _OfflineApiService extends ApiService {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    throw http.ClientException('Failed to fetch');
  }
}

class _DetailApiService extends ApiService {
  final bool isOnline;
  final bool pumpIsRunning;
  final bool includeReading;
  final bool includeSchedule;

  _DetailApiService({
    this.isOnline = true,
    this.pumpIsRunning = false,
    this.includeReading = true,
    this.includeSchedule = false,
  });

  @override
  Future<Map<String, dynamic>> getDevice(String id) async => {
    'id': id,
    'name': 'Greenhouse 1',
    'isOnline': isOnline,
    'createdAt': '2026-10-02T00:00:00Z',
  };

  @override
  Future<List<dynamic>> getDeviceReadings(
    String deviceId, {
    int? limit,
  }) async => includeReading
      ? [
          {
            'id': 'reading-1',
            'deviceId': deviceId,
            'temperature': 26.4,
            'humidity': 62,
            'ph': 6.2,
            'waterLevel': 12,
            'recordedAt': DateTime.now().toUtc().toIso8601String(),
          },
        ]
      : [];

  @override
  Future<Map<String, dynamic>> getPumpCommands(
    String deviceId, {
    int page = 1,
    int pageSize = 20,
    int? rangeHours,
  }) async => {
    'items': pumpIsRunning
        ? [
            {
              'id': 'command-1',
              'deviceId': deviceId,
              'isOn': true,
              'durationSeconds': 60,
              'status': 'Acknowledged',
              'issuedAt': DateTime.now().toUtc().toIso8601String(),
              'acknowledgedAt': DateTime.now()
                  .toUtc()
                  .subtract(const Duration(seconds: 3))
                  .toIso8601String(),
              'acknowledgedIsOn': true,
            },
          ]
        : [],
  };

  @override
  Future<List<dynamic>> getPumpSchedules(String deviceId) async =>
      includeSchedule
      ? [
          {
            'id': 'schedule-1',
            'deviceId': deviceId,
            'isEnabled': true,
            'weekdayMask': 127,
            'startTime': '06:00:00',
            'durationSeconds': 10,
            'timeZone': 'Asia/Ho_Chi_Minh',
            'createdAt': '2026-10-02T00:00:00Z',
          },
        ]
      : [];

  @override
  Future<Map<String, dynamic>> getAlerts(
    String deviceId, {
    String status = 'all',
    int page = 1,
    int pageSize = 20,
  }) async => {'items': []};

  @override
  Future<Map<String, dynamic>> getAlertSettings(String deviceId) async => {
    'highTemperatureC': 30,
    'lowWaterLevelPercent': 20,
  };
}

class _DeviceListApiService extends ApiService {
  _DeviceListApiService(this.count);

  final int count;
  final Set<String> deletedDeviceIds = {};
  String? provisionedDeviceId;

  @override
  Future<List<dynamic>> getDevices() async => [
    for (var index = 0; index < count; index++)
      if (!deletedDeviceIds.contains('device-$index'))
      {
        'id': 'device-$index',
        'name': 'Greenhouse $index',
        'isOnline': true,
        'createdAt': '2026-10-02T00:00:00Z',
      },
  ];

  @override
  Future<void> deleteDevice(String id) async {
    deletedDeviceIds.add(id);
  }

  @override
  Future<Map<String, dynamic>> createDevice(String name) async => {
    'id': 'device-generated-123',
    'name': name,
    'deviceKey': 'not-shown-to-user',
    'createdAt': '2026-10-02T00:00:00Z',
  };

  @override
  Future<Map<String, dynamic>> createProvisioningCode(String deviceId) async {
    provisionedDeviceId = deviceId;
    return {
      'code': '482913',
      'expiresAt': DateTime.now()
          .toUtc()
          .add(const Duration(minutes: 15))
          .toIso8601String(),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
  }
}

DeviceOverview _device({
  bool isOnline = true,
  List<DeviceAlert> alerts = const [],
}) => DeviceOverview(
  id: 'device-1',
  name: 'Greenhouse 1',
  isOnline: isOnline,
  alerts: alerts,
);

Widget _healthCard(List<DeviceOverview> devices, {VoidCallback? onAddDevice}) =>
    CupertinoApp(
      home: CupertinoPageScaffold(
        child: Center(
          child: FarmHealthCard(
            summary: FarmHealthSummary.fromDevices(devices),
            onAddDevice: onAddDevice,
          ),
        ),
      ),
    );

void main() {
  test('login stays unauthenticated when backend is unavailable', () async {
    final authProvider = AuthProvider(apiService: _OfflineApiService());
    addTearDown(authProvider.dispose);

    final success = await authProvider.login(
      'demo@aerogreen.vn',
      'Password123',
    );

    expect(success, isFalse);
    expect(authProvider.isAuthenticated, isFalse);
    expect(authProvider.errorMessage, isNotNull);
  });

  testWidgets('dashboard shows gateway status summary', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GatewayStatusCard(
          status: 'Mất kết nối',
          lastUpdate: '10:35',
          runtime: '5h 12m',
        ),
      ),
    );

    expect(find.text('ESP32 Gateway'), findsOneWidget);
    expect(find.text('🟢'), findsOneWidget);
    expect(find.text('Last update'), findsOneWidget);
    expect(find.text('Runtime'), findsOneWidget);
  });

  testWidgets('farm health shows add-device welcome with no devices', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_healthCard(const [], onAddDevice: () {}));

    expect(find.text('Chào mừng đến Aerogreen'), findsOneWidget);
    expect(find.text('Thêm thiết bị'), findsOneWidget);
    expect(find.text('Thiết bị online'), findsNothing);
  });

  testWidgets('farm health shows healthy state', (WidgetTester tester) async {
    await tester.pumpWidget(_healthCard([_device()]));

    expect(find.text('Trang trại đang ổn định'), findsOneWidget);
    expect(
      find.text('Tất cả thiết bị đang hoạt động bình thường.'),
      findsOneWidget,
    );
  });

  testWidgets('farm health shows attention for offline device', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_healthCard([_device(isOnline: false)]));

    expect(find.text('Cần chú ý'), findsOneWidget);
    expect(find.text('1 vấn đề cần kiểm tra.'), findsOneWidget);
  });

  testWidgets('farm health shows critical low-water alert', (
    WidgetTester tester,
  ) async {
    final lowWaterAlert = DeviceAlert(
      id: 'alert-1',
      deviceId: 'device-1',
      type: 'LOW_WATER_LEVEL',
      measuredValue: 12,
      threshold: 20,
      triggeredAt: '2026-10-02T00:00:00Z',
    );
    await tester.pumpWidget(
      _healthCard([
        _device(alerts: [lowWaterAlert]),
      ]),
    );

    expect(find.text('Cần xử lý ngay'), findsOneWidget);
    expect(
      find.text('Phát hiện tình trạng ảnh hưởng đến vận hành.'),
      findsOneWidget,
    );
  });

  testWidgets('device list search appears only above six devices', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoDevicesScreen(apiService: _DeviceListApiService(6)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoSearchTextField), findsNothing);

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoDevicesScreen(
          key: const ValueKey('seven-devices'),
          apiService: _DeviceListApiService(7),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
  });

  testWidgets('device deletion requires confirmation and removes the row', (
    WidgetTester tester,
  ) async {
    final apiService = _DeviceListApiService(1);
    await tester.pumpWidget(
      CupertinoApp(home: CupertinoDevicesScreen(apiService: apiService)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(CupertinoIcons.delete));
    await tester.pumpAndSettle();
    expect(find.text('Xóa thiết bị?'), findsOneWidget);

    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.text('Greenhouse 0'), findsOneWidget);
    expect(apiService.deletedDeviceIds, isEmpty);

    await tester.tap(find.byIcon(CupertinoIcons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();

    expect(apiService.deletedDeviceIds, contains('device-0'));
    expect(find.text('Greenhouse 0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('device creation carries generated ID into provisioning', (
    WidgetTester tester,
  ) async {
    final apiService = _DeviceListApiService(0);
    await tester.pumpWidget(
      CupertinoApp(home: CupertinoDevicesScreen(apiService: apiService)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), 'North greenhouse');
    await tester.tap(find.text('Tạo và thiết lập'));
    await tester.pumpAndSettle();

    expect(apiService.provisionedDeviceId, 'device-generated-123');
    expect(find.text('Device ID: device-generated-123'), findsOneWidget);
    expect(find.text('482913'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail disables controls offline and notes saved schedules', (
    WidgetTester tester,
  ) async {
    final device = Device(
      id: 'device-1',
      name: 'Greenhouse 1',
      isOnline: true,
      createdAt: '2026-10-02T00:00:00Z',
    );
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoDeviceDetailScreen(
          device: device,
          apiService: _DetailApiService(isOnline: false, includeSchedule: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Offline'), findsOneWidget);
    expect(
      find.text('Lịch đã lưu tiếp tục chạy tự động khi có kết nối.'),
      findsOneWidget,
    );
    final pumpButton = tester.widget<CupertinoButton>(
      find
          .ancestor(
            of: find.text('Bật 60s'),
            matching: find.byType(CupertinoButton),
          )
          .first,
    );
    expect(pumpButton.onPressed, isNull);
  });

  testWidgets('detail shows running pump state', (WidgetTester tester) async {
    final device = Device(
      id: 'device-1',
      name: 'Greenhouse 1',
      isOnline: true,
      createdAt: '2026-10-02T00:00:00Z',
    );
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoDeviceDetailScreen(
          device: device,
          apiService: _DetailApiService(pumpIsRunning: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bơm đang chạy'), findsOneWidget);
    expect(find.text('Tắt'), findsOneWidget);
  });

  testWidgets('detail shows missing sensor state', (WidgetTester tester) async {
    final device = Device(
      id: 'device-1',
      name: 'Greenhouse 1',
      isOnline: true,
      createdAt: '2026-10-02T00:00:00Z',
    );
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoDeviceDetailScreen(
          device: device,
          apiService: _DetailApiService(includeReading: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Không có dữ liệu mới'), findsOneWidget);
    expect(find.text('Không có dữ liệu'), findsNWidgets(4));
  });

  testWidgets('sensor grid marks values below configured threshold', (
    WidgetTester tester,
  ) async {
    final reading = SensorReading(
      id: 'reading-1',
      deviceId: 'device-1',
      temperature: 26,
      humidity: 62,
      ph: 6.2,
      waterLevel: 12,
      recordedAt: '2026-10-02T00:00:00Z',
    );
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 380,
              child: SensorGrid(
                reading: reading,
                waterLevelThreshold: 20,
                highTemperatureThreshold: 30,
                isOffline: false,
                onSensorTap: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final waterValue = tester.widget<Text>(find.text('12.0 %'));
    expect(waterValue.style?.color, CupertinoColors.systemOrange);
  });

  testWidgets('pump control shows command-sending state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: PumpControlCard(
              isOnline: true,
              isRunning: false,
              isSending: true,
              onPressed: _noop,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Đang gửi lệnh…'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });
}

void _noop() {}
