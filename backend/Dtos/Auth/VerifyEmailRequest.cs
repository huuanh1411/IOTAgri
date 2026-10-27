using System.ComponentModel.DataAnnotations;

namespace IOTAgriBackend.Dtos.Auth;

public record VerifyEmailRequest(
    [Required, EmailAddress] string Email,
    [Required, RegularExpression("^\\d{6}$")] string Code
);
