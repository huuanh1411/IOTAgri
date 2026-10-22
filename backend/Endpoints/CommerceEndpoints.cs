using System.Security.Claims;
using IOTAgriBackend.Data;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace IOTAgriBackend.Endpoints;

public record CheckoutItem(Guid ProductId, int Quantity);
public record CheckoutRequest(Guid CheckoutKey, string CustomerName, string Phone, string Address, List<CheckoutItem> Items, long ExpectedTotalVnd);
public class CommerceOptions
{
    public long ShippingFeeVnd { get; set; }
}
public record FulfillmentRequest(string Status, string? TrackingNumber);
public record ProductRequest(string Sku, string Name, string Kind, int CycleCount, string Contents, long PriceVnd, bool IsActive);

public static class CommerceEndpoints
{
    public static IEndpointRouteBuilder MapCommerceEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/store/products", async (ApplicationDbContext db, MomoPaymentService momo, IOptions<CommerceOptions> settings) =>
            Results.Ok(new { items = await db.StoreProducts.AsNoTracking().Where(p => p.IsActive).OrderBy(p => p.Kind).ThenBy(p => p.CycleCount).ToListAsync(),
                paymentAvailable = momo.Options.IsReady, fulfillment = "single_shipment", shippingFeeVnd = settings.Value.ShippingFeeVnd }));
        var orders = app.MapGroup("/api/store/orders").RequireAuthorization().WithTags("Store");
        orders.MapPost("", CreateOrderAsync);
        orders.MapGet("", async (ClaimsPrincipal user, ApplicationDbContext db, int page = 1) =>
        {
            if (page < 1 || page > 100000) return Results.BadRequest(new { error = "Trang không hợp lệ." });
            var userId = user.FindFirstValue(ClaimTypes.NameIdentifier);
            var query = db.StoreOrders.AsNoTracking().Where(o => o.UserId == userId);
            var totalCount = await query.CountAsync();
            var items = await query.Include(o => o.Items).OrderByDescending(o => o.CreatedAt).Skip((page - 1) * 20).Take(20).ToListAsync();
            return Results.Ok(new { items = items.Select(ToOrder), page, pageSize = 20, totalCount });
        });
        orders.MapGet("/{id:guid}", async (Guid id, ClaimsPrincipal user, ApplicationDbContext db) =>
        {
            var userId = user.FindFirstValue(ClaimTypes.NameIdentifier);
            var order = await db.StoreOrders.AsNoTracking().Include(o => o.Items).FirstOrDefaultAsync(o => o.Id == id && o.UserId == userId);
            return order is null ? Results.NotFound() : Results.Ok(ToOrder(order));
        });
        orders.MapPost("/{id:guid}/payment", StartPaymentAsync);
        app.MapPost("/api/store/payments/momo/ipn", NotifyAsync).AllowAnonymous().WithTags("Store");

        var admin = app.MapGroup("/api/admin/store").RequireAuthorization("AdminOnly").WithTags("Store Admin");
        admin.MapGet("/products", async (ApplicationDbContext db) => Results.Ok(await db.StoreProducts.AsNoTracking().OrderBy(p => p.Sku).ToListAsync()));
        admin.MapPut("/products/{id:guid}", SaveProductAsync);
        admin.MapGet("/orders", async (ApplicationDbContext db, int page = 1) =>
        {
            if (page < 1 || page > 100000) return Results.BadRequest();
            var totalCount = await db.StoreOrders.CountAsync();
            var items = await db.StoreOrders.AsNoTracking().Include(o => o.Items).OrderByDescending(o => o.CreatedAt).Skip((page - 1) * 20).Take(20).ToListAsync();
            return Results.Ok(new { items = items.Select(ToOrder), page, pageSize = 20, totalCount });
        });
        admin.MapPut("/orders/{id:guid}/fulfillment", async (Guid id, FulfillmentRequest request, ApplicationDbContext db) =>
        {
            await using var transaction = await db.Database.BeginTransactionAsync();
            var order = await LockedOrder(db, id);
            if (order is null) return Results.NotFound();
            await db.Entry(order).Collection(o => o.Items).LoadAsync();
            if (!CommerceRules.CanFulfill(order, request.Status) || request.TrackingNumber?.Length > 200)
                return Results.BadRequest(new { error = "Chỉ giao đơn đã thanh toán: unfulfilled → shipping → delivered." });
            order.FulfillmentStatus = request.Status;
            order.TrackingNumber = request.TrackingNumber?.Trim() ?? order.TrackingNumber;
            await db.SaveChangesAsync();
            await transaction.CommitAsync();
            return Results.Ok(ToOrder(order));
        });
        return app;
    }

    public static object ToOrder(StoreOrder o) => new
    {
        o.Id, o.CustomerName, o.Phone, o.Address, o.TotalVnd, o.PaymentStatus, o.FulfillmentStatus,
        o.TrackingNumber, o.CreatedAt, o.PaidAt, fulfillment = "single_shipment", o.ShippingFeeVnd,
        items = o.Items.Select(i => new { i.ProductId, i.Sku, i.Name, i.Kind, i.CycleCount, i.Contents, i.UnitPriceVnd, i.Quantity })
    };

    private static async Task<IResult> CreateOrderAsync(CheckoutRequest request, ClaimsPrincipal principal,
        ApplicationDbContext db, MomoPaymentService momo, IOptions<CommerceOptions> settings)
    {
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userId is null) return Results.Unauthorized();
        if (request.CheckoutKey == Guid.Empty || string.IsNullOrWhiteSpace(request.CustomerName) || request.CustomerName.Length > 200
            || string.IsNullOrWhiteSpace(request.Phone) || request.Phone.Length > 30
            || string.IsNullOrWhiteSpace(request.Address) || request.Address.Length > 1000
            || request.Items is null || request.Items.Count is < 1 or > 20
            || request.Items.Any(i => i.Quantity is < 1 or > 20)
            || request.Items.Select(i => i.ProductId).Distinct().Count() != request.Items.Count)
            return Results.BadRequest(new { error = "Kiểm tra người nhận, số điện thoại, địa chỉ và số lượng sản phẩm (1–20)." });
        var previous = await db.StoreOrders.Include(o => o.Items).FirstOrDefaultAsync(o => o.UserId == userId && o.CheckoutKey == request.CheckoutKey);
        if (previous is not null) return Results.Ok(ToOrder(previous));
        if (!momo.Options.IsReady) return Results.Problem("Thanh toán MoMo chưa được cấu hình.", statusCode: 503);
        var ids = request.Items.Select(i => i.ProductId).ToList();
        var products = await db.StoreProducts.AsNoTracking().Where(p => ids.Contains(p.Id) && p.IsActive).ToListAsync();
        if (products.Count != request.Items.Count) return Results.BadRequest(new { error = "Sản phẩm đã ngừng bán hoặc không tồn tại." });
        var order = new StoreOrder { UserId = userId, CheckoutKey = request.CheckoutKey,
            CustomerName = request.CustomerName.Trim(), Phone = request.Phone.Trim(), Address = request.Address.Trim() };
        try
        {
            order.Items = request.Items.Select(i => CommerceRules.Snapshot(products.Single(p => p.Id == i.ProductId), i.Quantity)).ToList();
            order.ShippingFeeVnd = settings.Value.ShippingFeeVnd;
            order.TotalVnd = CommerceRules.Total(order.Items, order.ShippingFeeVnd);
        }
        catch (ArgumentException e) { return Results.BadRequest(new { error = e.Message }); }
        if (request.ExpectedTotalVnd != order.TotalVnd)
            return Results.Conflict(new { error = "Giá sản phẩm hoặc phí giao hàng đã thay đổi. Vui lòng tải lại danh mục và kiểm tra tổng tiền." });
        db.StoreOrders.Add(order);
        db.StorePayments.Add(new StorePayment { Order = order });
        try { await db.SaveChangesAsync(); }
        catch (DbUpdateException e) when (e.InnerException is Npgsql.PostgresException { SqlState: "23505" })
        {
            db.ChangeTracker.Clear();
            previous = await db.StoreOrders.Include(o => o.Items).SingleOrDefaultAsync(o => o.UserId == userId && o.CheckoutKey == request.CheckoutKey);
            if (previous is null) throw;
            return Results.Ok(ToOrder(previous));
        }
        return Results.Created($"/api/store/orders/{order.Id}", ToOrder(order));
    }

    private static Task<StoreOrder?> LockedOrder(ApplicationDbContext db, Guid id) => db.StoreOrders
        .FromSqlInterpolated($"SELECT * FROM \"StoreOrders\" WHERE \"Id\" = {id} FOR UPDATE").SingleOrDefaultAsync();

    private static async Task<IResult> StartPaymentAsync(Guid id, ClaimsPrincipal principal,
        ApplicationDbContext db, MomoPaymentService momo, ILogger<MomoPaymentService> logger, CancellationToken ct)
    {
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userId is null) return Results.Unauthorized();
        if (!momo.Options.IsReady) return Results.Problem("Thanh toán MoMo chưa được cấu hình.", statusCode: 503);
        await using var transaction = await db.Database.BeginTransactionAsync(ct);
        var order = await LockedOrder(db, id);
        if (order is null || order.UserId != userId) return Results.NotFound();
        if (order.PaymentStatus == "paid") return Results.Conflict(new { error = "Đơn hàng đã thanh toán." });
        var payment = await db.StorePayments.SingleAsync(p => p.OrderId == id, ct);
        if (payment.Status == "failed") return Results.Conflict(new { error = "Giao dịch đã thất bại. Vui lòng đặt đơn mới hoặc liên hệ hỗ trợ nếu đã trừ tiền." });
        if (payment.PayUrl is not null) return Results.Ok(new { payUrl = payment.PayUrl });
        try
        {
            payment.PayUrl = await momo.CreateAsync(order, payment, ct);
            await db.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);
            return Results.Ok(new { payUrl = payment.PayUrl });
        }
        catch (Exception e) when (e is HttpRequestException or TaskCanceledException or InvalidOperationException or System.Text.Json.JsonException)
        {
            logger.LogWarning("MoMo session creation unavailable for store order {OrderId}; failure type {FailureType}", id, e.GetType().Name);
            return Results.Problem("Chưa nhận được liên kết MoMo. Kiểm tra trạng thái đơn trước khi thanh toán lại; liên hệ hỗ trợ nếu đã trừ tiền.", statusCode: 502);
        }
    }

    private static async Task<IResult> NotifyAsync(MomoNotification notification, ApplicationDbContext db, MomoPaymentService momo)
    {
        if (!MomoSignatures.Verify(notification, momo.Options)) return Results.BadRequest();
        var payment = await db.StorePayments.AsNoTracking().SingleOrDefaultAsync(p => p.GatewayOrderId == notification.OrderId);
        if (payment is null) return Results.NotFound();
        await using var transaction = await db.Database.BeginTransactionAsync();
        var order = await LockedOrder(db, payment.OrderId);
        payment = await db.StorePayments.SingleAsync(p => p.Id == payment.Id);
        try { CommerceRules.ApplyNotification(order!, payment, notification); }
        catch (ArgumentException) { return Results.BadRequest(); }
        await db.SaveChangesAsync();
        await transaction.CommitAsync();
        return Results.NoContent();
    }

    private static async Task<IResult> SaveProductAsync(Guid id, ProductRequest request, ApplicationDbContext db)
    {
        var product = new StoreProduct { Id = id, Sku = request.Sku?.Trim() ?? "", Name = request.Name?.Trim() ?? "",
            Kind = request.Kind, CycleCount = request.CycleCount, Contents = request.Contents?.Trim() ?? "", PriceVnd = request.PriceVnd, IsActive = request.IsActive };
        if (id == Guid.Empty || !CommerceRules.ValidProduct(product)) return Results.BadRequest(new { error = "Thông tin sản phẩm/gói refill không hợp lệ." });
        if (await db.StoreProducts.AnyAsync(p => p.Id != id && p.Sku == product.Sku)) return Results.Conflict(new { error = "SKU đã tồn tại." });
        var existing = await db.StoreProducts.FindAsync(id);
        if (existing is null) db.StoreProducts.Add(product);
        else db.Entry(existing).CurrentValues.SetValues(product);
        try { await db.SaveChangesAsync(); }
        catch (DbUpdateException e) when (e.InnerException is Npgsql.PostgresException { SqlState: "23505" })
        {
            return Results.Conflict(new { error = "SKU đã tồn tại. Vui lòng tải lại danh mục." });
        }
        return Results.Ok(product);
    }
}
