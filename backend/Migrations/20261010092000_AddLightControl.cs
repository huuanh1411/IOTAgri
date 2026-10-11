using IOTAgriBackend.Data;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IOTAgriBackend.Migrations;

[DbContext(typeof(ApplicationDbContext))]
[Migration("20261010092000_AddLightControl")]
public partial class AddLightControl : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<bool>(
            name: "IsLightOn",
            table: "Devices",
            type: "boolean",
            nullable: false,
            defaultValue: false);

        migrationBuilder.AddColumn<DateTime>(
            name: "LightStatusUpdatedAt",
            table: "Devices",
            type: "timestamp with time zone",
            nullable: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "IsLightOn",
            table: "Devices");

        migrationBuilder.DropColumn(
            name: "LightStatusUpdatedAt",
            table: "Devices");
    }
}
