using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Options;
using MimeKit;

namespace IOTAgriBackend.Services;

public class SmtpEmailSender : IEmailSender
{
    private readonly EmailVerificationOptions _options;

    public SmtpEmailSender(IOptions<EmailVerificationOptions> options)
    {
        _options = options.Value;
    }

    public async Task SendVerificationCodeAsync(string email, string code, CancellationToken cancellationToken = default)
    {
        ValidateOptions();

        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(_options.SenderName, _options.SenderAddress));
        message.To.Add(MailboxAddress.Parse(email));
        message.Subject = "IOTAgri email verification code";
        message.Body = new TextPart("plain")
        {
            Text = $"Your IOTAgri verification code is {code}. It expires in 15 minutes.",
        };

        using var client = new SmtpClient();
        await client.ConnectAsync(
            _options.Host,
            _options.Port,
            _options.UseStartTls ? SecureSocketOptions.StartTls : SecureSocketOptions.None,
            cancellationToken);
        await client.AuthenticateAsync(_options.Username, _options.Password, cancellationToken);
        await client.SendAsync(message, cancellationToken);
        await client.DisconnectAsync(true, cancellationToken);
    }

    private void ValidateOptions()
    {
        if (string.IsNullOrWhiteSpace(_options.Host)
            || string.IsNullOrWhiteSpace(_options.Username)
            || string.IsNullOrWhiteSpace(_options.Password)
            || string.IsNullOrWhiteSpace(_options.SenderAddress))
        {
            throw new InvalidOperationException("SMTP configuration is incomplete.");
        }
    }
}
