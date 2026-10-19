import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/models/device_overview.dart';
import 'package:iotagri_app/models/history_data.dart';

void main() {
  test(
    'maps water temperature and air humidity from the live dashboard DTO',
    () {
      final overview = DeviceOverview.fromJson({
        'deviceId': 'device-1',
        'name': 'Tháp 1',
        'isOnline': true,
        'activeAlerts': const [],
        'latestReading': {
          'id': 'reading-1',
          'deviceId': 'device-1',
          'solutionTemperature': 24.6,
          'humidity': 67.2,
          'recordedAt': '2026-10-16T08:00:00Z',
        },
      });

      final sample = HistorySample.fromReading(overview.latestReading!);

      expect(overview.latestReading!.solutionTemperature, 24.6);
      expect(overview.latestReading!.humidity, 67.2);
      expect(sample.values[HistorySensor.solutionTemperature], 24.6);
      expect(sample.values[HistorySensor.humidity], 67.2);
    },
  );
}
