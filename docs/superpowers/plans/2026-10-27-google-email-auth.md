# Google Sign-In and Email Verification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Google sign-in and SMTP-backed verification codes for email/password registrations without changing IOTAgri session-token behavior.

**Architecture:** Flutter exchanges Google ID tokens with IOTAgri API; API validates Google identity and issues current JWT/refresh tokens. Password accounts stay unconfirmed until an SMTP-delivered, hashed six-digit verification code is accepted. Existing accounts are deliberately forced to verify before next password login.

**Tech Stack:** ASP.NET Core 10 Minimal API, ASP.NET Identity, EF Core PostgreSQL migrations, MailKit SMTP, Google.Apis.Auth, Flutter, `google_sign_in`, provider, Dio.

**Spec:** `docs/superpowers/specs/2026-10-27-google-email-auth-design.md`

## Global Constraints

- Target Android, iOS, and Flutter Web.
- Trust only Google ID tokens validated server-side with configured client-ID audiences and `email_verified=true`.
- Continue issuing existing IOTAgri JWT access and refresh tokens; never store Google tokens.
- Email/password registrations require a six-digit code that expires after 15 minutes, permits five attempts, is single use, and is stored only as SHA-256 hash with server-side pepper.
- Existing password accounts must verify before their next login.
- SMTP config and OAuth configuration must come from environment or Dart defines; never commit credentials.
- Preserve untracked `.vscode/settings.json`.

---

### Task 1: Backend verification-code domain and SMTP service

**Files:**
- Create: `backend/Models/EmailVerificationCode.cs`
- Create: `backend/Services/EmailVerificationOptions.cs`
- Create: `backend/Services/IEmailSender.cs`
- Create: `backend/Services/SmtpEmailSender.cs`
- Modify: `backend/Data/ApplicationDbContext.cs`
- Modify: `backend/Program.cs`
- Modify: `backend/IOTAgriBackend.csproj`
- Create: `backend/tests/EmailVerificationCodeTests.cs`

**Interfaces:**
- Produces `EmailVerificationCode` with `UserId`, `CodeHash`, `ExpiresAt`, `AttemptCount`, `SentAt`, and `ConsumedAt`.
- Produces `IEmailSender.SendVerificationCodeAsync(string email, string code, CancellationToken cancellationToken = default)`.

- [ ] **Step 1: Write failing unit tests for generated code persistence rules**

```csharp
[Fact]
public void Verification_code_expiry_is_fifteen_minutes_after_issue()
{
    var issuedAt = new DateTime(2026, 10, 27, 10, 0, 0, DateTimeKind.Utc);
    var code = EmailVerificationCode.Create("user-1", "123456", "pepper", issuedAt);

    Assert.Equal(issuedAt.AddMinutes(15), code.ExpiresAt);
    Assert.NotEqual("123456", code.CodeHash);
    Assert.Equal(0, code.AttemptCount);
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~EmailVerificationCodeTests`
Expected: FAIL because `EmailVerificationCode` does not exist.

- [ ] **Step 3: Add MailKit and minimal verification model/service contracts**

```xml
<PackageReference Include="MailKit" Version="4.14.1" />
```

```csharp
public interface IEmailSender
{
    Task SendVerificationCodeAsync(string email, string code, CancellationToken cancellationToken = default);
}
```

- [ ] **Step 4: Implement model creation and SMTP sender**

```csharp
public static EmailVerificationCode Create(string userId, string code, string pepper, DateTime now)
{
    return new EmailVerificationCode
    {
        UserId = userId,
        CodeHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes($"{pepper}:{code}"))),
        SentAt = now,
        ExpiresAt = now.AddMinutes(15),
    };
}
```

Use MailKit with `SecureSocketOptions.StartTls`, configure from `Smtp` section, and register `IEmailSender` in `Program.cs`.

- [ ] **Step 5: Run test to verify it passes**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~EmailVerificationCodeTests`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add backend/IOTAgriBackend.csproj backend/Models/EmailVerificationCode.cs backend/Services/EmailVerificationOptions.cs backend/Services/IEmailSender.cs backend/Services/SmtpEmailSender.cs backend/Data/ApplicationDbContext.cs backend/Program.cs backend/tests/EmailVerificationCodeTests.cs
git commit -m "feat(auth): add SMTP verification code service"
```

### Task 2: Email registration, confirmation, resend, and login enforcement

**Files:**
- Create: `backend/Dtos/Auth/VerifyEmailRequest.cs`
- Create: `backend/Dtos/Auth/ResendVerificationCodeRequest.cs`
- Modify: `backend/Endpoints/AuthEndpoints.cs`
- Create: `backend/Migrations/<timestamp>_AddEmailVerificationCodes.cs`
- Modify: `backend/Migrations/ApplicationDbContextModelSnapshot.cs`
- Modify: `backend/tests/AuthHandlerTests.cs`

**Interfaces:**
- Consumes `IEmailSender` from Task 1.
- Produces `POST /api/auth/verify-email` and `POST /api/auth/resend-verification-code`.

- [ ] **Step 1: Write failing auth-handler tests**

