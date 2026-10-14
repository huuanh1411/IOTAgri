using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class ProvisioningCodeExtendedTests
{
    [Fact]
    public void Generated_code_is_twelve_characters_long()
    {
        var code = ProvisioningCode.Create();

        Assert.Equal(12, code.Length);
    }

    [Fact]
    public void Generated_code_uses_only_alphabet_characters()
    {
        const string Alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        var code = ProvisioningCode.Create();

        Assert.All(code, character => Assert.Contains(character, Alphabet));
    }

    [Fact]
    public void Generated_code_can_be_hashed_and_verified()
    {
        var code = ProvisioningCode.Create();
        Assert.True(ProvisioningCode.Matches(code, ProvisioningCode.Hash(code)));
    }

    [Fact]
    public void Hash_is_deterministic_for_same_input()
    {
        const string Code = "ABCD2345EFGH";

        var hash1 = ProvisioningCode.Hash(Code);
        var hash2 = ProvisioningCode.Hash(Code);

        Assert.Equal(hash1, hash2);
    }

    [Fact]
    public void Hash_differs_for_different_inputs()
    {
        var hash1 = ProvisioningCode.Hash("ABCD2345EFGH");
        var hash2 = ProvisioningCode.Hash("ABCD2345EFGI");

        Assert.NotEqual(hash1, hash2);
    }

    [Fact]
    public void Matches_returns_false_for_empty_string_vs_code_hash()
    {
        var code = ProvisioningCode.Create();
        var hash = ProvisioningCode.Hash(code);

        // Empty string should not match
        Assert.False(ProvisioningCode.Matches(string.Empty, hash));
    }

    [Fact]
    public void Matches_rejects_code_differing_in_last_character()
    {
        // Functional comparison test; this does not measure or prove timing safety.
        var code = "ABCD2345EFGH";
        var hash = ProvisioningCode.Hash(code);
        var almostCode = "ABCD2345EFGI"; // last char different

        Assert.False(ProvisioningCode.Matches(almostCode, hash));
    }
}
