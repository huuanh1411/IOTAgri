using System;
using IOTAgriBackend.Dtos.Pumps;
using Xunit;

namespace IOTAgriBackend.Tests;

public class PumpCommandHistoryQueryExtendedTests
{
    // HasValidPagination
    [Theory]
    [InlineData(1, 1, true)]
    [InlineData(1, 100, true)]
    [InlineData(1, 50, true)]
    [InlineData(1, 0, false)]   // pageSize below minimum
    [InlineData(0, 50, false)]  // page below minimum
    [InlineData(-1, 50, false)] // negative page
    [InlineData(1, 101, false)] // pageSize above maximum
    public void HasValidPagination_boundary_cases(int page, int pageSize, bool expected)
    {
        var query = new PumpCommandHistoryQuery(Page: page, PageSize: pageSize);

        Assert.Equal(expected, query.HasValidPagination);
    }

    // TryGetRange — valid explicit range
    [Fact]
    public void Accepts_explicit_from_to_range_within_31_days()
    {
        var from = new DateTimeOffset(2026, 9, 1, 0, 0, 0, TimeSpan.Zero);
        var to   = new DateTimeOffset(2026, 9, 30, 0, 0, 0, TimeSpan.Zero); // 29 days
        var now  = new DateTimeOffset(2026, 9, 30, 12, 0, 0, TimeSpan.Zero);

        var query = new PumpCommandHistoryQuery(From: from, To: to);
        var valid = query.TryGetRange(now, out var start, out var end);

        Assert.True(valid);
        Assert.Equal(from.UtcDateTime, start);
        Assert.Equal(to.UtcDateTime, end);
    }

    [Fact]
    public void Rejects_range_exceeding_31_days()
    {
        var from = new DateTimeOffset(2026, 8, 1, 0, 0, 0, TimeSpan.Zero);
        var to   = new DateTimeOffset(2026, 9, 5, 0, 0, 0, TimeSpan.Zero); // 35 days
        var now  = new DateTimeOffset(2026, 9, 10, 0, 0, 0, TimeSpan.Zero);

        var query = new PumpCommandHistoryQuery(From: from, To: to);
        var valid = query.TryGetRange(now, out _, out _);

        Assert.False(valid);
    }

    [Fact]
    public void Rejects_range_where_from_equals_to()
    {
        var point = new DateTimeOffset(2026, 9, 17, 12, 0, 0, TimeSpan.Zero);
        var now   = new DateTimeOffset(2026, 9, 17, 12, 0, 0, TimeSpan.Zero);

        var query = new PumpCommandHistoryQuery(From: point, To: point);
        var valid = query.TryGetRange(now, out _, out _);

        Assert.False(valid);
    }

    [Fact]
    public void Default_range_end_uses_now_when_to_is_not_specified()
    {
        var now = new DateTimeOffset(2026, 9, 17, 12, 0, 0, TimeSpan.Zero);

        var query = new PumpCommandHistoryQuery();
        query.TryGetRange(now, out _, out var end);

        Assert.Equal(now.UtcDateTime, end);
    }
}
