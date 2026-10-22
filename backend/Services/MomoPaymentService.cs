using System.Globalization;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using IOTAgriBackend.Models;
using Microsoft.Extensions.Options;

namespace IOTAgriBackend.Services;

public class MomoOptions
{
    public bool Enabled { get; set; }
    public string PartnerCode { get; set; } = "";
    public string AccessKey { get; set; } = "";
    public string SecretKey { get; set; } = "";
    public string Endpoint { get; set; } = "https://test-payment.momo.vn/v2/gateway/api/create";
    public string RedirectUrl { get; set; } = "";
    public string IpnUrl { get; set; } = "";
    public bool IsReady => Enabled && !string.IsNullOrWhiteSpace(PartnerCode)
        && !string.IsNullOrWhiteSpace(AccessKey) && !string.IsNullOrWhiteSpace(SecretKey)
        && IsHttps(RedirectUrl) && IsHttps(IpnUrl)
        && Endpoint is "https://test-payment.momo.vn/v2/gateway/api/create" or "https://payment.momo.vn/v2/gateway/api/create";
    private static bool IsHttps(string value) => Uri.TryCreate(value, UriKind.Absolute, out var uri) && uri.Scheme == "https";
}

public record MomoNotification(string PartnerCode, string OrderId, string RequestId, long Amount,
    string OrderInfo, string OrderType, long TransId, int ResultCode, string Message,
    string PayType, long ResponseTime, string ExtraData, string Signature);

public static class MomoSignatures
{
    public static string Sign(string raw, string secret) => Convert.ToHexStringLower(
        HMACSHA256.HashData(Encoding.UTF8.GetBytes(secret), Encoding.UTF8.GetBytes(raw)));

    public static string NotificationRaw(MomoNotification n, string accessKey) => FormattableString.Invariant(
        $"accessKey={accessKey}&amount={n.Amount}&extraData={n.ExtraData}&message={n.Message}&orderId={n.OrderId}&orderInfo={n.OrderInfo}&orderType={n.OrderType}&partnerCode={n.PartnerCode}&payType={n.PayType}&requestId={n.RequestId}&responseTime={n.ResponseTime}&resultCode={n.ResultCode}&transId={n.TransId}");

    public static bool Verify(MomoNotification n, MomoOptions options)
    {
        if (!options.IsReady || n.PartnerCode != options.PartnerCode || string.IsNullOrEmpty(n.Signature)) return false;
        try
        {
            var actual = Convert.FromHexString(n.Signature);
            var expected = Convert.FromHexString(Sign(NotificationRaw(n, options.AccessKey), options.SecretKey));
            return CryptographicOperations.FixedTimeEquals(actual, expected);
        }
        catch (FormatException) { return false; }
    }
}

public class MomoPaymentService(HttpClient http, IOptions<MomoOptions> settings)
{
    public MomoOptions Options => settings.Value;
    public async Task<string> CreateAsync(StoreOrder order, StorePayment payment, CancellationToken cancellationToken)
    {
        if (!Options.IsReady) throw new InvalidOperationException("Thanh toán MoMo chưa được cấu hình.");
        var orderInfo = $"Aerogreen {order.Id:N}";
        var redirectUrl = Options.RedirectUrl + (Options.RedirectUrl.Contains('?') ? "&" : "?") + $"storeOrderId={order.Id}";
        var amount = order.TotalVnd.ToString(CultureInfo.InvariantCulture);
        var raw = $"accessKey={Options.AccessKey}&amount={amount}&extraData=&ipnUrl={Options.IpnUrl}&orderId={payment.GatewayOrderId}&orderInfo={orderInfo}&partnerCode={Options.PartnerCode}&redirectUrl={redirectUrl}&requestId={payment.RequestId}&requestType=captureWallet";
        using var response = await http.PostAsJsonAsync(Options.Endpoint, new
        {
            partnerCode = Options.PartnerCode, requestId = payment.RequestId, amount = order.TotalVnd,
            orderId = payment.GatewayOrderId, orderInfo, redirectUrl, ipnUrl = Options.IpnUrl,
            requestType = "captureWallet", extraData = "", lang = "vi", autoCapture = true,
            signature = MomoSignatures.Sign(raw, Options.SecretKey)
        }, cancellationToken);
        response.EnsureSuccessStatusCode();
        using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync(cancellationToken));
        var root = json.RootElement;
        if (!root.TryGetProperty("resultCode", out var result) || result.GetInt32() != 0
            || !root.TryGetProperty("orderId", out var gatewayOrder) || gatewayOrder.GetString() != payment.GatewayOrderId
            || !root.TryGetProperty("requestId", out var request) || request.GetString() != payment.RequestId
            || !root.TryGetProperty("payUrl", out var link))
            throw new InvalidOperationException("MoMo chưa cấp liên kết thanh toán. Vui lòng kiểm tra lại đơn, không tạo đơn mới nếu đã trừ tiền.");
        var url = link.GetString();
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri) || uri.Scheme != "https"
            || uri.Host != (Options.Endpoint.Contains("test-payment") ? "test-payment.momo.vn" : "payment.momo.vn"))
            throw new InvalidOperationException("Liên kết thanh toán không hợp lệ.");
        return url!;
    }
}
