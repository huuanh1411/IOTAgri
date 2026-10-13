using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Reflection;
using IOTAgriBackend.Dtos.Auth;
using IOTAgriBackend.Dtos.Devices;
using Xunit;

namespace IOTAgriBackend.Tests;

public class DtoValidationContractTests
{
    private static bool ValidateConstructorAnnotations(object request, List<ValidationResult> results)
    {
        // Positional records place these attributes on constructor parameters,
        // not properties. TryValidateObject does not inspect those annotations.
        var constructor = request.GetType().GetConstructors().Single();
        var valid = true;
        foreach (var parameter in constructor.GetParameters())
        {
            var value = request.GetType().GetProperty(parameter.Name!)!.GetValue(request);
            var context = new ValidationContext(request) { MemberName = parameter.Name };
            valid &= Validator.TryValidateValue(value, context, results, parameter.GetCustomAttributes<ValidationAttribute>());
        }
        return valid;
    }

    // Test the declared annotation contract explicitly; does not assert that the
    // Minimal API pipeline invokes Validator automatically.
    [Theory]
    [InlineData("qa@example.test", "12345678", "QA", true)]
    [InlineData("qa@example.test", "1234567", "QA", false)]
    [InlineData("bad-email", "12345678", "QA", false)]
    [InlineData("qa@example.test", "12345678", " ", false)]
    [InlineData("", "12345678", "QA", false)]
    public void Registration_annotation_contract_enforces_email_password_length_and_name(string email, string password, string name, bool expected)
    {
        var request = new RegisterRequest(email, password, name);
        var results = new List<ValidationResult>();
        Assert.Equal(expected, ValidateConstructorAnnotations(request, results));
        if (!expected) Assert.NotEmpty(results);
    }

    [Theory]
    [InlineData(64, 128, true)]
    [InlineData(65, 128, false)]
    [InlineData(64, 129, false)]
    [InlineData(0, 1, false)]
    [InlineData(1, 0, false)]
    public void Claim_annotation_contract_checks_required_fields_and_exact_length_boundaries(int codeLength, int hardwareLength, bool expected)
    {
        var request = new ClaimDeviceRequest(new string('A', codeLength), new string('H', hardwareLength));
        var results = new List<ValidationResult>();
        Assert.Equal(expected, ValidateConstructorAnnotations(request, results));
        if (!expected) Assert.NotEmpty(results);
    }
}
