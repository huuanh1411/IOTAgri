using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace IOTAgriBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddStoreCommerce : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "StoreOrders",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<string>(type: "text", nullable: false),
                    CheckoutKey = table.Column<Guid>(type: "uuid", nullable: false),
                    CustomerName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Phone = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    Address = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    TotalVnd = table.Column<long>(type: "bigint", nullable: false),
                    ShippingFeeVnd = table.Column<long>(type: "bigint", nullable: false),
                    PaymentStatus = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    FulfillmentStatus = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    TrackingNumber = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    PaidAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StoreOrders", x => x.Id);
                    table.CheckConstraint("CK_StoreOrder_Total", "\"TotalVnd\" BETWEEN 1000 AND 50000000 AND \"ShippingFeeVnd\" BETWEEN 0 AND 1000000");
                    table.ForeignKey(
                        name: "FK_StoreOrders_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "StoreProducts",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Sku = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Kind = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    CycleCount = table.Column<int>(type: "integer", nullable: false),
                    Contents = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    PriceVnd = table.Column<long>(type: "bigint", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StoreProducts", x => x.Id);
                    table.CheckConstraint("CK_StoreProduct_Kind", "(\"Kind\" = 'hardware' AND \"CycleCount\" = 0) OR (\"Kind\" = 'refill' AND \"CycleCount\" BETWEEN 1 AND 100)");
                    table.CheckConstraint("CK_StoreProduct_Price", "\"PriceVnd\" >= 0 AND (NOT \"IsActive\" OR \"PriceVnd\" >= 1000)");
                });

            migrationBuilder.CreateTable(
                name: "StorePayments",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OrderId = table.Column<Guid>(type: "uuid", nullable: false),
                    RequestId = table.Column<string>(type: "text", nullable: false),
                    GatewayOrderId = table.Column<string>(type: "text", nullable: false),
                    Status = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    PayUrl = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: true),
                    TransactionId = table.Column<long>(type: "bigint", nullable: true),
                    ResultCode = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StorePayments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StorePayments_StoreOrders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "StoreOrders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "StoreOrderItems",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OrderId = table.Column<Guid>(type: "uuid", nullable: false),
                    ProductId = table.Column<Guid>(type: "uuid", nullable: false),
                    Sku = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Name = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Kind = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    CycleCount = table.Column<int>(type: "integer", nullable: false),
                    Contents = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    UnitPriceVnd = table.Column<long>(type: "bigint", nullable: false),
                    Quantity = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StoreOrderItems", x => x.Id);
                    table.CheckConstraint("CK_StoreOrderItem_Quantity", "\"Quantity\" BETWEEN 1 AND 20 AND \"UnitPriceVnd\" >= 1000");
                    table.ForeignKey(
                        name: "FK_StoreOrderItems_StoreOrders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "StoreOrders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_StoreOrderItems_StoreProducts_ProductId",
                        column: x => x.ProductId,
                        principalTable: "StoreProducts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.InsertData(
                table: "StoreProducts",
                columns: new[] { "Id", "Contents", "CycleCount", "IsActive", "Kind", "Name", "PriceVnd", "Sku" },
                values: new object[,]
                {
                    { new Guid("9a0449ed-6608-4486-b329-1292e9225001"), "Bộ thiết bị Aerogreen", 0, true, "hardware", "Hệ Thống Khí Canh Tự Động Aerogreen", 2950000L, "AEROGREEN-CORE" },
                    { new Guid("9a0449ed-6608-4486-b329-1292e9225002"), "Cây con và dung dịch dinh dưỡng cho 1 chu kỳ", 1, true, "refill", "Gói rau ăn — 1 chu kỳ", 299000L, "REFILL-1" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_StoreOrderItems_OrderId",
                table: "StoreOrderItems",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_StoreOrderItems_ProductId",
                table: "StoreOrderItems",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_StoreOrders_CreatedAt",
                table: "StoreOrders",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_StoreOrders_UserId_CheckoutKey",
                table: "StoreOrders",
                columns: new[] { "UserId", "CheckoutKey" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_StorePayments_GatewayOrderId",
                table: "StorePayments",
                column: "GatewayOrderId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_StorePayments_OrderId",
                table: "StorePayments",
                column: "OrderId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_StorePayments_RequestId",
                table: "StorePayments",
                column: "RequestId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_StorePayments_TransactionId",
                table: "StorePayments",
                column: "TransactionId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_StoreProducts_Sku",
                table: "StoreProducts",
                column: "Sku",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "StoreOrderItems");

            migrationBuilder.DropTable(
                name: "StorePayments");

            migrationBuilder.DropTable(
                name: "StoreProducts");

            migrationBuilder.DropTable(
                name: "StoreOrders");
        }
    }
}
