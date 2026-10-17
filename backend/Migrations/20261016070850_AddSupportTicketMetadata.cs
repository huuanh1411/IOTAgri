using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IOTAgriBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddSupportTicketMetadata : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Category",
                table: "SupportTickets",
                type: "character varying(64)",
                maxLength: 64,
                nullable: false,
                defaultValue: "Kỹ thuật");

            migrationBuilder.AddColumn<Guid>(
                name: "DeviceId",
                table: "SupportTickets",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DeviceName",
                table: "SupportTickets",
                type: "character varying(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_SupportTickets_DeviceId",
                table: "SupportTickets",
                column: "DeviceId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_SupportTickets_DeviceId",
                table: "SupportTickets");

            migrationBuilder.DropColumn(
                name: "Category",
                table: "SupportTickets");

            migrationBuilder.DropColumn(
                name: "DeviceId",
                table: "SupportTickets");

            migrationBuilder.DropColumn(
                name: "DeviceName",
                table: "SupportTickets");
        }
    }
}
