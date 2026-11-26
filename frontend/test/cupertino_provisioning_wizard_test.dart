import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/testing.dart';
import 'package:iotagri_app/cupertino/devices/cupertino_devices_screen.dart';
import 'package:iotagri_app/cupertino/devices/cupertino_provisioning_code_screen.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:iotagri_app/models/device.dart';
import 'package:iotagri_app/services/api_service.dart';
import 'package:iotagri_app/services/esp_provisioning_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

class _FakeApiService extends ApiService {
  int createCodeCalls = 0;
  int getDeviceCalls = 0;
  bool deviceOnline = true;
  bool createCodeFails = false;

  @override
  Future<Map<String, dynamic>> createProvisioningCode(String deviceId) async {
    createCodeCalls++;
    if (createCodeFails) throw Exception('offline');
    return {'code': 'SECRET-CODE', 'expiresAt': '2099-01-01T00:00:00Z'};
  }

  @override
  Future<Map<String, dynamic>> getDevice(String id) async {
    getDeviceCalls++;
    return {'id': id, 'isOnline': deviceOnline};
  }

  @override
  Future<List<dynamic>> getDeviceReadings(
    String deviceId, {
    int? limit,
  }) async => [
    {'temperature': 24},
  ];
}

class _OfflineApiService extends ApiService {
  @override
  Future<List<dynamic>> getDevices() async => throw Exception('offline');
}

class _DeviceListApiService extends _FakeApiService {
  @override
  Future<List<dynamic>> getDevices() async => [
    {
      'id': 'device-42',
      'name': 'Tower A',
      'isOnline': false,
      'createdAt': '2026-10-22T00:00:00Z',
    },
  ];
}

class _FakeEspService extends EspProvisioningService {
  _FakeEspService()
    : super(client: MockClient((_) async => throw UnimplementedError()));

  String? provisionedSsid;
  String? provisionedPassword;
  bool scanFails = false;
  EspProvisioningFailure? provisionFailure;
  int getStatusCalls = 0;

  @override
  Future<EspDeviceStatus> getStatus() async {
    getStatusCalls++;
    return const EspDeviceStatus(hardwareId: 'AGRI-12F4', setupMode: true);
  }

