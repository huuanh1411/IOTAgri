using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IOTAgriBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddLightScheduleDispatchState : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "LastTurnedOffOccurrenceUtc",
                table: "LightSchedules",
                type: "timestamp with time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LastTurnedOffOccurrenceUtc",
                table: "LightSchedules");
        }
    }
}
