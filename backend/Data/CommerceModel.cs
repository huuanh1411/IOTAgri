using IOTAgriBackend.Models;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Data;

public static class CommerceModel
{
    public static void Configure(ModelBuilder builder)
    {
        builder.Entity<StoreProduct>(e =>
        {
            e.HasIndex(p => p.Sku).IsUnique();
            e.Property(p => p.Sku).HasMaxLength(80);
            e.Property(p => p.Name).HasMaxLength(200);
            e.Property(p => p.Kind).HasMaxLength(16);
            e.Property(p => p.Contents).HasMaxLength(4000);
            e.ToTable(t =>
            {
                t.HasCheckConstraint("CK_StoreProduct_Price", "\"PriceVnd\" >= 0 AND (NOT \"IsActive\" OR \"PriceVnd\" >= 1000)");
                t.HasCheckConstraint("CK_StoreProduct_Kind", "(\"Kind\" = 'hardware' AND \"CycleCount\" = 0) OR (\"Kind\" = 'refill' AND \"CycleCount\" BETWEEN 1 AND 100)");
            });
        });
        builder.Entity<StoreOrder>(e =>
        {
            e.HasIndex(o => new { o.UserId, o.CheckoutKey }).IsUnique();
            e.HasIndex(o => o.CreatedAt);
            e.Property(o => o.CustomerName).HasMaxLength(200);
            e.Property(o => o.Phone).HasMaxLength(30);
            e.Property(o => o.Address).HasMaxLength(1000);
            e.Property(o => o.PaymentStatus).HasMaxLength(16);
            e.Property(o => o.FulfillmentStatus).HasMaxLength(16);
            e.Property(o => o.TrackingNumber).HasMaxLength(200);
            e.HasOne(o => o.User).WithMany().HasForeignKey(o => o.UserId).OnDelete(DeleteBehavior.Restrict);
            e.ToTable(t => t.HasCheckConstraint("CK_StoreOrder_Total", "\"TotalVnd\" BETWEEN 1000 AND 50000000 AND \"ShippingFeeVnd\" BETWEEN 0 AND 1000000"));
        });
        builder.Entity<StoreOrderItem>(e =>
        {
            e.HasOne(i => i.Order).WithMany(o => o.Items).HasForeignKey(i => i.OrderId).OnDelete(DeleteBehavior.Cascade);
            e.HasOne<StoreProduct>().WithMany().HasForeignKey(i => i.ProductId).OnDelete(DeleteBehavior.Restrict);
            e.Property(i => i.Sku).HasMaxLength(80);
            e.Property(i => i.Name).HasMaxLength(200);
            e.Property(i => i.Kind).HasMaxLength(16);
            e.Property(i => i.Contents).HasMaxLength(4000);
            e.ToTable(t => t.HasCheckConstraint("CK_StoreOrderItem_Quantity", "\"Quantity\" BETWEEN 1 AND 20 AND \"UnitPriceVnd\" >= 1000"));
        });
        builder.Entity<StorePayment>(e =>
        {
            e.HasIndex(p => p.OrderId).IsUnique();
            e.HasIndex(p => p.RequestId).IsUnique();
            e.HasIndex(p => p.GatewayOrderId).IsUnique();
            e.HasIndex(p => p.TransactionId).IsUnique();
            e.HasOne(p => p.Order).WithMany().HasForeignKey(p => p.OrderId).OnDelete(DeleteBehavior.Restrict);
            e.Property(p => p.Status).HasMaxLength(16);
            e.Property(p => p.PayUrl).HasMaxLength(4000);
        });
        builder.Entity<StoreProduct>().HasData(new StoreProduct
        {
            Id = Guid.Parse("9a0449ed-6608-4486-b329-1292e9225001"), Sku = "AEROGREEN-CORE",
            Name = "Hệ Thống Khí Canh Tự Động Aerogreen", PriceVnd = 2950000,
            Contents = "Bộ thiết bị Aerogreen", IsActive = true
        }, new StoreProduct
        {
            Id = Guid.Parse("9a0449ed-6608-4486-b329-1292e9225002"), Sku = "REFILL-1",
            Name = "Gói rau ăn — 1 chu kỳ", Kind = "refill", CycleCount = 1, PriceVnd = 299000,
            Contents = "Cây con và dung dịch dinh dưỡng cho 1 chu kỳ", IsActive = true
        });
    }
}
