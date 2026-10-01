using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IOTAgriBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddLuxToSensorReadings : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "Lux",
                table: "SensorReadings",
                type: "double precision",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Lux",
                table: "SensorReadings");
        }
    }
}
