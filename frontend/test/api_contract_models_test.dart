import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/models/device_overview.dart';
import 'package:iotagri_app/models/support_ticket.dart';

void main() {
  test('maps the backend dashboard DTO without losing device identity or alerts', () {
    final overview = DeviceOverview.fromJson({
      'deviceId': 'device-1',
      'name': 'Tower 1',
      'isOnline': true,
      'lastSeenAt': '2026-10-16T00:00:00Z',
      'latestReading': {
        'id': 'reading-1',
        'deviceId': 'device-1',
        'temperature': 24.5,
        'recordedAt': '2026-10-16T00:00:00Z',
      },
      'activeAlerts': [
        {
          'id': 'alert-1',
          'deviceId': 'device-1',
          'type': 'LOW_WATER_LEVEL',
          'measuredValue': 12,
          'threshold': 25,
          'triggeredAt': '2026-10-16T00:00:00Z',
        },
      ],
    });

    expect(overview.id, 'device-1');
    expect(overview.latestReading?.deviceId, 'device-1');
    expect(overview.alerts.single.deviceId, 'device-1');
  });

  test('maps ticket page messageCount from the backend contract', () {
    final ticket = SupportTicket.fromJson({
      'id': 'ticket-1',
      'subject': 'Sensor issue',
      'category': 'Sensors',
      'status': 'open',
      'priority': 'medium',
      'messageCount': 2,
      'createdAt': '2026-10-16T00:00:00Z',
    });

    expect(ticket.messagesCount, 2);
  });
}
