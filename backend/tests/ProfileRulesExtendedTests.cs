using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class ProfileRulesExtendedTests
{
    // Exact boundary: name at max length
    [Fact]
    public void Accepts_name_at_maximum_allowed_length()
    {
        var name = new string('a', ProfileRules.MaximumFullNameLength);

        Assert.Null(ProfileRules.Validate(name, null, out var normalized, out _));
        Assert.Equal(name, normalized);
    }

    [Fact]
    public void Rejects_name_one_char_over_maximum_allowed_length()
    {
        var name = new string('a', ProfileRules.MaximumFullNameLength + 1);

        Assert.NotNull(ProfileRules.Validate(name, null, out _, out _));
    }

    // Phone at max length
    [Fact]
    public void Accepts_phone_at_maximum_allowed_length()
    {
        // Build a valid phone that is exactly MaximumPhoneNumberLength chars
        // must have >= 8 digits and only allowed chars
        var phone = new string('1', ProfileRules.MaximumPhoneNumberLength);

        Assert.Null(ProfileRules.Validate("Valid Name", phone, out _, out _));
    }

    [Fact]
    public void Rejects_phone_one_char_over_maximum_allowed_length()
    {
        var phone = new string('1', ProfileRules.MaximumPhoneNumberLength + 1);

        Assert.NotNull(ProfileRules.Validate("Valid Name", phone, out _, out _));
    }

    // IsPhoneNumber — direct tests
    [Theory]
    [InlineData("12345678", true)]         // exactly 8 digits
    [InlineData("1234567", false)]          // only 7 digits
    [InlineData("+1234567890", true)]       // international format
    [InlineData("+84-912-345-678", true)]   // with dashes
    [InlineData("(028) 3822.1234", true)]   // with parens and dot
    [InlineData("abc12345678", false)]      // contains letters
    [InlineData("", false)]                 // empty string
    public void IsPhoneNumber_validates_format_directly(string value, bool expected)
    {
        Assert.Equal(expected, ProfileRules.IsPhoneNumber(value));
    }

    // Name trimming
    [Fact]
    public void Leading_and_trailing_spaces_are_trimmed_from_name()
    {
        Assert.Null(ProfileRules.Validate("  Tran Van B  ", null, out var name, out _));
        Assert.Equal("Tran Van B", name);
    }

    // Phone trimming
    [Fact]
    public void Leading_and_trailing_spaces_are_trimmed_from_phone()
    {
        Assert.Null(ProfileRules.Validate("Valid Name", "  0912345678  ", out _, out var phone));
        Assert.Equal("0912345678", phone);
    }
}
