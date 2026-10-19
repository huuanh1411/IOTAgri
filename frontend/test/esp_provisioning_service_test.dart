import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iotagri_app/services/esp_provisioning_service.dart';

void main() {
  test('reads ESP status and sorts scanned networks by signal', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/status') {
        return http.Response(
          jsonEncode({'hardwareId': 'AGRI-1234', 'setupMode': true}),
          200,
        );
      }
      return http.Response(
        jsonEncode({
          'networks': [
            {'ssid': 'Weak', 'rssi': -80},
            {'ssid': 'BETEA', 'rssi': -42},
          ],
        }),
        200,
      );
    });
    final service = EspProvisioningService(
      client: client,
      baseUrl: 'http://192.168.4.1',
    );

    final status = await service.getStatus();
    final networks = await service.scanNetworks();

    expect(status.hardwareId, 'AGRI-1234');
    expect(status.setupMode, isTrue);
    expect(networks.map((network) => network.ssid), ['BETEA', 'Weak']);
  });

  test('posts Wi-Fi and claim details directly to ESP', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/provision');
      expect(request.bodyFields, {
        'wifi': 'BETEA',
        'pass': 'secret-password',
        'api': 'http://192.168.1.55:8080',
        'code': 'ABC123',
      });
      return http.Response(jsonEncode({'ok': true}), 200);
    });
    final service = EspProvisioningService(
      client: client,
      baseUrl: 'http://192.168.4.1',
    );

    await service.provision(
      ssid: 'BETEA',
      password: 'secret-password',
      backendUrl: 'http://192.168.1.55:8080',
      claimCode: 'ABC123',
    );
  });

  test('surfaces the ESP provisioning error', () async {
    final service = EspProvisioningService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'error': 'Wi-Fi connection failed.'}),
          400,
        ),
      ),
      baseUrl: 'http://192.168.4.1',
    );

    expect(
      () => service.provision(
        ssid: 'BETEA',
        password: 'wrong',
        backendUrl: 'http://192.168.1.55:8080',
        claimCode: 'ABC123',
      ),
      throwsA(
        isA<EspProvisioningException>().having(
          (error) => error.message,
          'message',
          'Wi-Fi connection failed.',
        ),
      ),
    );
  });
}
