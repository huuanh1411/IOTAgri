class ProvisioningCode {
  final String code;
  final String expiresAt;
  final String createdAt;

  ProvisioningCode({
    required this.code,
    required this.expiresAt,
    required this.createdAt,
  });

  factory ProvisioningCode.fromJson(Map<String, dynamic> json) {
    return ProvisioningCode(
      code: json['code'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'expiresAt': expiresAt,
      'createdAt': createdAt,
    };
  }
}