```csharp
[Fact]
public async Task Correct_password_for_unconfirmed_user_returns_forbidden()
{
    var user = new ApplicationUser { EmailConfirmed = false };
    // Configure UserManager test double for a correct password and unlocked user.
    var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LoginAsync", request, users.Object, db.Object, tokens.Object, configuration);
    Assert.Equal(403, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
}

[Fact]
public async Task Resend_for_unknown_email_returns_accepted_without_sending_mail()
{
    // Configure no user and invoke ResendVerificationCodeAsync.
    Assert.Equal(202, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    sender.Verify(s => s.SendVerificationCodeAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Never);
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~AuthHandlerTests`
Expected: FAIL because email-confirmation behavior and handlers do not exist.

- [ ] **Step 3: Implement minimal endpoints**

- Register creates `EmailConfirmed=false`, creates one code, sends it, and returns `202`.
- Login returns `403 { error = "Email verification is required." }` only after correct password and lockout checks.
- Verification rejects missing/expired/consumed code, increments attempts for wrong code, consumes correct code, and confirms Identity email.
- Resend returns `202` for all addresses, replaces a prior active code only after one minute, and sends only for a known unconfirmed user.
- Generate and apply EF migration.

- [ ] **Step 4: Run focused backend tests**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~AuthHandlerTests|FullyQualifiedName~EmailVerificationCodeTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add backend/Dtos/Auth backend/Endpoints/AuthEndpoints.cs backend/Migrations backend/tests/AuthHandlerTests.cs
git commit -m "feat(auth): require email verification for password login"
```

### Task 3: Google token exchange API

**Files:**
- Create: `backend/Dtos/Auth/GoogleSignInRequest.cs`
- Create: `backend/Services/GoogleAuthOptions.cs`
- Create: `backend/Services/IGoogleTokenValidator.cs`
- Create: `backend/Services/GoogleTokenValidator.cs`
- Modify: `backend/IOTAgriBackend.csproj`
- Modify: `backend/Program.cs`
- Modify: `backend/Endpoints/AuthEndpoints.cs`
- Modify: `backend/tests/AuthHandlerTests.cs`

**Interfaces:**
- Produces `IGoogleTokenValidator.ValidateAsync(string idToken, CancellationToken cancellationToken = default)` returning subject, verified email, and display name.
- Produces `POST /api/auth/google` with `{ "idToken": "..." }` and existing `AuthResponse`.

- [ ] **Step 1: Write failing Google sign-in tests**

```csharp
[Fact]
public async Task Verified_google_identity_creates_confirmed_user_and_issues_tokens()
{
    // Configure validator result with subject, verified email, and display name.
    // Assert new user is EmailConfirmed and User role is assigned.
}

