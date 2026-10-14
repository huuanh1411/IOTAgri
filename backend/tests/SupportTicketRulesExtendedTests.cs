using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class SupportTicketRulesExtendedTests
{
    // IsValidStatus
    [Theory]
    [InlineData("open", true)]
    [InlineData("in_progress", true)]
    [InlineData("closed", true)]
    public void Accepts_all_known_statuses(string status, bool expected)
    {
        Assert.Equal(expected, SupportTicketRules.IsValidStatus(status));
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("OPEN")]
    [InlineData("pending")]
    [InlineData("done")]
    public void Rejects_unknown_or_null_status(string? status)
    {
        Assert.False(SupportTicketRules.IsValidStatus(status));
    }

    // IsValidPriority
    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("LOW")]
    [InlineData("critical")]
    public void Rejects_unknown_or_null_priority(string? priority)
    {
        Assert.False(SupportTicketRules.IsValidPriority(priority));
    }

    // IsValidTransition — additional invalid transitions
    [Theory]
    [InlineData("open", "open")]
    [InlineData("in_progress", "in_progress")]
    [InlineData("closed", "closed")]
    [InlineData("in_progress", "open")]
    public void Rejects_self_and_backward_transitions(string current, string next)
    {
        Assert.False(SupportTicketRules.IsValidTransition(current, next));
    }

    [Theory]
    [InlineData("open", "in_progress", true)]
    [InlineData("in_progress", "closed", true)]
    [InlineData("closed", "open", true)]
    public void Accepts_all_valid_ticket_transitions(string current, string next, bool expected)
    {
        Assert.Equal(expected, SupportTicketRules.IsValidTransition(current, next));
    }
}
