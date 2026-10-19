class LightSchedule {
  const LightSchedule({
    required this.id,
    required this.deviceId,
    required this.isEnabled,
    required this.weekdayMask,
    required this.startTime,
    required this.durationSeconds,
    required this.timeZone,
  });

  final String id;
  final String deviceId;
  final bool isEnabled;
  final int weekdayMask;
  final String startTime;
  final int durationSeconds;
  final String timeZone;

  factory LightSchedule.fromJson(Map<String, dynamic> json) => LightSchedule(
    id: json['id'] as String,
    deviceId: json['deviceId'] as String,
    isEnabled: json['isEnabled'] as bool,
    weekdayMask: json['weekdayMask'] as int,
    startTime: json['startTime'] as String,
    durationSeconds: json['durationSeconds'] as int,
    timeZone: json['timeZone'] as String,
  );
}
