class PumpCommand {
  final String id;
  final String deviceId;
  final bool isOn;
  final int durationSeconds;
  final String status;
  final String issuedAt;
  final String? acknowledgedAt;
  final bool? acknowledgedIsOn;
  final String? failureReason;

  PumpCommand({
    required this.id,
    required this.deviceId,
    required this.isOn,
    required this.durationSeconds,
    required this.status,
    required this.issuedAt,
    this.acknowledgedAt,
    this.acknowledgedIsOn,
    this.failureReason,
  });

  factory PumpCommand.fromJson(Map<String, dynamic> json) {
    return PumpCommand(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      isOn: json['isOn'] ?? false,
      durationSeconds: json['durationSeconds'] ?? 0,
      status: _statusValue(json['status']),
      issuedAt: json['issuedAt'] ?? '',
      acknowledgedAt: json['acknowledgedAt'],
      acknowledgedIsOn: json['acknowledgedIsOn'],
      failureReason: json['failureReason'],
    );
  }

  static String _statusValue(dynamic value) {
    if (value is String) return value;
    if (value is num) {
      return switch (value.toInt()) {
        0 => 'Pending',
        1 => 'Acknowledged',
        2 => 'Failed',
        _ => 'Unknown',
      };
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'isOn': isOn,
      'durationSeconds': durationSeconds,
      'status': status,
      'issuedAt': issuedAt,
      'acknowledgedAt': acknowledgedAt,
      'acknowledgedIsOn': acknowledgedIsOn,
      'failureReason': failureReason,
    };
  }
}
