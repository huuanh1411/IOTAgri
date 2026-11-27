using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IOTAgriBackend.Migrations
{
    /// <inheritdoc />
    public partial class RemoveCropSubscriptionRawPayload : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SePayRawPayload",
                table: "CropSubscriptions");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SePayRawPayload",
                table: "CropSubscriptions",
                type: "text",
                nullable: true);
        }
    }
}
