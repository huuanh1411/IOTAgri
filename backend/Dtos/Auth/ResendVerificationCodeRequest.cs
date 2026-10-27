using System.ComponentModel.DataAnnotations;

namespace IOTAgriBackend.Dtos.Auth;

public record ResendVerificationCodeRequest(
    [Required, EmailAddress] string Email
);
