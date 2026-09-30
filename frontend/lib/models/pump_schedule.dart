class PumpSchedule {
  final String id;
  final String deviceId;
  final bool isEnabled;
  final int weekdayMask;
  final String startTime;
  final int durationSeconds;
  final String timeZone;
  final String? lastDispatchedOccurrenceUtc;
  final String createdAt;

  PumpSchedule({
    required this.id,
    required this.deviceId,
    required this.isEnabled,
    required this.weekdayMask,
    required this.startTime,
    required this.durationSeconds,
    required this.timeZone,
    this.lastDispatchedOccurrenceUtc,
    required this.createdAt,
  });

  factory PumpSchedule.fromJson(Map<String, dynamic> json) {
    return PumpSchedule(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      isEnabled: json['isEnabled'] ?? false,
      weekdayMask: json['weekdayMask'] ?? 0,
      startTime: json['startTime'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 0,
      timeZone: json['timeZone'] ?? '',
      lastDispatchedOccurrenceUtc: json['lastDispatchedOccurrenceUtc'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'isEnabled': isEnabled,
      'weekdayMask': weekdayMask,
      'startTime': startTime,
      'durationSeconds': durationSeconds,
      'timeZone': timeZone,
      'lastDispatchedOccurrenceUtc': lastDispatchedOccurrenceUtc,
      'createdAt': createdAt,
    };
  }

  // Helper getters for UI
  List<int> get daysOfWeek {
    final days = <int>[];
    for (int i = 0; i < 7; i++) {
      if ((weekdayMask & (1 << i)) != 0) {
        days.add(i);
      }
    }
    return days;
  }

  bool get isActive => isEnabled && lastDispatchedOccurrenceUtc != null;
}