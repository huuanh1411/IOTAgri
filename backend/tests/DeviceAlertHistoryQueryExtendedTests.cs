using IOTAgriBackend.Dtos.Alerts;
using Xunit;

namespace IOTAgriBackend.Tests;

public class DeviceAlertHistoryQueryExtendedTests
{
    // HasValidStatus
    [Theory]
    [InlineData("active", true)]
    [InlineData("resolved", true)]
    [InlineData("all", true)]
    public void Accepts_all_known_statuses(string status, bool expected)
    {
        Assert.Equal(expected, new DeviceAlertHistoryQuery(status).HasValidStatus);
    }

    [Theory]
    [InlineData("pending")]
    [InlineData("ACTIVE")]
    [InlineData("")]
    public void Rejects_invalid_statuses(string status)
    {
        Assert.False(new DeviceAlertHistoryQuery(status).HasValidStatus);
    }

    // HasValidPagination
    [Theory]
    [InlineData(1, 1, true)]
    [InlineData(1, 100, true)]
    [InlineData(0, 50, false)]
    [InlineData(1, 0, false)]
    [InlineData(1, 101, false)]
    public void Pagination_boundary_values(int page, int pageSize, bool expected)
    {
        Assert.Equal(expected, new DeviceAlertHistoryQuery(Page: page, PageSize: pageSize).HasValidPagination);
    }

    // Default values
    [Fact]
    public void Default_query_uses_active_status_and_first_page()
    {
        var query = new DeviceAlertHistoryQuery();

        Assert.Equal("active", query.Status);
        Assert.Equal(1, query.Page);
        Assert.Equal(50, query.PageSize);
    }
}
