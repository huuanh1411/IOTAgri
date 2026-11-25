namespace IOTAgriBackend.Services;

public sealed class SubscriptionOptions
{
    public int MonthlyPriceVnd { get; set; }
    public string BankCode { get; set; } = string.Empty;
    public string AccountNumber { get; set; } = string.Empty;
    public string AccountName { get; set; } = string.Empty;
}

public sealed class SePayOptions
{
    public string WebhookSecret { get; set; } = string.Empty;
}