[Fact]
public async Task Unverified_google_email_is_rejected()
{
    // Configure validator to reject email_verified=false.
    Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~AuthHandlerTests`
Expected: FAIL because Google route and validator do not exist.

- [ ] **Step 3: Implement validator and endpoint**

Use `GoogleJsonWebSignature.ValidateAsync` with configuration-derived allowed audiences. Link external identity through `UserManager.AddLoginAsync` with `LoginProvider="Google"` and provider key set to validated Google `sub`. Link to same-email existing user only when that user has `EmailConfirmed=true`; otherwise return `409`. Create new users confirmed and assign User role. Issue existing tokens through `IssueTokensAsync`.

- [ ] **Step 4: Run focused backend tests**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~AuthHandlerTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add backend/Dtos/Auth/GoogleSignInRequest.cs backend/Services/GoogleAuthOptions.cs backend/Services/IGoogleTokenValidator.cs backend/Services/GoogleTokenValidator.cs backend/IOTAgriBackend.csproj backend/Program.cs backend/Endpoints/AuthEndpoints.cs backend/tests/AuthHandlerTests.cs
git commit -m "feat(auth): add Google identity token login"
```

### Task 4: Flutter auth API and verification screen

**Files:**
- Create: `frontend/lib/screens/auth/verify_email_screen.dart`
- Modify: `frontend/lib/constants/api_constants.dart`
- Modify: `frontend/lib/services/api_service.dart`
- Modify: `frontend/lib/providers/auth_provider.dart`
- Modify: `frontend/lib/screens/auth/register_screen.dart`
- Modify: `frontend/test/auth_login_error_test.dart`

**Interfaces:**
- Produces `AuthProvider.verifyEmail(String email, String code)` and `AuthProvider.resendVerificationCode(String email)`.
- Registration transitions to verification screen; it no longer calls password login immediately.

- [ ] **Step 1: Write failing provider/API tests**

```dart
test('register does not create a session before email confirmation', () async {
  final provider = AuthProvider(apiService: api);
  final success = await provider.register('qa@example.test', 'QaPassword1!', 'QA');
  expect(success, isTrue);
  expect(provider.isAuthenticated, isFalse);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/auth_login_error_test.dart`
Expected: FAIL because registration currently immediately logs in.

- [ ] **Step 3: Implement endpoints and screen**

Add API constants and `ApiService` calls for verification/resend. Change `AuthProvider.register` to only register. Add Material code screen with six-digit validation, submit, resend, error state, and return-to-login navigation. Push it after successful registration.

- [ ] **Step 4: Run Flutter auth tests**

Run: `flutter test test/auth_login_error_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/constants/api_constants.dart frontend/lib/services/api_service.dart frontend/lib/providers/auth_provider.dart frontend/lib/screens/auth/register_screen.dart frontend/lib/screens/auth/verify_email_screen.dart frontend/test/auth_login_error_test.dart
git commit -m "feat(auth): add email verification flow"
```

### Task 5: Flutter Google sign-in and platform configuration

**Files:**
- Modify: `frontend/pubspec.yaml`
- Modify: `frontend/lib/constants/api_constants.dart`
- Modify: `frontend/lib/services/api_service.dart`
- Modify: `frontend/lib/providers/auth_provider.dart`
- Modify: `frontend/lib/screens/auth/login_screen.dart`
- Modify: `frontend/android/app/build.gradle.kts`
- Modify: `frontend/ios/Runner/Info.plist`
- Create: `frontend/test/google_auth_test.dart`

**Interfaces:**
- Adds `google_sign_in` dependency.
- Produces `AuthProvider.loginWithGoogle()` which exchanges only Google ID token and stores app-issued session tokens using existing flow.

- [ ] **Step 1: Write failing Google API-exchange test**

```dart
test('Google sign-in exchanges ID token with API and stores returned IOTAgri tokens', () async {
  // Arrange fake Google ID token and HTTP response with accessToken/refreshToken.
  // Assert POST /api/auth/google receives idToken and session becomes authenticated.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/google_auth_test.dart`
Expected: FAIL because Google sign-in does not exist.

- [ ] **Step 3: Add minimal Google flow**

Add `google_sign_in`. Request an ID token using client IDs supplied only by `GOOGLE_WEB_CLIENT_ID` Dart define. Send that token to API and reuse existing session-token persistence. Add accessible Google button to login. Configure Android/iOS identifiers only as documented placeholders; no secrets or IDs are committed.

- [ ] **Step 4: Run Google and existing auth tests**

Run: `flutter test test/google_auth_test.dart test/auth_login_error_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add frontend/pubspec.yaml frontend/pubspec.lock frontend/lib/constants/api_constants.dart frontend/lib/services/api_service.dart frontend/lib/providers/auth_provider.dart frontend/lib/screens/auth/login_screen.dart frontend/android/app/build.gradle.kts frontend/ios/Runner/Info.plist frontend/test/google_auth_test.dart
git commit -m "feat(auth): add Flutter Google sign-in"
```

### Task 6: Configuration and documentation

**Files:**
- Modify: `.env.example`
- Modify: `compose.production.yaml`
- Modify: `backend/appsettings.json`
- Modify: `docs/api_contract.md`
- Modify: `README.md`

**Interfaces:**
- Adds environment mappings for `Smtp__Host`, `Smtp__Port`, `Smtp__Username`, `Smtp__Password`, `Smtp__FromEmail`, `Smtp__FromName`, `Smtp__UseStartTls`, `EmailVerification__Pepper`, and Google allowed client ID(s).

- [ ] **Step 1: Write documentation acceptance checklist in review notes**

```text
- Example config contains variable names only, not credentials.
- Production compose passes secrets from environment.
- API contract documents all three new auth routes and 403 login behavior.
- README explains Google Cloud console platform registration and transactional SMTP relay setup.
```

- [ ] **Step 2: Apply minimal config/docs changes**

Add empty/sample variable names only. Explain that Gmail app passwords are development/pilot-only and a VPS needs outbound TCP 587, not self-hosted SMTP.

- [ ] **Step 3: Verify no credential-like values were added**

Run: `git diff --check; git diff -- .env.example compose.production.yaml backend/appsettings.json README.md docs/api_contract.md`
Expected: clean whitespace check and only configuration/documentation values.

- [ ] **Step 4: Commit**

```bash
git add .env.example compose.production.yaml backend/appsettings.json docs/api_contract.md README.md
git commit -m "docs(auth): document Google and SMTP setup"
```

### Task 7: End-to-end validation

**Files:**
- Modify: `docs/superpowers/specs/2026-10-27-google-email-auth-design.md` only if verification reveals design mismatch.

- [ ] **Step 1: Run backend auth suite**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~Auth`
Expected: PASS.

- [ ] **Step 2: Run Flutter auth suite**

Run: `flutter test test/auth_login_error_test.dart test/google_auth_test.dart`
Expected: PASS.

- [ ] **Step 3: Build backend and analyze Flutter**

Run: `dotnet build backend/IOTAgriBackend.csproj --no-restore; flutter analyze`
Expected: both commands exit 0.

- [ ] **Step 4: Update graph**

Run: `graphify update .`
Expected: graph command exits 0.

- [ ] **Step 5: Commit any graph output required by repository convention**

```bash
git status --short
git add graphify-out
git commit -m "chore: update code graph"
```

Only commit graph files if generated output is tracked and changes are limited to this feature.
