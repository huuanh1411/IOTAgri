using System;
using System.Linq;
using IOTAgriBackend.Data;
using IOTAgriBackend.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Xunit;

namespace IOTAgriBackend.Tests;

public class DatabaseModelContractTests
{
    private static ApplicationDbContext Context() => new(new DbContextOptionsBuilder<ApplicationDbContext>()
        .UseNpgsql("Host=127.0.0.1;Port=1;Database=qa_metadata").Options);

    [Theory]
    [InlineData(typeof(RefreshToken), "Token")]
    [InlineData(typeof(Device), "DeviceKey")]
    [InlineData(typeof(Device), "ProvisionedHardwareId")]
    [InlineData(typeof(PumpScheduleOccurrence), "CommandId")]
    public void Security_and_idempotency_keys_have_unique_indexes(Type type, string property)
    {
        using var db = Context();
        var entity = db.Model.FindEntityType(type)!;
        Assert.Contains(entity.GetIndexes(), i => i.IsUnique && i.Properties.Select(p => p.Name).SequenceEqual(new[] { property }));
        Assert.Equal(System.Data.ConnectionState.Closed, db.Database.GetDbConnection().State);
    }

    [Fact]
    public void Active_alert_uniqueness_and_schedule_occurrence_deduplication_are_configured()
    {
        using var db = Context();
        var alertIndex = Assert.Single(db.Model.FindEntityType(typeof(DeviceAlert))!.GetIndexes(), i => i.IsUnique);
        Assert.Equal(new[] { "DeviceId", "Type" }, alertIndex.Properties.Select(p => p.Name));
        Assert.Equal("\"ResolvedAt\" IS NULL", alertIndex.GetFilter());
        Assert.Contains(db.Model.FindEntityType(typeof(PumpScheduleOccurrence))!.GetIndexes(), i => i.IsUnique &&
            i.Properties.Select(p => p.Name).SequenceEqual(new[] { "ScheduleId", "OccurrenceUtc" }));
    }

    [Theory]
    [InlineData(typeof(Device), "OwnerId", DeleteBehavior.SetNull)]
    [InlineData(typeof(SensorReading), "DeviceId", DeleteBehavior.Cascade)]
    [InlineData(typeof(SupportTicket), "UserId", DeleteBehavior.Restrict)]
    [InlineData(typeof(SupportTicketMessage), "TicketId", DeleteBehavior.Cascade)]
    public void Ownership_and_history_foreign_keys_have_expected_delete_rules(Type type, string property, DeleteBehavior behavior)
    {
        using var db = Context();
        var fk = Assert.Single(db.Model.FindEntityType(type)!.GetForeignKeys(), f => f.Properties.Any(p => p.Name == property));
        Assert.Equal(behavior, fk.DeleteBehavior);
    }

    [Fact]
    public void Pump_and_singleton_settings_constraints_are_in_design_time_model()
    {
        using var db = Context();
        var model = db.GetService<IDesignTimeModel>().Model;
        Assert.Contains(model.FindEntityType(typeof(PumpCommand))!.GetCheckConstraints(), c => c.Name == "CK_PumpCommands_DurationSeconds" && c.Sql.Contains("> 0"));
        Assert.Contains(model.FindEntityType(typeof(SystemAlertDefaults))!.GetCheckConstraints(), c => c.Name == "CK_SystemAlertDefaults_Singleton" && c.Sql == "\"Id\" = 1");
        Assert.Equal(512, model.FindEntityType(typeof(PumpCommand))!.FindProperty("FailureReason")!.GetMaxLength());
    }
}
