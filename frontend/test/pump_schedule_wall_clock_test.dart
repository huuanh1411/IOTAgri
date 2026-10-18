import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iotagri_app/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('Vietnam recurrence sends wall-clock fields, never a phone instant', () async {
    final api = ApiService(client: MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['startTime'], '00:05:00');
      expect(body['endTime'], '01:05:00');
      expect(body['timeZone'], 'Asia/Ho_Chi_Minh');
      expect(body['weekdayMask'], 16);
      expect(body['activeFromDate'], '2026-10-15');
      return http.Response('{}', 201);
    }));
    await api.createPumpSchedule('device', '00:05:00', 30, [4],
        endTime: '01:05:00', intervalMinutes: 30,
        activeFromDate: DateTime(2026, 10, 15));
  });

  test('offset-bearing instant cannot silently change recurrence wall clock', () async {
    final api = ApiService(client: MockClient((_) async => fail('Must not send an ambiguous recurrence')));
    await expectLater(api.createPumpSchedule('device', '2026-10-15T06:00:00-04:00', 30, [4]),
        throwsFormatException);
  });
}
