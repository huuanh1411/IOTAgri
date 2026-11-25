using System.ComponentModel.DataAnnotations;

namespace IOTAgriBackend.Dtos.Subscriptions;

public record CreateCropSubscriptionRequest([Required, StringLength(100)] string CropName);

public record CropSubscriptionResponse(
    Guid Id,
    Guid DeviceId,
    string CropName,
    int AmountVnd,
    string PaymentCode,
    string Status,
    DateTime CreatedAt,
    DateTime PaymentExpiresAt,
    DateTime? PaidAt,
    DateTime? ExpiresAt);

public record CropSubscriptionPaymentResponse(
    CropSubscriptionResponse Subscription,
    string BankCode,
    string AccountNumber,
    string AccountName);