  @override
  Future<List<EspWifiNetwork>> scanNetworks() async {
    if (scanFails) {
      throw const EspProvisioningException(
        'ESP could not scan Wi-Fi networks.',
      );
    }
    return const [
      EspWifiNetwork(ssid: 'BETEA', rssi: -42),
      EspWifiNetwork(ssid: 'Home 2.4G', rssi: -67),
    ];
  }

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
    if (provisionFailure case final failure?) {
      throw EspProvisioningException('Provisioning failed.', failure: failure);
    }
  }

  @override
  void close() {}
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final device = Device(
    id: 'device-42',
    name: 'Tower A',
    isOnline: false,
    createdAt: '2026-10-22T00:00:00Z',
  );

  testWidgets('opening setup reflects the device route in the browser URL', (
    tester,
  ) async {
    final api = _DeviceListApiService();
    final router = GoRouter(
      initialLocation: '/devices',
      routes: [
        GoRoute(
          path: '/devices',
          name: 'devices',
          builder: (_, _) => CupertinoDevicesScreen(apiService: api),
          routes: [
            GoRoute(
              path: ':deviceId/setup',
              name: 'device-setup',
              builder: (_, _) => CupertinoProvisioningCodeScreen(
                device: device,
                apiService: api,
                espProvisioningService: _FakeEspService(),
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      CupertinoApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(CupertinoIcons.qrcode));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/devices/${device.id}/setup',
    );
  });

  testWidgets('allows manual provisioning when the ESP scan fails', (
    tester,
  ) async {
    final esp = _FakeEspService()..scanFails = true;
    await tester.pumpWidget(
      buildLocalizedCupertinoApp(
        home: CupertinoProvisioningCodeScreen(
          device: device,
          apiService: _FakeApiService(),
          espProvisioningService: esp,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Thiết bị đã sẵn sàng'));
    await tester.pumpAndSettle();

    // Recovery through the ESP's own portal must be possible before scanning.
    await tester.ensureVisible(find.text('Thông tin kỹ thuật'));
    await tester.tap(find.text('Thông tin kỹ thuật'));
    await tester.pumpAndSettle();
    expect(find.textContaining('SECRET-CODE'), findsOneWidget);
    await tester.tap(
      find.widgetWithText(CupertinoActionSheetAction, 'Đã hiểu'),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Kết nối với ESP').last);
    await tester.tap(find.text('Kết nối với ESP').last);
    await tester.pumpAndSettle();
    expect(find.text('Bước 3/5'), findsOneWidget);
    expect(find.byType(CupertinoTextField), findsNWidgets(2));
    await tester.enterText(find.byType(CupertinoTextField).first, 'GTA house');
    await tester.enterText(find.byType(CupertinoTextField).last, 'wifi-secret');
    final submit = find.widgetWithText(CupertinoButton, 'Thiết lập thiết bị');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(esp.provisionedSsid, 'GTA house');
    expect(esp.provisionedPassword, 'wifi-secret');
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Bước 5/5'), findsOneWidget);
  });

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

  testWidgets('does not request a new code while connected to the ESP AP', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'device_setup_${device.id}_code': 'SECRET-CODE',
      'device_setup_${device.id}_expires_at': '2099-01-01T00:00:00Z',
      'device_setup_${device.id}_stage': 1,
    });
    final api = _FakeApiService();
    final esp = _FakeEspService()
      ..provisionFailure = EspProvisioningFailure.claimRejected;
    await tester.pumpWidget(
      buildLocalizedCupertinoApp(
        home: CupertinoProvisioningCodeScreen(
          device: device,
          apiService: api,
          espProvisioningService: esp,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(
      find.byType(CupertinoProvisioningCodeScreen),
    );
    final l10n = AppLocalizations.of(context)!;
    await tester.tap(find.text(l10n.connectToEspAction).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('BETEA'));
    await tester.enterText(find.byType(CupertinoTextField), 'wifi-secret');
    await tester.tap(
      find.widgetWithText(CupertinoButton, l10n.setUpDeviceAction),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.setupStepProgress(3, 5)), findsOneWidget);
    expect(find.text('Provisioning failed.'), findsOneWidget);
    expect(api.createCodeCalls, 0);
  });

  testWidgets('restores the ESP connection step after the web tab rebuilds', (
    tester,
  ) async {
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
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thiết bị đã sẵn sàng'));
    await tester.pumpAndSettle();
    expect(find.text('Bước 2/5'), findsOneWidget);
    expect(api.createCodeCalls, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      buildLocalizedCupertinoApp(
        home: CupertinoProvisioningCodeScreen(
          device: device,
          apiService: api,
          espProvisioningService: _FakeEspService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bước 2/5'), findsOneWidget);
    expect(api.createCodeCalls, 1);
  });

  testWidgets('resumes backend polling after a rebuild during ESP handoff', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'device_setup_${device.id}_code': 'CONSUMED-CODE',
      'device_setup_${device.id}_expires_at': '2020-01-01T00:00:00Z',
      'device_setup_${device.id}_stage': 3,
    });
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
    await tester.pump();

    expect(find.text('Bước 4/5'), findsOneWidget);
    expect(api.createCodeCalls, 0);
    expect(esp.getStatusCalls, 0);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Bước 5/5'), findsOneWidget);
    expect(api.getDeviceCalls, 1);
    expect(esp.getStatusCalls, 0);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('device_setup_${device.id}_code'), isNull);
  });

  testWidgets('persists handoff before the ESP disconnects the web app', (
    tester,
  ) async {
    final api = _FakeApiService()..deviceOnline = false;

    Future<void> mount() => tester.pumpWidget(
      buildLocalizedCupertinoApp(
        home: CupertinoProvisioningCodeScreen(
          device: device,
          apiService: api,
          espProvisioningService: _FakeEspService(),
        ),
      ),
    );

    await mount();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thiết bị đã sẵn sàng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kết nối với ESP').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('BETEA'));
    await tester.enterText(find.byType(CupertinoTextField), 'wifi-secret');
    await tester.tap(
      find.widgetWithText(CupertinoButton, 'Thiết lập thiết bị'),
    );
    await tester.pump();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('device_setup_${device.id}_stage'), 3);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    api.createCodeFails = true;
    api.deviceOnline = true;
    await mount();
    await tester.pump();
    await tester.pump();

    expect(find.text('Bước 4/5'), findsOneWidget);
    expect(api.createCodeCalls, 1);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('keeps registration pending and allows retry after timeout', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'device_setup_${device.id}_code': 'CONSUMED-CODE',
      'device_setup_${device.id}_expires_at': '2020-01-01T00:00:00Z',
      'device_setup_${device.id}_stage': 3,
    });
    final api = _FakeApiService()..deviceOnline = false;

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

    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
    }

    expect(api.getDeviceCalls, 20);
    expect(find.text('Thử lại'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.checkmark_circle_fill), findsNWidgets(3));
    expect(find.byIcon(CupertinoIcons.circle_filled), findsOneWidget);

    api.deviceOnline = true;
    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(api.getDeviceCalls, 21);
    expect(find.text('Bước 5/5'), findsOneWidget);
  });

  testWidgets('can restart provisioning after backend confirmation times out', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'device_setup_${device.id}_code': 'CONSUMED-CODE',
      'device_setup_${device.id}_expires_at': '2020-01-01T00:00:00Z',
      'device_setup_${device.id}_stage': 3,
    });
    final api = _FakeApiService()..deviceOnline = false;

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

    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
    }

    final context = tester.element(
      find.byType(CupertinoProvisioningCodeScreen),
    );
    final l10n = AppLocalizations.of(context)!;
    await tester.ensureVisible(find.text(l10n.restartDeviceSetupAction));
    await tester.tap(find.text(l10n.restartDeviceSetupAction));
    await tester.pumpAndSettle();

    expect(api.createCodeCalls, 1);
    expect(find.text(l10n.setupStepProgress(2, 5)), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('device_setup_${device.id}_code'),
      'SECRET-CODE',
    );
    expect(preferences.getInt('device_setup_${device.id}_stage'), 1);
  });

  testWidgets('restores setup route when the devices API is offline', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'device_setup_${device.id}_code': 'SECRET-CODE',
      'device_setup_${device.id}_expires_at': '2099-01-01T00:00:00Z',
      'device_setup_${device.id}_stage': 2,
    });
    final router = GoRouter(
      initialLocation: '/devices',
      routes: [
        GoRoute(
          path: '/devices',
          name: 'devices',
          builder: (_, _) =>
              CupertinoDevicesScreen(apiService: _OfflineApiService()),
          routes: [
            GoRoute(
              path: ':deviceId/setup',
              name: 'device-setup',
              builder: (_, _) => CupertinoProvisioningCodeScreen(
                device: device,
                apiService: _FakeApiService(),
                espProvisioningService: _FakeEspService(),
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      CupertinoApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/devices/${device.id}/setup',
    );
    expect(find.text('Bước 2/5'), findsOneWidget);
    expect(find.text('Hãy kiểm tra kết nối mạng và thử lại.'), findsNothing);
  });
}
