class Device {
  final String id;
  final String name;
  final bool isOnline;
  final String? lastSeenAt;
  final String createdAt;
  final String? deviceKey;
  final String? location;
  final bool isLightOn;
  final String? lightStatusUpdatedAt;

  Device({
    required this.id,
    required this.name,
    required this.isOnline,
    this.lastSeenAt,
    required this.createdAt,
    this.deviceKey,
    this.location,
    this.isLightOn = false,
    this.lightStatusUpdatedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeenAt: json['lastSeenAt'],
      createdAt: json['createdAt'] ?? '',
      deviceKey: json['deviceKey'],
      location: json['location'],
      isLightOn: json['isLightOn'] ?? false,
      lightStatusUpdatedAt: json['lightStatusUpdatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt,
      'createdAt': createdAt,
      'deviceKey': deviceKey,
      'location': location,
      'isLightOn': isLightOn,
      'lightStatusUpdatedAt': lightStatusUpdatedAt,
    };
  }
}
