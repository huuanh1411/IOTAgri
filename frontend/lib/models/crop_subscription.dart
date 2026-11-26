class CropSubscription {
  const CropSubscription({
    required this.id,
    required this.deviceId,
    required this.cropName,
    required this.amountVnd,
    required this.paymentCode,
    required this.status,
    required this.createdAt,
    required this.paymentExpiresAt,
    this.paidAt,
    this.expiresAt,
  });

  final String id;
  final String deviceId;
  final String cropName;
  final int amountVnd;
  final String paymentCode;
  final String status;
  final DateTime createdAt;
  final DateTime paymentExpiresAt;
  final DateTime? paidAt;
  final DateTime? expiresAt;

  bool get isPending => status == 'Pending';
  bool get isActive => status == 'Active';

  factory CropSubscription.fromJson(Map<String, dynamic> json) =>
      CropSubscription(
        id: json['id'] as String,
        deviceId: json['deviceId'] as String,
        cropName: json['cropName'] as String,
        amountVnd: json['amountVnd'] as int,
        paymentCode: json['paymentCode'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        paymentExpiresAt: DateTime.parse(json['paymentExpiresAt'] as String),
        paidAt: _dateOrNull(json['paidAt']),
        expiresAt: _dateOrNull(json['expiresAt']),
      );

  static DateTime? _dateOrNull(dynamic value) =>
      value == null ? null : DateTime.parse(value as String);
}

class CropSubscriptionPayment {
  const CropSubscriptionPayment({
    required this.subscription,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
  });

  final CropSubscription subscription;
  final String bankCode;
  final String accountNumber;
  final String accountName;

  factory CropSubscriptionPayment.fromJson(Map<String, dynamic> json) =>
      CropSubscriptionPayment(
        subscription: CropSubscription.fromJson(
          json['subscription'] as Map<String, dynamic>,
        ),
        bankCode: json['bankCode'] as String,
        accountNumber: json['accountNumber'] as String,
        accountName: json['accountName'] as String,
      );
}
