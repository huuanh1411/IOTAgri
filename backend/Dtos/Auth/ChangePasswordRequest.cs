using System.ComponentModel.DataAnnotations;

namespace IOTAgriBackend.Dtos.Auth;

public record ChangePasswordRequest(
    [Required] string CurrentPassword,
    [Required, MinLength(8)] string NewPassword,
    bool LogoutOtherDevices = false);
