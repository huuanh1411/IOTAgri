namespace IOTAgriBackend.Services;

public interface IEmailSender
{
    Task SendVerificationCodeAsync(string email, string code, CancellationToken cancellationToken = default);
}
