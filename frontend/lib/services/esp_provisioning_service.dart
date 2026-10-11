import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class EspDeviceStatus {
  final String hardwareId;
  final bool setupMode;

  const EspDeviceStatus({required this.hardwareId, required this.setupMode});

  factory EspDeviceStatus.fromJson(Map<String, dynamic> json) =>
      EspDeviceStatus(
        hardwareId: json['hardwareId'] as String? ?? '',
        setupMode: json['setupMode'] as bool? ?? false,
      );
}

class EspWifiNetwork {
  final String ssid;
  final int rssi;

  const EspWifiNetwork({required this.ssid, required this.rssi});

  factory EspWifiNetwork.fromJson(Map<String, dynamic> json) => EspWifiNetwork(
    ssid: json['ssid'] as String? ?? '',
    rssi: (json['rssi'] as num?)?.toInt() ?? -100,
  );
}

class EspProvisioningException implements Exception {
  final String message;

  const EspProvisioningException(this.message);

  @override
  String toString() => message;
}

class EspProvisioningService {
  final http.Client _client;
  final bool _ownsClient;
  final Uri _baseUri;

  EspProvisioningService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _ownsClient = client == null,
      _baseUri = Uri.parse(baseUrl ?? ApiConstants.espSetupUrl);

  Uri _uri(String path) => _baseUri.replace(path: path);

  Future<EspDeviceStatus> getStatus() async {
    final response = await _client
        .get(_uri('/api/status'))
        .timeout(const Duration(seconds: 8));
    _requireSuccess(response, 'Không tìm thấy ESP tại ${_baseUri.host}.');
    return EspDeviceStatus.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<EspWifiNetwork>> scanNetworks() async {
    final response = await _client
        .get(_uri('/api/networks'))
        .timeout(const Duration(seconds: 15));
    _requireSuccess(response, 'ESP không quét được mạng Wi-Fi.');

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final networks = (decoded['networks'] as List<dynamic>? ?? const [])
        .map((item) => EspWifiNetwork.fromJson(item as Map<String, dynamic>))
        .where((network) => network.ssid.isNotEmpty)
        .toList();
    networks.sort((a, b) => b.rssi.compareTo(a.rssi));
    return networks;
  }

  Future<void> provision({
    required String ssid,
    required String password,
    required String backendUrl,
    required String claimCode,
  }) async {
    final response = await _client
        .post(
          _uri('/api/provision'),
          body: {
            'wifi': ssid,
            'pass': password,
            'api': backendUrl,
            'code': claimCode,
          },
        )
        .timeout(const Duration(seconds: 45));
    _requireSuccess(response, 'ESP không thể hoàn tất thiết lập.');
  }

  void _requireSuccess(http.Response response, String fallback) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw EspProvisioningException(body['error'] as String? ?? fallback);
    } on FormatException {
      throw EspProvisioningException(
        response.body.trim().isEmpty ? fallback : response.body.trim(),
      );
    }
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}
