# Google Sign-In and Email Verification Design

## Goal

Allow Android, iOS, and Flutter Web users to sign in with Google. Require users who register with an email and password to confirm their email address using a code sent by SMTP before they can sign in.

## Authentication model

Flutter obtains a Google ID token from Google Sign-In and sends it to the API. The API validates the token's signature, issuer, audience, expiry, subject, email, and `email_verified` claim. It then finds a user by the Google provider key, links a matching existing account only when that account's email is confirmed, or creates a confirmed User account. The API, not Google, continues to issue existing IOTAgri JWT access and refresh tokens.

Email/password registration creates an unconfirmed account. The API sends a six-digit confirmation code by authenticated SMTP. The code is stored only as a SHA-256 hash, expires after 15 minutes, can be tried five times, and is invalidated after use. Resends are limited to one per minute and replace an earlier active code. Login rejects unconfirmed password accounts with `403`.

Existing accounts must verify their email before their next password login, per user decision. Existing Google-linked users are not assumed because the product does not yet have Google login.

## Backend components

- `EmailVerificationCode`: persistence model linked to `ApplicationUser`; unique active-code access is enforced in code by replacing existing records for a user.
- `IEmailSender` / SMTP implementation: one focused service that reads `Smtp` configuration, uses STARTTLS, and sends the verification email. Configuration absence produces a safe server failure and no credentials appear in responses or logs.
- `GoogleTokenValidator`: validates Google-issued ID tokens for configured OAuth client IDs. The Google `sub` claim is stored through ASP.NET Identity external-logins API, avoiding a custom provider-key column.
- Auth routes: add Google sign-in, email-code confirmation, and resend routes. Existing register, password login, refresh, logout, and JWT issuance behavior remains unchanged aside from email-confirmation enforcement.

## API

- `POST /api/auth/google` body `{ "idToken": "..." }` returns current `AuthResponse`.
- `POST /api/auth/verify-email` body `{ "email": "...", "code": "123456" }` returns `204`.
- `POST /api/auth/resend-verification-code` body `{ "email": "..." }` returns `202`, including for unknown addresses to avoid account enumeration.
- `POST /api/auth/register` returns `202` after creating the user and sending the code; it does not issue tokens.
- `POST /api/auth/login` returns `403 { "error": "Email verification is required." }` for a correct password on an unconfirmed account.

## Flutter components

Add `google_sign_in` to the existing Flutter dependency manifest. Login screen gets a Google button. Auth service posts the ID token to `/api/auth/google`, stores issued IOTAgri tokens using existing storage, and initializes the user exactly as password login does.

Registration flow navigates to a verification-code screen. It submits the verification code, supports resend, and returns to login after success. Use existing Material auth screens and `AuthProvider`/`ApiService`; do not create a parallel auth stack.

Google OAuth client IDs are injected via Dart defines. Platform-native client IDs and web authorized origins are configured in Google Cloud Console; values are not committed.

## Configuration and deployment

`Smtp` values are environment-only: host, port, username, password, sender address, sender name, and STARTTLS toggle. Production compose maps each option from deployment environment variables. Google client IDs are configuration values: backend accepts an allow-list; Flutter Web uses its Web client ID as a Dart define.

Use a transactional SMTP relay in production. Gmail SMTP is suitable only for low-volume development or a pilot. VPS needs outbound TCP 587; no self-hosted mail server is part of this feature.

## Security and failure handling

No Gmail password, app password, OAuth secret, or client ID configuration is committed. Google ID tokens are validated server-side; Flutter-provided email/name values are never trusted. Codes are cryptographically random numeric values, hashes use a server-side pepper, and routes are rate-limited through existing rate limiting where available. SMTP failures return generic service failure; registration does not expose credentials.

## Tests

Backend tests cover unconfirmed password login rejection, code success/failure/expiry/attempt exhaustion, unknown-email resend behavior, SMTP invocation, Google token validation failures, and account create/link rules. Flutter tests cover verification and Google exchange API requests and registration no longer attempting immediate login.

## Out of scope

Password reset, changing email, local Mailpit container, provider-specific bounce webhooks, background mail queues, and a self-hosted SMTP server.
