import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iotagri_app/core/theme/app_theme.dart';
import 'package:iotagri_app/cupertino/devices/cupertino_device_detail_screen.dart';
import 'package:iotagri_app/cupertino/devices/pump_schedules_screen.dart';
import 'package:iotagri_app/models/device.dart';
import 'package:iotagri_app/screens/devices/devices_screen.dart';
import 'package:iotagri_app/screens/devices/provisioning_code_screen.dart';
import 'package:iotagri_app/services/api_service.dart';

class MockNarrowApiService extends ApiService {
  @override
  Future<Map<String, dynamic>> getDevice(String id) async => {
        'id': id,
        'name': 'Tháp Thử Nghiệm 320px',
        'isOnline': true,
        'location': 'Khu A',
        'createdAt': '2026-10-01T00:00:00Z',
        'lastSeenAt': '2026-10-16T08:30:00Z',
      };

  @override
  Future<List<dynamic>> getDevices() async => [
        {
          'id': 'd1',
          'name': 'Tháp Thử Nghiệm 320px',
          'isOnline': true,
          'location': 'Khu A',
          'createdAt': '2026-10-01T00:00:00Z',
          'lastSeenAt': '2026-10-16T08:30:00Z',
        }
      ];

  @override
  Future<List<dynamic>> getDeviceReadings(String id, {int? limit}) async =>
      [
        {
          'id': 'r1',
          'deviceId': id,
          'temperature': 25.5,
          'humidity': 65.0,
          'solutionTemperature': 22.0,
          'tds': 600.0,
          'waterLevel': 80.0,
          'ph': 6.2,
          'recordedAt': '2026-10-16T08:30:00Z',
        }
      ];

  @override
  Future<Map<String, dynamic>> getPumpCommands(
    String id, {
    int page = 1,
    int pageSize = 20,
    int? rangeHours,
  }) async => {
        'items': <dynamic>[],
        'totalCount': 0,
        'page': 1,
        'pageSize': 20,
      };

  @override
  Future<List<dynamic>> getPumpSchedules(String id) async => [
        {
          'id': 's1',
          'deviceId': id,
          'startTime': '08:00:00',
          'durationSeconds': 30,
          'intervalMinutes': 15,
          'weekdayMask': 127,
          'isEnabled': true,
        }
      ];

  @override
  Future<Map<String, dynamic>> getAlerts(
    String id, {
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async => {
        'items': <dynamic>[],
        'totalCount': 0,
      };

  @override
  Future<Map<String, dynamic>> getAlertSettings(String id) async => {
        'highTemperatureC': 35.0,
        'lowWaterLevelPercent': 20.0,
      };

  @override
  Future<Map<String, dynamic>> createProvisioningCode(String id) async => {
        'code': 'AGRI-TEST-320',
        'expiresAt': DateTime.now()
            .add(const Duration(minutes: 15))
            .toIso8601String(),
        'qrPayload': 'payload',
      };
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final testDevice = Device(
    id: 'd1',
    name: 'Tháp Thử Nghiệm 320px',
    isOnline: true,
    location: 'Khu A',
    createdAt: '2026-10-01T00:00:00Z',
    lastSeenAt: '2026-10-16T08:30:00Z',
  );

  testWidgets(
      'CupertinoDeviceDetailScreen renders at 320px width without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = MockNarrowApiService();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: CupertinoDeviceDetailScreen(
          device: testDevice,
          apiService: api,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tháp Thử Nghiệm 320px'), findsWidgets);
    expect(find.text('Cảm biến'), findsOneWidget);
    expect(find.text('Điều khiển bơm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'AddDeviceDialog renders at 320px width without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: AddDeviceDialog()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Thêm Thiết Bị Mới'), findsOneWidget);
    expect(find.text('Thêm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
