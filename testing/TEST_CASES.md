# Backend test cases

Generated from test source and actual TRX results. No planned/unwritten tests are represented as implemented.

212 test methods / 345 independently executed cases (each InlineData row is one case).
Stable IDs use the SHA-256 prefix of the full executed test name. Registry includes native TRX IDs.

All inputs, arrange/act operations and assertions are retained below from the matching test body; see the source link for complete surrounding fixtures.

Actual PASS means assertions completed, not that every backend behavior is correct. Metadata tests do not validate middleware enforcement.

## AdminBootstrapSettingsTests.IsConfigured_requires_email_and_password

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminBootstrapSettings.IsConfigured
- **Test identity:** `IOTAgriBackend.Tests.AdminBootstrapSettingsTests.IsConfigured_requires_email_and_password`
- **Test type:** Unit test
- **Scenario:** IsConfigured requires email and password
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminBootstrapSettingsTests.cs:13](../backend/tests/AdminBootstrapSettingsTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var settings = new AdminBootstrapSettings { Email = email, Password = password };

        Assert.Equal(expected, settings.IsConfigured);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-D651CE012C | IOTAgriBackend.Tests.AdminBootstrapSettingsTests.IsConfigured_requires_email_and_password(email: "admin@example.com", password: "Password123", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=e7c50ca6-fca0-724c-379e-8d7df89fd3fa; [log](reports/summary/followup-final-test.log) |
| TC-BE-8FC69C7091 | IOTAgriBackend.Tests.AdminBootstrapSettingsTests.IsConfigured_requires_email_and_password(email: "admin@example.com", password: null, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=20829d10-4763-134f-8ad2-c0520e29c601; [log](reports/summary/followup-final-test.log) |
| TC-BE-3D380D4B87 | IOTAgriBackend.Tests.AdminBootstrapSettingsTests.IsConfigured_requires_email_and_password(email: null, password: "Password123", expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=16823fa6-9d43-b8a6-d8a2-16395e413e58; [log](reports/summary/followup-final-test.log) |
| TC-BE-4A45ADEF1A | IOTAgriBackend.Tests.AdminBootstrapSettingsTests.IsConfigured_requires_email_and_password(email: null, password: null, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=36550a54-d7c2-fb18-2457-b62a46e4e554; [log](reports/summary/followup-final-test.log) |

## AdminEndpointMappingTests.Every_admin_endpoint_requires_admin_policy

- **Module:** Endpoint/security
- **Component:** AdminEndpoints.MapAdminEndpoints
- **Test identity:** `IOTAgriBackend.Tests.AdminEndpointMappingTests.Every_admin_endpoint_requires_admin_policy`
- **Test type:** Route metadata component test
- **Scenario:** Every admin endpoint requires admin policy
- **Preconditions / isolation:** Construct WebApplication without Start/Run; EF provider configured but never connected.
- **Test file:** [backend/tests/AdminEndpointMappingTests.cs:19](../backend/tests/AdminEndpointMappingTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var builder = WebApplication.CreateBuilder();
        builder.Services.AddDbContext<ApplicationDbContext>(options => options.UseNpgsql("Host=localhost;Database=admin_endpoint_test"));
        builder.Services.AddIdentityCore<ApplicationUser>().AddRoles<IdentityRole>().AddEntityFrameworkStores<ApplicationDbContext>();
        await using var app = builder.Build();
        app.MapAdminEndpoints();

        var endpoints = ((IEndpointRouteBuilder)app).DataSources.SelectMany(source => source.Endpoints)
            .OfType<RouteEndpoint>()
            .Where(endpoint => endpoint.RoutePattern.RawText?.StartsWith("/api/admin") == true)
            .ToList();

        Assert.Equal(16, endpoints.Count);
        Assert.Contains(endpoints, endpoint => endpoint.RoutePattern.RawText == "/api/admin/overview");
        Assert.Contains(endpoints, endpoint => endpoint.RoutePattern.RawText == "/api/admin/reports/summary");
        Assert.Contains(endpoints, endpoint => endpoint.RoutePattern.RawText == "/api/admin/reports.csv");
        Assert.Contains(endpoints, endpoint => endpoint.RoutePattern.RawText == "/api/admin/status");
        Assert.Contains(endpoints, endpoint => endpoint.RoutePattern.RawText == "/api/admin/settings/alert-defaults");
        Assert.All(endpoints, endpoint => Assert.Contains(endpoint.Metadata.GetOrderedMetadata<IAuthorizeData>(), data => data.Policy == "AdminOnly"));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-DBB0BB1C0F | IOTAgriBackend.Tests.AdminEndpointMappingTests.Every_admin_endpoint_requires_admin_policy | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5f89a729-fbc8-90fd-1baa-5430123810be; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesExtendedTests.Allows_locking_admin_when_multiple_admins_exist

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Allows_locking_admin_when_multiple_admins_exist`
- **Test type:** Unit test
- **Scenario:** Allows locking admin when multiple admins exist
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesExtendedTests.cs:67](../backend/tests/AdminRoleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var error = AdminRoleRules.ValidateLock("actor", "target", true, true, 2);

        Assert.Null(error);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-66819DEF53 | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Allows_locking_admin_when_multiple_admins_exist | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c6e8bf16-25f3-1367-6dad-f9fe6e56e883; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesExtendedTests.Allows_locking_non_admin_user_even_if_only_one_admin_remains

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Allows_locking_non_admin_user_even_if_only_one_admin_remains`
- **Test type:** Unit test
- **Scenario:** Allows locking non admin user even if only one admin remains
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesExtendedTests.cs:59](../backend/tests/AdminRoleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var error = AdminRoleRules.ValidateLock("actor", "target", true, false, 1);

        Assert.Null(error);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-786232F920 | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Allows_locking_non_admin_user_even_if_only_one_admin_remains | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=ed930f06-4ffa-d417-7369-022c3f52639a; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesExtendedTests.Allows_unlock_of_last_admin

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Allows_unlock_of_last_admin`
- **Test type:** Unit test
- **Scenario:** Allows unlock of last admin
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesExtendedTests.cs:50](../backend/tests/AdminRoleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // isLocked=false means we are UNLOCKING, not locking
        var error = AdminRoleRules.ValidateLock("actor", "target", false, true, 1);

        Assert.Null(error);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-66D19B3B04 | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Allows_unlock_of_last_admin | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=17418f67-4648-7829-82c6-e8412db7f355; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesExtendedTests.Allows_valid_roles_for_different_users

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Allows_valid_roles_for_different_users`
- **Test type:** Unit test
- **Scenario:** Allows valid roles for different users
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesExtendedTests.cs:12](../backend/tests/AdminRoleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var error = AdminRoleRules.Validate("actor", "target", role, false, 2);

        Assert.Null(error);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-05A45F369C | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Allows_valid_roles_for_different_users(role: "Admin") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b2020943-3f04-dd24-59c4-55c7b04a7585; [log](reports/summary/followup-final-test.log) |
| TC-BE-4640BA591A | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Allows_valid_roles_for_different_users(role: "User") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b477f59a-ec40-1bd5-7cf1-6b19adee56a6; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesExtendedTests.Demotes_admin_when_multiple_admins_exist_is_allowed

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Demotes_admin_when_multiple_admins_exist_is_allowed`
- **Test type:** Unit test
- **Scenario:** Demotes admin when multiple admins exist is allowed
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesExtendedTests.cs:41](../backend/tests/AdminRoleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var error = AdminRoleRules.Validate("actor", "target", "User", true, 2);

        Assert.Null(error);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3C097C900F | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Demotes_admin_when_multiple_admins_exist_is_allowed | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7ffe44d7-88b2-66b3-7a68-5063424abf3e; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesExtendedTests.Promotes_non_admin_to_admin_is_allowed

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Promotes_non_admin_to_admin_is_allowed`
- **Test type:** Unit test
- **Scenario:** Promotes non admin to admin is allowed
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesExtendedTests.cs:32](../backend/tests/AdminRoleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // targetIsAdmin=false means no last-admin check needed
        var error = AdminRoleRules.Validate("actor", "target", "Admin", false, 1);

        Assert.Null(error);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-C19F4C5E9B | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Promotes_non_admin_to_admin_is_allowed | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=325c9777-a765-b9fd-543c-8304343d0dac; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesExtendedTests.Rejects_all_unsupported_filter_values

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Rejects_all_unsupported_filter_values`
- **Test type:** Unit test
- **Scenario:** Rejects all unsupported filter values
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesExtendedTests.cs:90](../backend/tests/AdminRoleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var error = AdminRoleRules.ValidateListFilter(filter, out _);

        Assert.NotNull(error);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-16B0288C49 | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Rejects_all_unsupported_filter_values(filter: "all") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=3ec4c97e-27e7-77b1-c369-9865ba003790; [log](reports/summary/followup-final-test.log) |
| TC-BE-07BDF49FE1 | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Rejects_all_unsupported_filter_values(filter: "pending") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a7af0ad6-f44f-a16d-d6e1-b2937084c371; [log](reports/summary/followup-final-test.log) |
| TC-BE-9E9458D918 | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Rejects_all_unsupported_filter_values(filter: "suspended") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=234d9fd5-19db-4580-4a4c-089b7286cac2; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesExtendedTests.Rejects_invalid_role_strings

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Rejects_invalid_role_strings`
- **Test type:** Unit test
- **Scenario:** Rejects invalid role strings
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesExtendedTests.cs:24](../backend/tests/AdminRoleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var error = AdminRoleRules.Validate("actor", "target", role, false, 2);

        Assert.NotNull(error);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-2614F48427 | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Rejects_invalid_role_strings(role: "") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=61ed9775-8982-1a97-a33a-daa10006cdba; [log](reports/summary/followup-final-test.log) |
| TC-BE-ED35104132 | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Rejects_invalid_role_strings(role: "Moderator") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=48f437ee-5efa-a6de-5bf5-0880502daf93; [log](reports/summary/followup-final-test.log) |
| TC-BE-0CEB8D2EDC | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Rejects_invalid_role_strings(role: "admin") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6a1162bb-a21c-14e5-6e56-caef8b1175cd; [log](reports/summary/followup-final-test.log) |
| TC-BE-AA50710E2A | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Rejects_invalid_role_strings(role: null) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c00ba45a-8ac5-f054-f3e2-c4e277598b3d; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesExtendedTests.Trims_and_normalizes_filter

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Trims_and_normalizes_filter`
- **Test type:** Unit test
- **Scenario:** Trims and normalizes filter
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesExtendedTests.cs:78](../backend/tests/AdminRoleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var error = AdminRoleRules.ValidateListFilter(filter, out var normalized);

        Assert.Null(error);
        Assert.Equal(expectedNormalized, normalized);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-85A95040EE | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Trims_and_normalizes_filter(filter: "  ", expectedNormalized: null) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=1007afd7-60a5-da08-3f12-13f75dccf40f; [log](reports/summary/followup-final-test.log) |
| TC-BE-6F3D7B77A5 | IOTAgriBackend.Tests.AdminRoleRulesExtendedTests.Trims_and_normalizes_filter(filter: "  ACTIVE  ", expectedNormalized: "active") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=edf67103-6c0c-fe90-643a-91ca1efcbcda; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesTests.Normalizes_supported_user_filters

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesTests.Normalizes_supported_user_filters`
- **Test type:** Unit test
- **Scenario:** Normalizes supported user filters
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesTests.cs:36](../backend/tests/AdminRoleRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Null(AdminRoleRules.ValidateListFilter(filter, out var normalized));
        Assert.Equal(expected, normalized);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-32C0E826E4 | IOTAgriBackend.Tests.AdminRoleRulesTests.Normalizes_supported_user_filters(filter: "LOCKED", expected: "locked") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=db48b0f3-6a3b-0e7a-f196-ca67cc074f30; [log](reports/summary/followup-final-test.log) |
| TC-BE-9AC6F22D25 | IOTAgriBackend.Tests.AdminRoleRulesTests.Normalizes_supported_user_filters(filter: "active", expected: "active") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=0ccc4035-6453-23ea-3bd1-0f8af79544da; [log](reports/summary/followup-final-test.log) |
| TC-BE-29435A2792 | IOTAgriBackend.Tests.AdminRoleRulesTests.Normalizes_supported_user_filters(filter: "admin", expected: "admin") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7b469ec3-3686-d09a-894f-3c1e731c8b36; [log](reports/summary/followup-final-test.log) |
| TC-BE-EF2EC35F0A | IOTAgriBackend.Tests.AdminRoleRulesTests.Normalizes_supported_user_filters(filter: null, expected: null) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=69b1d711-97b5-3a36-3131-c2fcfda6123a; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesTests.Rejects_self_and_last_admin_locking

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesTests.Rejects_self_and_last_admin_locking`
- **Test type:** Unit test
- **Scenario:** Rejects self and last admin locking
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesTests.cs:23](../backend/tests/AdminRoleRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(AdminRoleRules.ValidateLock("admin", "admin", true, true, 2));
        Assert.NotNull(AdminRoleRules.ValidateLock("other", "admin", true, true, 1));
        Assert.Null(AdminRoleRules.ValidateLock("other", "admin", true, true, 2));
        Assert.Null(AdminRoleRules.ValidateLock("other", "user", false, false, 1));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3DD911FB06 | IOTAgriBackend.Tests.AdminRoleRulesTests.Rejects_self_and_last_admin_locking | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7727b9f8-7708-619b-7cf0-8c5a3618bfb3; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesTests.Rejects_self_changes_and_last_admin_demotion

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesTests.Rejects_self_changes_and_last_admin_demotion`
- **Test type:** Unit test
- **Scenario:** Rejects self changes and last admin demotion
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesTests.cs:9](../backend/tests/AdminRoleRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(AdminRoleRules.Validate("admin", "admin", "User", true, 2));
        Assert.NotNull(AdminRoleRules.Validate("other", "admin", "User", true, 1));
        Assert.Null(AdminRoleRules.Validate("other", "admin", "User", true, 2));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-148379190E | IOTAgriBackend.Tests.AdminRoleRulesTests.Rejects_self_changes_and_last_admin_demotion | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=44effef0-c831-6b1a-761c-b574f862a570; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesTests.Rejects_unknown_role

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesTests.Rejects_unknown_role`
- **Test type:** Unit test
- **Scenario:** Rejects unknown role
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesTests.cs:17](../backend/tests/AdminRoleRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(AdminRoleRules.Validate("admin", "user", "Owner", false, 1));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-90E6063CEF | IOTAgriBackend.Tests.AdminRoleRulesTests.Rejects_unknown_role | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=ce8d8e4e-65e7-573f-1c7f-94e80fe6b2e6; [log](reports/summary/followup-final-test.log) |

## AdminRoleRulesTests.Rejects_unknown_user_filter

- **Module:** Profile/provisioning/presence/admin
- **Component:** AdminRoleRules
- **Test identity:** `IOTAgriBackend.Tests.AdminRoleRulesTests.Rejects_unknown_user_filter`
- **Test type:** Unit test
- **Scenario:** Rejects unknown user filter
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/AdminRoleRulesTests.cs:43](../backend/tests/AdminRoleRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(AdminRoleRules.ValidateListFilter("pending", out _));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-01BA495A3A | IOTAgriBackend.Tests.AdminRoleRulesTests.Rejects_unknown_user_filter | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4b66eb48-3673-7afb-e5b9-fed6757757b1; [log](reports/summary/followup-final-test.log) |

## AuthHandlerTests.Locked_user_with_correct_password_must_not_receive_tokens

- **Module:** Authentication/profile
- **Component:** AuthEndpoints.LoginAsync / UpdateProfileAsync
- **Test identity:** `IOTAgriBackend.Tests.AuthHandlerTests.Locked_user_with_correct_password_must_not_receive_tokens`
- **Test type:** Handler unit test
- **Scenario:** Locked user with correct password must not receive tokens
- **Preconditions / isolation:** Mock UserManager; lockout regression also mocks DbSet/SaveChanges/ITokenService; no database.
- **Test file:** [backend/tests/AuthHandlerTests.cs:36](../backend/tests/AuthHandlerTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // Regression for the account-lock feature. No real DB or token issuer is used.
        // Intentionally retain FAIL if LoginAsync bypasses Identity lockout.
        var user = new ApplicationUser { Id = "locked-user", LockoutEnabled = true, LockoutEnd = DateTimeOffset.MaxValue };
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByEmailAsync("locked@example.test")).ReturnsAsync(user);
        users.Setup(u => u.CheckPasswordAsync(user, "QaPassword1!")).ReturnsAsync(true);
        users.Setup(u => u.IsLockedOutAsync(user)).ReturnsAsync(true);
        users.Setup(u => u.GetRolesAsync(user)).ReturnsAsync(new List<string> { "User" });
        var tokens = new Mock<ITokenService>();
        tokens.Setup(t => t.CreateAccessToken(user, It.IsAny<IList<string>>())).Returns("qa-access-token");
        tokens.Setup(t => t.GenerateRefreshTokenValue()).Returns("qa-refresh-token");
        var set = new Mock<DbSet<RefreshToken>>();
        var db = new Mock<ApplicationDbContext>(new DbContextOptionsBuilder<ApplicationDbContext>().Options);
        db.Setup(d => d.Set<RefreshToken>()).Returns(set.Object);
        db.Setup(d => d.SaveChangesAsync(It.IsAny<CancellationToken>())).ReturnsAsync(1);
        var config = new ConfigurationBuilder().AddInMemoryCollection().Build();
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LoginAsync",
            new LoginRequest("locked@example.test", "QaPassword1!"), users.Object, db.Object, tokens.Object, config);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        tokens.Verify(t => t.GenerateRefreshTokenValue(), Times.Never);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-F21073B388 | IOTAgriBackend.Tests.AuthHandlerTests.Locked_user_with_correct_password_must_not_receive_tokens | Locked user denied (401); no refresh token generated. | Assert.Equal() Failure: Values differ<br>Expected: 401<br>Actual:   200 | FAIL | BE-001; [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d38c6c64-a386-552b-384f-8d44bae70216; [log](reports/summary/followup-final-test.log) |

## AuthHandlerTests.Profile_update_normalizes_fields_resets_phone_confirmation_and_returns_roles

- **Module:** Authentication/profile
- **Component:** AuthEndpoints.LoginAsync / UpdateProfileAsync
- **Test identity:** `IOTAgriBackend.Tests.AuthHandlerTests.Profile_update_normalizes_fields_resets_phone_confirmation_and_returns_roles`
- **Test type:** Handler unit test
- **Scenario:** Profile update normalizes fields resets phone confirmation and returns roles
- **Preconditions / isolation:** Mock UserManager; lockout regression also mocks DbSet/SaveChanges/ITokenService; no database.
- **Test file:** [backend/tests/AuthHandlerTests.cs:61](../backend/tests/AuthHandlerTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var user = new ApplicationUser { Id = "qa-user", Email = "qa@example.test", PhoneNumber = "0912345678", PhoneNumberConfirmed = true };
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.GetUserAsync(It.IsAny<ClaimsPrincipal>())).ReturnsAsync(user);
        users.Setup(u => u.UpdateAsync(user)).ReturnsAsync(Microsoft.AspNetCore.Identity.IdentityResult.Success);
        users.Setup(u => u.GetRolesAsync(user)).ReturnsAsync(new List<string> { "User" });
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "UpdateProfileAsync",
            new UpdateProfileRequest("  QA Name  ", "  0987654321  "), new ClaimsPrincipal(), users.Object);
        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        var profile = Assert.IsType<UserProfileResponse>(Assert.IsAssignableFrom<IValueHttpResult>(result).Value);
        Assert.Equal("QA Name", profile.FullName);
        Assert.Equal("0987654321", profile.PhoneNumber);
        Assert.Equal(new[] { "User" }, profile.Roles);
        Assert.False(user.PhoneNumberConfirmed);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-47336D7AA5 | IOTAgriBackend.Tests.AuthHandlerTests.Profile_update_normalizes_fields_resets_phone_confirmation_and_returns_roles | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=3aa7efef-a6c5-30ce-715d-e680dfa55213; [log](reports/summary/followup-final-test.log) |

## AuthHandlerTests.Profile_update_validation_failure_does_not_persist

- **Module:** Authentication/profile
- **Component:** AuthEndpoints.LoginAsync / UpdateProfileAsync
- **Test identity:** `IOTAgriBackend.Tests.AuthHandlerTests.Profile_update_validation_failure_does_not_persist`
- **Test type:** Handler unit test
- **Scenario:** Profile update validation failure does not persist
- **Preconditions / isolation:** Mock UserManager; lockout regression also mocks DbSet/SaveChanges/ITokenService; no database.
- **Test file:** [backend/tests/AuthHandlerTests.cs:79](../backend/tests/AuthHandlerTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.GetUserAsync(It.IsAny<ClaimsPrincipal>())).ReturnsAsync(new ApplicationUser());
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "UpdateProfileAsync",
            new UpdateProfileRequest(" ", null), new ClaimsPrincipal(), users.Object);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        users.Verify(u => u.UpdateAsync(It.IsAny<ApplicationUser>()), Times.Never);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-277DC52BFD | IOTAgriBackend.Tests.AuthHandlerTests.Profile_update_validation_failure_does_not_persist | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=1c91168e-db28-344b-bd51-385b327fcff3; [log](reports/summary/followup-final-test.log) |

## AuthHandlerTests.Unknown_user_or_wrong_password_returns_unauthorized_without_database

- **Module:** Authentication/profile
- **Component:** AuthEndpoints.LoginAsync / UpdateProfileAsync
- **Test identity:** `IOTAgriBackend.Tests.AuthHandlerTests.Unknown_user_or_wrong_password_returns_unauthorized_without_database`
- **Test type:** Handler unit test
- **Scenario:** Unknown user or wrong password returns unauthorized without database
- **Preconditions / isolation:** Mock UserManager; lockout regression also mocks DbSet/SaveChanges/ITokenService; no database.
- **Test file:** [backend/tests/AuthHandlerTests.cs:24](../backend/tests/AuthHandlerTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var user = new ApplicationUser();
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByEmailAsync("qa@example.test")).ReturnsAsync(exists ? user : null);
        users.Setup(u => u.CheckPasswordAsync(user, "wrong-password")).ReturnsAsync(passwordCorrect);
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LoginAsync", new LoginRequest("qa@example.test", "wrong-password"), users.Object, null, null, null);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        users.Verify(u => u.GetRolesAsync(It.IsAny<ApplicationUser>()), Times.Never);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-C313A5E755 | IOTAgriBackend.Tests.AuthHandlerTests.Unknown_user_or_wrong_password_returns_unauthorized_without_database(exists: False, passwordCorrect: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=be4fce24-4940-fe45-3968-38d105aba0a8; [log](reports/summary/followup-final-test.log) |
| TC-BE-D46E636ED1 | IOTAgriBackend.Tests.AuthHandlerTests.Unknown_user_or_wrong_password_returns_unauthorized_without_database(exists: True, passwordCorrect: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=9b016f5f-d87d-ba2f-f76f-48062676961d; [log](reports/summary/followup-final-test.log) |

## BackendEndpointMetadataTests.All_protected_routes_have_authorization_and_public_claim_has_rate_limit_metadata

- **Module:** Endpoint/security
- **Component:** All seven Endpoint Map* registration methods
- **Test identity:** `IOTAgriBackend.Tests.BackendEndpointMetadataTests.All_protected_routes_have_authorization_and_public_claim_has_rate_limit_metadata`
- **Test type:** Route metadata component test
- **Scenario:** All protected routes have authorization and public claim has rate limit metadata
- **Preconditions / isolation:** Construct WebApplication without Start/Run; EF provider configured but never connected.
- **Test file:** [backend/tests/BackendEndpointMetadataTests.cs:22](../backend/tests/BackendEndpointMetadataTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // Component metadata test, not a middleware integration test. Never start app.
        var builder = WebApplication.CreateBuilder(new WebApplicationOptions { EnvironmentName = "Testing", Args = Array.Empty<string>() });
        builder.Services.AddDbContext<ApplicationDbContext>(o => o.UseNpgsql("Host=127.0.0.1;Port=1;Database=qa_metadata"));
        builder.Services.AddIdentityCore<ApplicationUser>().AddRoles<IdentityRole>().AddEntityFrameworkStores<ApplicationDbContext>();
        builder.Services.AddSingleton<MqttIngestionService>();
        builder.Services.AddScoped<ITokenService, TokenService>();
        await using var app = builder.Build();
        app.MapAuthEndpoints();
        app.MapAdminEndpoints();
        app.MapTicketEndpoints();
        app.MapDeviceEndpoints();
        app.MapDeviceProvisioningEndpoints();
        app.MapSensorEndpoints();
        app.MapDashboardEndpoints();
        var routes = ((IEndpointRouteBuilder)app).DataSources.SelectMany(s => s.Endpoints).OfType<RouteEndpoint>().ToList();
        Assert.Equal(49, routes.Count);
        foreach (var route in routes)
        {
            var path = route.RoutePattern.RawText!;
            var authorization = route.Metadata.GetOrderedMetadata<IAuthorizeData>();
            if (path is "/api/auth/register" or "/api/auth/login" or "/api/auth/refresh" or "/api/device-provisioning/claims")
                Assert.Empty(authorization);
            else if (path.StartsWith("/api/admin", StringComparison.Ordinal))
                Assert.Contains(authorization, a => a.Policy == "AdminOnly");
            else
                Assert.NotEmpty(authorization);
        }
        var claim = Assert.Single(routes, r => r.RoutePattern.RawText == "/api/device-provisioning/claims");
        Assert.Equal("deviceClaims", claim.Metadata.GetMetadata<EnableRateLimitingAttribute>()?.PolicyName);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-E2F428AB89 | IOTAgriBackend.Tests.BackendEndpointMetadataTests.All_protected_routes_have_authorization_and_public_claim_has_rate_limit_metadata | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=fed41466-4c45-7164-031b-50a7d95a0bdf; [log](reports/summary/followup-final-test.log) |

## BackgroundServiceGuardTests.Disabled_scheduler_completes_without_database_or_mqtt_access

- **Module:** MQTT/scheduler
- **Component:** MqttIngestionService.PublishPumpCommandAsync / ProcessReadingAsync / ProcessPumpStatusAsync; PumpScheduleDispatchService.ExecuteAsync disabled branch
- **Test identity:** `IOTAgriBackend.Tests.BackgroundServiceGuardTests.Disabled_scheduler_completes_without_database_or_mqtt_access`
- **Test type:** Unit test
- **Scenario:** Disabled scheduler completes without database or mqtt access
- **Preconditions / isolation:** Strict scope factory; MQTT client constructed but never started/connected; scheduler disabled.
- **Test file:** [backend/tests/BackgroundServiceGuardTests.cs:57](../backend/tests/BackgroundServiceGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var scopes = new Mock<IServiceScopeFactory>(MockBehavior.Strict);
        using var mqtt = Mqtt(scopes.Object);
        using var scheduler = new PumpScheduleDispatchService(scopes.Object, new ConfigurationBuilder().Build(), mqtt, NullLogger<PumpScheduleDispatchService>.Instance);
        await scheduler.StartAsync(CancellationToken.None);
        Assert.NotNull(scheduler.ExecuteTask);
        await scheduler.ExecuteTask;
        await scheduler.StopAsync(CancellationToken.None);
        scopes.Verify(s => s.CreateScope(), Times.Never);
        Assert.False(mqtt.IsConnected);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-C836589C6B | IOTAgriBackend.Tests.BackgroundServiceGuardTests.Disabled_scheduler_completes_without_database_or_mqtt_access | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=22d6a3ed-51e2-abd2-f2bc-e5f389166936; [log](reports/summary/followup-final-test.log) |

## BackgroundServiceGuardTests.Disconnected_publish_throws_without_scope_or_broker_connection

- **Module:** MQTT/scheduler
- **Component:** MqttIngestionService.PublishPumpCommandAsync / ProcessReadingAsync / ProcessPumpStatusAsync; PumpScheduleDispatchService.ExecuteAsync disabled branch
- **Test identity:** `IOTAgriBackend.Tests.BackgroundServiceGuardTests.Disconnected_publish_throws_without_scope_or_broker_connection`
- **Test type:** Unit test
- **Scenario:** Disconnected publish throws without scope or broker connection
- **Preconditions / isolation:** Strict scope factory; MQTT client constructed but never started/connected; scheduler disabled.
- **Test file:** [backend/tests/BackgroundServiceGuardTests.cs:21](../backend/tests/BackgroundServiceGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var scopes = new Mock<IServiceScopeFactory>(MockBehavior.Strict);
        using var mqtt = Mqtt(scopes.Object);
        Assert.False(mqtt.IsConnected);
        var error = await Assert.ThrowsAsync<InvalidOperationException>(() => mqtt.PublishPumpCommandAsync("qa-key", new PumpCommand(), CancellationToken.None));
        Assert.Equal("MQTT client is not connected.", error.Message);
        scopes.Verify(s => s.CreateScope(), Times.Never);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-060D54128E | IOTAgriBackend.Tests.BackgroundServiceGuardTests.Disconnected_publish_throws_without_scope_or_broker_connection | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7074b26f-c328-33da-feed-34ec922ba25d; [log](reports/summary/followup-final-test.log) |

## BackgroundServiceGuardTests.Null_json_payload_is_ignored_before_database_scope

- **Module:** MQTT/scheduler
- **Component:** MqttIngestionService.PublishPumpCommandAsync / ProcessReadingAsync / ProcessPumpStatusAsync; PumpScheduleDispatchService.ExecuteAsync disabled branch
- **Test identity:** `IOTAgriBackend.Tests.BackgroundServiceGuardTests.Null_json_payload_is_ignored_before_database_scope`
- **Test type:** Unit test
- **Scenario:** Null json payload is ignored before database scope
- **Preconditions / isolation:** Strict scope factory; MQTT client constructed but never started/connected; scheduler disabled.
- **Test file:** [backend/tests/BackgroundServiceGuardTests.cs:34](../backend/tests/BackgroundServiceGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var scopes = new Mock<IServiceScopeFactory>(MockBehavior.Strict);
        using var mqtt = Mqtt(scopes.Object);
        var args = method == "ProcessReadingAsync"
            ? new object[] { "qa-key", Encoding.UTF8.GetBytes("null") }
            : new object[] { "qa-key", Encoding.UTF8.GetBytes("null"), "devices/qa-key/pump-status" };
        await (Task)typeof(MqttIngestionService).GetMethod(method, BindingFlags.Instance | BindingFlags.NonPublic)!.Invoke(mqtt, args)!;
        scopes.Verify(s => s.CreateScope(), Times.Never);
        Assert.False(mqtt.IsConnected);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-87CC980960 | IOTAgriBackend.Tests.BackgroundServiceGuardTests.Null_json_payload_is_ignored_before_database_scope(method: "ProcessPumpStatusAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7b4a39d3-a9b6-e2ca-a7ca-1b2ee414ed31; [log](reports/summary/followup-final-test.log) |
| TC-BE-C92C4DDF0C | IOTAgriBackend.Tests.BackgroundServiceGuardTests.Null_json_payload_is_ignored_before_database_scope(method: "ProcessReadingAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=28456fc4-1d74-0fc5-7b1a-5318862f6af4; [log](reports/summary/followup-final-test.log) |

## BackgroundServiceGuardTests.Oversized_pump_status_is_ignored_before_parsing_or_database_scope

- **Module:** MQTT/scheduler
- **Component:** MqttIngestionService.PublishPumpCommandAsync / ProcessReadingAsync / ProcessPumpStatusAsync; PumpScheduleDispatchService.ExecuteAsync disabled branch
- **Test identity:** `IOTAgriBackend.Tests.BackgroundServiceGuardTests.Oversized_pump_status_is_ignored_before_parsing_or_database_scope`
- **Test type:** Unit test
- **Scenario:** Oversized pump status is ignored before parsing or database scope
- **Preconditions / isolation:** Strict scope factory; MQTT client constructed but never started/connected; scheduler disabled.
- **Test file:** [backend/tests/BackgroundServiceGuardTests.cs:47](../backend/tests/BackgroundServiceGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var scopes = new Mock<IServiceScopeFactory>(MockBehavior.Strict);
        using var mqtt = Mqtt(scopes.Object);
        await (Task)typeof(MqttIngestionService).GetMethod("ProcessPumpStatusAsync", BindingFlags.Instance | BindingFlags.NonPublic)!
            .Invoke(mqtt, new object[] { "qa-key", new byte[1025], "devices/qa-key/pump-status" })!;
        scopes.Verify(s => s.CreateScope(), Times.Never);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-4BEABF8074 | IOTAgriBackend.Tests.BackgroundServiceGuardTests.Oversized_pump_status_is_ignored_before_parsing_or_database_scope | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=798a37fb-72a1-5493-c96f-ed7d4a56ba9a; [log](reports/summary/followup-final-test.log) |

## DatabaseModelContractTests.Active_alert_uniqueness_and_schedule_occurrence_deduplication_are_configured

- **Module:** Data access
- **Component:** ApplicationDbContext.OnModelCreating
- **Test identity:** `IOTAgriBackend.Tests.DatabaseModelContractTests.Active_alert_uniqueness_and_schedule_occurrence_deduplication_are_configured`
- **Test type:** EF metadata component test
- **Scenario:** Active alert uniqueness and schedule occurrence deduplication are configured
- **Preconditions / isolation:** Npgsql model only; no connection, migration, query, or shared database.
- **Test file:** [backend/tests/DatabaseModelContractTests.cs:31](../backend/tests/DatabaseModelContractTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        using var db = Context();
        var alertIndex = Assert.Single(db.Model.FindEntityType(typeof(DeviceAlert))!.GetIndexes(), i => i.IsUnique);
        Assert.Equal(new[] { "DeviceId", "Type" }, alertIndex.Properties.Select(p => p.Name));
        Assert.Equal("\"ResolvedAt\" IS NULL", alertIndex.GetFilter());
        Assert.Contains(db.Model.FindEntityType(typeof(PumpScheduleOccurrence))!.GetIndexes(), i => i.IsUnique &&
            i.Properties.Select(p => p.Name).SequenceEqual(new[] { "ScheduleId", "OccurrenceUtc" }));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-78FC0916ED | IOTAgriBackend.Tests.DatabaseModelContractTests.Active_alert_uniqueness_and_schedule_occurrence_deduplication_are_configured | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=31097229-2468-d07e-6e04-f3c763312ea9; [log](reports/summary/followup-final-test.log) |

## DatabaseModelContractTests.Ownership_and_history_foreign_keys_have_expected_delete_rules

- **Module:** Data access
- **Component:** ApplicationDbContext.OnModelCreating
- **Test identity:** `IOTAgriBackend.Tests.DatabaseModelContractTests.Ownership_and_history_foreign_keys_have_expected_delete_rules`
- **Test type:** EF metadata component test
- **Scenario:** Ownership and history foreign keys have expected delete rules
- **Preconditions / isolation:** Npgsql model only; no connection, migration, query, or shared database.
- **Test file:** [backend/tests/DatabaseModelContractTests.cs:46](../backend/tests/DatabaseModelContractTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        using var db = Context();
        var fk = Assert.Single(db.Model.FindEntityType(type)!.GetForeignKeys(), f => f.Properties.Any(p => p.Name == property));
        Assert.Equal(behavior, fk.DeleteBehavior);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-6A9A90C145 | IOTAgriBackend.Tests.DatabaseModelContractTests.Ownership_and_history_foreign_keys_have_expected_delete_rules(type: typeof(IOTAgriBackend.Models.Device), property: "OwnerId", behavior: SetNull) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=ddfc4204-30f7-5ef7-5436-17deb1f0f817; [log](reports/summary/followup-final-test.log) |
| TC-BE-4C20433DE2 | IOTAgriBackend.Tests.DatabaseModelContractTests.Ownership_and_history_foreign_keys_have_expected_delete_rules(type: typeof(IOTAgriBackend.Models.SensorReading), property: "DeviceId", behavior: Cascade) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a6db1ca9-c115-2ee8-e593-d11622594f82; [log](reports/summary/followup-final-test.log) |
| TC-BE-21781730C9 | IOTAgriBackend.Tests.DatabaseModelContractTests.Ownership_and_history_foreign_keys_have_expected_delete_rules(type: typeof(IOTAgriBackend.Models.SupportTicket), property: "UserId", behavior: Restrict) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b2a41ca9-9053-e3ec-8369-c8b89af1051e; [log](reports/summary/followup-final-test.log) |
| TC-BE-A7D5C3D531 | IOTAgriBackend.Tests.DatabaseModelContractTests.Ownership_and_history_foreign_keys_have_expected_delete_rules(type: typeof(IOTAgriBackend.Models.SupportTicketMessage), property: "TicketId", behavior: Cascade) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=efb86a30-d2d3-2bfb-08af-23f5ce957798; [log](reports/summary/followup-final-test.log) |

## DatabaseModelContractTests.Pump_and_singleton_settings_constraints_are_in_design_time_model

- **Module:** Data access
- **Component:** ApplicationDbContext.OnModelCreating
- **Test identity:** `IOTAgriBackend.Tests.DatabaseModelContractTests.Pump_and_singleton_settings_constraints_are_in_design_time_model`
- **Test type:** EF metadata component test
- **Scenario:** Pump and singleton settings constraints are in design time model
- **Preconditions / isolation:** Npgsql model only; no connection, migration, query, or shared database.
- **Test file:** [backend/tests/DatabaseModelContractTests.cs:54](../backend/tests/DatabaseModelContractTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        using var db = Context();
        var model = db.GetService<IDesignTimeModel>().Model;
        Assert.Contains(model.FindEntityType(typeof(PumpCommand))!.GetCheckConstraints(), c => c.Name == "CK_PumpCommands_DurationSeconds" && c.Sql.Contains("> 0"));
        Assert.Contains(model.FindEntityType(typeof(SystemAlertDefaults))!.GetCheckConstraints(), c => c.Name == "CK_SystemAlertDefaults_Singleton" && c.Sql == "\"Id\" = 1");
        Assert.Equal(512, model.FindEntityType(typeof(PumpCommand))!.FindProperty("FailureReason")!.GetMaxLength());
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-97C2E9D37F | IOTAgriBackend.Tests.DatabaseModelContractTests.Pump_and_singleton_settings_constraints_are_in_design_time_model | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=0b4d0760-280e-315c-0001-8d4927029801; [log](reports/summary/followup-final-test.log) |

## DatabaseModelContractTests.Security_and_idempotency_keys_have_unique_indexes

- **Module:** Data access
- **Component:** ApplicationDbContext.OnModelCreating
- **Test identity:** `IOTAgriBackend.Tests.DatabaseModelContractTests.Security_and_idempotency_keys_have_unique_indexes`
- **Test type:** EF metadata component test
- **Scenario:** Security and idempotency keys have unique indexes
- **Preconditions / isolation:** Npgsql model only; no connection, migration, query, or shared database.
- **Test file:** [backend/tests/DatabaseModelContractTests.cs:22](../backend/tests/DatabaseModelContractTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        using var db = Context();
        var entity = db.Model.FindEntityType(type)!;
        Assert.Contains(entity.GetIndexes(), i => i.IsUnique && i.Properties.Select(p => p.Name).SequenceEqual(new[] { property }));
        Assert.Equal(System.Data.ConnectionState.Closed, db.Database.GetDbConnection().State);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-7EA07C36EF | IOTAgriBackend.Tests.DatabaseModelContractTests.Security_and_idempotency_keys_have_unique_indexes(type: typeof(IOTAgriBackend.Models.Device), property: "DeviceKey") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=1ecf0ea8-a7c1-0252-d374-4503453118f2; [log](reports/summary/followup-final-test.log) |
| TC-BE-76A5EEEFB0 | IOTAgriBackend.Tests.DatabaseModelContractTests.Security_and_idempotency_keys_have_unique_indexes(type: typeof(IOTAgriBackend.Models.Device), property: "ProvisionedHardwareId") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=0aff45a5-3aaf-79a2-4b23-2b0e2016f10d; [log](reports/summary/followup-final-test.log) |
| TC-BE-F8F7466754 | IOTAgriBackend.Tests.DatabaseModelContractTests.Security_and_idempotency_keys_have_unique_indexes(type: typeof(IOTAgriBackend.Models.PumpScheduleOccurrence), property: "CommandId") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=0c7ff6de-ca05-f75a-f91a-fc4931d7f6fd; [log](reports/summary/followup-final-test.log) |
| TC-BE-FD8E70301B | IOTAgriBackend.Tests.DatabaseModelContractTests.Security_and_idempotency_keys_have_unique_indexes(type: typeof(IOTAgriBackend.Models.RefreshToken), property: "Token") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=59afaaee-3905-6b85-5f0b-c5f66d225fe3; [log](reports/summary/followup-final-test.log) |

## DeviceAlertHistoryQueryExtendedTests.Accepts_all_known_statuses

- **Module:** Alerts
- **Component:** DeviceAlertHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Accepts_all_known_statuses`
- **Test type:** Unit test
- **Scenario:** Accepts all known statuses
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertHistoryQueryExtendedTests.cs:13](../backend/tests/DeviceAlertHistoryQueryExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Equal(expected, new DeviceAlertHistoryQuery(status).HasValidStatus);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-A340B2531D | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Accepts_all_known_statuses(status: "active", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=04608e57-b9ad-3e93-5faf-fabaf5b2253f; [log](reports/summary/followup-final-test.log) |
| TC-BE-D7C8BD6541 | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Accepts_all_known_statuses(status: "all", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=41bb3266-1e34-7560-7f28-99150672da1e; [log](reports/summary/followup-final-test.log) |
| TC-BE-D3DCDF5422 | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Accepts_all_known_statuses(status: "resolved", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a31f3f06-eb8c-41c2-3daa-6d3ea059874c; [log](reports/summary/followup-final-test.log) |

## DeviceAlertHistoryQueryExtendedTests.Default_query_uses_active_status_and_first_page

- **Module:** Alerts
- **Component:** DeviceAlertHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Default_query_uses_active_status_and_first_page`
- **Test type:** Unit test
- **Scenario:** Default query uses active status and first page
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertHistoryQueryExtendedTests.cs:41](../backend/tests/DeviceAlertHistoryQueryExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var query = new DeviceAlertHistoryQuery();

        Assert.Equal("active", query.Status);
        Assert.Equal(1, query.Page);
        Assert.Equal(50, query.PageSize);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-21F14072FD | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Default_query_uses_active_status_and_first_page | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=f500c8b7-3878-10de-66e7-e8d9a91b47c1; [log](reports/summary/followup-final-test.log) |

## DeviceAlertHistoryQueryExtendedTests.Pagination_boundary_values

- **Module:** Alerts
- **Component:** DeviceAlertHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Pagination_boundary_values`
- **Test type:** Unit test
- **Scenario:** Pagination boundary values
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertHistoryQueryExtendedTests.cs:34](../backend/tests/DeviceAlertHistoryQueryExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Equal(expected, new DeviceAlertHistoryQuery(Page: page, PageSize: pageSize).HasValidPagination);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-98A93858A8 | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Pagination_boundary_values(page: 0, pageSize: 50, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=18fb4f28-5245-5eb4-5ec4-0ba5b54cca6a; [log](reports/summary/followup-final-test.log) |
| TC-BE-A76CAA7131 | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Pagination_boundary_values(page: 1, pageSize: 0, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=577ee64a-bd31-82f8-17ce-3b19b98c2e72; [log](reports/summary/followup-final-test.log) |
| TC-BE-19532036D9 | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Pagination_boundary_values(page: 1, pageSize: 1, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=cb8bbeb7-77a1-f17d-2ce1-160536ccbc9a; [log](reports/summary/followup-final-test.log) |
| TC-BE-BA3E1DD193 | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Pagination_boundary_values(page: 1, pageSize: 100, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=8caed57b-e5ba-b790-bc3b-35988b80462a; [log](reports/summary/followup-final-test.log) |
| TC-BE-635868EEB8 | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Pagination_boundary_values(page: 1, pageSize: 101, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=57c95d52-2ca8-36ee-73e4-955e48bc1348; [log](reports/summary/followup-final-test.log) |

## DeviceAlertHistoryQueryExtendedTests.Rejects_invalid_statuses

- **Module:** Alerts
- **Component:** DeviceAlertHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Rejects_invalid_statuses`
- **Test type:** Unit test
- **Scenario:** Rejects invalid statuses
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertHistoryQueryExtendedTests.cs:22](../backend/tests/DeviceAlertHistoryQueryExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(new DeviceAlertHistoryQuery(status).HasValidStatus);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-E378E14A7D | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Rejects_invalid_statuses(status: "") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d51d37d7-0e81-cb73-1609-df458f8c5bbc; [log](reports/summary/followup-final-test.log) |
| TC-BE-50923C934A | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Rejects_invalid_statuses(status: "ACTIVE") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5445b34d-8260-1cb9-ed02-fa95d7e8ad26; [log](reports/summary/followup-final-test.log) |
| TC-BE-C1DFC5D99D | IOTAgriBackend.Tests.DeviceAlertHistoryQueryExtendedTests.Rejects_invalid_statuses(status: "pending") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=dd90b1eb-c3a4-295b-b630-17c1896442e6; [log](reports/summary/followup-final-test.log) |

## DeviceAlertHistoryQueryTests.Defaults_to_first_page_of_active_alerts

- **Module:** Alerts
- **Component:** DeviceAlertHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertHistoryQueryTests.Defaults_to_first_page_of_active_alerts`
- **Test type:** Unit test
- **Scenario:** Defaults to first page of active alerts
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertHistoryQueryTests.cs:9](../backend/tests/DeviceAlertHistoryQueryTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var query = new DeviceAlertHistoryQuery();

        Assert.Equal("active", query.Status);
        Assert.Equal(1, query.Page);
        Assert.Equal(50, query.PageSize);
        Assert.True(query.HasValidPagination);
        Assert.True(query.HasValidStatus);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-0094901FB9 | IOTAgriBackend.Tests.DeviceAlertHistoryQueryTests.Defaults_to_first_page_of_active_alerts | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5ede0c2f-9efa-0c11-5bbb-9824e8d109cf; [log](reports/summary/followup-final-test.log) |

## DeviceAlertHistoryQueryTests.Rejects_unknown_status

- **Module:** Alerts
- **Component:** DeviceAlertHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertHistoryQueryTests.Rejects_unknown_status`
- **Test type:** Unit test
- **Scenario:** Rejects unknown status
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertHistoryQueryTests.cs:23](../backend/tests/DeviceAlertHistoryQueryTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(new DeviceAlertHistoryQuery(status).HasValidStatus);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-95A7E0DC5B | IOTAgriBackend.Tests.DeviceAlertHistoryQueryTests.Rejects_unknown_status(status: "ACTIVE") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=03707cec-c9b1-635b-503e-922a101afd4f; [log](reports/summary/followup-final-test.log) |
| TC-BE-0B99F860BF | IOTAgriBackend.Tests.DeviceAlertHistoryQueryTests.Rejects_unknown_status(status: "unknown") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a78a63e3-fb67-2f10-c175-f73feb465334; [log](reports/summary/followup-final-test.log) |

## DeviceAlertResponseTests.From_maps_HighTemperature_alert_to_HIGH_TEMPERATURE_string

- **Module:** Alerts
- **Component:** DeviceAlertResponse
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertResponseTests.From_maps_HighTemperature_alert_to_HIGH_TEMPERATURE_string`
- **Test type:** Unit test
- **Scenario:** From maps HighTemperature alert to HIGH TEMPERATURE string
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertResponseTests.cs:11](../backend/tests/DeviceAlertResponseTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var alert = new DeviceAlert
        {
            Id = Guid.NewGuid(),
            Type = DeviceAlertType.HighTemperature,
            MeasuredValue = 37.5,
            Threshold = 35.0,
            TriggeredAt = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc),
            ResolvedAt = null,
        };

        var response = DeviceAlertResponse.From(alert);

        Assert.Equal("HIGH_TEMPERATURE", response.Type);
        Assert.Equal(alert.Id, response.Id);
        Assert.Equal(37.5, response.MeasuredValue);
        Assert.Equal(35.0, response.Threshold);
        Assert.Null(response.ResolvedAt);
        Assert.Equal(alert.TriggeredAt, response.TriggeredAt);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-730502AD33 | IOTAgriBackend.Tests.DeviceAlertResponseTests.From_maps_HighTemperature_alert_to_HIGH_TEMPERATURE_string | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=da140d3c-6225-7902-f08f-32f098bbed9f; [log](reports/summary/followup-final-test.log) |

## DeviceAlertResponseTests.From_maps_LowWaterLevel_alert_to_LOW_WATER_LEVEL_string

- **Module:** Alerts
- **Component:** DeviceAlertResponse
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertResponseTests.From_maps_LowWaterLevel_alert_to_LOW_WATER_LEVEL_string`
- **Test type:** Unit test
- **Scenario:** From maps LowWaterLevel alert to LOW WATER LEVEL string
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertResponseTests.cs:34](../backend/tests/DeviceAlertResponseTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var resolvedAt = new DateTime(2026, 10, 1, 14, 0, 0, DateTimeKind.Utc);
        var alert = new DeviceAlert
        {
            Id = Guid.NewGuid(),
            Type = DeviceAlertType.LowWaterLevel,
            MeasuredValue = 15.0,
            Threshold = 20.0,
            TriggeredAt = new DateTime(2026, 10, 1, 10, 0, 0, DateTimeKind.Utc),
            ResolvedAt = resolvedAt,
        };

        var response = DeviceAlertResponse.From(alert);

        Assert.Equal("LOW_WATER_LEVEL", response.Type);
        Assert.Equal(15.0, response.MeasuredValue);
        Assert.Equal(20.0, response.Threshold);
        Assert.Equal(resolvedAt, response.ResolvedAt);
        Assert.Equal(alert.Id, response.Id);
        Assert.Equal(alert.TriggeredAt, response.TriggeredAt);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-EBAFCCCD4E | IOTAgriBackend.Tests.DeviceAlertResponseTests.From_maps_LowWaterLevel_alert_to_LOW_WATER_LEVEL_string | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=f64b79b4-93ba-beec-d394-f7906bb83fd7; [log](reports/summary/followup-final-test.log) |

## DeviceAlertRulesExtendedTests.Both_device_thresholds_null_falls_back_to_system_defaults

- **Module:** Alerts
- **Component:** DeviceAlertRules
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Both_device_thresholds_null_falls_back_to_system_defaults`
- **Test type:** Unit test
- **Scenario:** Both device thresholds null falls back to system defaults
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertRulesExtendedTests.cs:11](../backend/tests/DeviceAlertRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = DeviceAlertRules.EffectiveThresholds(null, null, 35, 20);

        Assert.Equal(35, result.HighTemperatureC);
        Assert.Equal(20, result.LowWaterLevelPercent);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-70201364A8 | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Both_device_thresholds_null_falls_back_to_system_defaults | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b39072c8-6f98-af9e-551a-79809ee3dec1; [log](reports/summary/followup-final-test.log) |

## DeviceAlertRulesExtendedTests.Both_device_thresholds_override_system_defaults

- **Module:** Alerts
- **Component:** DeviceAlertRules
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Both_device_thresholds_override_system_defaults`
- **Test type:** Unit test
- **Scenario:** Both device thresholds override system defaults
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertRulesExtendedTests.cs:20](../backend/tests/DeviceAlertRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = DeviceAlertRules.EffectiveThresholds(40, 15, 35, 20);

        Assert.Equal(40, result.HighTemperatureC);
        Assert.Equal(15, result.LowWaterLevelPercent);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-2B170CC27F | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Both_device_thresholds_override_system_defaults | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6c330440-20b5-e8cc-1c1b-49ff96411f9a; [log](reports/summary/followup-final-test.log) |

## DeviceAlertRulesExtendedTests.High_temperature_boundary_conditions

- **Module:** Alerts
- **Component:** DeviceAlertRules
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.High_temperature_boundary_conditions`
- **Test type:** Unit test
- **Scenario:** High temperature boundary conditions
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertRulesExtendedTests.cs:43](../backend/tests/DeviceAlertRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = DeviceAlertRules.IsUnsafe(
            DeviceAlertType.HighTemperature,
            temperature,
            null,
            threshold,
            null);

        Assert.Equal(expected, result);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3D9677AE8A | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.High_temperature_boundary_conditions(temperature: -40, threshold: 35, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=dfc0b603-f480-ace4-2e11-c6ab8f1cf55d; [log](reports/summary/followup-final-test.log) |
| TC-BE-ABAF4F18D2 | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.High_temperature_boundary_conditions(temperature: 34.999000000000002, threshold: 35, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=17c93fe8-1831-4a47-aec1-00265b370b0f; [log](reports/summary/followup-final-test.log) |
| TC-BE-07961797DB | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.High_temperature_boundary_conditions(temperature: 35, threshold: 35, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=8e8a8974-af51-cd7c-3925-8d999c6697c2; [log](reports/summary/followup-final-test.log) |
| TC-BE-15BAEBC226 | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.High_temperature_boundary_conditions(temperature: 35.000999999999998, threshold: 35, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=926d34a3-8b68-aa00-1eaa-fcd5258fc27f; [log](reports/summary/followup-final-test.log) |

## DeviceAlertRulesExtendedTests.High_temperature_with_null_threshold_returns_null

- **Module:** Alerts
- **Component:** DeviceAlertRules
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.High_temperature_with_null_threshold_returns_null`
- **Test type:** Unit test
- **Scenario:** High temperature with null threshold returns null
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertRulesExtendedTests.cs:75](../backend/tests/DeviceAlertRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = DeviceAlertRules.IsUnsafe(
            DeviceAlertType.HighTemperature,
            36.0,
            null,
            null, // null threshold
            null);

        Assert.Null(result);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-CEEEF688E3 | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.High_temperature_with_null_threshold_returns_null | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=9d68d8c9-0175-5d08-739b-f14de2970696; [log](reports/summary/followup-final-test.log) |

## DeviceAlertRulesExtendedTests.Low_water_level_boundary_conditions

- **Module:** Alerts
- **Component:** DeviceAlertRules
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Low_water_level_boundary_conditions`
- **Test type:** Unit test
- **Scenario:** Low water level boundary conditions
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertRulesExtendedTests.cs:61](../backend/tests/DeviceAlertRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = DeviceAlertRules.IsUnsafe(
            DeviceAlertType.LowWaterLevel,
            null,
            waterLevel,
            null,
            threshold);

        Assert.Equal(expected, result);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-5C853ED5D2 | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Low_water_level_boundary_conditions(waterLevel: 100, threshold: 20, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6f195afc-1b76-a2f5-bd52-d807fc855e70; [log](reports/summary/followup-final-test.log) |
| TC-BE-001DB93588 | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Low_water_level_boundary_conditions(waterLevel: 19.998999999999999, threshold: 20, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b317eba9-65b2-7b53-6863-ac71a4306876; [log](reports/summary/followup-final-test.log) |
| TC-BE-D133FC6F65 | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Low_water_level_boundary_conditions(waterLevel: 20, threshold: 20, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=35897060-0650-3869-b3b8-73345a3468d6; [log](reports/summary/followup-final-test.log) |
| TC-BE-975D4E6B81 | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Low_water_level_boundary_conditions(waterLevel: 20.001000000000001, threshold: 20, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=19dd86c3-dce4-0584-6a2a-4250250b828e; [log](reports/summary/followup-final-test.log) |

## DeviceAlertRulesExtendedTests.Low_water_level_with_null_measurement_returns_null

- **Module:** Alerts
- **Component:** DeviceAlertRules
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Low_water_level_with_null_measurement_returns_null`
- **Test type:** Unit test
- **Scenario:** Low water level with null measurement returns null
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertRulesExtendedTests.cs:88](../backend/tests/DeviceAlertRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = DeviceAlertRules.IsUnsafe(
            DeviceAlertType.LowWaterLevel,
            null,
            null, // null measurement
            null,
            20.0);

        Assert.Null(result);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-81E47BF089 | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Low_water_level_with_null_measurement_returns_null | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=91c3872e-71f7-475b-a129-e4cda5b3f638; [log](reports/summary/followup-final-test.log) |

## DeviceAlertRulesExtendedTests.Only_water_level_device_threshold_overrides_while_temp_falls_back

- **Module:** Alerts
- **Component:** DeviceAlertRules
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Only_water_level_device_threshold_overrides_while_temp_falls_back`
- **Test type:** Unit test
- **Scenario:** Only water level device threshold overrides while temp falls back
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertRulesExtendedTests.cs:29](../backend/tests/DeviceAlertRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = DeviceAlertRules.EffectiveThresholds(null, 10, 35, 20);

        Assert.Equal(35, result.HighTemperatureC);
        Assert.Equal(10, result.LowWaterLevelPercent);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-794452A46B | IOTAgriBackend.Tests.DeviceAlertRulesExtendedTests.Only_water_level_device_threshold_overrides_while_temp_falls_back | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a2a82d0b-0291-6d8b-a72f-79eb2920bf29; [log](reports/summary/followup-final-test.log) |

## DeviceAlertRulesTests.Device_thresholds_override_global_defaults_independently

- **Module:** Alerts
- **Component:** DeviceAlertRules
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertRulesTests.Device_thresholds_override_global_defaults_independently`
- **Test type:** Unit test
- **Scenario:** Device thresholds override global defaults independently
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertRulesTests.cs:57](../backend/tests/DeviceAlertRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var thresholds = DeviceAlertRules.EffectiveThresholds(42, null, 35, 20);

        Assert.Equal(42, thresholds.HighTemperatureC);
        Assert.Equal(20, thresholds.LowWaterLevelPercent);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-7A7CE036B3 | IOTAgriBackend.Tests.DeviceAlertRulesTests.Device_thresholds_override_global_defaults_independently | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=15ad56a2-0cf9-7062-2662-b21253817b87; [log](reports/summary/followup-final-test.log) |

## DeviceAlertRulesTests.Low_water_alert_triggers_at_or_below_threshold

- **Module:** Alerts
- **Component:** DeviceAlertRules
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertRulesTests.Low_water_alert_triggers_at_or_below_threshold`
- **Test type:** Unit test
- **Scenario:** Low water alert triggers at or below threshold
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertRulesTests.cs:27](../backend/tests/DeviceAlertRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var actual = DeviceAlertRules.IsUnsafe(
            DeviceAlertType.LowWaterLevel,
            null,
            waterLevel,
            null,
            threshold);

        Assert.Equal(expected, actual);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-28FDB3960C | IOTAgriBackend.Tests.DeviceAlertRulesTests.Low_water_alert_triggers_at_or_below_threshold(waterLevel: 20, threshold: 20, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=f060d126-d92b-3127-1499-f030daf40072; [log](reports/summary/followup-final-test.log) |
| TC-BE-C48B51D202 | IOTAgriBackend.Tests.DeviceAlertRulesTests.Low_water_alert_triggers_at_or_below_threshold(waterLevel: 20.100000000000001, threshold: 20, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=70ec4600-9263-0b09-3f1c-15a0c66acb8e; [log](reports/summary/followup-final-test.log) |

## DeviceAlertRulesTests.Missing_measurement_or_threshold_does_not_resolve_or_trigger_an_alert

- **Module:** Alerts
- **Component:** DeviceAlertRules
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertRulesTests.Missing_measurement_or_threshold_does_not_resolve_or_trigger_an_alert`
- **Test type:** Unit test
- **Scenario:** Missing measurement or threshold does not resolve or trigger an alert
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertRulesTests.cs:40](../backend/tests/DeviceAlertRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Null(DeviceAlertRules.IsUnsafe(
            DeviceAlertType.HighTemperature,
            null,
            null,
            35,
            null));
        Assert.Null(DeviceAlertRules.IsUnsafe(
            DeviceAlertType.LowWaterLevel,
            null,
            10,
            null,
            null));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-142E0807C3 | IOTAgriBackend.Tests.DeviceAlertRulesTests.Missing_measurement_or_threshold_does_not_resolve_or_trigger_an_alert | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=543b95fc-da01-d4b9-7f4c-793d3c06da7f; [log](reports/summary/followup-final-test.log) |

## DeviceAlertRulesTests.Temperature_alert_triggers_at_or_above_threshold

- **Module:** Alerts
- **Component:** DeviceAlertRules
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertRulesTests.Temperature_alert_triggers_at_or_above_threshold`
- **Test type:** Unit test
- **Scenario:** Temperature alert triggers at or above threshold
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertRulesTests.cs:12](../backend/tests/DeviceAlertRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var actual = DeviceAlertRules.IsUnsafe(
            DeviceAlertType.HighTemperature,
            temperature,
            null,
            threshold,
            null);

        Assert.Equal(expected, actual);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-2C0BC075BA | IOTAgriBackend.Tests.DeviceAlertRulesTests.Temperature_alert_triggers_at_or_above_threshold(temperature: 34.899999999999999, threshold: 35, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=10b23e7d-5e17-5281-3d7c-8c33f9508a0a; [log](reports/summary/followup-final-test.log) |
| TC-BE-93E5930531 | IOTAgriBackend.Tests.DeviceAlertRulesTests.Temperature_alert_triggers_at_or_above_threshold(temperature: 35, threshold: 35, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c5f709a7-27fc-ff0c-475b-7935c9b4cc9b; [log](reports/summary/followup-final-test.log) |

## DeviceAlertSettingsRequestTests.Allows_disabled_or_finite_thresholds

- **Module:** Alerts
- **Component:** DeviceAlertSettingsRequest
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertSettingsRequestTests.Allows_disabled_or_finite_thresholds`
- **Test type:** Unit test
- **Scenario:** Allows disabled or finite thresholds
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertSettingsRequestTests.cs:9](../backend/tests/DeviceAlertSettingsRequestTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.True(new DeviceAlertSettingsRequest(null, null).IsValid);
        Assert.True(new DeviceAlertSettingsRequest(35, 20).IsValid);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-1BD6078591 | IOTAgriBackend.Tests.DeviceAlertSettingsRequestTests.Allows_disabled_or_finite_thresholds | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=bc86989e-6a21-ce9a-39f6-c62c51436e7e; [log](reports/summary/followup-final-test.log) |

## DeviceAlertSettingsRequestTests.Rejects_non_finite_and_out_of_range_water_thresholds

- **Module:** Alerts
- **Component:** DeviceAlertSettingsRequest
- **Test identity:** `IOTAgriBackend.Tests.DeviceAlertSettingsRequestTests.Rejects_non_finite_and_out_of_range_water_thresholds`
- **Test type:** Unit test
- **Scenario:** Rejects non finite and out of range water thresholds
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/DeviceAlertSettingsRequestTests.cs:16](../backend/tests/DeviceAlertSettingsRequestTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(new DeviceAlertSettingsRequest(double.NaN, 20).IsValid);
        Assert.False(new DeviceAlertSettingsRequest(35, -0.1).IsValid);
        Assert.False(new DeviceAlertSettingsRequest(35, 100.1).IsValid);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-0C4481A06A | IOTAgriBackend.Tests.DeviceAlertSettingsRequestTests.Rejects_non_finite_and_out_of_range_water_thresholds | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6e504149-d6a4-4e59-3c4a-d51424508656; [log](reports/summary/followup-final-test.log) |

## DevicePresenceExtendedTests.Device_just_seen_is_online

- **Module:** Profile/provisioning/presence/admin
- **Component:** DevicePresence
- **Test identity:** `IOTAgriBackend.Tests.DevicePresenceExtendedTests.Device_just_seen_is_online`
- **Test type:** Unit test
- **Scenario:** Device just seen is online
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/DevicePresenceExtendedTests.cs:38](../backend/tests/DevicePresenceExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);

        Assert.False(DevicePresence.IsOffline(now, now));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-4DC6E59884 | IOTAgriBackend.Tests.DevicePresenceExtendedTests.Device_just_seen_is_online | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=02e24f4c-ee1b-1a24-c366-2837f5bff746; [log](reports/summary/followup-final-test.log) |

## DevicePresenceExtendedTests.Device_seen_exactly_at_offline_threshold_is_offline

- **Module:** Profile/provisioning/presence/admin
- **Component:** DevicePresence
- **Test identity:** `IOTAgriBackend.Tests.DevicePresenceExtendedTests.Device_seen_exactly_at_offline_threshold_is_offline`
- **Test type:** Unit test
- **Scenario:** Device seen exactly at offline threshold is offline
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/DevicePresenceExtendedTests.cs:20](../backend/tests/DevicePresenceExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);
        var lastSeen = now - OfflineAfter; // exactly at boundary

        Assert.True(DevicePresence.IsOffline(lastSeen, now));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-699D0C0619 | IOTAgriBackend.Tests.DevicePresenceExtendedTests.Device_seen_exactly_at_offline_threshold_is_offline | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=be3d38a2-0238-6bc6-4477-4667054fc727; [log](reports/summary/followup-final-test.log) |

## DevicePresenceExtendedTests.Device_seen_in_the_future_relative_to_now_is_online

- **Module:** Profile/provisioning/presence/admin
- **Component:** DevicePresence
- **Test identity:** `IOTAgriBackend.Tests.DevicePresenceExtendedTests.Device_seen_in_the_future_relative_to_now_is_online`
- **Test type:** Unit test
- **Scenario:** Device seen in the future relative to now is online
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/DevicePresenceExtendedTests.cs:46](../backend/tests/DevicePresenceExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // Handles clock skew gracefully
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);
        var lastSeen = now.AddSeconds(5);

        Assert.False(DevicePresence.IsOffline(lastSeen, now));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-48C623C8CE | IOTAgriBackend.Tests.DevicePresenceExtendedTests.Device_seen_in_the_future_relative_to_now_is_online | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=77bfbc19-18dc-6f2a-025f-4751e78fb66b; [log](reports/summary/followup-final-test.log) |

## DevicePresenceExtendedTests.Device_seen_one_millisecond_before_threshold_is_online

- **Module:** Profile/provisioning/presence/admin
- **Component:** DevicePresence
- **Test identity:** `IOTAgriBackend.Tests.DevicePresenceExtendedTests.Device_seen_one_millisecond_before_threshold_is_online`
- **Test type:** Unit test
- **Scenario:** Device seen one millisecond before threshold is online
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/DevicePresenceExtendedTests.cs:29](../backend/tests/DevicePresenceExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);
        var lastSeen = now - OfflineAfter + TimeSpan.FromMilliseconds(1);

        Assert.False(DevicePresence.IsOffline(lastSeen, now));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-33658F4625 | IOTAgriBackend.Tests.DevicePresenceExtendedTests.Device_seen_one_millisecond_before_threshold_is_online | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=61c292b3-f17c-1610-cc8a-0ac8ff5553f7; [log](reports/summary/followup-final-test.log) |

## DevicePresenceExtendedTests.Device_with_null_lastSeenAt_is_always_offline

- **Module:** Profile/provisioning/presence/admin
- **Component:** DevicePresence
- **Test identity:** `IOTAgriBackend.Tests.DevicePresenceExtendedTests.Device_with_null_lastSeenAt_is_always_offline`
- **Test type:** Unit test
- **Scenario:** Device with null lastSeenAt is always offline
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/DevicePresenceExtendedTests.cs:12](../backend/tests/DevicePresenceExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);

        Assert.True(DevicePresence.IsOffline(null, now));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-E3FB560C35 | IOTAgriBackend.Tests.DevicePresenceExtendedTests.Device_with_null_lastSeenAt_is_always_offline | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=166e0bc8-cb72-f7ae-842e-93b228fad476; [log](reports/summary/followup-final-test.log) |

## DevicePresenceExtendedTests.OfflineAfter_constant_is_thirty_seconds

- **Module:** Profile/provisioning/presence/admin
- **Component:** DevicePresence
- **Test identity:** `IOTAgriBackend.Tests.DevicePresenceExtendedTests.OfflineAfter_constant_is_thirty_seconds`
- **Test type:** Unit test
- **Scenario:** OfflineAfter constant is thirty seconds
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/DevicePresenceExtendedTests.cs:56](../backend/tests/DevicePresenceExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Equal(TimeSpan.FromSeconds(30), DevicePresence.OfflineAfter);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-BEA52B585C | IOTAgriBackend.Tests.DevicePresenceExtendedTests.OfflineAfter_constant_is_thirty_seconds | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c9fbf1a7-7b67-ccc3-1d19-d50a5260533a; [log](reports/summary/followup-final-test.log) |

## DevicePresenceTests.Marks_devices_offline_after_thirty_seconds_without_a_reading

- **Module:** Profile/provisioning/presence/admin
- **Component:** DevicePresence
- **Test identity:** `IOTAgriBackend.Tests.DevicePresenceTests.Marks_devices_offline_after_thirty_seconds_without_a_reading`
- **Test type:** Unit test
- **Scenario:** Marks devices offline after thirty seconds without a reading
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/DevicePresenceTests.cs:10](../backend/tests/DevicePresenceTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);

        Assert.False(DevicePresence.IsOffline(now.AddSeconds(-29), now));
        Assert.True(DevicePresence.IsOffline(now.AddSeconds(-30), now));
        Assert.True(DevicePresence.IsOffline(null, now));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-EE6D20E82F | IOTAgriBackend.Tests.DevicePresenceTests.Marks_devices_offline_after_thirty_seconds_without_a_reading | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=404d3124-a263-7f9a-372c-65af8d6b6be5; [log](reports/summary/followup-final-test.log) |

## DtoValidationContractTests.Claim_annotation_contract_checks_required_fields_and_exact_length_boundaries

- **Module:** DTO validation
- **Component:** RegisterRequest / ClaimDeviceRequest constructor ValidationAttribute declarations
- **Test identity:** `IOTAgriBackend.Tests.DtoValidationContractTests.Claim_annotation_contract_checks_required_fields_and_exact_length_boundaries`
- **Test type:** Unit test
- **Scenario:** Claim annotation contract checks required fields and exact length boundaries
- **Preconditions / isolation:** Validate declared constructor parameter attributes; does not validate automatic HTTP middleware execution.
- **Test file:** [backend/tests/DtoValidationContractTests.cs:50](../backend/tests/DtoValidationContractTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var request = new ClaimDeviceRequest(new string('A', codeLength), new string('H', hardwareLength));
        var results = new List<ValidationResult>();
        Assert.Equal(expected, ValidateConstructorAnnotations(request, results));
        if (!expected) Assert.NotEmpty(results);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-0530E54F56 | IOTAgriBackend.Tests.DtoValidationContractTests.Claim_annotation_contract_checks_required_fields_and_exact_length_boundaries(codeLength: 0, hardwareLength: 1, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7d4e6bff-2aa6-d39c-296b-9a85b802566e; [log](reports/summary/followup-final-test.log) |
| TC-BE-3CF1F86812 | IOTAgriBackend.Tests.DtoValidationContractTests.Claim_annotation_contract_checks_required_fields_and_exact_length_boundaries(codeLength: 1, hardwareLength: 0, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d217a419-ab8f-a88e-734f-24ffb2cae108; [log](reports/summary/followup-final-test.log) |
| TC-BE-FF1B8E40A1 | IOTAgriBackend.Tests.DtoValidationContractTests.Claim_annotation_contract_checks_required_fields_and_exact_length_boundaries(codeLength: 64, hardwareLength: 128, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=ccceb9ce-ff9a-208e-cb52-c038537e76d8; [log](reports/summary/followup-final-test.log) |
| TC-BE-50E5337380 | IOTAgriBackend.Tests.DtoValidationContractTests.Claim_annotation_contract_checks_required_fields_and_exact_length_boundaries(codeLength: 64, hardwareLength: 129, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=df5bdc21-5d15-25be-4426-8af520a174bc; [log](reports/summary/followup-final-test.log) |
| TC-BE-B37FC25878 | IOTAgriBackend.Tests.DtoValidationContractTests.Claim_annotation_contract_checks_required_fields_and_exact_length_boundaries(codeLength: 65, hardwareLength: 128, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=f63185bb-1ccd-a0f1-a1df-bcbfc8327477; [log](reports/summary/followup-final-test.log) |

## DtoValidationContractTests.Registration_annotation_contract_enforces_email_password_length_and_name

- **Module:** DTO validation
- **Component:** RegisterRequest / ClaimDeviceRequest constructor ValidationAttribute declarations
- **Test identity:** `IOTAgriBackend.Tests.DtoValidationContractTests.Registration_annotation_contract_enforces_email_password_length_and_name`
- **Test type:** Unit test
- **Scenario:** Registration annotation contract enforces email password length and name
- **Preconditions / isolation:** Validate declared constructor parameter attributes; does not validate automatic HTTP middleware execution.
- **Test file:** [backend/tests/DtoValidationContractTests.cs:36](../backend/tests/DtoValidationContractTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var request = new RegisterRequest(email, password, name);
        var results = new List<ValidationResult>();
        Assert.Equal(expected, ValidateConstructorAnnotations(request, results));
        if (!expected) Assert.NotEmpty(results);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3FA714DB80 | IOTAgriBackend.Tests.DtoValidationContractTests.Registration_annotation_contract_enforces_email_password_length_and_name(email: "", password: "12345678", name: "QA", expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=00070543-940f-0908-2aa2-2625698734e1; [log](reports/summary/followup-final-test.log) |
| TC-BE-955D47E03A | IOTAgriBackend.Tests.DtoValidationContractTests.Registration_annotation_contract_enforces_email_password_length_and_name(email: "bad-email", password: "12345678", name: "QA", expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=de3068e3-da92-3f05-9583-64a9b7a9b6a7; [log](reports/summary/followup-final-test.log) |
| TC-BE-A030D8A7F4 | IOTAgriBackend.Tests.DtoValidationContractTests.Registration_annotation_contract_enforces_email_password_length_and_name(email: "qa@example.test", password: "1234567", name: "QA", expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4a3d352f-bfdd-b429-dcd2-99f902341ddb; [log](reports/summary/followup-final-test.log) |
| TC-BE-519A5D671F | IOTAgriBackend.Tests.DtoValidationContractTests.Registration_annotation_contract_enforces_email_password_length_and_name(email: "qa@example.test", password: "12345678", name: " ", expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4ed21817-6742-e5a5-8ca8-a940b7edf39a; [log](reports/summary/followup-final-test.log) |
| TC-BE-4A53BA4C9B | IOTAgriBackend.Tests.DtoValidationContractTests.Registration_annotation_contract_enforces_email_password_length_and_name(email: "qa@example.test", password: "12345678", name: "QA", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=e51703f2-f790-6a89-0105-c217d50303da; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Admin_lists_reject_invalid_pagination_before_accessing_database

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Admin_lists_reject_invalid_pagination_before_accessing_database`
- **Test type:** Handler unit test
- **Scenario:** Admin lists reject invalid pagination before accessing database
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:115](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var userResult = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "ListUsersAsync", null, null, null, null, page, size);
        var deviceResult = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "ListDevicesAsync", null, null, null, page, size);
        var auditResult = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "ListAuditLogsAsync", null, null, null, null, page, size);
        foreach (var result in new[] { userResult, deviceResult, auditResult })
        {
            Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
            Assert.NotNull(Assert.IsAssignableFrom<IValueHttpResult>(result).Value);
        }
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-4439F0C799 | IOTAgriBackend.Tests.EndpointGuardTests.Admin_lists_reject_invalid_pagination_before_accessing_database(page: 0, size: 50) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=715ac0f8-1f94-5c58-ae33-94e1bddb41a8; [log](reports/summary/followup-final-test.log) |
| TC-BE-800E9990DD | IOTAgriBackend.Tests.EndpointGuardTests.Admin_lists_reject_invalid_pagination_before_accessing_database(page: 1, size: 0) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6880a756-334f-8be6-e3d4-c630ab737f67; [log](reports/summary/followup-final-test.log) |
| TC-BE-E8908F9CC5 | IOTAgriBackend.Tests.EndpointGuardTests.Admin_lists_reject_invalid_pagination_before_accessing_database(page: 1, size: 101) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=f906bca3-c028-fe7e-ead8-cd2479fec938; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Admin_mutations_reject_missing_actor_before_using_dependencies

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Admin_mutations_reject_missing_actor_before_using_dependencies`
- **Test type:** Handler unit test
- **Scenario:** Admin mutations reject missing actor before using dependencies
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:82](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        object?[] args = method switch
        {
            "UpdateRoleAsync" or "UpdateLockAsync" => new object?[] { "target", null, Anonymous, null, null },
            "UpdateDeviceOwnerAsync" => new object?[] { Guid.Empty, null, Anonymous, null, null },
            _ => new object?[] { null, Anonymous, null },
        };
        var result = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), method, args);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-025A0D5B96 | IOTAgriBackend.Tests.EndpointGuardTests.Admin_mutations_reject_missing_actor_before_using_dependencies(method: "UpdateAlertDefaultsAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=62959ee1-e01a-6c02-9496-85eefe08008e; [log](reports/summary/followup-final-test.log) |
| TC-BE-6307A70935 | IOTAgriBackend.Tests.EndpointGuardTests.Admin_mutations_reject_missing_actor_before_using_dependencies(method: "UpdateDeviceOwnerAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a4756952-084c-40b4-8a80-9f2b3a933fed; [log](reports/summary/followup-final-test.log) |
| TC-BE-FCF521248F | IOTAgriBackend.Tests.EndpointGuardTests.Admin_mutations_reject_missing_actor_before_using_dependencies(method: "UpdateLockAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d546c484-726f-166c-4779-7551906e72a2; [log](reports/summary/followup-final-test.log) |
| TC-BE-4F53E23BE0 | IOTAgriBackend.Tests.EndpointGuardTests.Admin_mutations_reject_missing_actor_before_using_dependencies(method: "UpdateRoleAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=37a0da4e-9363-06c7-a32e-d7574f170672; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Daily_medians_reject_non_monday_week_start

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Daily_medians_reject_non_monday_week_start`
- **Test type:** Handler unit test
- **Scenario:** Daily medians reject non monday week start
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:167](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = await BackendTestDoubles.InvokeHandler(typeof(SensorEndpoints), "GetDailyMediansAsync", Guid.Empty, new DateOnly(2026, 1, 6), Actor(), null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3535C91E3B | IOTAgriBackend.Tests.EndpointGuardTests.Daily_medians_reject_non_monday_week_start | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=657ee397-4ed7-4f99-1a16-e584e0bf0215; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Dashboard_rejects_missing_identity_without_querying_database

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Dashboard_rejects_missing_identity_without_querying_database`
- **Test type:** Handler unit test
- **Scenario:** Dashboard rejects missing identity without querying database
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:71](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = await BackendTestDoubles.InvokeHandler(typeof(DashboardEndpoints), "GetOverviewAsync", Anonymous, null);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-CF3CFF834D | IOTAgriBackend.Tests.EndpointGuardTests.Dashboard_rejects_missing_identity_without_querying_database | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=09d69fca-fe78-dc56-267e-bff726be4725; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies`
- **Test type:** Handler unit test
- **Scenario:** Device handlers reject missing user id before accessing dependencies
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:35](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        object?[] args = method switch
        {
            "CreateAsync" => new object?[] { new CreateDeviceRequest("QA"), Anonymous, null },
            "ListAsync" => new object?[] { Anonymous, null },
            "UpdateAsync" or "UpdateAlertSettingsAsync" => new object?[] { Guid.Empty, null, Anonymous, null },
            "SendPumpCommandAsync" => new object?[] { Guid.Empty, null, Anonymous, null, null, null, CancellationToken.None },
            "GetPumpCommandsAsync" or "GetAlertsAsync" => new object?[] { Guid.Empty, Anonymous, null, null },
            "CreatePumpScheduleAsync" => new object?[] { Guid.Empty, null, Anonymous, null, null },
            "UpdatePumpScheduleAsync" => new object?[] { Guid.Empty, Guid.Empty, null, Anonymous, null, null },
            "DeletePumpScheduleAsync" => new object?[] { Guid.Empty, Guid.Empty, Anonymous, null },
            _ => new object?[] { Guid.Empty, Anonymous, null },
        };
        var result = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), method, args);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-67505AB946 | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "CreateAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=793ae0f1-0d27-9db1-7b19-748504883b81; [log](reports/summary/followup-final-test.log) |
| TC-BE-067F1F4B56 | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "CreatePumpScheduleAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=ff83a452-411b-2d4a-cc2e-35d4111c772a; [log](reports/summary/followup-final-test.log) |
| TC-BE-C82E6CE0AB | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "DeleteAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=bfb09dee-a1ea-6082-f797-df8a153758a5; [log](reports/summary/followup-final-test.log) |
| TC-BE-58C3B75AD9 | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "DeletePumpScheduleAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=18fa4013-dbf2-6210-7ef7-6db4ab664f34; [log](reports/summary/followup-final-test.log) |
| TC-BE-1F3FF18FC5 | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "GetAlertSettingsAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=eee46903-a725-e77c-6716-1d0afd01badb; [log](reports/summary/followup-final-test.log) |
| TC-BE-6E9B6DB41A | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "GetAlertsAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=2cf1d832-f0be-b0a0-38b7-608438c32538; [log](reports/summary/followup-final-test.log) |
| TC-BE-CE01FE592A | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "GetAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=e456ff84-d280-a0d4-a29c-3c11e666131d; [log](reports/summary/followup-final-test.log) |
| TC-BE-437D7408F8 | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "GetPumpCommandsAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=de7608bc-5761-94e6-eae6-26f2b19c7db7; [log](reports/summary/followup-final-test.log) |
| TC-BE-6B33B8554C | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "ListAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6b8b36e8-3d95-f713-adc0-4ff987f8a22b; [log](reports/summary/followup-final-test.log) |
| TC-BE-D827AE7F51 | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "ListPumpSchedulesAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=3dfd3b09-d213-258f-6405-bcdf36005598; [log](reports/summary/followup-final-test.log) |
| TC-BE-71E2AB56C0 | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "SendPumpCommandAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=3323334b-ccfd-bace-2e3d-951bc05c0416; [log](reports/summary/followup-final-test.log) |
| TC-BE-0B421F9BEA | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "UpdateAlertSettingsAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=8f15c0c8-90a9-9eb2-795d-17c32e681c3a; [log](reports/summary/followup-final-test.log) |
| TC-BE-54DBCA5764 | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "UpdateAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=71c4776b-b412-b1ab-d990-d8073bfe363f; [log](reports/summary/followup-final-test.log) |
| TC-BE-17502AF78C | IOTAgriBackend.Tests.EndpointGuardTests.Device_handlers_reject_missing_user_id_before_accessing_dependencies(method: "UpdatePumpScheduleAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=ba6419dd-c4d2-dede-dae3-bb9061f5db77; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Invalid_aggregation_interval_returns_bad_request_before_database_access

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Invalid_aggregation_interval_returns_bad_request_before_database_access`
- **Test type:** Handler unit test
- **Scenario:** Invalid aggregation interval returns bad request before database access
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:159](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = await BackendTestDoubles.InvokeHandler(typeof(SensorEndpoints), "GetAggregatedReadingsAsync", Guid.Empty, Actor(), null, "DROP TABLE", null, null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Contains("Invalid interval", Assert.IsType<string>(Assert.IsAssignableFrom<IValueHttpResult>(result).Value));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-55FFC7E343 | IOTAgriBackend.Tests.EndpointGuardTests.Invalid_aggregation_interval_returns_bad_request_before_database_access | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d4cac32d-e081-134e-7ea0-e9111d9bb80d; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Invalid_system_thresholds_return_bad_request_before_database_access

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Invalid_system_thresholds_return_bad_request_before_database_access`
- **Test type:** Handler unit test
- **Scenario:** Invalid system thresholds return bad request before database access
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:184](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "UpdateAlertDefaultsAsync", new UpdateSystemAlertDefaultsRequest(35, 101), Actor(), null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-AC130680E5 | IOTAgriBackend.Tests.EndpointGuardTests.Invalid_system_thresholds_return_bad_request_before_database_access | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=667fcea3-18af-e655-6aef-211ebdebcaa1; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Provisioning_rejects_missing_code_or_hardware_without_database

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Provisioning_rejects_missing_code_or_hardware_without_database`
- **Test type:** Handler unit test
- **Scenario:** Provisioning rejects missing code or hardware without database
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:177](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = await BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "ClaimAsync", new ClaimDeviceRequest(code!, hardware!), null, null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-B9C0D1C5F3 | IOTAgriBackend.Tests.EndpointGuardTests.Provisioning_rejects_missing_code_or_hardware_without_database(code: " ", hardware: "hardware") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=64d65375-85b0-4e77-57e3-ef8c8330e1b6; [log](reports/summary/followup-final-test.log) |
| TC-BE-4E119B38A4 | IOTAgriBackend.Tests.EndpointGuardTests.Provisioning_rejects_missing_code_or_hardware_without_database(code: "code", hardware: null) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=bd7af05e-c508-f261-c617-c263e7155346; [log](reports/summary/followup-final-test.log) |
| TC-BE-6AE11213C9 | IOTAgriBackend.Tests.EndpointGuardTests.Provisioning_rejects_missing_code_or_hardware_without_database(code: null, hardware: "hardware") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=34759c12-184c-df5b-9bed-11547263a886; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Registration_missing_email_returns_validation_problem_without_user_store

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Registration_missing_email_returns_validation_problem_without_user_store`
- **Test type:** Handler unit test
- **Scenario:** Registration missing email returns validation problem without user store
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:150](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "RegisterAsync", new RegisterRequest("", "QaPassword1!", "QA"), null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        var problem = Assert.IsType<HttpValidationProblemDetails>(Assert.IsAssignableFrom<IValueHttpResult>(result).Value);
        Assert.Contains("request", problem.Errors.Keys);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-BC17E2105B | IOTAgriBackend.Tests.EndpointGuardTests.Registration_missing_email_returns_validation_problem_without_user_store | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4727eef0-b544-f401-79c2-eb48f5fd0c98; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Sensor_handlers_reject_missing_identity_without_querying_database

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Sensor_handlers_reject_missing_identity_without_querying_database`
- **Test type:** Handler unit test
- **Scenario:** Sensor handlers reject missing identity without querying database
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:58](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        object?[] args = method switch
        {
            "GetReadingsAsync" => new object?[] { Guid.Empty, Anonymous, null, 50 },
            "GetAggregatedReadingsAsync" => new object?[] { Guid.Empty, Anonymous, null, "hour", null, null },
            _ => new object?[] { Guid.Empty, new DateOnly(2026, 1, 5), Anonymous, null },
        };
        var result = await BackendTestDoubles.InvokeHandler(typeof(SensorEndpoints), method, args);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-67A41F9AE5 | IOTAgriBackend.Tests.EndpointGuardTests.Sensor_handlers_reject_missing_identity_without_querying_database(method: "GetAggregatedReadingsAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7c7684a5-767b-60d3-bc53-38a6cb37f9a3; [log](reports/summary/followup-final-test.log) |
| TC-BE-914131AAA1 | IOTAgriBackend.Tests.EndpointGuardTests.Sensor_handlers_reject_missing_identity_without_querying_database(method: "GetDailyMediansAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=98224830-c382-2490-0e58-e738b20d69ce; [log](reports/summary/followup-final-test.log) |
| TC-BE-76973D7B96 | IOTAgriBackend.Tests.EndpointGuardTests.Sensor_handlers_reject_missing_identity_without_querying_database(method: "GetHourlyMediansAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=727b3ca1-48fd-9a1b-f310-785ca131d942; [log](reports/summary/followup-final-test.log) |
| TC-BE-D86C48B953 | IOTAgriBackend.Tests.EndpointGuardTests.Sensor_handlers_reject_missing_identity_without_querying_database(method: "GetReadingsAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d8f9a4c4-38b4-bebc-559f-45d4c07abb7a; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Ticket_creation_rejects_missing_text_before_user_lookup

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Ticket_creation_rejects_missing_text_before_user_lookup`
- **Test type:** Handler unit test
- **Scenario:** Ticket creation rejects missing text before user lookup
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:132](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "CreateAsync",
            new CreateSupportTicketRequest(subject, message), Actor(), null, null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-8F2BBA4D43 | IOTAgriBackend.Tests.EndpointGuardTests.Ticket_creation_rejects_missing_text_before_user_lookup(subject: "  ", message: "message") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=ad908219-595f-b05a-53e1-fb2aa0345021; [log](reports/summary/followup-final-test.log) |
| TC-BE-807E20E95F | IOTAgriBackend.Tests.EndpointGuardTests.Ticket_creation_rejects_missing_text_before_user_lookup(subject: "subject", message: " ") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d7078779-70d7-0d92-d324-4cf2f1d920cd; [log](reports/summary/followup-final-test.log) |
| TC-BE-C118871A2A | IOTAgriBackend.Tests.EndpointGuardTests.Ticket_creation_rejects_missing_text_before_user_lookup(subject: "subject", message: null) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=01b63dc2-1eed-3f81-1085-36b8b3932c54; [log](reports/summary/followup-final-test.log) |
| TC-BE-20A52E1B04 | IOTAgriBackend.Tests.EndpointGuardTests.Ticket_creation_rejects_missing_text_before_user_lookup(subject: null, message: "message") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=eadac5c0-ecb5-9c78-5b2f-7eb9770d68be; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Ticket_creation_rejects_text_over_limits

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Ticket_creation_rejects_text_over_limits`
- **Test type:** Handler unit test
- **Scenario:** Ticket creation rejects text over limits
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:142](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var result = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "CreateAsync",
            new CreateSupportTicketRequest(new string('s', subjectLength), new string('m', messageLength)), Actor(), null, null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-37DD07FBD6 | IOTAgriBackend.Tests.EndpointGuardTests.Ticket_creation_rejects_text_over_limits(subjectLength: 1, messageLength: 4001) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=f7b52e67-7b04-eb49-f62b-daace172bacd; [log](reports/summary/followup-final-test.log) |
| TC-BE-AAAD6AF739 | IOTAgriBackend.Tests.EndpointGuardTests.Ticket_creation_rejects_text_over_limits(subjectLength: 201, messageLength: 1) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=37e70131-e1dd-66fa-4710-6c3fc513d82b; [log](reports/summary/followup-final-test.log) |

## EndpointGuardTests.Ticket_mutations_reject_missing_actor_before_using_dependencies

- **Module:** Endpoint validation
- **Component:** DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body
- **Test identity:** `IOTAgriBackend.Tests.EndpointGuardTests.Ticket_mutations_reject_missing_actor_before_using_dependencies`
- **Test type:** Handler unit test
- **Scenario:** Ticket mutations reject missing actor before using dependencies
- **Preconditions / isolation:** Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access.
- **Test file:** [backend/tests/EndpointGuardTests.cs:99](../backend/tests/EndpointGuardTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        object?[] args = method switch
        {
            "CreateAsync" => new object?[] { null, Anonymous, null, null },
            "ReplyAsync" => new object?[] { Guid.Empty, null, Anonymous, null, null },
            _ => new object?[] { Guid.Empty, null, Anonymous, null },
        };
        var result = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), method, args);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-7526B9CE71 | IOTAgriBackend.Tests.EndpointGuardTests.Ticket_mutations_reject_missing_actor_before_using_dependencies(method: "CreateAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b2b755a3-7f96-454e-1a09-fc05540cf926; [log](reports/summary/followup-final-test.log) |
| TC-BE-764E5434C6 | IOTAgriBackend.Tests.EndpointGuardTests.Ticket_mutations_reject_missing_actor_before_using_dependencies(method: "ReplyAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b3eb48dc-b9ea-ed26-fab3-4810eb998477; [log](reports/summary/followup-final-test.log) |
| TC-BE-88347FDAC9 | IOTAgriBackend.Tests.EndpointGuardTests.Ticket_mutations_reject_missing_actor_before_using_dependencies(method: "UpdatePriorityAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=fe7a3dff-512f-943a-16c5-7ee48bcc6eb9; [log](reports/summary/followup-final-test.log) |
| TC-BE-DC76332623 | IOTAgriBackend.Tests.EndpointGuardTests.Ticket_mutations_reject_missing_actor_before_using_dependencies(method: "UpdateStatusAsync") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a8563e98-8e61-2088-50eb-6fc29d502e6e; [log](reports/summary/followup-final-test.log) |

## HttpIntegrationTests.Cors_preflight_allows_configured_frontend_origin_and_omits_unknown_origin

- **Module:** HTTP/security/validation
- **Component:** Auth/Device/Ticket/Provisioning/Admin routes with real JWT authorization, CORS, rate-limiter and Identity/EF persistence
- **Test identity:** `IOTAgriBackend.Tests.HttpIntegrationTests.Cors_preflight_allows_configured_frontend_origin_and_omits_unknown_origin`
- **Test type:** HTTP component integration test
- **Scenario:** Cors preflight allows configured frontend origin and omits unknown origin
- **Preconditions / isolation:** ASP.NET TestHost with real routes, Identity/JWT and disposable PostgreSQL; fresh request scopes. Pipeline reconstructed from Program.cs without executing production startup/hosted jobs.
- **Test file:** [backend/tests/HttpIntegrationTests.cs:60](../backend/tests/HttpIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        using var request = new HttpRequestMessage(HttpMethod.Options, "/api/auth/login");
        request.Headers.Add("Origin", "http://localhost:8081");
        request.Headers.Add("Access-Control-Request-Method", "POST");
        using var response = await client.SendAsync(request);
        Assert.Equal("http://localhost:8081", Assert.Single(response.Headers.GetValues("Access-Control-Allow-Origin")));
        using var unknown = new HttpRequestMessage(HttpMethod.Options, "/api/auth/login");
        unknown.Headers.Add("Origin", "http://unknown.example.test");
        unknown.Headers.Add("Access-Control-Request-Method", "POST");
        using var refused = await client.SendAsync(unknown);
        Assert.False(refused.Headers.Contains("Access-Control-Allow-Origin"));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-E0CAD636BF | IOTAgriBackend.Tests.HttpIntegrationTests.Cors_preflight_allows_configured_frontend_origin_and_omits_unknown_origin | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=114d35f6-c995-bbba-6b52-03b9944476b4; [log](reports/summary/followup-final-test.log) |

## HttpIntegrationTests.Device_create_over_http_must_reject_blank_required_name

- **Module:** HTTP/security/validation
- **Component:** Auth/Device/Ticket/Provisioning/Admin routes with real JWT authorization, CORS, rate-limiter and Identity/EF persistence
- **Test identity:** `IOTAgriBackend.Tests.HttpIntegrationTests.Device_create_over_http_must_reject_blank_required_name`
- **Test type:** HTTP component integration test
- **Scenario:** Device create over http must reject blank required name
- **Preconditions / isolation:** ASP.NET TestHost with real routes, Identity/JWT and disposable PostgreSQL; fresh request scopes. Pipeline reconstructed from Program.cs without executing production startup/hosted jobs.
- **Test file:** [backend/tests/HttpIntegrationTests.cs:136](../backend/tests/HttpIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        var tokens = await RegisterLogin(client);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        using var response = await client.PostAsJsonAsync("/api/devices/", new CreateDeviceRequest(" "));
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-68FB64C3A3 | IOTAgriBackend.Tests.HttpIntegrationTests.Device_create_over_http_must_reject_blank_required_name | Assertions in body above, with parameters in this row. | Assert.Equal() Failure: Values differ<br>Expected: BadRequest<br>Actual:   Created | FAIL | BE-004; [TRX](reports/coverage/followup-final/backend-tests.trx) testId=1a08ea71-df03-46aa-cc93-68601bb31724; [log](reports/summary/followup-final-test.log) |

## HttpIntegrationTests.Jwt_middleware_denies_anonymous_and_user_admin_access_but_allows_real_admin_token

- **Module:** HTTP/security/validation
- **Component:** Auth/Device/Ticket/Provisioning/Admin routes with real JWT authorization, CORS, rate-limiter and Identity/EF persistence
- **Test identity:** `IOTAgriBackend.Tests.HttpIntegrationTests.Jwt_middleware_denies_anonymous_and_user_admin_access_but_allows_real_admin_token`
- **Test type:** HTTP component integration test
- **Scenario:** Jwt middleware denies anonymous and user admin access but allows real admin token
- **Preconditions / isolation:** ASP.NET TestHost with real routes, Identity/JWT and disposable PostgreSQL; fresh request scopes. Pipeline reconstructed from Program.cs without executing production startup/hosted jobs.
- **Test file:** [backend/tests/HttpIntegrationTests.cs:34](../backend/tests/HttpIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        using var anonymous = await client.GetAsync("/api/admin/overview");
        Assert.Equal(HttpStatusCode.Unauthorized, anonymous.StatusCode);
        var tokens = await RegisterLogin(client);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        using var denied = await client.GetAsync("/api/admin/overview");
        Assert.Equal(HttpStatusCode.Forbidden, denied.StatusCode);
        using var scope = app.Services.CreateScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var user = (await users.FindByEmailAsync("qa@example.test"))!;
        Assert.True((await users.AddToRoleAsync(user, "Admin")).Succeeded);
        using var login = await client.PostAsJsonAsync("/api/auth/login", new LoginRequest(user.Email!, "QaPassword1!"));
        var adminToken = (await login.Content.ReadFromJsonAsync<AuthResponse>())!;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", adminToken.AccessToken);
        using var allowed = await client.GetAsync("/api/admin/overview");
        Assert.Equal(HttpStatusCode.OK, allowed.StatusCode);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "invalid-qa-token");
        using var invalid = await client.GetAsync("/api/devices/");
        Assert.Equal(HttpStatusCode.Unauthorized, invalid.StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-D38C80F268 | IOTAgriBackend.Tests.HttpIntegrationTests.Jwt_middleware_denies_anonymous_and_user_admin_access_but_allows_real_admin_token | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=e139a21a-5c3e-a2b9-2e69-99519312e6b7; [log](reports/summary/followup-final-test.log) |

## HttpIntegrationTests.Locked_user_login_over_http_must_be_denied

- **Module:** HTTP/security/validation
- **Component:** Auth/Device/Ticket/Provisioning/Admin routes with real JWT authorization, CORS, rate-limiter and Identity/EF persistence
- **Test identity:** `IOTAgriBackend.Tests.HttpIntegrationTests.Locked_user_login_over_http_must_be_denied`
- **Test type:** HTTP component integration test
- **Scenario:** Locked user login over http must be denied
- **Preconditions / isolation:** ASP.NET TestHost with real routes, Identity/JWT and disposable PostgreSQL; fresh request scopes. Pipeline reconstructed from Program.cs without executing production startup/hosted jobs.
- **Test file:** [backend/tests/HttpIntegrationTests.cs:93](../backend/tests/HttpIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        await RegisterLogin(client);
        using var scope = app.Services.CreateScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var user = (await users.FindByEmailAsync("qa@example.test"))!;
        user.LockoutEnabled = true;
        user.LockoutEnd = DateTimeOffset.MaxValue;
        Assert.True((await users.UpdateAsync(user)).Succeeded);
        Assert.True(await users.IsLockedOutAsync(user));
        using var response = await client.PostAsJsonAsync("/api/auth/login", new LoginRequest(user.Email!, "QaPassword1!"));
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3DD8720D40 | IOTAgriBackend.Tests.HttpIntegrationTests.Locked_user_login_over_http_must_be_denied | Locked user denied (401); no refresh token generated. | Assert.Equal() Failure: Values differ<br>Expected: Unauthorized<br>Actual:   OK | FAIL | BE-001; [TRX](reports/coverage/followup-final/backend-tests.trx) testId=cadf091f-fc4c-1a16-51a3-f6b0375988e2; [log](reports/summary/followup-final-test.log) |

## HttpIntegrationTests.Provisioning_rate_limiter_rejects_eleventh_request_in_same_window

- **Module:** HTTP/security/validation
- **Component:** Auth/Device/Ticket/Provisioning/Admin routes with real JWT authorization, CORS, rate-limiter and Identity/EF persistence
- **Test identity:** `IOTAgriBackend.Tests.HttpIntegrationTests.Provisioning_rate_limiter_rejects_eleventh_request_in_same_window`
- **Test type:** HTTP component integration test
- **Scenario:** Provisioning rate limiter rejects eleventh request in same window
- **Preconditions / isolation:** ASP.NET TestHost with real routes, Identity/JWT and disposable PostgreSQL; fresh request scopes. Pipeline reconstructed from Program.cs without executing production startup/hosted jobs.
- **Test file:** [backend/tests/HttpIntegrationTests.cs:78](../backend/tests/HttpIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        for (var i = 0; i < 10; i++)
        {
            using var response = await client.PostAsJsonAsync("/api/device-provisioning/claims", new { code = "", hardwareId = "" });
            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        }
        using var rejected = await client.PostAsJsonAsync("/api/device-provisioning/claims", new { code = "", hardwareId = "" });
        Assert.Equal(HttpStatusCode.ServiceUnavailable, rejected.StatusCode);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-D67B619FA9 | IOTAgriBackend.Tests.HttpIntegrationTests.Provisioning_rate_limiter_rejects_eleventh_request_in_same_window | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=468a5c55-42e4-ebfe-fe7d-1739f75847fa; [log](reports/summary/followup-final-test.log) |

## HttpIntegrationTests.Ticket_reply_over_http_with_fresh_request_scope_must_persist_new_message

- **Module:** HTTP/security/validation
- **Component:** Auth/Device/Ticket/Provisioning/Admin routes with real JWT authorization, CORS, rate-limiter and Identity/EF persistence
- **Test identity:** `IOTAgriBackend.Tests.HttpIntegrationTests.Ticket_reply_over_http_with_fresh_request_scope_must_persist_new_message`
- **Test type:** HTTP component integration test
- **Scenario:** Ticket reply over http with fresh request scope must persist new message
- **Preconditions / isolation:** ASP.NET TestHost with real routes, Identity/JWT and disposable PostgreSQL; fresh request scopes. Pipeline reconstructed from Program.cs without executing production startup/hosted jobs.
- **Test file:** [backend/tests/HttpIntegrationTests.cs:111](../backend/tests/HttpIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        var tokens = await RegisterLogin(client);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        using var create = await client.PostAsJsonAsync("/api/tickets", new CreateSupportTicketRequest("QA Ticket", "Initial message"));
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);
        var ticket = (await create.Content.ReadFromJsonAsync<SupportTicketDetailResponse>())!;
        using var scope = app.Services.CreateScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var user = (await users.FindByEmailAsync("qa@example.test"))!;
        Assert.True((await users.AddToRoleAsync(user, "Admin")).Succeeded);
        using var login = await client.PostAsJsonAsync("/api/auth/login", new LoginRequest(user.Email!, "QaPassword1!"));
        var admin = (await login.Content.ReadFromJsonAsync<AuthResponse>())!;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", admin.AccessToken);
        using var reply = await client.PostAsJsonAsync($"/api/admin/tickets/{ticket.Ticket.Id}/messages", new AddSupportTicketMessageRequest("QA Reply"));
        Assert.Equal(HttpStatusCode.OK, reply.StatusCode);
        var detail = (await reply.Content.ReadFromJsonAsync<SupportTicketDetailResponse>())!;
        Assert.Equal(2, detail.Messages.Count);
        Assert.Contains(detail.Messages, m => m.Message == "QA Reply");
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-AC1A30D175 | IOTAgriBackend.Tests.HttpIntegrationTests.Ticket_reply_over_http_with_fresh_request_scope_must_persist_new_message | Assertions in body above, with parameters in this row. | Microsoft.EntityFrameworkCore.DbUpdateConcurrencyException : The database operation was expected to affect 1 row(s), but actually affected 0 row(s); data may have been modified or deleted since entities were loaded. See https://go.microsoft.com/fwlink/?LinkId=527962 for information on understanding and handling optimistic concurrency exceptions. | FAIL | BE-003; [TRX](reports/coverage/followup-final/backend-tests.trx) testId=954b044e-0c97-5586-6d42-35628bb90a52; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Admin_report_csv_and_alert_default_update_reflect_real_persisted_state

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Admin_report_csv_and_alert_default_update_reflect_real_persisted_state`
- **Test type:** Database integration test
- **Scenario:** Admin report csv and alert default update reflect real persisted state
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:285](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        device.IsOnline = true;
        await db.SaveChangesAsync();
        var update = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "UpdateAlertDefaultsAsync", new UpdateSystemAlertDefaultsRequest(41, 17), Principal(), db);
        Assert.Equal(41, Assert.IsType<SystemAlertDefaultsResponse>(Value(update)).HighTemperatureC);
        Assert.Equal(1, await db.SystemAlertDefaults.CountAsync());
        Assert.Equal("settings.alert-defaults.updated", (await db.AdminAuditLogs.SingleAsync()).Action);
        var overview = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "GetOverviewAsync", db);
        var data = Assert.IsType<AdminOverviewResponse>(Value(overview));
        Assert.Equal(1, data.Users);
        Assert.Equal(1, data.Devices);
        Assert.Equal(1, data.OnlineDevices);
        var csv = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "DownloadReportCsvAsync", db);
        var file = Assert.IsType<Microsoft.AspNetCore.Http.HttpResults.FileContentHttpResult>(csv);
        Assert.Equal("admin-report.csv", file.FileDownloadName);
        Assert.Contains("devices.online,1\r\n", Encoding.UTF8.GetString(file.FileContents.Span));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3CBCB54932 | IOTAgriBackend.Tests.PostgresIntegrationTests.Admin_report_csv_and_alert_default_update_reflect_real_persisted_state | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=922487df-acfe-334d-d068-63d58e73ac3c; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Alert_settings_round_trip_and_history_filter_exclude_resolved_records

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Alert_settings_round_trip_and_history_filter_exclude_resolved_records`
- **Test type:** Database integration test
- **Scenario:** Alert settings round trip and history filter exclude resolved records
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:201](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var settings = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "UpdateAlertSettingsAsync", device.Id, new DeviceAlertSettingsRequest(42, 15), Principal(), db);
        Assert.Equal(42, Assert.IsType<DeviceAlertSettingsResponse>(Value(settings)).HighTemperatureC);
        db.DeviceAlerts.AddRange(new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.HighTemperature },
            new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.LowWaterLevel, ResolvedAt = DateTime.UtcNow });
        await db.SaveChangesAsync();
        var result = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "GetAlertsAsync", device.Id, Principal(), db, new DeviceAlertHistoryQuery("active"));
        var page = Assert.IsType<DeviceAlertPage>(Value(result));
        Assert.Equal(1, page.TotalCount);
        Assert.Equal("HIGH_TEMPERATURE", Assert.Single(page.Items).Type);
        Assert.Equal(404, Status(await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "GetAlertsAsync", device.Id, Principal("other"), db, new DeviceAlertHistoryQuery())));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-9ED1630ED7 | IOTAgriBackend.Tests.PostgresIntegrationTests.Alert_settings_round_trip_and_history_filter_exclude_resolved_records | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a70ad7b9-8eee-fb44-9495-6934e8599c43; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.All_migrations_can_roll_back_on_empty_disposable_database

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.All_migrations_can_roll_back_on_empty_disposable_database`
- **Test type:** Database integration test
- **Scenario:** All migrations can roll back on empty disposable database
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:383](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        await db.Database.MigrateAsync("0");
        Assert.Empty(await db.Database.GetAppliedMigrationsAsync());
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-90FC4CE0BC | IOTAgriBackend.Tests.PostgresIntegrationTests.All_migrations_can_roll_back_on_empty_disposable_database | Assertions in body above, with parameters in this row. | Npgsql.PostgresException : 42601: syntax error at or near "\"<br><br>POSITION: 43 | FAIL | BE-002; [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5da24e04-bd4f-8e37-a4b4-a10578468a3e; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Dashboard_includes_only_owners_devices_latest_readings_and_active_alerts

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Dashboard_includes_only_owners_devices_latest_readings_and_active_alerts`
- **Test type:** Database integration test
- **Scenario:** Dashboard includes only owners devices latest readings and active alerts
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:268](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var first = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        db.SensorReadings.AddRange(new SensorReading { DeviceId = device.Id, RecordedAt = first, Temperature = 10 }, new SensorReading { DeviceId = device.Id, RecordedAt = first.AddHours(1), Temperature = 30 });
        db.DeviceAlerts.Add(new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.HighTemperature });
        db.Devices.Add(new Device { Name = "Unowned", DeviceKey = "qa-other" });
        await db.SaveChangesAsync();
        var result = await BackendTestDoubles.InvokeHandler(typeof(DashboardEndpoints), "GetOverviewAsync", Principal(), db);
        var overview = Assert.Single(Assert.IsAssignableFrom<IEnumerable<DeviceOverviewResponse>>(Value(result)));
        Assert.Equal(device.Id, overview.DeviceId);
        Assert.Equal(30, overview.LatestReading!.Temperature);
        Assert.Single(overview.ActiveAlerts);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-D5A74B0DA2 | IOTAgriBackend.Tests.PostgresIntegrationTests.Dashboard_includes_only_owners_devices_latest_readings_and_active_alerts | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=ec4c1cd3-c800-a495-7297-e0af75e4c2fb; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Database_enforces_unique_device_key_and_filtered_active_alert_index

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Database_enforces_unique_device_key_and_filtered_active_alert_index`
- **Test type:** Database integration test
- **Scenario:** Database enforces unique device key and filtered active alert index
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:181](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        db.Devices.Add(new Device { DeviceKey = device.DeviceKey, Name = "Duplicate" });
        var duplicate = await Assert.ThrowsAsync<DbUpdateException>(() => db.SaveChangesAsync());
        Assert.Equal(PostgresErrorCodes.UniqueViolation, Assert.IsType<PostgresException>(duplicate.InnerException).SqlState);
        db.ChangeTracker.Clear();
        db.DeviceAlerts.Add(new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.HighTemperature });
        await db.SaveChangesAsync();
        db.DeviceAlerts.Add(new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.HighTemperature });
        var activeDuplicate = await Assert.ThrowsAsync<DbUpdateException>(() => db.SaveChangesAsync());
        Assert.Equal(PostgresErrorCodes.UniqueViolation, Assert.IsType<PostgresException>(activeDuplicate.InnerException).SqlState);
        db.ChangeTracker.Clear();
        db.DeviceAlerts.Add(new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.HighTemperature, ResolvedAt = DateTime.UtcNow });
        await db.SaveChangesAsync();
        Assert.Equal(2, await db.DeviceAlerts.CountAsync());
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-D5BD911407 | IOTAgriBackend.Tests.PostgresIntegrationTests.Database_enforces_unique_device_key_and_filtered_active_alert_index | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=804db881-4235-e2cd-6f46-be6c5534c78b; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Device_crud_persists_updates_and_hides_device_from_other_owner

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Device_crud_persists_updates_and_hides_device_from_other_owner`
- **Test type:** Database integration test
- **Scenario:** Device crud persists updates and hides device from other owner
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:60](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        db.Users.Add(new ApplicationUser { Id = "qa-owner", UserName = "qa" });
        await db.SaveChangesAsync();
        var create = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "CreateAsync", new CreateDeviceRequest("Original"), Principal(), db);
        Assert.Equal(201, Status(create));
        var device = await db.Devices.SingleAsync();
        Assert.Matches("^[A-Za-z0-9_-]{43}$", device.DeviceKey);
        var denied = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "GetAsync", device.Id, Principal("other-owner"), db);
        Assert.Equal(404, Status(denied));
        var update = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "UpdateAsync", device.Id, new UpdateDeviceRequest("Updated"), Principal(), db);
        Assert.Equal("Updated", Assert.IsType<DeviceResponse>(Value(update)).Name);
        db.ChangeTracker.Clear();
        Assert.Equal("Updated", (await db.Devices.SingleAsync()).Name);
        var delete = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "DeleteAsync", device.Id, Principal(), db);
        Assert.Equal(204, Status(delete));
        Assert.Empty(await db.Devices.ToListAsync());
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-E64D1F2053 | IOTAgriBackend.Tests.PostgresIntegrationTests.Device_crud_persists_updates_and_hides_device_from_other_owner | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=388f5ea7-e0f2-b595-f2ae-f447f39b0cf3; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Fresh_database_applies_all_migrations_and_has_no_pending_model_changes

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Fresh_database_applies_all_migrations_and_has_no_pending_model_changes`
- **Test type:** Database integration test
- **Scenario:** Fresh database applies all migrations and has no pending model changes
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:49](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var applied = (await db.Database.GetAppliedMigrationsAsync()).ToList();
        Assert.Equal(14, applied.Count);
        Assert.Contains("20261009120000_AddSolutionTemperatureToSensorReadings", applied);
        Assert.Empty(await db.Database.GetPendingMigrationsAsync());
        Assert.False(db.Database.HasPendingModelChanges());
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-321533CAB4 | IOTAgriBackend.Tests.PostgresIntegrationTests.Fresh_database_applies_all_migrations_and_has_no_pending_model_changes | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=714f336a-0eec-a37a-d140-4067c63922c2; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Hourly_median_sql_uses_percentile_cont_and_preserves_empty_hours

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Hourly_median_sql_uses_percentile_cont_and_preserves_empty_hours`
- **Test type:** Database integration test
- **Scenario:** Hourly median sql uses percentile cont and preserves empty hours
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:100](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        foreach (var (minute, value) in new[] { (10, 10d), (20, 30d), (30, 50d), (40, 90d) })
            db.SensorReadings.Add(new SensorReading { DeviceId = device.Id, RecordedAt = start.AddMinutes(minute), Temperature = value, SolutionTemperature = value });
        await db.SaveChangesAsync();
        var result = await BackendTestDoubles.InvokeHandler(typeof(SensorEndpoints), "GetHourlyMediansAsync", device.Id, new DateOnly(2026, 10, 1), Principal(), db);
        var buckets = Assert.IsAssignableFrom<IReadOnlyList<SensorMedianBucket>>(Value(result));
        Assert.Equal(24, buckets.Count);
        Assert.Equal(40, buckets[0].MedianTemperature);
        Assert.Equal(40, buckets[0].MedianSolutionTemperature);
        Assert.Equal(4, buckets[0].SampleCount);
        Assert.Null(buckets[1].MedianTemperature);
        Assert.Equal(0, buckets[1].SampleCount);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-DD357ACF88 | IOTAgriBackend.Tests.PostgresIntegrationTests.Hourly_median_sql_uses_percentile_cont_and_preserves_empty_hours | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=77d8a8cb-8df4-c8eb-8afe-583cecc3e34f; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Logout_revokes_only_callers_refresh_token_and_is_idempotent

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Logout_revokes_only_callers_refresh_token_and_is_idempotent`
- **Test type:** Database integration test
- **Scenario:** Logout revokes only callers refresh token and is idempotent
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:165](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        await SeedDevice(db);
        db.RefreshTokens.Add(new RefreshToken { UserId = "qa-owner", Token = "qa-logout-token", ExpiresAt = DateTime.UtcNow.AddDays(1) });
        await db.SaveChangesAsync();
        var request = new RefreshRequest("qa-logout-token");
        Assert.Equal(204, Status(await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LogoutAsync", request, Principal("other"), db)));
        Assert.Null((await db.RefreshTokens.SingleAsync()).RevokedAt);
        Assert.Equal(204, Status(await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LogoutAsync", request, Principal(), db)));
        db.ChangeTracker.Clear();
        Assert.NotNull((await db.RefreshTokens.SingleAsync()).RevokedAt);
        Assert.Equal(204, Status(await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LogoutAsync", request, Principal(), db)));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3A81E52BAD | IOTAgriBackend.Tests.PostgresIntegrationTests.Logout_revokes_only_callers_refresh_token_and_is_idempotent | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=00881499-df73-dd7e-e269-2b287b3b396c; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Mqtt_pump_acknowledgement_persists_failed_status_and_reason

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Mqtt_pump_acknowledgement_persists_failed_status_and_reason`
- **Test type:** Database integration test
- **Scenario:** Mqtt pump acknowledgement persists failed status and reason
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:344](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var command = new PumpCommand { DeviceId = device.Id, IsOn = true };
        db.PumpCommands.Add(command);
        await db.SaveChangesAsync();
        using var services = new ServiceCollection().AddDbContext<ApplicationDbContext>(o => o.UseNpgsql(db.Database.GetConnectionString())).BuildServiceProvider();
        using var mqtt = new MqttIngestionService(services.GetRequiredService<IServiceScopeFactory>(), new ConfigurationBuilder().Build(), NullLogger<MqttIngestionService>.Instance);
        var payload = Encoding.UTF8.GetBytes("{\"commandId\":\"" + command.Id + "\",\"isOn\":false,\"success\":false,\"reason\":\" LOW_WATER \"}");
        await (Task)typeof(MqttIngestionService).GetMethod("ProcessPumpStatusAsync", BindingFlags.Instance | BindingFlags.NonPublic)!.Invoke(mqtt, new object[] { "qa-device-key", payload, "devices/qa-device-key/pump-status" })!;
        db.ChangeTracker.Clear();
        var saved = await db.PumpCommands.SingleAsync();
        Assert.Equal(PumpCommandStatus.Failed, saved.Status);
        Assert.Equal("LOW_WATER", saved.FailureReason);
        Assert.NotNull(saved.AcknowledgedAt);
        Assert.False(saved.AcknowledgedIsOn);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-FF7E2A1B05 | IOTAgriBackend.Tests.PostgresIntegrationTests.Mqtt_pump_acknowledgement_persists_failed_status_and_reason | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=f6c455ae-62fc-fc97-6afc-43ea504f32f4; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Mqtt_reading_adapter_persists_presence_triggers_alerts_and_resolves_safe_reading

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Mqtt_reading_adapter_persists_presence_triggers_alerts_and_resolves_safe_reading`
- **Test type:** Database integration test
- **Scenario:** Mqtt reading adapter persists presence triggers alerts and resolves safe reading
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:325](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        await SeedDevice(db);
        using var services = new ServiceCollection().AddDbContext<ApplicationDbContext>(o => o.UseNpgsql(db.Database.GetConnectionString())).BuildServiceProvider();
        using var mqtt = new MqttIngestionService(services.GetRequiredService<IServiceScopeFactory>(), new ConfigurationBuilder().Build(), NullLogger<MqttIngestionService>.Instance);
        var process = typeof(MqttIngestionService).GetMethod("ProcessReadingAsync", BindingFlags.Instance | BindingFlags.NonPublic)!;
        await (Task)process.Invoke(mqtt, new object[] { "qa-device-key", Encoding.UTF8.GetBytes("{\"temperature\":40,\"waterLevel\":10}") })!;
        db.ChangeTracker.Clear();
        Assert.Equal(2, await db.DeviceAlerts.CountAsync(a => a.ResolvedAt == null));
        Assert.True((await db.Devices.SingleAsync()).IsOnline);
        await (Task)process.Invoke(mqtt, new object[] { "qa-device-key", Encoding.UTF8.GetBytes("{\"temperature\":20,\"waterLevel\":80}") })!;
        db.ChangeTracker.Clear();
        Assert.Equal(2, await db.SensorReadings.CountAsync());
        Assert.Equal(2, await db.DeviceAlerts.CountAsync(a => a.ResolvedAt != null));
        Assert.False(mqtt.IsConnected); // adapter integration, not broker transport
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-971AA7D274 | IOTAgriBackend.Tests.PostgresIntegrationTests.Mqtt_reading_adapter_persists_presence_triggers_alerts_and_resolves_safe_reading | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=cb735de9-bf90-f26d-5712-05de382cc37d; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Provisioning_code_claim_is_one_use_and_clears_secret_hash

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Provisioning_code_claim_is_one_use_and_clears_secret_hash`
- **Test type:** Database integration test
- **Scenario:** Provisioning code claim is one use and clears secret hash
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:119](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var issued = await BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "CreateCodeAsync", device.Id, Principal(), db);
        var code = Assert.IsType<CreateProvisioningCodeResponse>(Value(issued));
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["DeviceProvisioning:MqttHost"] = "qa-broker", ["Mqtt:Port"] = "1883" }).Build();
        var request = new ClaimDeviceRequest(" " + code.Code.ToLowerInvariant() + " ", " qa-hardware ");
        var result = await BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "ClaimAsync", request, db, config);
        Assert.Equal(200, Status(result));
        Assert.Equal(device.DeviceKey, Assert.IsType<ClaimDeviceResponse>(Value(result)).DeviceKey);
        db.ChangeTracker.Clear();
        var saved = await db.Devices.SingleAsync();
        Assert.Null(saved.ProvisioningCodeHash);
        Assert.Null(saved.ProvisioningCodeExpiresAt);
        Assert.Equal("QA-HARDWARE", saved.ProvisionedHardwareId);
        Assert.NotNull(saved.ProvisionedAt);
        Assert.Equal(400, Status(await BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "ClaimAsync", request, db, config)));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-A570018459 | IOTAgriBackend.Tests.PostgresIntegrationTests.Provisioning_code_claim_is_one_use_and_clears_secret_hash | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d4845a85-2e84-b71b-cc92-90eea2bc11d8; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Provisioning_concurrent_claims_allow_exactly_one_success

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Provisioning_concurrent_claims_allow_exactly_one_success`
- **Test type:** Database integration test
- **Scenario:** Provisioning concurrent claims allow exactly one success
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:364](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var issued = await BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "CreateCodeAsync", device.Id, Principal(), db);
        var code = Assert.IsType<CreateProvisioningCodeResponse>(Value(issued)).Code;
        var options = new DbContextOptionsBuilder<ApplicationDbContext>().UseNpgsql(db.Database.GetConnectionString()).Options;
        await using var first = new ApplicationDbContext(options);
        await using var second = new ApplicationDbContext(options);
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["DeviceProvisioning:MqttHost"] = "qa-broker" }).Build();
        var results = await Task.WhenAll(BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "ClaimAsync", new ClaimDeviceRequest(code, "FIRST"), first, config),
            BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "ClaimAsync", new ClaimDeviceRequest(code, "SECOND"), second, config));
        Assert.Single(results, r => Status(r) == 200);
        Assert.Single(results, r => Status(r) is 400 or 409);
        db.ChangeTracker.Clear();
        Assert.Contains((await db.Devices.SingleAsync()).ProvisionedHardwareId, new[] { "FIRST", "SECOND" });
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-A8925AF7E2 | IOTAgriBackend.Tests.PostgresIntegrationTests.Provisioning_concurrent_claims_allow_exactly_one_success | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=290df18b-8b6a-8411-39f4-b78bb0bc0025; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Pump_history_filters_date_range_and_projects_failures_in_descending_order

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Pump_history_filters_date_range_and_projects_failures_in_descending_order`
- **Test type:** Database integration test
- **Scenario:** Pump history filters date range and projects failures in descending order
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:218](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        db.PumpCommands.AddRange(new PumpCommand { DeviceId = device.Id, IssuedAt = start, Status = PumpCommandStatus.Failed, FailureReason = "QA_FAILURE" },
            new PumpCommand { DeviceId = device.Id, IssuedAt = start.AddHours(1), Status = PumpCommandStatus.Acknowledged },
            new PumpCommand { DeviceId = device.Id, IssuedAt = start.AddDays(-1) });
        await db.SaveChangesAsync();
        var query = new PumpCommandHistoryQuery(new DateTimeOffset(start), new DateTimeOffset(start.AddDays(1)));
        var result = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "GetPumpCommandsAsync", device.Id, Principal(), db, query);
        var page = Assert.IsType<PumpCommandHistoryPage>(Value(result));
        Assert.Equal(2, page.TotalCount);
        Assert.Equal(start.AddHours(1), page.Items[0].IssuedAt);
        Assert.Equal("QA_FAILURE", page.Items[1].FailureReason);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-46BE71BD13 | IOTAgriBackend.Tests.PostgresIntegrationTests.Pump_history_filters_date_range_and_projects_failures_in_descending_order | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=82f8acaa-094d-922b-5b2c-4a540c2261cb; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Refresh_rotation_revokes_original_token_and_rejects_reuse

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Refresh_rotation_revokes_original_token_and_rejects_reuse`
- **Test type:** Database integration test
- **Scenario:** Refresh rotation revokes original token and rejects reuse
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:140](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var user = await db.Users.SingleAsync();
        var old = new RefreshToken { UserId = user.Id, Token = "old-qa-token", ExpiresAt = DateTime.UtcNow.AddDays(1) };
        db.RefreshTokens.Add(old);
        await db.SaveChangesAsync();
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.GetRolesAsync(It.IsAny<ApplicationUser>())).ReturnsAsync(new List<string> { "User" });
        var tokens = new Mock<ITokenService>();
        tokens.Setup(t => t.CreateAccessToken(It.IsAny<ApplicationUser>(), It.IsAny<IList<string>>())).Returns("qa-access");
        tokens.Setup(t => t.GenerateRefreshTokenValue()).Returns("new-qa-token");
        var config = new ConfigurationBuilder().Build();
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "RefreshAsync", new RefreshRequest(old.Token), users.Object, db, tokens.Object, config);
        Assert.Equal("new-qa-token", Assert.IsType<AuthResponse>(Value(result)).RefreshToken);
        db.ChangeTracker.Clear();
        var original = await db.RefreshTokens.SingleAsync(t => t.Token == "old-qa-token");
        Assert.NotNull(original.RevokedAt);
        Assert.Equal("new-qa-token", original.ReplacedByToken);
        Assert.Equal(401, Status(await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "RefreshAsync", new RefreshRequest(old.Token), users.Object, db, tokens.Object, config)));
        Assert.Equal(2, await db.RefreshTokens.CountAsync());
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-4B0453B2B4 | IOTAgriBackend.Tests.PostgresIntegrationTests.Refresh_rotation_revokes_original_token_and_rejects_reuse | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b99327d7-3c42-9175-0b1f-1cd93c124a70; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Scheduler_claim_is_idempotent_and_disconnected_publish_stays_pending_for_retry

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Scheduler_claim_is_idempotent_and_disconnected_publish_stays_pending_for_retry`
- **Test type:** Database integration test
- **Scenario:** Scheduler claim is idempotent and disconnected publish stays pending for retry
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:391](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var schedule = new PumpSchedule { DeviceId = device.Id, WeekdayMask = 127, StartTime = new TimeOnly(6, 0), DurationSeconds = 60, TimeZone = "Asia/Bangkok" };
        db.PumpSchedules.Add(schedule);
        await db.SaveChangesAsync();
        using var services = new ServiceCollection().AddDbContext<ApplicationDbContext>(o => o.UseNpgsql(db.Database.GetConnectionString())).BuildServiceProvider();
        var scopes = services.GetRequiredService<IServiceScopeFactory>();
        using var mqtt = new MqttIngestionService(scopes, new ConfigurationBuilder().Build(), NullLogger<MqttIngestionService>.Instance);
        using var scheduler = new PumpScheduleDispatchService(scopes, new ConfigurationBuilder().Build(), mqtt, NullLogger<PumpScheduleDispatchService>.Instance);
        var claim = typeof(PumpScheduleDispatchService).GetMethod("ClaimAndPublishAsync", BindingFlags.Instance | BindingFlags.NonPublic)!;
        var occurrence = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        await (Task)claim.Invoke(scheduler, new object[] { schedule.Id, occurrence, System.Threading.CancellationToken.None })!;
        await (Task)claim.Invoke(scheduler, new object[] { schedule.Id, occurrence, System.Threading.CancellationToken.None })!;
        db.ChangeTracker.Clear();
        var pending = await db.PumpScheduleOccurrences.SingleAsync();
        Assert.Null(pending.DispatchedAt);
        Assert.Equal(occurrence, pending.OccurrenceUtc);
        var command = await db.PumpCommands.SingleAsync();
        Assert.Equal(pending.CommandId, command.Id);
        Assert.Equal(PumpCommandSource.Scheduled, command.Source);
        Assert.Equal(PumpCommandStatus.Pending, command.Status);
        Assert.False(mqtt.IsConnected);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-8860B62DD9 | IOTAgriBackend.Tests.PostgresIntegrationTests.Scheduler_claim_is_idempotent_and_disconnected_publish_stays_pending_for_retry | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6b0bde46-20c8-eeb3-1e04-dd7341a1005f; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Sensor_aggregate_sql_computes_real_postgresql_min_average_max_and_count

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Sensor_aggregate_sql_computes_real_postgresql_min_average_max_and_count`
- **Test type:** Database integration test
- **Scenario:** Sensor aggregate sql computes real postgresql min average max and count
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:81](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        db.SensorReadings.AddRange(new SensorReading { DeviceId = device.Id, RecordedAt = start.AddMinutes(10), Temperature = 20, WaterLevel = 40 },
            new SensorReading { DeviceId = device.Id, RecordedAt = start.AddMinutes(20), Temperature = 30, WaterLevel = 60 });
        await db.SaveChangesAsync();
        var result = await BackendTestDoubles.InvokeHandler(typeof(SensorEndpoints), "GetAggregatedReadingsAsync", device.Id, Principal(), db, "hour", start, start.AddHours(1));
        var bucket = Assert.Single(Assert.IsType<List<AggregatedReadingBucket>>(Value(result)));
        Assert.Equal(start, bucket.BucketStart);
        Assert.Equal(25, bucket.AvgTemperature);
        Assert.Equal(20, bucket.MinTemperature);
        Assert.Equal(30, bucket.MaxTemperature);
        Assert.Equal(50, bucket.AvgWaterLevel);
        Assert.Equal(2, bucket.SampleCount);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-F942C42FF6 | IOTAgriBackend.Tests.PostgresIntegrationTests.Sensor_aggregate_sql_computes_real_postgresql_min_average_max_and_count | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a8e9ca71-dab9-5d3a-62b6-285cd6fb10e7; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Sequential_schedule_crud_rejects_overlap_and_preserves_owned_transaction

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Sequential_schedule_crud_rejects_overlap_and_preserves_owned_transaction`
- **Test type:** Database integration test
- **Scenario:** Sequential schedule crud rejects overlap and preserves owned transaction
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:307](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var config = new ConfigurationBuilder().Build();
        var request = new PumpScheduleRequest(true, 1, new TimeOnly(6, 0), 60, "Asia/Bangkok");
        var create = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "CreatePumpScheduleAsync", device.Id, request, Principal(), db, config);
        Assert.Equal(201, Status(create));
        var saved = Assert.IsType<PumpScheduleResponse>(Value(create));
        var overlap = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "CreatePumpScheduleAsync", device.Id, request, Principal(), db, config);
        Assert.Equal(400, Status(overlap));
        var update = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "UpdatePumpScheduleAsync", device.Id, saved.Id, request with { StartTime = new TimeOnly(7, 0) }, Principal(), db, config);
        Assert.Equal(new TimeOnly(7, 0), Assert.IsType<PumpScheduleResponse>(Value(update)).StartTime);
        Assert.Equal(204, Status(await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "DeletePumpScheduleAsync", device.Id, saved.Id, Principal(), db)));
        Assert.Empty(await db.PumpSchedules.ToListAsync());
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-1EC44F7D38 | IOTAgriBackend.Tests.PostgresIntegrationTests.Sequential_schedule_crud_rejects_overlap_and_preserves_owned_transaction | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=1929b0cd-4f44-aa12-5d88-8bd5fbf3d43d; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Ticket_create_reply_transition_and_search_persist_messages_and_audit

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Ticket_create_reply_transition_and_search_persist_messages_and_audit`
- **Test type:** Database integration test
- **Scenario:** Ticket create reply transition and search persist messages and audit
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:236](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        await SeedDevice(db);
        var owner = await db.Users.SingleAsync();
        var admin = new ApplicationUser { Id = "qa-admin", FullName = "QA Admin" };
        db.Users.Add(admin);
        await db.SaveChangesAsync();
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByIdAsync(owner.Id)).ReturnsAsync(owner);
        users.Setup(u => u.FindByIdAsync(admin.Id)).ReturnsAsync(admin);
        var created = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "CreateAsync", new CreateSupportTicketRequest("  Pump help  ", "  Initial message  "), Principal(), db, users.Object);
        Assert.Equal(201, Status(created));
        var ticket = Assert.IsType<SupportTicketDetailResponse>(Value(created));
        Assert.Equal("Pump help", ticket.Ticket.Subject);
        Assert.Equal("Initial message", Assert.Single(ticket.Messages).Message);
        Assert.False(ticket.Messages[0].IsAdmin);
        var reply = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "ReplyAsync", ticket.Ticket.Id, new AddSupportTicketMessageRequest("  QA reply  "), Principal(admin.Id), db, users.Object);
        var detail = Assert.IsType<SupportTicketDetailResponse>(Value(reply));
        Assert.Equal(2, detail.Messages.Count);
        Assert.True(detail.Messages.Last().IsAdmin);
        Assert.Equal("QA reply", detail.Messages.Last().Message);
        var status = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "UpdateStatusAsync", ticket.Ticket.Id, new UpdateSupportTicketStatusRequest(" IN_PROGRESS "), Principal(admin.Id), db);
        Assert.Equal("in_progress", Assert.IsType<SupportTicketDetailResponse>(Value(status)).Ticket.Status);
        var priority = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "UpdatePriorityAsync", ticket.Ticket.Id, new UpdateSupportTicketPriorityRequest(" HIGH "), Principal(admin.Id), db);
        Assert.Equal("high", Assert.IsType<SupportTicketDetailResponse>(Value(priority)).Ticket.Priority);
        var listed = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "ListAsync", db, "in_progress", "PUMP", 1, 50);
        Assert.Equal(1, Assert.IsType<SupportTicketPage>(Value(listed)).TotalCount);
        Assert.Equal(3, await db.AdminAuditLogs.CountAsync());
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-7D9CE29880 | IOTAgriBackend.Tests.PostgresIntegrationTests.Ticket_create_reply_transition_and_search_persist_messages_and_audit | Assertions in body above, with parameters in this row. | Microsoft.EntityFrameworkCore.DbUpdateConcurrencyException : The database operation was expected to affect 1 row(s), but actually affected 0 row(s); data may have been modified or deleted since entities were loaded. See https://go.microsoft.com/fwlink/?LinkId=527962 for information on understanding and handling optimistic concurrency exceptions. | FAIL | BE-003; [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7a3702bc-186c-98c7-4072-f7f3d060009e; [log](reports/summary/followup-final-test.log) |

## PostgresIntegrationTests.Ticket_status_and_priority_updates_persist_audit_without_reply_dependency

- **Module:** PostgreSQL persistence/adapters/migrations
- **Component:** ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body
- **Test identity:** `IOTAgriBackend.Tests.PostgresIntegrationTests.Ticket_status_and_priority_updates_persist_audit_without_reply_dependency`
- **Test type:** Database integration test
- **Scenario:** Ticket status and priority updates persist audit without reply dependency
- **Preconditions / isolation:** Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker.
- **Test file:** [backend/tests/PostgresIntegrationTests.cs:418](../backend/tests/PostgresIntegrationTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        await using var db = await _fixture.CreateDatabaseAsync();
        await SeedDevice(db);
        var user = await db.Users.SingleAsync();
        var ticket = new SupportTicket { UserId = user.Id, Subject = "QA Status" };
        db.SupportTickets.Add(ticket);
        await db.SaveChangesAsync();
        var status = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "UpdateStatusAsync", ticket.Id, new UpdateSupportTicketStatusRequest(" IN_PROGRESS "), Principal(), db);
        Assert.Equal("in_progress", Assert.IsType<SupportTicketDetailResponse>(Value(status)).Ticket.Status);
        var priority = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "UpdatePriorityAsync", ticket.Id, new UpdateSupportTicketPriorityRequest(" HIGH "), Principal(), db);
        Assert.Equal("high", Assert.IsType<SupportTicketDetailResponse>(Value(priority)).Ticket.Priority);
        Assert.Equal(2, await db.AdminAuditLogs.CountAsync());
        var listed = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "ListAsync", db, "in_progress", "STATUS", 1, 50);
        Assert.Equal(1, Assert.IsType<SupportTicketPage>(Value(listed)).TotalCount);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3D9E3EB1F2 | IOTAgriBackend.Tests.PostgresIntegrationTests.Ticket_status_and_priority_updates_persist_audit_without_reply_dependency | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5efb34d0-48b3-c56a-acf0-d27e2373cf60; [log](reports/summary/followup-final-test.log) |

## ProfileRulesExtendedTests.Accepts_name_at_maximum_allowed_length

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesExtendedTests.Accepts_name_at_maximum_allowed_length`
- **Test type:** Unit test
- **Scenario:** Accepts name at maximum allowed length
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesExtendedTests.cs:10](../backend/tests/ProfileRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var name = new string('a', ProfileRules.MaximumFullNameLength);

        Assert.Null(ProfileRules.Validate(name, null, out var normalized, out _));
        Assert.Equal(name, normalized);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-C1C37F6A46 | IOTAgriBackend.Tests.ProfileRulesExtendedTests.Accepts_name_at_maximum_allowed_length | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=81a09efa-5f95-4993-f705-0933523ff6d7; [log](reports/summary/followup-final-test.log) |

## ProfileRulesExtendedTests.Accepts_phone_at_maximum_allowed_length

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesExtendedTests.Accepts_phone_at_maximum_allowed_length`
- **Test type:** Unit test
- **Scenario:** Accepts phone at maximum allowed length
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesExtendedTests.cs:28](../backend/tests/ProfileRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // Build a valid phone that is exactly MaximumPhoneNumberLength chars
        // must have >= 8 digits and only allowed chars
        var phone = new string('1', ProfileRules.MaximumPhoneNumberLength);

        Assert.Null(ProfileRules.Validate("Valid Name", phone, out _, out _));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-BEFF5AE713 | IOTAgriBackend.Tests.ProfileRulesExtendedTests.Accepts_phone_at_maximum_allowed_length | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c01e4222-98b7-a6c3-d39c-d1feb76cdc39; [log](reports/summary/followup-final-test.log) |

## ProfileRulesExtendedTests.IsPhoneNumber_validates_format_directly

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesExtendedTests.IsPhoneNumber_validates_format_directly`
- **Test type:** Unit test
- **Scenario:** IsPhoneNumber validates format directly
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesExtendedTests.cs:54](../backend/tests/ProfileRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Equal(expected, ProfileRules.IsPhoneNumber(value));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-A490506D52 | IOTAgriBackend.Tests.ProfileRulesExtendedTests.IsPhoneNumber_validates_format_directly(value: "", expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=74cbfb73-efcb-13fa-bb3d-458968171754; [log](reports/summary/followup-final-test.log) |
| TC-BE-6CCCDD7E5A | IOTAgriBackend.Tests.ProfileRulesExtendedTests.IsPhoneNumber_validates_format_directly(value: "(028) 3822.1234", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=79e209c9-cf6e-cb48-a056-56ff67df7d34; [log](reports/summary/followup-final-test.log) |
| TC-BE-90F53C9120 | IOTAgriBackend.Tests.ProfileRulesExtendedTests.IsPhoneNumber_validates_format_directly(value: "+1234567890", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b815b0b1-9dfc-9270-105d-0b060a29540f; [log](reports/summary/followup-final-test.log) |
| TC-BE-85386D3D93 | IOTAgriBackend.Tests.ProfileRulesExtendedTests.IsPhoneNumber_validates_format_directly(value: "+84-912-345-678", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d03e2595-fd31-cae4-2d1a-16dfd5067d3a; [log](reports/summary/followup-final-test.log) |
| TC-BE-2E7909016C | IOTAgriBackend.Tests.ProfileRulesExtendedTests.IsPhoneNumber_validates_format_directly(value: "1234567", expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=bbfda910-adac-2ded-980c-168d423e3b97; [log](reports/summary/followup-final-test.log) |
| TC-BE-362BA753F4 | IOTAgriBackend.Tests.ProfileRulesExtendedTests.IsPhoneNumber_validates_format_directly(value: "12345678", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5f179bc6-ba7d-a01a-68af-86e347c356ac; [log](reports/summary/followup-final-test.log) |
| TC-BE-FB80685307 | IOTAgriBackend.Tests.ProfileRulesExtendedTests.IsPhoneNumber_validates_format_directly(value: "abc12345678", expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4ba06aac-8536-ffcc-b968-73818bbbac89; [log](reports/summary/followup-final-test.log) |

## ProfileRulesExtendedTests.Leading_and_trailing_spaces_are_trimmed_from_name

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesExtendedTests.Leading_and_trailing_spaces_are_trimmed_from_name`
- **Test type:** Unit test
- **Scenario:** Leading and trailing spaces are trimmed from name
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesExtendedTests.cs:61](../backend/tests/ProfileRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Null(ProfileRules.Validate("  Tran Van B  ", null, out var name, out _));
        Assert.Equal("Tran Van B", name);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-B89FAA4A0A | IOTAgriBackend.Tests.ProfileRulesExtendedTests.Leading_and_trailing_spaces_are_trimmed_from_name | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=17c900db-e377-b316-eb86-d360dbfb5ced; [log](reports/summary/followup-final-test.log) |

## ProfileRulesExtendedTests.Leading_and_trailing_spaces_are_trimmed_from_phone

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesExtendedTests.Leading_and_trailing_spaces_are_trimmed_from_phone`
- **Test type:** Unit test
- **Scenario:** Leading and trailing spaces are trimmed from phone
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesExtendedTests.cs:69](../backend/tests/ProfileRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Null(ProfileRules.Validate("Valid Name", "  0912345678  ", out _, out var phone));
        Assert.Equal("0912345678", phone);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-FCF7439194 | IOTAgriBackend.Tests.ProfileRulesExtendedTests.Leading_and_trailing_spaces_are_trimmed_from_phone | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6b85c157-2903-e6f8-9e8d-5b19a90760ed; [log](reports/summary/followup-final-test.log) |

## ProfileRulesExtendedTests.Rejects_name_one_char_over_maximum_allowed_length

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesExtendedTests.Rejects_name_one_char_over_maximum_allowed_length`
- **Test type:** Unit test
- **Scenario:** Rejects name one char over maximum allowed length
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesExtendedTests.cs:19](../backend/tests/ProfileRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var name = new string('a', ProfileRules.MaximumFullNameLength + 1);

        Assert.NotNull(ProfileRules.Validate(name, null, out _, out _));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-0ABAD7EA22 | IOTAgriBackend.Tests.ProfileRulesExtendedTests.Rejects_name_one_char_over_maximum_allowed_length | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=e0170719-0920-8646-c07f-91e5b5e20023; [log](reports/summary/followup-final-test.log) |

## ProfileRulesExtendedTests.Rejects_phone_one_char_over_maximum_allowed_length

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesExtendedTests.Rejects_phone_one_char_over_maximum_allowed_length`
- **Test type:** Unit test
- **Scenario:** Rejects phone one char over maximum allowed length
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesExtendedTests.cs:38](../backend/tests/ProfileRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var phone = new string('1', ProfileRules.MaximumPhoneNumberLength + 1);

        Assert.NotNull(ProfileRules.Validate("Valid Name", phone, out _, out _));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-A86450E1D5 | IOTAgriBackend.Tests.ProfileRulesExtendedTests.Rejects_phone_one_char_over_maximum_allowed_length | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=53a573fb-8250-6075-abde-00267387a7e3; [log](reports/summary/followup-final-test.log) |

## ProfileRulesTests.Accepts_name_with_optional_phone

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesTests.Accepts_name_with_optional_phone`
- **Test type:** Unit test
- **Scenario:** Accepts name with optional phone
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesTests.cs:9](../backend/tests/ProfileRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Null(ProfileRules.Validate("Nguyễn Văn A", null, out var name, out var phone));
        Assert.Equal("Nguyễn Văn A", name);
        Assert.Null(phone);

        Assert.Null(ProfileRules.Validate("  Nguyễn Văn A  ", " +84 912 345 678 ", out name, out phone));
        Assert.Equal("Nguyễn Văn A", name);
        Assert.Equal("+84 912 345 678", phone);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-6A31E4835D | IOTAgriBackend.Tests.ProfileRulesTests.Accepts_name_with_optional_phone | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=34bfcc2b-8178-6804-3350-7f13fc33f968; [log](reports/summary/followup-final-test.log) |

## ProfileRulesTests.Accepts_supported_phone_shapes

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesTests.Accepts_supported_phone_shapes`
- **Test type:** Unit test
- **Scenario:** Accepts supported phone shapes
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesTests.cs:56](../backend/tests/ProfileRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Null(ProfileRules.Validate("Nguyễn Văn A", phone, out _, out _));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-DB29A19B29 | IOTAgriBackend.Tests.ProfileRulesTests.Accepts_supported_phone_shapes(phone: "(028) 3822-1234") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c330504c-248d-66f9-8bda-1c63f14c8240; [log](reports/summary/followup-final-test.log) |
| TC-BE-206AA82A2F | IOTAgriBackend.Tests.ProfileRulesTests.Accepts_supported_phone_shapes(phone: "+84 912 345 678") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=0c08ea91-2169-e792-a5c6-549c168e7374; [log](reports/summary/followup-final-test.log) |
| TC-BE-C710B75B09 | IOTAgriBackend.Tests.ProfileRulesTests.Accepts_supported_phone_shapes(phone: "0912345678") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=3e07dd7b-a7ca-6852-332a-6f6ffd34e190; [log](reports/summary/followup-final-test.log) |

## ProfileRulesTests.Rejects_malformed_phone

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesTests.Rejects_malformed_phone`
- **Test type:** Unit test
- **Scenario:** Rejects malformed phone
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesTests.cs:47](../backend/tests/ProfileRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(ProfileRules.Validate("Nguyễn Văn A", phone, out _, out _));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-BC5D7F7835 | IOTAgriBackend.Tests.ProfileRulesTests.Rejects_malformed_phone(phone: "0912-345-678; DROP") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=f7df2bbd-89b6-e04b-3070-a679f0cb7bb7; [log](reports/summary/followup-final-test.log) |
| TC-BE-96FFD94E32 | IOTAgriBackend.Tests.ProfileRulesTests.Rejects_malformed_phone(phone: "12345") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4e44332e-674a-27a8-74ae-d7901c9cf137; [log](reports/summary/followup-final-test.log) |
| TC-BE-7036901846 | IOTAgriBackend.Tests.ProfileRulesTests.Rejects_malformed_phone(phone: "not-a-phone") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=60b01f56-0f9a-0cb2-7bff-577f200e8121; [log](reports/summary/followup-final-test.log) |

## ProfileRulesTests.Rejects_overlong_name

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesTests.Rejects_overlong_name`
- **Test type:** Unit test
- **Scenario:** Rejects overlong name
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesTests.cs:37](../backend/tests/ProfileRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var name = new string('a', ProfileRules.MaximumFullNameLength + 1);
        Assert.NotNull(ProfileRules.Validate(name, null, out _, out _));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-245E1CAB88 | IOTAgriBackend.Tests.ProfileRulesTests.Rejects_overlong_name | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=173fb351-cf58-a971-b6af-a21a1e4ea411; [log](reports/summary/followup-final-test.log) |

## ProfileRulesTests.Rejects_overlong_phone

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesTests.Rejects_overlong_phone`
- **Test type:** Unit test
- **Scenario:** Rejects overlong phone
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesTests.cs:62](../backend/tests/ProfileRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var phone = new string('1', ProfileRules.MaximumPhoneNumberLength + 1);
        Assert.NotNull(ProfileRules.Validate("Nguyễn Văn A", phone, out _, out _));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-395F7A9173 | IOTAgriBackend.Tests.ProfileRulesTests.Rejects_overlong_phone | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a689a15a-f332-b842-27c3-7bbeca257949; [log](reports/summary/followup-final-test.log) |

## ProfileRulesTests.Requires_full_name

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesTests.Requires_full_name`
- **Test type:** Unit test
- **Scenario:** Requires full name
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesTests.cs:31](../backend/tests/ProfileRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(ProfileRules.Validate(fullName, null, out _, out _));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-139131E64C | IOTAgriBackend.Tests.ProfileRulesTests.Requires_full_name(fullName: "   ") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7d7a2f8c-b9ba-71b8-9cbd-8d523e7ce129; [log](reports/summary/followup-final-test.log) |
| TC-BE-905A927F74 | IOTAgriBackend.Tests.ProfileRulesTests.Requires_full_name(fullName: "") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=74bad3d8-58c3-1dd7-5770-8c2c5015585d; [log](reports/summary/followup-final-test.log) |
| TC-BE-CC77361DC9 | IOTAgriBackend.Tests.ProfileRulesTests.Requires_full_name(fullName: null) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=60e4441e-ca4a-3a97-1c48-38ddd48f6ec1; [log](reports/summary/followup-final-test.log) |

## ProfileRulesTests.Treats_blank_phone_as_removal

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProfileRules
- **Test identity:** `IOTAgriBackend.Tests.ProfileRulesTests.Treats_blank_phone_as_removal`
- **Test type:** Unit test
- **Scenario:** Treats blank phone as removal
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProfileRulesTests.cs:21](../backend/tests/ProfileRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Null(ProfileRules.Validate("Nguyễn Văn A", "   ", out _, out var phone));
        Assert.Null(phone);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-6CF3F4E581 | IOTAgriBackend.Tests.ProfileRulesTests.Treats_blank_phone_as_removal | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=e3c138a2-124a-9f4f-3d9f-f0b838c884a6; [log](reports/summary/followup-final-test.log) |

## ProvisioningCodeExtendedTests.Generated_code_can_be_hashed_and_verified

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProvisioningCode
- **Test identity:** `IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Generated_code_can_be_hashed_and_verified`
- **Test type:** Unit test
- **Scenario:** Generated code can be hashed and verified
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProvisioningCodeExtendedTests.cs:26](../backend/tests/ProvisioningCodeExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var code = ProvisioningCode.Create();
        Assert.True(ProvisioningCode.Matches(code, ProvisioningCode.Hash(code)));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-6B5EC30AF4 | IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Generated_code_can_be_hashed_and_verified | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=547f3289-cf18-c8db-d7ae-081984e9edfe; [log](reports/summary/followup-final-test.log) |

## ProvisioningCodeExtendedTests.Generated_code_is_twelve_characters_long

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProvisioningCode
- **Test identity:** `IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Generated_code_is_twelve_characters_long`
- **Test type:** Unit test
- **Scenario:** Generated code is twelve characters long
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProvisioningCodeExtendedTests.cs:9](../backend/tests/ProvisioningCodeExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var code = ProvisioningCode.Create();

        Assert.Equal(12, code.Length);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-08DFDB553D | IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Generated_code_is_twelve_characters_long | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d6211e30-049e-2b6f-8e7c-1f46b7e3ea4b; [log](reports/summary/followup-final-test.log) |

## ProvisioningCodeExtendedTests.Generated_code_uses_only_alphabet_characters

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProvisioningCode
- **Test identity:** `IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Generated_code_uses_only_alphabet_characters`
- **Test type:** Unit test
- **Scenario:** Generated code uses only alphabet characters
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProvisioningCodeExtendedTests.cs:17](../backend/tests/ProvisioningCodeExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        const string Alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        var code = ProvisioningCode.Create();

        Assert.All(code, character => Assert.Contains(character, Alphabet));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-F23AE995E0 | IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Generated_code_uses_only_alphabet_characters | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=3235e29e-ed0f-b404-0d82-b1731ad98d17; [log](reports/summary/followup-final-test.log) |

## ProvisioningCodeExtendedTests.Hash_differs_for_different_inputs

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProvisioningCode
- **Test identity:** `IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Hash_differs_for_different_inputs`
- **Test type:** Unit test
- **Scenario:** Hash differs for different inputs
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProvisioningCodeExtendedTests.cs:44](../backend/tests/ProvisioningCodeExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var hash1 = ProvisioningCode.Hash("ABCD2345EFGH");
        var hash2 = ProvisioningCode.Hash("ABCD2345EFGI");

        Assert.NotEqual(hash1, hash2);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-2FAAE7E655 | IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Hash_differs_for_different_inputs | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a2fd657e-ef53-eec1-4e2b-41791a69dadc; [log](reports/summary/followup-final-test.log) |

## ProvisioningCodeExtendedTests.Hash_is_deterministic_for_same_input

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProvisioningCode
- **Test identity:** `IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Hash_is_deterministic_for_same_input`
- **Test type:** Unit test
- **Scenario:** Hash is deterministic for same input
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProvisioningCodeExtendedTests.cs:33](../backend/tests/ProvisioningCodeExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        const string Code = "ABCD2345EFGH";

        var hash1 = ProvisioningCode.Hash(Code);
        var hash2 = ProvisioningCode.Hash(Code);

        Assert.Equal(hash1, hash2);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-D37940F750 | IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Hash_is_deterministic_for_same_input | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=888c2157-d2c4-69ec-a782-cc8f9a6791c6; [log](reports/summary/followup-final-test.log) |

## ProvisioningCodeExtendedTests.Matches_rejects_code_differing_in_last_character

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProvisioningCode
- **Test identity:** `IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Matches_rejects_code_differing_in_last_character`
- **Test type:** Unit test
- **Scenario:** Matches rejects code differing in last character
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProvisioningCodeExtendedTests.cs:63](../backend/tests/ProvisioningCodeExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // Functional comparison test; this does not measure or prove timing safety.
        var code = "ABCD2345EFGH";
        var hash = ProvisioningCode.Hash(code);
        var almostCode = "ABCD2345EFGI"; // last char different

        Assert.False(ProvisioningCode.Matches(almostCode, hash));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-8A3927547B | IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Matches_rejects_code_differing_in_last_character | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=cdccb0f1-f7d2-6a17-12f7-b069abf59004; [log](reports/summary/followup-final-test.log) |

## ProvisioningCodeExtendedTests.Matches_returns_false_for_empty_string_vs_code_hash

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProvisioningCode
- **Test identity:** `IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Matches_returns_false_for_empty_string_vs_code_hash`
- **Test type:** Unit test
- **Scenario:** Matches returns false for empty string vs code hash
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProvisioningCodeExtendedTests.cs:53](../backend/tests/ProvisioningCodeExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var code = ProvisioningCode.Create();
        var hash = ProvisioningCode.Hash(code);

        // Empty string should not match
        Assert.False(ProvisioningCode.Matches(string.Empty, hash));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-279EE4E79B | IOTAgriBackend.Tests.ProvisioningCodeExtendedTests.Matches_returns_false_for_empty_string_vs_code_hash | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b6e1b58d-d90b-0430-a23e-1b2de004341b; [log](reports/summary/followup-final-test.log) |

## ProvisioningCodeTests.Code_hashing_is_case_sensitive_after_the_endpoint_normalizes_input

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProvisioningCode
- **Test identity:** `IOTAgriBackend.Tests.ProvisioningCodeTests.Code_hashing_is_case_sensitive_after_the_endpoint_normalizes_input`
- **Test type:** Unit test
- **Scenario:** Code hashing is case sensitive after the endpoint normalizes input
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProvisioningCodeTests.cs:18](../backend/tests/ProvisioningCodeTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var code = "ABCD2345EFGH";

        Assert.True(ProvisioningCode.Matches(code, ProvisioningCode.Hash(code.ToUpperInvariant())));
        Assert.False(ProvisioningCode.Matches(code.ToLowerInvariant(), ProvisioningCode.Hash(code)));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-9B26867644 | IOTAgriBackend.Tests.ProvisioningCodeTests.Code_hashing_is_case_sensitive_after_the_endpoint_normalizes_input | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4b0b319b-03de-08e6-802a-721672859433; [log](reports/summary/followup-final-test.log) |

## ProvisioningCodeTests.Generated_code_matches_its_hash_only

- **Module:** Profile/provisioning/presence/admin
- **Component:** ProvisioningCode
- **Test identity:** `IOTAgriBackend.Tests.ProvisioningCodeTests.Generated_code_matches_its_hash_only`
- **Test type:** Unit test
- **Scenario:** Generated code matches its hash only
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/ProvisioningCodeTests.cs:9](../backend/tests/ProvisioningCodeTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var code = ProvisioningCode.Create();

        Assert.True(ProvisioningCode.Matches(code, ProvisioningCode.Hash(code)));
        Assert.False(ProvisioningCode.Matches("WRONG-CODE", ProvisioningCode.Hash(code)));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-7E91E225F5 | IOTAgriBackend.Tests.ProvisioningCodeTests.Generated_code_matches_its_hash_only | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=9c15cd38-9c0a-d3fd-28a2-7622245958f7; [log](reports/summary/followup-final-test.log) |

## PumpCommandHistoryQueryExtendedTests.Accepts_explicit_from_to_range_within_31_days

- **Module:** Pump control/scheduling
- **Component:** PumpCommandHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.Accepts_explicit_from_to_range_within_31_days`
- **Test type:** Unit/serialization test
- **Scenario:** Accepts explicit from to range within 31 days
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandHistoryQueryExtendedTests.cs:27](../backend/tests/PumpCommandHistoryQueryExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var from = new DateTimeOffset(2026, 9, 1, 0, 0, 0, TimeSpan.Zero);
        var to   = new DateTimeOffset(2026, 9, 30, 0, 0, 0, TimeSpan.Zero); // 29 days
        var now  = new DateTimeOffset(2026, 9, 30, 12, 0, 0, TimeSpan.Zero);

        var query = new PumpCommandHistoryQuery(From: from, To: to);
        var valid = query.TryGetRange(now, out var start, out var end);

        Assert.True(valid);
        Assert.Equal(from.UtcDateTime, start);
        Assert.Equal(to.UtcDateTime, end);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-98FB441800 | IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.Accepts_explicit_from_to_range_within_31_days | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4056d7a3-af16-14d4-332e-d9d3d814a674; [log](reports/summary/followup-final-test.log) |

## PumpCommandHistoryQueryExtendedTests.Default_range_end_uses_now_when_to_is_not_specified

- **Module:** Pump control/scheduling
- **Component:** PumpCommandHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.Default_range_end_uses_now_when_to_is_not_specified`
- **Test type:** Unit/serialization test
- **Scenario:** Default range end uses now when to is not specified
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandHistoryQueryExtendedTests.cs:67](../backend/tests/PumpCommandHistoryQueryExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var now = new DateTimeOffset(2026, 9, 17, 12, 0, 0, TimeSpan.Zero);

        var query = new PumpCommandHistoryQuery();
        query.TryGetRange(now, out _, out var end);

        Assert.Equal(now.UtcDateTime, end);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-05AC52DDED | IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.Default_range_end_uses_now_when_to_is_not_specified | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=8d270feb-2a3b-dffe-a26a-a621981995f4; [log](reports/summary/followup-final-test.log) |

## PumpCommandHistoryQueryExtendedTests.HasValidPagination_boundary_cases

- **Module:** Pump control/scheduling
- **Component:** PumpCommandHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.HasValidPagination_boundary_cases`
- **Test type:** Unit/serialization test
- **Scenario:** HasValidPagination boundary cases
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandHistoryQueryExtendedTests.cs:18](../backend/tests/PumpCommandHistoryQueryExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var query = new PumpCommandHistoryQuery(Page: page, PageSize: pageSize);

        Assert.Equal(expected, query.HasValidPagination);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-8BEC600BE6 | IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.HasValidPagination_boundary_cases(page: -1, pageSize: 50, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=af7d78e2-8775-fa47-6a35-b6c356ab1759; [log](reports/summary/followup-final-test.log) |
| TC-BE-290A8E6843 | IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.HasValidPagination_boundary_cases(page: 0, pageSize: 50, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=bf9c97f5-0448-0fb5-c585-53f2c37f72db; [log](reports/summary/followup-final-test.log) |
| TC-BE-24900FB9EA | IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.HasValidPagination_boundary_cases(page: 1, pageSize: 0, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=271adfad-161c-5914-cc92-2b41cf0ad069; [log](reports/summary/followup-final-test.log) |
| TC-BE-71C9463A5A | IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.HasValidPagination_boundary_cases(page: 1, pageSize: 1, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=43c8957e-0bc7-58bc-34b7-b5a28a1d9811; [log](reports/summary/followup-final-test.log) |
| TC-BE-3BF0DCFA14 | IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.HasValidPagination_boundary_cases(page: 1, pageSize: 100, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b4e87350-438d-e117-d6aa-fa3e91aa25e1; [log](reports/summary/followup-final-test.log) |
| TC-BE-8F0FD18470 | IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.HasValidPagination_boundary_cases(page: 1, pageSize: 101, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=63a46ea7-17e7-1d74-2fb9-1c13c29cd08b; [log](reports/summary/followup-final-test.log) |
| TC-BE-6EFB5BCE26 | IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.HasValidPagination_boundary_cases(page: 1, pageSize: 50, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=1a54280a-d109-e42a-5562-50e5c8a70bb3; [log](reports/summary/followup-final-test.log) |

## PumpCommandHistoryQueryExtendedTests.Rejects_range_exceeding_31_days

- **Module:** Pump control/scheduling
- **Component:** PumpCommandHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.Rejects_range_exceeding_31_days`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects range exceeding 31 days
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandHistoryQueryExtendedTests.cs:42](../backend/tests/PumpCommandHistoryQueryExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var from = new DateTimeOffset(2026, 8, 1, 0, 0, 0, TimeSpan.Zero);
        var to   = new DateTimeOffset(2026, 9, 5, 0, 0, 0, TimeSpan.Zero); // 35 days
        var now  = new DateTimeOffset(2026, 9, 10, 0, 0, 0, TimeSpan.Zero);

        var query = new PumpCommandHistoryQuery(From: from, To: to);
        var valid = query.TryGetRange(now, out _, out _);

        Assert.False(valid);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3A7969316A | IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.Rejects_range_exceeding_31_days | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=8db5c94d-d93c-9773-df74-6c253f42c426; [log](reports/summary/followup-final-test.log) |

## PumpCommandHistoryQueryExtendedTests.Rejects_range_where_from_equals_to

- **Module:** Pump control/scheduling
- **Component:** PumpCommandHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.Rejects_range_where_from_equals_to`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects range where from equals to
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandHistoryQueryExtendedTests.cs:55](../backend/tests/PumpCommandHistoryQueryExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var point = new DateTimeOffset(2026, 9, 17, 12, 0, 0, TimeSpan.Zero);
        var now   = new DateTimeOffset(2026, 9, 17, 12, 0, 0, TimeSpan.Zero);

        var query = new PumpCommandHistoryQuery(From: point, To: point);
        var valid = query.TryGetRange(now, out _, out _);

        Assert.False(valid);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-D0A9F4E659 | IOTAgriBackend.Tests.PumpCommandHistoryQueryExtendedTests.Rejects_range_where_from_equals_to | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=dc0f82d8-e61a-cb9f-6ea5-761d7288bf6a; [log](reports/summary/followup-final-test.log) |

## PumpCommandHistoryQueryTests.Defaults_to_the_previous_seven_days

- **Module:** Pump control/scheduling
- **Component:** PumpCommandHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandHistoryQueryTests.Defaults_to_the_previous_seven_days`
- **Test type:** Unit/serialization test
- **Scenario:** Defaults to the previous seven days
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandHistoryQueryTests.cs:10](../backend/tests/PumpCommandHistoryQueryTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var now = new DateTimeOffset(2026, 9, 17, 12, 0, 0, TimeSpan.Zero);

        var valid = new PumpCommandHistoryQuery().TryGetRange(now, out var start, out var end);

        Assert.True(valid);
        Assert.Equal(now.UtcDateTime.AddDays(-7), start);
        Assert.Equal(now.UtcDateTime, end);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-FE0FC1D8AC | IOTAgriBackend.Tests.PumpCommandHistoryQueryTests.Defaults_to_the_previous_seven_days | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=1e68836a-3d0a-c05a-b0f9-a4cf00cb9931; [log](reports/summary/followup-final-test.log) |

## PumpCommandHistoryQueryTests.Rejects_invalid_range_and_page_size

- **Module:** Pump control/scheduling
- **Component:** PumpCommandHistoryQuery
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandHistoryQueryTests.Rejects_invalid_range_and_page_size`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects invalid range and page size
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandHistoryQueryTests.cs:22](../backend/tests/PumpCommandHistoryQueryTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var now = new DateTimeOffset(2026, 9, 17, 12, 0, 0, TimeSpan.Zero);

        Assert.False(new PumpCommandHistoryQuery(now.AddDays(1), now).TryGetRange(now, out _, out _));
        Assert.False(new PumpCommandHistoryQuery(PageSize: 101).HasValidPagination);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-041DB657B8 | IOTAgriBackend.Tests.PumpCommandHistoryQueryTests.Rejects_invalid_range_and_page_size | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a1a52495-fbaa-2982-8868-71b9ae77d4ba; [log](reports/summary/followup-final-test.log) |

## PumpCommandRequestExtendedTests.Empty_guid_command_id_makes_request_invalid

- **Module:** Pump control/scheduling
- **Component:** PumpCommandRequest
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.Empty_guid_command_id_makes_request_invalid`
- **Test type:** Unit/serialization test
- **Scenario:** Empty guid command id makes request invalid
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandRequestExtendedTests.cs:39](../backend/tests/PumpCommandRequestExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(new PumpCommandRequest(Guid.Empty, false, null).IsValid(600));
        Assert.False(new PumpCommandRequest(Guid.Empty, true, 300).IsValid(600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-DA30CF834C | IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.Empty_guid_command_id_makes_request_invalid | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=ca72edee-7933-0c38-26d5-6231361f6e8b; [log](reports/summary/followup-final-test.log) |

## PumpCommandRequestExtendedTests.Off_command_with_max_duration_is_always_invalid

- **Module:** Pump control/scheduling
- **Component:** PumpCommandRequest
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.Off_command_with_max_duration_is_always_invalid`
- **Test type:** Unit/serialization test
- **Scenario:** Off command with max duration is always invalid
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandRequestExtendedTests.cs:47](../backend/tests/PumpCommandRequestExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), false, 600).IsValid(600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-DEA7CCFC76 | IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.Off_command_with_max_duration_is_always_invalid | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4ce40473-f183-69f7-7b59-9435371e0064; [log](reports/summary/followup-final-test.log) |

## PumpCommandRequestExtendedTests.On_command_with_duration_at_exact_maximum_is_valid

- **Module:** Pump control/scheduling
- **Component:** PumpCommandRequest
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.On_command_with_duration_at_exact_maximum_is_valid`
- **Test type:** Unit/serialization test
- **Scenario:** On command with duration at exact maximum is valid
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandRequestExtendedTests.cs:11](../backend/tests/PumpCommandRequestExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.True(new PumpCommandRequest(Guid.NewGuid(), true, 600).IsValid(600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-E3A32297D9 | IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.On_command_with_duration_at_exact_maximum_is_valid | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=ebbedec8-d39a-dce3-8c86-1a3c96220114; [log](reports/summary/followup-final-test.log) |

## PumpCommandRequestExtendedTests.On_command_with_duration_of_one_second_is_valid

- **Module:** Pump control/scheduling
- **Component:** PumpCommandRequest
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.On_command_with_duration_of_one_second_is_valid`
- **Test type:** Unit/serialization test
- **Scenario:** On command with duration of one second is valid
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandRequestExtendedTests.cs:18](../backend/tests/PumpCommandRequestExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.True(new PumpCommandRequest(Guid.NewGuid(), true, 1).IsValid(600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-2B9CDDEDB9 | IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.On_command_with_duration_of_one_second_is_valid | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c444dc7e-32d6-aa07-465f-183990ef2cf5; [log](reports/summary/followup-final-test.log) |

## PumpCommandRequestExtendedTests.On_command_with_duration_of_zero_is_invalid

- **Module:** Pump control/scheduling
- **Component:** PumpCommandRequest
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.On_command_with_duration_of_zero_is_invalid`
- **Test type:** Unit/serialization test
- **Scenario:** On command with duration of zero is invalid
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandRequestExtendedTests.cs:25](../backend/tests/PumpCommandRequestExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), true, 0).IsValid(600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-2C37D3C715 | IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.On_command_with_duration_of_zero_is_invalid | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4bffa0a6-0a46-3d4e-a871-cdbfacf542a1; [log](reports/summary/followup-final-test.log) |

## PumpCommandRequestExtendedTests.On_command_with_negative_duration_is_invalid

- **Module:** Pump control/scheduling
- **Component:** PumpCommandRequest
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.On_command_with_negative_duration_is_invalid`
- **Test type:** Unit/serialization test
- **Scenario:** On command with negative duration is invalid
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandRequestExtendedTests.cs:32](../backend/tests/PumpCommandRequestExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), true, -1).IsValid(600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-CD932A8FAE | IOTAgriBackend.Tests.PumpCommandRequestExtendedTests.On_command_with_negative_duration_is_invalid | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7d16df13-02c0-0f2f-9ed1-3e97e0b57d35; [log](reports/summary/followup-final-test.log) |

## PumpCommandRequestTests.Off_command_cannot_include_a_duration

- **Module:** Pump control/scheduling
- **Component:** PumpCommandRequest
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandRequestTests.Off_command_cannot_include_a_duration`
- **Test type:** Unit/serialization test
- **Scenario:** Off command cannot include a duration
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandRequestTests.cs:18](../backend/tests/PumpCommandRequestTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), false, 1).IsValid(600));
        Assert.True(new PumpCommandRequest(Guid.NewGuid(), false, null).IsValid(600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-005162EE7A | IOTAgriBackend.Tests.PumpCommandRequestTests.Off_command_cannot_include_a_duration | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=205d86ea-ba26-3fd2-22ae-a3a9e6a675c9; [log](reports/summary/followup-final-test.log) |

## PumpCommandRequestTests.On_command_requires_a_bounded_duration

- **Module:** Pump control/scheduling
- **Component:** PumpCommandRequest
- **Test identity:** `IOTAgriBackend.Tests.PumpCommandRequestTests.On_command_requires_a_bounded_duration`
- **Test type:** Unit/serialization test
- **Scenario:** On command requires a bounded duration
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpCommandRequestTests.cs:10](../backend/tests/PumpCommandRequestTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), true, null).IsValid(600));
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), true, 601).IsValid(600));
        Assert.True(new PumpCommandRequest(Guid.NewGuid(), true, 600).IsValid(600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-FF5B31D67A | IOTAgriBackend.Tests.PumpCommandRequestTests.On_command_requires_a_bounded_duration | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=348b82bd-faaf-f8be-9208-d0117443b749; [log](reports/summary/followup-final-test.log) |

## PumpMqttMessageExtendedTests.Empty_reason_normalizes_to_null

- **Module:** Pump control/scheduling
- **Component:** PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason
- **Test identity:** `IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Empty_reason_normalizes_to_null`
- **Test type:** Unit/serialization test
- **Scenario:** Empty reason normalizes to null
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpMqttMessageExtendedTests.cs:22](../backend/tests/PumpMqttMessageExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var status = new PumpStatusMessage(null, true, null, "");

        Assert.Null(status.NormalizedReason);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-278939C304 | IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Empty_reason_normalizes_to_null | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=f8d96344-6095-4858-1cc7-da19e91a4d18; [log](reports/summary/followup-final-test.log) |

## PumpMqttMessageExtendedTests.Explicit_success_false_marks_message_as_failed

- **Module:** Pump control/scheduling
- **Component:** PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason
- **Test identity:** `IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Explicit_success_false_marks_message_as_failed`
- **Test type:** Unit/serialization test
- **Scenario:** Explicit success false marks message as failed
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpMqttMessageExtendedTests.cs:58](../backend/tests/PumpMqttMessageExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var status = new PumpStatusMessage(null, false, false, "TIMEOUT");

        Assert.False(status.WasSuccessful);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-4F752E58F3 | IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Explicit_success_false_marks_message_as_failed | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d6634065-36aa-9334-6071-bbcb6bf12cc1; [log](reports/summary/followup-final-test.log) |

## PumpMqttMessageExtendedTests.Explicit_success_true_marks_message_as_successful

- **Module:** Pump control/scheduling
- **Component:** PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason
- **Test identity:** `IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Explicit_success_true_marks_message_as_successful`
- **Test type:** Unit/serialization test
- **Scenario:** Explicit success true marks message as successful
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpMqttMessageExtendedTests.cs:66](../backend/tests/PumpMqttMessageExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var status = new PumpStatusMessage(null, true, true, null);

        Assert.True(status.WasSuccessful);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-19BD7ECA06 | IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Explicit_success_true_marks_message_as_successful | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=bf025802-1609-445d-cd4a-066400e5656d; [log](reports/summary/followup-final-test.log) |

## PumpMqttMessageExtendedTests.Null_reason_normalizes_to_null

- **Module:** Pump control/scheduling
- **Component:** PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason
- **Test identity:** `IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Null_reason_normalizes_to_null`
- **Test type:** Unit/serialization test
- **Scenario:** Null reason normalizes to null
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpMqttMessageExtendedTests.cs:14](../backend/tests/PumpMqttMessageExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var status = new PumpStatusMessage(null, true, null, null);

        Assert.Null(status.NormalizedReason);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-AB4D071C9A | IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Null_reason_normalizes_to_null | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5290733c-4bfc-cc2c-0c10-0b7bb3b16b4c; [log](reports/summary/followup-final-test.log) |

## PumpMqttMessageExtendedTests.PumpCommandMessage_serializes_and_deserializes_correctly

- **Module:** Pump control/scheduling
- **Component:** PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason
- **Test identity:** `IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.PumpCommandMessage_serializes_and_deserializes_correctly`
- **Test type:** Unit/serialization test
- **Scenario:** PumpCommandMessage serializes and deserializes correctly
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpMqttMessageExtendedTests.cs:75](../backend/tests/PumpMqttMessageExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var commandId = Guid.NewGuid();
        var original = new PumpCommandMessage(commandId, true, 300);

        var json = JsonSerializer.Serialize(original, JsonOptions);
        var deserialized = JsonSerializer.Deserialize<PumpCommandMessage>(json, JsonOptions);

        Assert.NotNull(deserialized);
        Assert.Equal(commandId, deserialized.CommandId);
        Assert.True(deserialized.IsOn);
        Assert.Equal(300, deserialized.DurationSeconds);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-EDA23BE793 | IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.PumpCommandMessage_serializes_and_deserializes_correctly | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=33211eff-5a85-e33f-1c8a-aa7bfa911b83; [log](reports/summary/followup-final-test.log) |

## PumpMqttMessageExtendedTests.PumpCommandMessage_with_null_duration_serializes_correctly

- **Module:** Pump control/scheduling
- **Component:** PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason
- **Test identity:** `IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.PumpCommandMessage_with_null_duration_serializes_correctly`
- **Test type:** Unit/serialization test
- **Scenario:** PumpCommandMessage with null duration serializes correctly
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpMqttMessageExtendedTests.cs:90](../backend/tests/PumpMqttMessageExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var original = new PumpCommandMessage(Guid.NewGuid(), false, null);

        var json = JsonSerializer.Serialize(original, JsonOptions);
        var deserialized = JsonSerializer.Deserialize<PumpCommandMessage>(json, JsonOptions);

        Assert.NotNull(deserialized);
        Assert.False(deserialized.IsOn);
        Assert.Null(deserialized.DurationSeconds);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-C7F9495CEB | IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.PumpCommandMessage_with_null_duration_serializes_correctly | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6b39cf7f-dcb3-c7cc-d5c4-6f4b9ca5c028; [log](reports/summary/followup-final-test.log) |

## PumpMqttMessageExtendedTests.Reason_exceeding_512_chars_is_truncated_to_512

- **Module:** Pump control/scheduling
- **Component:** PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason
- **Test identity:** `IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Reason_exceeding_512_chars_is_truncated_to_512`
- **Test type:** Unit/serialization test
- **Scenario:** Reason exceeding 512 chars is truncated to 512
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpMqttMessageExtendedTests.cs:38](../backend/tests/PumpMqttMessageExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var longReason = new string('X', 600);
        var status = new PumpStatusMessage(null, false, false, longReason);

        Assert.Equal(512, status.NormalizedReason!.Length);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-B69C6EB6E0 | IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Reason_exceeding_512_chars_is_truncated_to_512 | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4982c46a-d30e-2038-e842-db1e78624d82; [log](reports/summary/followup-final-test.log) |

## PumpMqttMessageExtendedTests.Reason_of_exactly_512_chars_is_not_truncated

- **Module:** Pump control/scheduling
- **Component:** PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason
- **Test identity:** `IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Reason_of_exactly_512_chars_is_not_truncated`
- **Test type:** Unit/serialization test
- **Scenario:** Reason of exactly 512 chars is not truncated
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpMqttMessageExtendedTests.cs:47](../backend/tests/PumpMqttMessageExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var exactReason = new string('X', 512);
        var status = new PumpStatusMessage(null, false, false, exactReason);

        Assert.Equal(512, status.NormalizedReason!.Length);
        Assert.Equal(exactReason, status.NormalizedReason);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-2A62F6843D | IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Reason_of_exactly_512_chars_is_not_truncated | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=66910eb6-ec9d-95a8-6a4d-18044d7a2d0e; [log](reports/summary/followup-final-test.log) |

## PumpMqttMessageExtendedTests.Whitespace_only_reason_normalizes_to_null

- **Module:** Pump control/scheduling
- **Component:** PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason
- **Test identity:** `IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Whitespace_only_reason_normalizes_to_null`
- **Test type:** Unit/serialization test
- **Scenario:** Whitespace only reason normalizes to null
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpMqttMessageExtendedTests.cs:30](../backend/tests/PumpMqttMessageExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var status = new PumpStatusMessage(null, true, null, "   ");

        Assert.Null(status.NormalizedReason);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-5B587E9A79 | IOTAgriBackend.Tests.PumpMqttMessageExtendedTests.Whitespace_only_reason_normalizes_to_null | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=0c4b02fa-aab9-4db9-d380-84e84bd88ac7; [log](reports/summary/followup-final-test.log) |

## PumpMqttMessageTests.Legacy_status_without_success_remains_acknowledged

- **Module:** Pump control/scheduling
- **Component:** PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason
- **Test identity:** `IOTAgriBackend.Tests.PumpMqttMessageTests.Legacy_status_without_success_remains_acknowledged`
- **Test type:** Unit/serialization test
- **Scenario:** Legacy status without success remains acknowledged
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpMqttMessageTests.cs:12](../backend/tests/PumpMqttMessageTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var status = JsonSerializer.Deserialize<PumpStatusMessage>(
            """{"commandId":"ad2ff566-68e4-4e96-a799-9bb617c0e491","isOn":true}""",
            JsonOptions);

        Assert.NotNull(status);
        Assert.True(status.WasSuccessful);
        Assert.Null(status.NormalizedReason);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-71733FC0C8 | IOTAgriBackend.Tests.PumpMqttMessageTests.Legacy_status_without_success_remains_acknowledged | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=23e1ae42-7b92-0960-fc22-3278418cf235; [log](reports/summary/followup-final-test.log) |

## PumpMqttMessageTests.Safety_rejection_preserves_a_bounded_reason

- **Module:** Pump control/scheduling
- **Component:** PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason
- **Test identity:** `IOTAgriBackend.Tests.PumpMqttMessageTests.Safety_rejection_preserves_a_bounded_reason`
- **Test type:** Unit/serialization test
- **Scenario:** Safety rejection preserves a bounded reason
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpMqttMessageTests.cs:24](../backend/tests/PumpMqttMessageTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var status = JsonSerializer.Deserialize<PumpStatusMessage>(
            """{"commandId":"ad2ff566-68e4-4e96-a799-9bb617c0e491","isOn":false,"success":false,"reason":" LOW_WATER "}""",
            JsonOptions);

        Assert.NotNull(status);
        Assert.False(status.WasSuccessful);
        Assert.Equal("LOW_WATER", status.NormalizedReason);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3210C9583F | IOTAgriBackend.Tests.PumpMqttMessageTests.Safety_rejection_preserves_a_bounded_reason | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c65cdf98-7b63-bc15-9bc4-35bfeaa33c28; [log](reports/summary/followup-final-test.log) |

## PumpScheduleBoundaryTests.Adjacent_schedules_that_touch_at_end_do_not_overlap

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules.GetDueOccurrencesUtc / TryGetDueOccurrenceUtc / Overlaps
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleBoundaryTests.Adjacent_schedules_that_touch_at_end_do_not_overlap`
- **Test type:** Unit/serialization test
- **Scenario:** Adjacent schedules that touch at end do not overlap
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleBoundaryTests.cs:34](../backend/tests/PumpScheduleBoundaryTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var first = new PumpSchedule { WeekdayMask = 1, StartTime = new TimeOnly(6, 0), DurationSeconds = 600 };
        var adjacent = new PumpSchedule { WeekdayMask = 1, StartTime = new TimeOnly(6, 10), DurationSeconds = 600 };
        Assert.False(PumpScheduleRules.Overlaps(first, new[] { adjacent }));
        Assert.False(PumpScheduleRules.Overlaps(adjacent, new[] { first }));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3015C8FAF6 | IOTAgriBackend.Tests.PumpScheduleBoundaryTests.Adjacent_schedules_that_touch_at_end_do_not_overlap | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=953ba9bb-0dbd-55af-71b2-d553d6ed7c02; [log](reports/summary/followup-final-test.log) |

## PumpScheduleBoundaryTests.Due_window_is_inclusive_and_does_not_dispatch_future_occurrences

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules.GetDueOccurrencesUtc / TryGetDueOccurrenceUtc / Overlaps
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleBoundaryTests.Due_window_is_inclusive_and_does_not_dispatch_future_occurrences`
- **Test type:** Unit/serialization test
- **Scenario:** Due window is inclusive and does not dispatch future occurrences
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleBoundaryTests.cs:15](../backend/tests/PumpScheduleBoundaryTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var due = new DateTime(2026, 1, 3, 23, 0, 0, DateTimeKind.Utc);
        var schedule = new PumpSchedule { IsEnabled = true, WeekdayMask = 1, StartTime = new TimeOnly(6, 0), TimeZone = "Asia/Bangkok" };
        var found = PumpScheduleRules.TryGetDueOccurrenceUtc(schedule, due.AddSeconds(secondsAfterStart), TimeSpan.FromSeconds(90), out var occurrence);
        Assert.Equal(expected, found);
        Assert.Equal(expected ? due : default, occurrence);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-9287B858F5 | IOTAgriBackend.Tests.PumpScheduleBoundaryTests.Due_window_is_inclusive_and_does_not_dispatch_future_occurrences(secondsAfterStart: -1, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7606f6f8-c3f9-6aad-c730-abb37fc6f844; [log](reports/summary/followup-final-test.log) |
| TC-BE-AD9EBE0B67 | IOTAgriBackend.Tests.PumpScheduleBoundaryTests.Due_window_is_inclusive_and_does_not_dispatch_future_occurrences(secondsAfterStart: 0, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a329b64d-bf8e-45da-1b1f-9a40159589dd; [log](reports/summary/followup-final-test.log) |
| TC-BE-B172BCBF3D | IOTAgriBackend.Tests.PumpScheduleBoundaryTests.Due_window_is_inclusive_and_does_not_dispatch_future_occurrences(secondsAfterStart: 90, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=60d3fb3d-bd0c-0f3f-532f-3c4ed257acf9; [log](reports/summary/followup-final-test.log) |
| TC-BE-B127D9C88D | IOTAgriBackend.Tests.PumpScheduleBoundaryTests.Due_window_is_inclusive_and_does_not_dispatch_future_occurrences(secondsAfterStart: 91, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=0a1e8212-1306-8f2c-4463-827ebde0dca6; [log](reports/summary/followup-final-test.log) |

## PumpScheduleBoundaryTests.Overnight_window_dispatches_previous_days_occurrence_but_excludes_end_time

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules.GetDueOccurrencesUtc / TryGetDueOccurrenceUtc / Overlaps
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleBoundaryTests.Overnight_window_dispatches_previous_days_occurrence_but_excludes_end_time`
- **Test type:** Unit/serialization test
- **Scenario:** Overnight window dispatches previous days occurrence but excludes end time
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleBoundaryTests.cs:25](../backend/tests/PumpScheduleBoundaryTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var schedule = new PumpSchedule { IsEnabled = true, WeekdayMask = 64, StartTime = new TimeOnly(23, 30), EndTime = new TimeOnly(1, 0), IntervalMinutes = 30, TimeZone = "Etc/UTC" };
        var midnight = new DateTime(2026, 1, 4, 0, 0, 0, DateTimeKind.Utc);
        Assert.Equal(new[] { midnight }, PumpScheduleRules.GetDueOccurrencesUtc(schedule, midnight, TimeSpan.FromSeconds(90)));
        Assert.Empty(PumpScheduleRules.GetDueOccurrencesUtc(schedule, midnight.AddHours(1), TimeSpan.FromSeconds(90)));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-74CC04D11E | IOTAgriBackend.Tests.PumpScheduleBoundaryTests.Overnight_window_dispatches_previous_days_occurrence_but_excludes_end_time | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4fecfa29-237c-5032-b35b-bc9dac4ae57f; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Accepts_duration_one_second_less_than_interval

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Accepts_duration_one_second_less_than_interval`
- **Test type:** Unit/serialization test
- **Scenario:** Accepts duration one second less than interval
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:95](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // durationSeconds=1799 < intervalMinutes(30)*60=1800
        Assert.Null(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 1799, "Asia/Bangkok", 3600,
            endTime: new TimeOnly(8, 0), intervalMinutes: 30));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-814584B317 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Accepts_duration_one_second_less_than_interval | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c2985c3a-8c4c-4acd-5d65-71240edc3578; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Accepts_intervalMinutes_of_sixty

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Accepts_intervalMinutes_of_sixty`
- **Test type:** Unit/serialization test
- **Scenario:** Accepts intervalMinutes of sixty
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:80](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Null(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 30, "Asia/Bangkok", 3600,
            endTime: new TimeOnly(8, 0), intervalMinutes: 60));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-D2CF064B0E | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Accepts_intervalMinutes_of_sixty | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=adf79c5e-644e-1d02-cdbb-dd205eab10c4; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Accepts_maximum_duration_equal_to_limit

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Accepts_maximum_duration_equal_to_limit`
- **Test type:** Unit/serialization test
- **Scenario:** Accepts maximum duration equal to limit
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:27](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Null(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 600, "Asia/Bangkok", 600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-855841DC59 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Accepts_maximum_duration_equal_to_limit | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d902c1f6-a652-e662-3e9b-a9fa29ff2a9b; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Accepts_overnight_window_where_endTime_is_before_startTime

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Accepts_overnight_window_where_endTime_is_before_startTime`
- **Test type:** Unit/serialization test
- **Scenario:** Accepts overnight window where endTime is before startTime
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:110](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // endTime=01:00 < startTime=23:30 -> overnight window
        Assert.Null(PumpScheduleRules.Validate(true, 1, new TimeOnly(23, 30), 60, "Asia/Bangkok", 3600,
            endTime: new TimeOnly(1, 0), intervalMinutes: 30));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-4146E8C096 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Accepts_overnight_window_where_endTime_is_before_startTime | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=743444d6-6651-3615-0808-b6c275c348dd; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Disabled_candidate_never_overlaps

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Disabled_candidate_never_overlaps`
- **Test type:** Unit/serialization test
- **Scenario:** Disabled candidate never overlaps
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:120](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var disabled = new PumpSchedule
        {
            IsEnabled = false,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600,
        };
        var existing = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600,
        };

        Assert.False(PumpScheduleRules.Overlaps(disabled, [existing]));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-165A852F9D | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Disabled_candidate_never_overlaps | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=422852ab-be08-53a9-be1f-dc8eacbeb968; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Non_overlapping_schedules_on_same_day_do_not_conflict

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Non_overlapping_schedules_on_same_day_do_not_conflict`
- **Test type:** Unit/serialization test
- **Scenario:** Non overlapping schedules on same day do not conflict
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:157](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var morning = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600, // ends 6:10
        };
        var afternoon = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(14, 0),
            DurationSeconds = 600, // starts 14:00
        };

        Assert.False(PumpScheduleRules.Overlaps(morning, [afternoon]));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-2E3A23BDF6 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Non_overlapping_schedules_on_same_day_do_not_conflict | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=83602816-832f-b35e-2230-044b3ba48add; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Occurrence_is_returned_in_ascending_order

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Occurrence_is_returned_in_ascending_order`
- **Test type:** Unit/serialization test
- **Scenario:** Occurrence is returned in ascending order
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:273](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var schedule = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1, // Sunday
            StartTime = new TimeOnly(6, 0),
            EndTime = new TimeOnly(7, 0),
            IntervalMinutes = 30,
            DurationSeconds = 60,
            TimeZone = "Asia/Bangkok",
        };
        // Bangkok Sunday 6:00 = UTC Saturday 23:00
        // Bangkok Sunday 6:30 = UTC Saturday 23:30
        var utcNow = new DateTime(2026, 1, 3, 23, 30, 0, DateTimeKind.Utc);

        var occurrences = PumpScheduleRules.GetDueOccurrencesUtc(schedule, utcNow, TimeSpan.FromMinutes(35));

        Assert.Equal(new[] { utcNow.AddMinutes(-30), utcNow }, occurrences);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-AECFB2B23B | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Occurrence_is_returned_in_ascending_order | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5a8abf59-b2b9-11df-8e2c-e943edb16e1e; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Overlapping_schedules_on_same_day_are_detected

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Overlapping_schedules_on_same_day_are_detected`
- **Test type:** Unit/serialization test
- **Scenario:** Overlapping schedules on same day are detected
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:178](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var first = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 3600, // ends 7:00
        };
        var second = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 30), // starts 6:30 inside first
            DurationSeconds = 600,
        };

        Assert.True(PumpScheduleRules.Overlaps(second, [first]));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-B66E3431BE | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Overlapping_schedules_on_same_day_are_detected | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=43f8f534-db17-b2f9-ce3b-77f3ca423a69; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Rejects_duration_equal_to_interval_in_seconds

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_duration_equal_to_interval_in_seconds`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects duration equal to interval in seconds
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:87](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // durationSeconds=1800 >= intervalMinutes(30)*60=1800
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 1800, "Asia/Bangkok", 3600,
            endTime: new TimeOnly(8, 0), intervalMinutes: 30));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-EBE99E402F | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_duration_equal_to_interval_in_seconds | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=0dfc6e61-102a-48e6-fc8d-ce52892bb7b7; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Rejects_duration_of_zero

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_duration_of_zero`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects duration of zero
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:33](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 0, "Asia/Bangkok", 600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-E848F6EFD1 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_duration_of_zero | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=9d3a7c10-2ff0-4bd7-3906-da7fadef3e8f; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Rejects_endTime_equal_to_startTime

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_endTime_equal_to_startTime`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects endTime equal to startTime
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:59](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 60, "Asia/Bangkok", 600,
            endTime: new TimeOnly(6, 0), intervalMinutes: 30));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-60C6D3EC8B | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_endTime_equal_to_startTime | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4be087cf-ce50-6f00-6451-79b02346b3d3; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Rejects_endTime_without_intervalMinutes

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_endTime_without_intervalMinutes`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects endTime without intervalMinutes
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:45](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 60, "Asia/Bangkok", 600,
            endTime: new TimeOnly(8, 0), intervalMinutes: null));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-162F70EFAA | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_endTime_without_intervalMinutes | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=693fc771-04e9-17c6-f747-7b69f53c6774; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Rejects_intervalMinutes_greater_than_sixty

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_intervalMinutes_greater_than_sixty`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects intervalMinutes greater than sixty
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:73](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 10, "Asia/Bangkok", 600,
            endTime: new TimeOnly(8, 0), intervalMinutes: 61));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-E910C7095D | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_intervalMinutes_greater_than_sixty | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=68fd4ef2-2d19-47d8-408e-5e62a0251c04; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Rejects_intervalMinutes_of_zero

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_intervalMinutes_of_zero`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects intervalMinutes of zero
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:66](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 10, "Asia/Bangkok", 600,
            endTime: new TimeOnly(8, 0), intervalMinutes: 0));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-2FBEC51A30 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_intervalMinutes_of_zero | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5db66576-bab4-3d1e-decc-5525b5692ac8; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Rejects_intervalMinutes_without_endTime

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_intervalMinutes_without_endTime`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects intervalMinutes without endTime
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:52](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 60, "Asia/Bangkok", 600,
            endTime: null, intervalMinutes: 30));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-E509A33754 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_intervalMinutes_without_endTime | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=fdf1a312-f030-2534-a956-0e63a8c16fef; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Rejects_negative_duration

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_negative_duration`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects negative duration
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:39](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), -1, "Asia/Bangkok", 600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-780908F602 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_negative_duration | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c5715db1-1cd5-84ff-0bc4-5b6a3698ff15; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Rejects_weekday_mask_with_bits_beyond_sunday_to_saturday

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_weekday_mask_with_bits_beyond_sunday_to_saturday`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects weekday mask with bits beyond sunday to saturday
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:20](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // 0b10000000 = bit 7, which is out of range
        Assert.NotNull(PumpScheduleRules.Validate(true, 0b10000000, new TimeOnly(6, 0), 60, "Asia/Bangkok", 3600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-CF919C7DDA | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_weekday_mask_with_bits_beyond_sunday_to_saturday | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=cc3c1957-ce62-8c49-cfc1-ba9997cd10ff; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Rejects_windows_time_zone_id

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_windows_time_zone_id`
- **Test type:** Unit/serialization test
- **Scenario:** Rejects windows time zone id
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:103](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // Windows time zone IDs are not valid IANA IDs
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 60, "SE Asia Standard Time", 600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-0E03715771 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Rejects_windows_time_zone_id | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a680b3d9-7d95-3e53-1d6e-ac0aed888211; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Returns_empty_list_for_invalid_time_zone

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Returns_empty_list_for_invalid_time_zone`
- **Test type:** Unit/serialization test
- **Scenario:** Returns empty list for invalid time zone
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:256](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var schedule = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 127,
            StartTime = new TimeOnly(6, 0),
            TimeZone = "Invalid/Zone",
        };
        var now = new DateTime(2026, 1, 4, 23, 0, 0, DateTimeKind.Utc);

        var result = PumpScheduleRules.GetDueOccurrencesUtc(schedule, now, TimeSpan.FromSeconds(90));

        Assert.Empty(result);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-A0F2349FA1 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Returns_empty_list_for_invalid_time_zone | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d2dc4573-81b4-aadb-a0d6-9dfe26c7d203; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Returns_empty_list_when_due_window_is_zero

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Returns_empty_list_when_due_window_is_zero`
- **Test type:** Unit/serialization test
- **Scenario:** Returns empty list when due window is zero
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:239](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var schedule = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 127,
            StartTime = new TimeOnly(6, 0),
            TimeZone = "Asia/Bangkok",
        };
        var now = new DateTime(2026, 1, 4, 23, 0, 0, DateTimeKind.Utc);

        var result = PumpScheduleRules.GetDueOccurrencesUtc(schedule, now, TimeSpan.Zero);

        Assert.Empty(result);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-399FF53008 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Returns_empty_list_when_due_window_is_zero | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d55b9797-1b92-acbf-7311-30f3a937b602; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Returns_empty_list_when_schedule_is_disabled

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Returns_empty_list_when_schedule_is_disabled`
- **Test type:** Unit/serialization test
- **Scenario:** Returns empty list when schedule is disabled
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:222](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var schedule = new PumpSchedule
        {
            IsEnabled = false,
            WeekdayMask = 127,
            StartTime = new TimeOnly(6, 0),
            TimeZone = "Asia/Bangkok",
        };
        var now = new DateTime(2026, 1, 4, 23, 0, 0, DateTimeKind.Utc); // Bangkok 06:00

        var result = PumpScheduleRules.GetDueOccurrencesUtc(schedule, now, TimeSpan.FromSeconds(90));

        Assert.Empty(result);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-0D0EB668AD | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Returns_empty_list_when_schedule_is_disabled | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a4a3e55e-99f8-b5ed-aca1-2cc8fddd7855; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Schedule_does_not_overlap_with_itself_by_id

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Schedule_does_not_overlap_with_itself_by_id`
- **Test type:** Unit/serialization test
- **Scenario:** Schedule does not overlap with itself by id
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:141](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var id = Guid.NewGuid();
        var schedule = new PumpSchedule
        {
            Id = id,
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600,
        };

        Assert.False(PumpScheduleRules.Overlaps(schedule, [schedule]));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-094C6AB9EE | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Schedule_does_not_overlap_with_itself_by_id | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=024403ab-3af5-2455-c270-d3603624c7f4; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Schedules_on_different_days_with_no_time_overlap_do_not_conflict

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Schedules_on_different_days_with_no_time_overlap_do_not_conflict`
- **Test type:** Unit/serialization test
- **Scenario:** Schedules on different days with no time overlap do not conflict
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:199](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var monday = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 2, // Monday
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600,
        };
        var wednesday = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 8, // Wednesday
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600,
        };

        Assert.False(PumpScheduleRules.Overlaps(monday, [wednesday]));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-D72F03AACB | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Schedules_on_different_days_with_no_time_overlap_do_not_conflict | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=16f191f6-f319-2e81-0a05-a69f7c849c39; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesExtendedTests.Validates_minimum_valid_weekday_mask_value_of_one

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Validates_minimum_valid_weekday_mask_value_of_one`
- **Test type:** Unit/serialization test
- **Scenario:** Validates minimum valid weekday mask value of one
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesExtendedTests.cs:13](../backend/tests/PumpScheduleRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // mask=1 = Sunday only
        Assert.Null(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 60, "Asia/Bangkok", 3600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-DE6FE9C964 | IOTAgriBackend.Tests.PumpScheduleRulesExtendedTests.Validates_minimum_valid_weekday_mask_value_of_one | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=3b1ec8ae-eee5-8da8-5d12-77828ab2d083; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesTests.Detects_overlap_across_week_boundary

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesTests.Detects_overlap_across_week_boundary`
- **Test type:** Unit/serialization test
- **Scenario:** Detects overlap across week boundary
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesTests.cs:22](../backend/tests/PumpScheduleRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var saturdayLate = new PumpSchedule
        {
            WeekdayMask = 64,
            StartTime = new TimeOnly(23, 55),
            DurationSeconds = 600,
            IsEnabled = true,
        };
        var sundayEarly = new PumpSchedule
        {
            WeekdayMask = 1,
            StartTime = new TimeOnly(0, 0),
            DurationSeconds = 600,
            IsEnabled = true,
        };

        Assert.True(PumpScheduleRules.Overlaps(saturdayLate, [sundayEarly]));
        sundayEarly.IsEnabled = false;
        Assert.False(PumpScheduleRules.Overlaps(saturdayLate, [sundayEarly]));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-05B1ECA2AD | IOTAgriBackend.Tests.PumpScheduleRulesTests.Detects_overlap_across_week_boundary | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=acaf63b4-0fe2-6231-060a-f3bcd8e21bdc; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesTests.Detects_overlap_for_an_overnight_interval

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesTests.Detects_overlap_for_an_overnight_interval`
- **Test type:** Unit/serialization test
- **Scenario:** Detects overlap for an overnight interval
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesTests.cs:45](../backend/tests/PumpScheduleRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var saturdayWindow = new PumpSchedule
        {
            WeekdayMask = 64,
            StartTime = new TimeOnly(23, 30),
            EndTime = new TimeOnly(1, 0),
            IntervalMinutes = 30,
            DurationSeconds = 60,
            IsEnabled = true,
        };
        var sundayMidnight = new PumpSchedule
        {
            WeekdayMask = 1,
            StartTime = new TimeOnly(0, 0),
            DurationSeconds = 60,
            IsEnabled = true,
        };

        Assert.True(PumpScheduleRules.Overlaps(saturdayWindow, [sundayMidnight]));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-BB3091FD47 | IOTAgriBackend.Tests.PumpScheduleRulesTests.Detects_overlap_for_an_overnight_interval | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=717829c4-5b41-28b9-d5c7-2deb48caa328; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesTests.Finds_each_interval_occurrence_inside_the_configured_window

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesTests.Finds_each_interval_occurrence_inside_the_configured_window`
- **Test type:** Unit/serialization test
- **Scenario:** Finds each interval occurrence inside the configured window
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesTests.cs:87](../backend/tests/PumpScheduleRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var schedule = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            EndTime = new TimeOnly(7, 0),
            IntervalMinutes = 30,
            DurationSeconds = 30,
            TimeZone = "Asia/Bangkok",
        };
        var dueNow = new DateTime(2026, 1, 3, 23, 30, 0, DateTimeKind.Utc);

        var occurrences = PumpScheduleRules.GetDueOccurrencesUtc(schedule, dueNow, TimeSpan.FromSeconds(90));

        Assert.Equal([dueNow], occurrences);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-EB493C2C62 | IOTAgriBackend.Tests.PumpScheduleRulesTests.Finds_each_interval_occurrence_inside_the_configured_window | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d7ac047d-2898-6d78-7f8e-c53740a42f4b; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesTests.Finds_only_a_current_valid_occurrence

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesTests.Finds_only_a_current_valid_occurrence`
- **Test type:** Unit/serialization test
- **Scenario:** Finds only a current valid occurrence
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesTests.cs:68](../backend/tests/PumpScheduleRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var bangkokSunday = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            TimeZone = "Asia/Bangkok",
        };
        var dueNow = new DateTime(2026, 1, 3, 23, 0, 0, DateTimeKind.Utc);

        Assert.True(PumpScheduleRules.TryGetDueOccurrenceUtc(bangkokSunday, dueNow, TimeSpan.FromSeconds(90), out var occurrence));
        Assert.Equal(dueNow, occurrence);
        Assert.False(PumpScheduleRules.TryGetDueOccurrenceUtc(bangkokSunday, dueNow.AddMinutes(2), TimeSpan.FromSeconds(90), out _));
        bangkokSunday.IsEnabled = false;
        Assert.False(PumpScheduleRules.TryGetDueOccurrenceUtc(bangkokSunday, dueNow, TimeSpan.FromSeconds(90), out _));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-571A070348 | IOTAgriBackend.Tests.PumpScheduleRulesTests.Finds_only_a_current_valid_occurrence | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=0daa1195-1da9-2eab-c011-ee414f6947dc; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesTests.Skips_nonexistent_dst_time_and_uses_one_fallback_occurrence

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesTests.Skips_nonexistent_dst_time_and_uses_one_fallback_occurrence`
- **Test type:** Unit/serialization test
- **Scenario:** Skips nonexistent dst time and uses one fallback occurrence
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesTests.cs:107](../backend/tests/PumpScheduleRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var newYorkSunday = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(2, 30),
            TimeZone = "America/New_York",
        };
        var springForwardUtc = new DateTime(2026, 3, 8, 7, 30, 0, DateTimeKind.Utc);

        Assert.False(PumpScheduleRules.TryGetDueOccurrenceUtc(newYorkSunday, springForwardUtc, TimeSpan.FromMinutes(90), out _));

        newYorkSunday.StartTime = new TimeOnly(1, 30);
        var zone = TimeZoneInfo.FindSystemTimeZoneById(newYorkSunday.TimeZone);
        var expected = TimeZoneInfo.ConvertTimeToUtc(new DateTime(2026, 11, 1, 1, 30, 0, DateTimeKind.Unspecified), zone);

        Assert.True(PumpScheduleRules.TryGetDueOccurrenceUtc(newYorkSunday, expected, TimeSpan.FromSeconds(90), out var occurrence));
        Assert.Equal(expected, occurrence);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-C4FD33B49C | IOTAgriBackend.Tests.PumpScheduleRulesTests.Skips_nonexistent_dst_time_and_uses_one_fallback_occurrence | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=71752c04-56eb-4969-530c-d37d77318b82; [log](reports/summary/followup-final-test.log) |

## PumpScheduleRulesTests.Validates_mask_duration_and_iana_time_zone

- **Module:** Pump control/scheduling
- **Component:** PumpScheduleRules
- **Test identity:** `IOTAgriBackend.Tests.PumpScheduleRulesTests.Validates_mask_duration_and_iana_time_zone`
- **Test type:** Unit/serialization test
- **Scenario:** Validates mask duration and iana time zone
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpScheduleRulesTests.cs:11](../backend/tests/PumpScheduleRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Null(PumpScheduleRules.Validate(true, 127, new TimeOnly(6, 0), 600, "Asia/Bangkok", 600));
        Assert.NotNull(PumpScheduleRules.Validate(null, 1, new TimeOnly(6, 0), 60, "Asia/Bangkok", 600));
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, null, 60, "Asia/Bangkok", 600));
        Assert.NotNull(PumpScheduleRules.Validate(true, 0, new TimeOnly(6, 0), 600, "Asia/Bangkok", 600));
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 601, "Asia/Bangkok", 600));
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 60, "SE Asia Standard Time", 600));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-13DC2CC3B8 | IOTAgriBackend.Tests.PumpScheduleRulesTests.Validates_mask_duration_and_iana_time_zone | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=f2db6581-92a9-2d0c-4275-a80f9e50c7f6; [log](reports/summary/followup-final-test.log) |

## PumpSchemaTests.New_command_is_pending_and_has_a_unique_id

- **Module:** Pump control/scheduling
- **Component:** PumpCommand initial status and identifier generation
- **Test identity:** `IOTAgriBackend.Tests.PumpSchemaTests.New_command_is_pending_and_has_a_unique_id`
- **Test type:** Unit/serialization test
- **Scenario:** New command is pending and has a unique id
- **Preconditions / isolation:** Isolated in-memory fixtures; fixed UTC instants for scheduling and history.
- **Test file:** [backend/tests/PumpSchemaTests.cs:9](../backend/tests/PumpSchemaTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var first = new PumpCommand();
        var second = new PumpCommand();

        Assert.Equal(PumpCommandStatus.Pending, first.Status);
        Assert.NotEqual(first.Id, second.Id);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-181ED7BBB7 | IOTAgriBackend.Tests.PumpSchemaTests.New_command_is_pending_and_has_a_unique_id | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5dcbf302-3144-a303-f135-26649769c4d1; [log](reports/summary/followup-final-test.log) |

## RefreshTokenStateTests.Token_is_active_only_when_unrevoked_and_not_expired

- **Module:** Profile/provisioning/presence/admin
- **Component:** RefreshToken.IsActive
- **Test identity:** `IOTAgriBackend.Tests.RefreshTokenStateTests.Token_is_active_only_when_unrevoked_and_not_expired`
- **Test type:** Unit test
- **Scenario:** Token is active only when unrevoked and not expired
- **Preconditions / isolation:** Isolated inputs in test source; no production configuration or external dependency.
- **Test file:** [backend/tests/RefreshTokenStateTests.cs:14](../backend/tests/RefreshTokenStateTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        // Extreme fixed dates avoid sleeps and races around the real clock boundary.
        var token = new RefreshToken
        {
            ExpiresAt = futureExpiry ? DateTime.MaxValue : DateTime.MinValue,
            RevokedAt = revoked ? new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) : null,
        };
        Assert.Equal(expected, token.IsActive);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-CCD9EA4EE2 | IOTAgriBackend.Tests.RefreshTokenStateTests.Token_is_active_only_when_unrevoked_and_not_expired(revoked: False, futureExpiry: False, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=0e6bfd59-cf85-f654-14eb-2a8291d648aa; [log](reports/summary/followup-final-test.log) |
| TC-BE-3006691465 | IOTAgriBackend.Tests.RefreshTokenStateTests.Token_is_active_only_when_unrevoked_and_not_expired(revoked: False, futureExpiry: True, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4c721a3d-606a-4cb0-f260-ab54cc6890fa; [log](reports/summary/followup-final-test.log) |
| TC-BE-58141A5CEC | IOTAgriBackend.Tests.RefreshTokenStateTests.Token_is_active_only_when_unrevoked_and_not_expired(revoked: True, futureExpiry: False, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=e9509642-e36c-167a-3506-3a84207c8c03; [log](reports/summary/followup-final-test.log) |
| TC-BE-FF7DB985B0 | IOTAgriBackend.Tests.RefreshTokenStateTests.Token_is_active_only_when_unrevoked_and_not_expired(revoked: True, futureExpiry: True, expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4a2df08f-292a-9041-6721-3a00c21b0119; [log](reports/summary/followup-final-test.log) |

## SeederBehaviorTests.Create_failure_throws_error_code_and_does_not_assign_role

- **Module:** Bootstrap/security
- **Component:** AdminBootstrapper.SeedAsync / RoleSeeder.SeedAsync
- **Test identity:** `IOTAgriBackend.Tests.SeederBehaviorTests.Create_failure_throws_error_code_and_does_not_assign_role`
- **Test type:** Unit test
- **Scenario:** Create failure throws error code and does not assign role
- **Preconditions / isolation:** Mock UserManager/RoleManager with disposable DI provider; no Identity store.
- **Test file:** [backend/tests/SeederBehaviorTests.cs:69](../backend/tests/SeederBehaviorTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.CreateAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()))
            .ReturnsAsync(IdentityResult.Failed(new IdentityError { Code = "InvalidPassword" }));
        using var services = new ServiceCollection().AddSingleton(users.Object).BuildServiceProvider();
        var error = await Assert.ThrowsAsync<InvalidOperationException>(() => AdminBootstrapper.SeedAsync(services, Configuration()));
        Assert.Contains("InvalidPassword", error.Message);
        users.Verify(u => u.AddToRoleAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()), Times.Never);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-AFEF0D67CA | IOTAgriBackend.Tests.SeederBehaviorTests.Create_failure_throws_error_code_and_does_not_assign_role | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=363a70a3-28ed-ec39-0f00-ba10c481cf3c; [log](reports/summary/followup-final-test.log) |

## SeederBehaviorTests.Existing_admin_account_is_preserved_and_role_only_added_if_missing

- **Module:** Bootstrap/security
- **Component:** AdminBootstrapper.SeedAsync / RoleSeeder.SeedAsync
- **Test identity:** `IOTAgriBackend.Tests.SeederBehaviorTests.Existing_admin_account_is_preserved_and_role_only_added_if_missing`
- **Test type:** Unit test
- **Scenario:** Existing admin account is preserved and role only added if missing
- **Preconditions / isolation:** Mock UserManager/RoleManager with disposable DI provider; no Identity store.
- **Test file:** [backend/tests/SeederBehaviorTests.cs:54](../backend/tests/SeederBehaviorTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var user = new ApplicationUser { FullName = "Existing Profile" };
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByEmailAsync("qa@example.test")).ReturnsAsync(user);
        users.Setup(u => u.IsInRoleAsync(user, "Admin")).ReturnsAsync(hasRole);
        users.Setup(u => u.AddToRoleAsync(user, "Admin")).ReturnsAsync(IdentityResult.Success);
        using var services = new ServiceCollection().AddSingleton(users.Object).BuildServiceProvider();
        await AdminBootstrapper.SeedAsync(services, Configuration());
        Assert.Equal("Existing Profile", user.FullName);
        users.Verify(u => u.CreateAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()), Times.Never);
        users.Verify(u => u.AddToRoleAsync(user, "Admin"), hasRole ? Times.Never() : Times.Once());
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-5ABC93C054 | IOTAgriBackend.Tests.SeederBehaviorTests.Existing_admin_account_is_preserved_and_role_only_added_if_missing(hasRole: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=218e1e2d-56e5-852f-c557-0f8fed02185d; [log](reports/summary/followup-final-test.log) |
| TC-BE-64BD2782A7 | IOTAgriBackend.Tests.SeederBehaviorTests.Existing_admin_account_is_preserved_and_role_only_added_if_missing(hasRole: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6957fc10-2670-bfca-7e44-eb3bee43e035; [log](reports/summary/followup-final-test.log) |

## SeederBehaviorTests.New_admin_is_created_with_expected_profile_and_assigned_role

- **Module:** Bootstrap/security
- **Component:** AdminBootstrapper.SeedAsync / RoleSeeder.SeedAsync
- **Test identity:** `IOTAgriBackend.Tests.SeederBehaviorTests.New_admin_is_created_with_expected_profile_and_assigned_role`
- **Test type:** Unit test
- **Scenario:** New admin is created with expected profile and assigned role
- **Preconditions / isolation:** Mock UserManager/RoleManager with disposable DI provider; no Identity store.
- **Test file:** [backend/tests/SeederBehaviorTests.cs:34](../backend/tests/SeederBehaviorTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var users = BackendTestDoubles.Users();
        ApplicationUser? created = null;
        users.Setup(u => u.FindByEmailAsync("qa@example.test")).ReturnsAsync((ApplicationUser?)null);
        users.Setup(u => u.CreateAsync(It.IsAny<ApplicationUser>(), "QaPassword1!"))
            .Callback<ApplicationUser, string>((u, _) => created = u).ReturnsAsync(IdentityResult.Success);
        users.Setup(u => u.AddToRoleAsync(It.IsAny<ApplicationUser>(), "Admin")).ReturnsAsync(IdentityResult.Success);
        using var services = new ServiceCollection().AddSingleton(users.Object).BuildServiceProvider();
        await AdminBootstrapper.SeedAsync(services, Configuration(fullName: name));
        Assert.NotNull(created);
        Assert.Equal("qa@example.test", created.Email);
        Assert.Equal(created.Email, created.UserName);
        Assert.Equal(expectedName, created.FullName);
        users.Verify(u => u.AddToRoleAsync(created, "Admin"), Times.Once);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-AD83DF605B | IOTAgriBackend.Tests.SeederBehaviorTests.New_admin_is_created_with_expected_profile_and_assigned_role(name: "  ", expectedName: "Administrator") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=98c059e1-9bc3-73c3-dd2c-7f1daf1d709a; [log](reports/summary/followup-final-test.log) |
| TC-BE-D6E05A2788 | IOTAgriBackend.Tests.SeederBehaviorTests.New_admin_is_created_with_expected_profile_and_assigned_role(name: "QA Admin", expectedName: "QA Admin") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=683f169c-0a04-bac3-790b-87da43315fa1; [log](reports/summary/followup-final-test.log) |
| TC-BE-B975578414 | IOTAgriBackend.Tests.SeederBehaviorTests.New_admin_is_created_with_expected_profile_and_assigned_role(name: null, expectedName: "Administrator") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=9f14275c-4c10-938c-f893-7dfc5b0abe63; [log](reports/summary/followup-final-test.log) |

## SeederBehaviorTests.Role_assignment_failure_throws_error_code

- **Module:** Bootstrap/security
- **Component:** AdminBootstrapper.SeedAsync / RoleSeeder.SeedAsync
- **Test identity:** `IOTAgriBackend.Tests.SeederBehaviorTests.Role_assignment_failure_throws_error_code`
- **Test type:** Unit test
- **Scenario:** Role assignment failure throws error code
- **Preconditions / isolation:** Mock UserManager/RoleManager with disposable DI provider; no Identity store.
- **Test file:** [backend/tests/SeederBehaviorTests.cs:81](../backend/tests/SeederBehaviorTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var users = BackendTestDoubles.Users();
        var user = new ApplicationUser();
        users.Setup(u => u.FindByEmailAsync("qa@example.test")).ReturnsAsync(user);
        users.Setup(u => u.AddToRoleAsync(user, "Admin"))
            .ReturnsAsync(IdentityResult.Failed(new IdentityError { Code = "RoleUnavailable" }));
        using var services = new ServiceCollection().AddSingleton(users.Object).BuildServiceProvider();
        var error = await Assert.ThrowsAsync<InvalidOperationException>(() => AdminBootstrapper.SeedAsync(services, Configuration()));
        Assert.Contains("RoleUnavailable", error.Message);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-1764759515 | IOTAgriBackend.Tests.SeederBehaviorTests.Role_assignment_failure_throws_error_code | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=e1ecb1f0-bd1f-f14e-127a-8d644ba0bd58; [log](reports/summary/followup-final-test.log) |

## SeederBehaviorTests.Role_seeder_creates_only_missing_user_and_admin_roles

- **Module:** Bootstrap/security
- **Component:** AdminBootstrapper.SeedAsync / RoleSeeder.SeedAsync
- **Test identity:** `IOTAgriBackend.Tests.SeederBehaviorTests.Role_seeder_creates_only_missing_user_and_admin_roles`
- **Test type:** Unit test
- **Scenario:** Role seeder creates only missing user and admin roles
- **Preconditions / isolation:** Mock UserManager/RoleManager with disposable DI provider; no Identity store.
- **Test file:** [backend/tests/SeederBehaviorTests.cs:96](../backend/tests/SeederBehaviorTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var roles = BackendTestDoubles.Roles();
        var created = new List<string>();
        roles.Setup(r => r.RoleExistsAsync(It.IsAny<string>())).ReturnsAsync(rolesExist);
        roles.Setup(r => r.CreateAsync(It.IsAny<IdentityRole>()))
            .Callback<IdentityRole>(role => created.Add(role.Name!)).ReturnsAsync(IdentityResult.Success);
        using var services = new ServiceCollection().AddSingleton(roles.Object).BuildServiceProvider();
        await RoleSeeder.SeedAsync(services);
        Assert.Equal(rolesExist ? Array.Empty<string>() : new[] { "User", "Admin" }, created);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-C01BCD7D6A | IOTAgriBackend.Tests.SeederBehaviorTests.Role_seeder_creates_only_missing_user_and_admin_roles(rolesExist: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=805cc4ee-ab40-cf18-9ef1-9d3fd565a5d4; [log](reports/summary/followup-final-test.log) |
| TC-BE-1E2D336F63 | IOTAgriBackend.Tests.SeederBehaviorTests.Role_seeder_creates_only_missing_user_and_admin_roles(rolesExist: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=f1382bc2-9c89-10dc-3993-d852d8b0bd8a; [log](reports/summary/followup-final-test.log) |

## SeederBehaviorTests.Unconfigured_bootstrap_does_not_resolve_user_manager

- **Module:** Bootstrap/security
- **Component:** AdminBootstrapper.SeedAsync / RoleSeeder.SeedAsync
- **Test identity:** `IOTAgriBackend.Tests.SeederBehaviorTests.Unconfigured_bootstrap_does_not_resolve_user_manager`
- **Test type:** Unit test
- **Scenario:** Unconfigured bootstrap does not resolve user manager
- **Preconditions / isolation:** Mock UserManager/RoleManager with disposable DI provider; no Identity store.
- **Test file:** [backend/tests/SeederBehaviorTests.cs:23](../backend/tests/SeederBehaviorTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        using var services = new ServiceCollection().BuildServiceProvider();
        await AdminBootstrapper.SeedAsync(services, Configuration(email: null));
        Assert.Null(services.GetService<UserManager<ApplicationUser>>());
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-0F8CE7D5DF | IOTAgriBackend.Tests.SeederBehaviorTests.Unconfigured_bootstrap_does_not_resolve_user_manager | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=1ca40527-f4af-c083-6e5e-33225f17a1b7; [log](reports/summary/followup-final-test.log) |

## SensorMedianBucketExtendedTests.Bucket_start_timestamps_are_evenly_spaced_by_interval

- **Module:** Sensor contracts/series
- **Component:** SensorMedianBuckets.Complete
- **Test identity:** `IOTAgriBackend.Tests.SensorMedianBucketExtendedTests.Bucket_start_timestamps_are_evenly_spaced_by_interval`
- **Test type:** Unit/serialization test
- **Scenario:** Bucket start timestamps are evenly spaced by interval
- **Preconditions / isolation:** In-memory JSON or bucket dictionary; no ESP32, SQL aggregation, or broker.
- **Test file:** [backend/tests/SensorMedianBucketExtendedTests.cs:42](../backend/tests/SensorMedianBucketExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        var interval = TimeSpan.FromMinutes(30);

        var buckets = SensorMedianBuckets.Complete(start, 4, interval,
            new Dictionary<DateTime, SensorMedianBucket>());

        Assert.Equal(start, buckets[0].BucketStart);
        Assert.Equal(start.AddMinutes(30), buckets[1].BucketStart);
        Assert.Equal(start.AddMinutes(60), buckets[2].BucketStart);
        Assert.Equal(start.AddMinutes(90), buckets[3].BucketStart);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-DE8C253D86 | IOTAgriBackend.Tests.SensorMedianBucketExtendedTests.Bucket_start_timestamps_are_evenly_spaced_by_interval | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=053ade53-fdff-a205-9a91-7d9f44666f26; [log](reports/summary/followup-final-test.log) |

## SensorMedianBucketExtendedTests.Count_of_zero_returns_empty_list

- **Module:** Sensor contracts/series
- **Component:** SensorMedianBuckets.Complete
- **Test identity:** `IOTAgriBackend.Tests.SensorMedianBucketExtendedTests.Count_of_zero_returns_empty_list`
- **Test type:** Unit/serialization test
- **Scenario:** Count of zero returns empty list
- **Preconditions / isolation:** In-memory JSON or bucket dictionary; no ESP32, SQL aggregation, or broker.
- **Test file:** [backend/tests/SensorMedianBucketExtendedTests.cs:31](../backend/tests/SensorMedianBucketExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);

        var buckets = SensorMedianBuckets.Complete(start, 0, TimeSpan.FromHours(1),
            new Dictionary<DateTime, SensorMedianBucket>());

        Assert.Empty(buckets);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-5B8D8DE62D | IOTAgriBackend.Tests.SensorMedianBucketExtendedTests.Count_of_zero_returns_empty_list | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b3b36bd1-0b7a-0059-0f8f-6a61f5585147; [log](reports/summary/followup-final-test.log) |

## SensorMedianBucketExtendedTests.Empty_source_produces_all_null_medians

- **Module:** Sensor contracts/series
- **Component:** SensorMedianBuckets.Complete
- **Test identity:** `IOTAgriBackend.Tests.SensorMedianBucketExtendedTests.Empty_source_produces_all_null_medians`
- **Test type:** Unit/serialization test
- **Scenario:** Empty source produces all null medians
- **Preconditions / isolation:** In-memory JSON or bucket dictionary; no ESP32, SQL aggregation, or broker.
- **Test file:** [backend/tests/SensorMedianBucketExtendedTests.cs:11](../backend/tests/SensorMedianBucketExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        var empty = new Dictionary<DateTime, SensorMedianBucket>();

        var buckets = SensorMedianBuckets.Complete(start, 3, TimeSpan.FromHours(1), empty);

        Assert.Equal(3, buckets.Count);
        Assert.All(buckets, bucket =>
        {
            Assert.Null(bucket.MedianTemperature);
            Assert.Null(bucket.MedianHumidity);
            Assert.Null(bucket.MedianPh);
            Assert.Null(bucket.MedianTds);
            Assert.Null(bucket.MedianWaterLevel);
            Assert.Equal(0, bucket.SampleCount);
        });
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-0B7DC23401 | IOTAgriBackend.Tests.SensorMedianBucketExtendedTests.Empty_source_produces_all_null_medians | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=9c4da810-2b6a-6b87-fc57-316cb1b15893; [log](reports/summary/followup-final-test.log) |

## SensorMedianBucketExtendedTests.Source_bucket_at_matching_timestamp_preserves_all_fields

- **Module:** Sensor contracts/series
- **Component:** SensorMedianBuckets.Complete
- **Test identity:** `IOTAgriBackend.Tests.SensorMedianBucketExtendedTests.Source_bucket_at_matching_timestamp_preserves_all_fields`
- **Test type:** Unit/serialization test
- **Scenario:** Source bucket at matching timestamp preserves all fields
- **Preconditions / isolation:** In-memory JSON or bucket dictionary; no ESP32, SQL aggregation, or broker.
- **Test file:** [backend/tests/SensorMedianBucketExtendedTests.cs:57](../backend/tests/SensorMedianBucketExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        var bucket = new SensorMedianBucket(
            BucketStart: start,
            MedianTemperature: 28.5,
            MedianSolutionTemperature: 26.0,
            MedianHumidity: 72.0,
            MedianPh: 6.5,
            MedianTds: 450,
            MedianWaterLevel: 65.0,
            MedianLux: 300,
            SampleCount: 12);

        var source = new Dictionary<DateTime, SensorMedianBucket> { [start] = bucket };
        var result = SensorMedianBuckets.Complete(start, 1, TimeSpan.FromHours(1), source);

        Assert.Single(result);
        Assert.Equal(28.5, result[0].MedianTemperature);
        Assert.Equal(26.0, result[0].MedianSolutionTemperature);
        Assert.Equal(72.0, result[0].MedianHumidity);
        Assert.Equal(6.5, result[0].MedianPh);
        Assert.Equal(450, result[0].MedianTds);
        Assert.Equal(65.0, result[0].MedianWaterLevel);
        Assert.Equal(300, result[0].MedianLux);
        Assert.Equal(12, result[0].SampleCount);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3BD95BDE22 | IOTAgriBackend.Tests.SensorMedianBucketExtendedTests.Source_bucket_at_matching_timestamp_preserves_all_fields | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a1ef0e27-6c20-11be-d7c5-dfe453ad5a41; [log](reports/summary/followup-final-test.log) |

## SensorMedianBucketTests.Daily_series_contains_seven_days

- **Module:** Sensor contracts/series
- **Component:** SensorMedianBuckets.Complete
- **Test identity:** `IOTAgriBackend.Tests.SensorMedianBucketTests.Daily_series_contains_seven_days`
- **Test type:** Unit/serialization test
- **Scenario:** Daily series contains seven days
- **Preconditions / isolation:** In-memory JSON or bucket dictionary; no ESP32, SQL aggregation, or broker.
- **Test file:** [backend/tests/SensorMedianBucketTests.cs:31](../backend/tests/SensorMedianBucketTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var start = new DateTime(2026, 9, 14, 0, 0, 0, DateTimeKind.Utc);

        var buckets = SensorMedianBuckets.Complete(start, 7, TimeSpan.FromDays(1), new Dictionary<DateTime, SensorMedianBucket>());

        Assert.Equal(7, buckets.Count);
        Assert.Equal(start.AddDays(6), buckets[6].BucketStart);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-5F20695A89 | IOTAgriBackend.Tests.SensorMedianBucketTests.Daily_series_contains_seven_days | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=358252e1-e3fc-39f5-de9b-3b033a5bef1e; [log](reports/summary/followup-final-test.log) |

## SensorMedianBucketTests.Hourly_series_contains_empty_hours_and_preserves_medians

- **Module:** Sensor contracts/series
- **Component:** SensorMedianBuckets.Complete
- **Test identity:** `IOTAgriBackend.Tests.SensorMedianBucketTests.Hourly_series_contains_empty_hours_and_preserves_medians`
- **Test type:** Unit/serialization test
- **Scenario:** Hourly series contains empty hours and preserves medians
- **Preconditions / isolation:** In-memory JSON or bucket dictionary; no ESP32, SQL aggregation, or broker.
- **Test file:** [backend/tests/SensorMedianBucketTests.cs:11](../backend/tests/SensorMedianBucketTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var start = new DateTime(2026, 9, 17, 0, 0, 0, DateTimeKind.Utc);
        var source = new Dictionary<DateTime, SensorMedianBucket>
        {
            [start.AddHours(2)] = new(start.AddHours(2), 2, 3, 2, 2, 2, 2, 200, 3),
        };

        var buckets = SensorMedianBuckets.Complete(start, 24, TimeSpan.FromHours(1), source);

        Assert.Equal(24, buckets.Count);
        Assert.Equal(2, buckets[2].MedianTemperature);
        Assert.Equal(3, buckets[2].MedianSolutionTemperature);
        Assert.Equal(200, buckets[2].MedianLux);
        Assert.Equal(3, buckets[2].SampleCount);
        Assert.Null(buckets[0].MedianTemperature);
        Assert.Equal(0, buckets[0].SampleCount);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-803A8B864C | IOTAgriBackend.Tests.SensorMedianBucketTests.Hourly_series_contains_empty_hours_and_preserves_medians | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c2b9f8c1-bd8d-57db-18df-209108096cd5; [log](reports/summary/followup-final-test.log) |

## SensorReadingContractTests.Esp32_payload_maps_all_aerogreen_sensor_values

- **Module:** Sensor contracts/series
- **Component:** SensorReadingRequest JSON contract
- **Test identity:** `IOTAgriBackend.Tests.SensorReadingContractTests.Esp32_payload_maps_all_aerogreen_sensor_values`
- **Test type:** Unit/serialization test
- **Scenario:** Esp32 payload maps all aerogreen sensor values
- **Preconditions / isolation:** In-memory JSON or bucket dictionary; no ESP32, SQL aggregation, or broker.
- **Test file:** [backend/tests/SensorReadingContractTests.cs:12](../backend/tests/SensorReadingContractTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        const string payload =
            """
            {
              "temperature": 29.1,
              "solutionTemperature": 26.7,
              "humidity": 73.2,
              "tds": 520,
              "waterLevel": 71.3
            }
            """;

        var reading = JsonSerializer.Deserialize<SensorReadingRequest>(payload, JsonOptions);

        Assert.NotNull(reading);
        Assert.Equal(29.1, reading.Temperature);
        Assert.Equal(26.7, reading.SolutionTemperature);
        Assert.Equal(73.2, reading.Humidity);
        Assert.Equal(520, reading.Tds);
        Assert.Equal(71.3, reading.WaterLevel);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-0960E58DE2 | IOTAgriBackend.Tests.SensorReadingContractTests.Esp32_payload_maps_all_aerogreen_sensor_values | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5cd88d45-9732-0577-1943-af4a584f114c; [log](reports/summary/followup-final-test.log) |

## SupportTicketRulesExtendedTests.Accepts_all_known_statuses

- **Module:** Support tickets
- **Component:** SupportTicketRules
- **Test identity:** `IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Accepts_all_known_statuses`
- **Test type:** Unit test
- **Scenario:** Accepts all known statuses
- **Preconditions / isolation:** Pure status/priority decision rules; no database.
- **Test file:** [backend/tests/SupportTicketRulesExtendedTests.cs:13](../backend/tests/SupportTicketRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Equal(expected, SupportTicketRules.IsValidStatus(status));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-ACD7B97E71 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Accepts_all_known_statuses(status: "closed", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=467a849c-fc80-f0f4-184c-73ea3dd0d121; [log](reports/summary/followup-final-test.log) |
| TC-BE-602B5BA05B | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Accepts_all_known_statuses(status: "in_progress", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=cf860ea6-be5f-9b29-9c6a-497c357f16e0; [log](reports/summary/followup-final-test.log) |
| TC-BE-96790BBC0A | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Accepts_all_known_statuses(status: "open", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=2fe8a5bb-86e4-779d-b8e3-90e68b1761a2; [log](reports/summary/followup-final-test.log) |

## SupportTicketRulesExtendedTests.Accepts_all_valid_ticket_transitions

- **Module:** Support tickets
- **Component:** SupportTicketRules
- **Test identity:** `IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Accepts_all_valid_ticket_transitions`
- **Test type:** Unit test
- **Scenario:** Accepts all valid ticket transitions
- **Preconditions / isolation:** Pure status/priority decision rules; no database.
- **Test file:** [backend/tests/SupportTicketRulesExtendedTests.cs:55](../backend/tests/SupportTicketRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Equal(expected, SupportTicketRules.IsValidTransition(current, next));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-F00231069C | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Accepts_all_valid_ticket_transitions(current: "closed", next: "open", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a542cff3-9d15-3ed1-5237-8fcd3126e6cc; [log](reports/summary/followup-final-test.log) |
| TC-BE-255ED080ED | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Accepts_all_valid_ticket_transitions(current: "in_progress", next: "closed", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c2a5b0a9-cc05-de6f-a644-fd57c921aa62; [log](reports/summary/followup-final-test.log) |
| TC-BE-5ACCFF62E7 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Accepts_all_valid_ticket_transitions(current: "open", next: "in_progress", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6920b6ac-e2f5-ff69-fdc9-d196ab55b0d4; [log](reports/summary/followup-final-test.log) |

## SupportTicketRulesExtendedTests.Rejects_self_and_backward_transitions

- **Module:** Support tickets
- **Component:** SupportTicketRules
- **Test identity:** `IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_self_and_backward_transitions`
- **Test type:** Unit test
- **Scenario:** Rejects self and backward transitions
- **Preconditions / isolation:** Pure status/priority decision rules; no database.
- **Test file:** [backend/tests/SupportTicketRulesExtendedTests.cs:46](../backend/tests/SupportTicketRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(SupportTicketRules.IsValidTransition(current, next));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-38CA60E9DE | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_self_and_backward_transitions(current: "closed", next: "closed") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5561d0b2-d139-56b8-aed6-eb4797397144; [log](reports/summary/followup-final-test.log) |
| TC-BE-DC7BE43408 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_self_and_backward_transitions(current: "in_progress", next: "in_progress") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=5ec5d9ec-ce01-5e7e-f27d-61a2e4d5a21f; [log](reports/summary/followup-final-test.log) |
| TC-BE-CF48481191 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_self_and_backward_transitions(current: "in_progress", next: "open") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=11d00eae-740d-4e17-7990-66ba2c578bba; [log](reports/summary/followup-final-test.log) |
| TC-BE-C96B469D61 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_self_and_backward_transitions(current: "open", next: "open") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a6218e5b-6f5b-630e-0f33-ac922feae64d; [log](reports/summary/followup-final-test.log) |

## SupportTicketRulesExtendedTests.Rejects_unknown_or_null_priority

- **Module:** Support tickets
- **Component:** SupportTicketRules
- **Test identity:** `IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_unknown_or_null_priority`
- **Test type:** Unit test
- **Scenario:** Rejects unknown or null priority
- **Preconditions / isolation:** Pure status/priority decision rules; no database.
- **Test file:** [backend/tests/SupportTicketRulesExtendedTests.cs:35](../backend/tests/SupportTicketRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(SupportTicketRules.IsValidPriority(priority));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-AF5C4C27F3 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_unknown_or_null_priority(priority: "") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=fa927c49-8adc-8930-708d-bbe68d6a6bb0; [log](reports/summary/followup-final-test.log) |
| TC-BE-54D4AC2D5A | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_unknown_or_null_priority(priority: "LOW") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=70653879-648a-db69-ee69-c38677126849; [log](reports/summary/followup-final-test.log) |
| TC-BE-61B5435201 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_unknown_or_null_priority(priority: "critical") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4cc98394-8be6-2454-1659-3ab38a9c8925; [log](reports/summary/followup-final-test.log) |
| TC-BE-49C26FE006 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_unknown_or_null_priority(priority: null) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=69ef0078-3da9-65fb-f012-9c6a224cab29; [log](reports/summary/followup-final-test.log) |

## SupportTicketRulesExtendedTests.Rejects_unknown_or_null_status

- **Module:** Support tickets
- **Component:** SupportTicketRules
- **Test identity:** `IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_unknown_or_null_status`
- **Test type:** Unit test
- **Scenario:** Rejects unknown or null status
- **Preconditions / isolation:** Pure status/priority decision rules; no database.
- **Test file:** [backend/tests/SupportTicketRulesExtendedTests.cs:24](../backend/tests/SupportTicketRulesExtendedTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.False(SupportTicketRules.IsValidStatus(status));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-EA957B6D56 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_unknown_or_null_status(status: "") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=90c4c1ad-5170-22f3-dbd5-2162984cf4da; [log](reports/summary/followup-final-test.log) |
| TC-BE-4E6D3742A1 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_unknown_or_null_status(status: "OPEN") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c8aee784-40ba-a3b7-7a47-6732e76deee6; [log](reports/summary/followup-final-test.log) |
| TC-BE-6709300891 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_unknown_or_null_status(status: "done") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=e6e6759b-59f1-89d0-2db7-0f666bb4a249; [log](reports/summary/followup-final-test.log) |
| TC-BE-0E1F0CCF6F | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_unknown_or_null_status(status: "pending") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b6a35f96-8c1c-d42d-c070-51116f954408; [log](reports/summary/followup-final-test.log) |
| TC-BE-D4322B5002 | IOTAgriBackend.Tests.SupportTicketRulesExtendedTests.Rejects_unknown_or_null_status(status: null) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=081f6ee9-c1fc-2d3a-ae28-de3bf9aea027; [log](reports/summary/followup-final-test.log) |

## SupportTicketRulesTests.Accepts_known_priorities

- **Module:** Support tickets
- **Component:** SupportTicketRules
- **Test identity:** `IOTAgriBackend.Tests.SupportTicketRulesTests.Accepts_known_priorities`
- **Test type:** Unit test
- **Scenario:** Accepts known priorities
- **Preconditions / isolation:** Pure status/priority decision rules; no database.
- **Test file:** [backend/tests/SupportTicketRulesTests.cs:23](../backend/tests/SupportTicketRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.True(SupportTicketRules.IsValidPriority(priority));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-EB8C60BBD6 | IOTAgriBackend.Tests.SupportTicketRulesTests.Accepts_known_priorities(priority: "high") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=3d52d51a-05c7-d951-010d-7f4cf961a14b; [log](reports/summary/followup-final-test.log) |
| TC-BE-E05716C2E3 | IOTAgriBackend.Tests.SupportTicketRulesTests.Accepts_known_priorities(priority: "low") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a10ad1ac-3bbe-3d81-8d0f-d228fe3ada9f; [log](reports/summary/followup-final-test.log) |
| TC-BE-ACD8DFC15D | IOTAgriBackend.Tests.SupportTicketRulesTests.Accepts_known_priorities(priority: "medium") | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=8c08c172-181e-b117-9ecb-e9f8c3c2d360; [log](reports/summary/followup-final-test.log) |

## SupportTicketRulesTests.Allows_only_safe_status_transitions

- **Module:** Support tickets
- **Component:** SupportTicketRules
- **Test identity:** `IOTAgriBackend.Tests.SupportTicketRulesTests.Allows_only_safe_status_transitions`
- **Test type:** Unit test
- **Scenario:** Allows only safe status transitions
- **Preconditions / isolation:** Pure status/priority decision rules; no database.
- **Test file:** [backend/tests/SupportTicketRulesTests.cs:14](../backend/tests/SupportTicketRulesTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.Equal(expected, SupportTicketRules.IsValidTransition(current, next));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-255A09E096 | IOTAgriBackend.Tests.SupportTicketRulesTests.Allows_only_safe_status_transitions(current: "closed", next: "in_progress", expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=a5235dbe-6fea-b702-f991-d3efd185309b; [log](reports/summary/followup-final-test.log) |
| TC-BE-28D93D56DB | IOTAgriBackend.Tests.SupportTicketRulesTests.Allows_only_safe_status_transitions(current: "closed", next: "open", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=9324f0fc-5f14-487f-9f9f-5c8781800d2a; [log](reports/summary/followup-final-test.log) |
| TC-BE-DCE2DAEE4F | IOTAgriBackend.Tests.SupportTicketRulesTests.Allows_only_safe_status_transitions(current: "in_progress", next: "closed", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=1129684c-ce67-1283-4fcf-4d07b94b4ba5; [log](reports/summary/followup-final-test.log) |
| TC-BE-F5948B0A00 | IOTAgriBackend.Tests.SupportTicketRulesTests.Allows_only_safe_status_transitions(current: "open", next: "closed", expected: False) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=db06d7bb-59e5-c69a-4e28-dae6bce1bd4a; [log](reports/summary/followup-final-test.log) |
| TC-BE-D92357B4A6 | IOTAgriBackend.Tests.SupportTicketRulesTests.Allows_only_safe_status_transitions(current: "open", next: "in_progress", expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=84afdcf3-8a85-2fb2-2ea7-5910b1ad5379; [log](reports/summary/followup-final-test.log) |

## TicketEndpointMappingTests.Ticket_create_requires_login_and_admin_routes_require_admin_policy

- **Module:** Endpoint/security
- **Component:** TicketEndpoints.MapTicketEndpoints
- **Test identity:** `IOTAgriBackend.Tests.TicketEndpointMappingTests.Ticket_create_requires_login_and_admin_routes_require_admin_policy`
- **Test type:** Route metadata component test
- **Scenario:** Ticket create requires login and admin routes require admin policy
- **Preconditions / isolation:** Construct WebApplication without Start/Run; EF provider configured but never connected.
- **Test file:** [backend/tests/TicketEndpointMappingTests.cs:18](../backend/tests/TicketEndpointMappingTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var builder = WebApplication.CreateBuilder();
        builder.Services.AddDbContext<ApplicationDbContext>(options => options.UseNpgsql("Host=localhost;Database=ticket_endpoint_test"));
        builder.Services.AddIdentityCore<ApplicationUser>().AddRoles<IdentityRole>().AddEntityFrameworkStores<ApplicationDbContext>();
        using var app = builder.Build();
        app.MapTicketEndpoints();
        var endpoints = ((IEndpointRouteBuilder)app).DataSources.SelectMany(source => source.Endpoints)
            .OfType<RouteEndpoint>().ToList();

        var create = Assert.Single(endpoints, endpoint => endpoint.RoutePattern.RawText?.StartsWith("/api/tickets") == true);
        Assert.Contains(create.Metadata.GetOrderedMetadata<IAuthorizeData>(), data => data.Policy is null);

        var admin = endpoints.Where(endpoint => endpoint.RoutePattern.RawText?.StartsWith("/api/admin/tickets") == true).ToList();
        Assert.Equal(5, admin.Count);
        Assert.All(admin, endpoint => Assert.Contains(endpoint.Metadata.GetOrderedMetadata<IAuthorizeData>(), data => data.Policy == "AdminOnly"));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-ABC24EBE50 | IOTAgriBackend.Tests.TicketEndpointMappingTests.Ticket_create_requires_login_and_admin_routes_require_admin_policy | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b303ee2e-520c-c452-8cb6-75a7a927b8f7; [log](reports/summary/followup-final-test.log) |

## TokenServiceTests.Access_token_has_valid_signature_identity_roles_and_expiry

- **Module:** JWT/security
- **Component:** TokenService
- **Test identity:** `IOTAgriBackend.Tests.TokenServiceTests.Access_token_has_valid_signature_identity_roles_and_expiry`
- **Test type:** Unit test
- **Scenario:** Access token has valid signature identity roles and expiry
- **Preconditions / isolation:** In-memory QA-only signing configuration; local JWT validation; bounded before/after clock for expiry.
- **Test file:** [backend/tests/TokenServiceTests.cs:28](../backend/tests/TokenServiceTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var user = new ApplicationUser { Id = "qa-user", Email = "qa@example.test", FullName = "QA User" };
        var before = DateTime.UtcNow;
        var token = new TokenService(Configuration(expiry: configuredExpiry)).CreateAccessToken(user, new[] { "User", "Admin" });
        var after = DateTime.UtcNow;
        var handler = new JwtSecurityTokenHandler { MapInboundClaims = false };
        var principal = handler.ValidateToken(token, new TokenValidationParameters
        {
            ValidIssuer = "qa-issuer", ValidAudience = "qa-audience",
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Key)),
            ValidateLifetime = true, ClockSkew = TimeSpan.Zero,
        }, out var validated);
        var jwt = Assert.IsType<JwtSecurityToken>(validated);
        Assert.Equal(SecurityAlgorithms.HmacSha256, jwt.Header.Alg);
        Assert.Equal(user.Id, principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value);
        Assert.Equal(user.Id, principal.FindFirst(ClaimTypes.NameIdentifier)?.Value);
        Assert.Equal(user.Email, principal.FindFirst(JwtRegisteredClaimNames.Email)?.Value);
        Assert.Equal(user.FullName, principal.FindFirst("fullName")?.Value);
        Assert.Equal(new[] { "Admin", "User" }, principal.FindAll(ClaimTypes.Role).Select(c => c.Value).OrderBy(v => v));
        Assert.True(Guid.TryParse(principal.FindFirst(JwtRegisteredClaimNames.Jti)?.Value, out _));
        // JWT NumericDate truncates sub-second precision. Capture both sides of the call.
        Assert.InRange(jwt.ValidTo, before.AddMinutes(minutes).AddSeconds(-1), after.AddMinutes(minutes));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-8F2340C628 | IOTAgriBackend.Tests.TokenServiceTests.Access_token_has_valid_signature_identity_roles_and_expiry(configuredExpiry: "5", minutes: 5) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=0d5b6422-1008-b323-b49f-4d0199ca2a45; [log](reports/summary/followup-final-test.log) |
| TC-BE-DE3B3C564E | IOTAgriBackend.Tests.TokenServiceTests.Access_token_has_valid_signature_identity_roles_and_expiry(configuredExpiry: null, minutes: 15) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=7c71bfd1-f8b1-2c4a-3436-95ccdce78d44; [log](reports/summary/followup-final-test.log) |

## TokenServiceTests.Missing_key_throws_explicit_configuration_error

- **Module:** JWT/security
- **Component:** TokenService
- **Test identity:** `IOTAgriBackend.Tests.TokenServiceTests.Missing_key_throws_explicit_configuration_error`
- **Test type:** Unit test
- **Scenario:** Missing key throws explicit configuration error
- **Preconditions / isolation:** In-memory QA-only signing configuration; local JWT validation; bounded before/after clock for expiry.
- **Test file:** [backend/tests/TokenServiceTests.cs:54](../backend/tests/TokenServiceTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var error = Assert.Throws<InvalidOperationException>(() => new TokenService(Configuration(null))
            .CreateAccessToken(new ApplicationUser(), Array.Empty<string>()));
        Assert.Equal("Jwt:Key is not configured.", error.Message);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-D4A80A2056 | IOTAgriBackend.Tests.TokenServiceTests.Missing_key_throws_explicit_configuration_error | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c204877c-8d84-cfbb-ba9c-0019196c7ff9; [log](reports/summary/followup-final-test.log) |

## TokenServiceTests.Null_email_and_no_roles_produce_empty_email_without_role_claims

- **Module:** JWT/security
- **Component:** TokenService
- **Test identity:** `IOTAgriBackend.Tests.TokenServiceTests.Null_email_and_no_roles_produce_empty_email_without_role_claims`
- **Test type:** Unit test
- **Scenario:** Null email and no roles produce empty email without role claims
- **Preconditions / isolation:** In-memory QA-only signing configuration; local JWT validation; bounded before/after clock for expiry.
- **Test file:** [backend/tests/TokenServiceTests.cs:62](../backend/tests/TokenServiceTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var token = new TokenService(Configuration()).CreateAccessToken(new ApplicationUser { Email = null }, Array.Empty<string>());
        var jwt = new JwtSecurityTokenHandler().ReadJwtToken(token);
        Assert.Equal(string.Empty, jwt.Claims.Single(c => c.Type == JwtRegisteredClaimNames.Email).Value);
        Assert.DoesNotContain(jwt.Claims, c => c.Type == ClaimTypes.Role);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-9532F553C5 | IOTAgriBackend.Tests.TokenServiceTests.Null_email_and_no_roles_produce_empty_email_without_role_claims | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=91667c67-5f8f-d78b-70da-279a2af58442; [log](reports/summary/followup-final-test.log) |

## TokenServiceTests.Refresh_token_is_valid_base64_encoding_of_64_bytes

- **Module:** JWT/security
- **Component:** TokenService
- **Test identity:** `IOTAgriBackend.Tests.TokenServiceTests.Refresh_token_is_valid_base64_encoding_of_64_bytes`
- **Test type:** Unit test
- **Scenario:** Refresh token is valid base64 encoding of 64 bytes
- **Preconditions / isolation:** In-memory QA-only signing configuration; local JWT validation; bounded before/after clock for expiry.
- **Test file:** [backend/tests/TokenServiceTests.cs:83](../backend/tests/TokenServiceTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var token = new TokenService(Configuration()).GenerateRefreshTokenValue();
        Assert.Equal(64, Convert.FromBase64String(token).Length);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-183DF69A4A | IOTAgriBackend.Tests.TokenServiceTests.Refresh_token_is_valid_base64_encoding_of_64_bytes | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=af5b1155-cd36-bd45-8a37-3b64fe0d2a5c; [log](reports/summary/followup-final-test.log) |

## TokenServiceTests.Token_is_rejected_when_validated_with_a_different_signing_key

- **Module:** JWT/security
- **Component:** TokenService
- **Test identity:** `IOTAgriBackend.Tests.TokenServiceTests.Token_is_rejected_when_validated_with_a_different_signing_key`
- **Test type:** Unit test
- **Scenario:** Token is rejected when validated with a different signing key
- **Preconditions / isolation:** In-memory QA-only signing configuration; local JWT validation; bounded before/after clock for expiry.
- **Test file:** [backend/tests/TokenServiceTests.cs:71](../backend/tests/TokenServiceTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var handler = new JwtSecurityTokenHandler();
        var token = new TokenService(Configuration()).CreateAccessToken(new ApplicationUser(), Array.Empty<string>());
        Assert.Throws<SecurityTokenSignatureKeyNotFoundException>(() => handler.ValidateToken(token, new TokenValidationParameters
        {
            ValidIssuer = "qa-issuer", ValidAudience = "qa-audience",
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Key.Replace("qa-only", "wrong!!"))),
        }, out _));
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-AB7727AD43 | IOTAgriBackend.Tests.TokenServiceTests.Token_is_rejected_when_validated_with_a_different_signing_key | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=9d34c035-3f39-480c-4d7d-0e860f7296bd; [log](reports/summary/followup-final-test.log) |

## UpdateSystemAlertDefaultsRequestTests.Accepts_valid_finite_thresholds

- **Module:** Alerts
- **Component:** UpdateSystemAlertDefaultsRequest
- **Test identity:** `IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Accepts_valid_finite_thresholds`
- **Test type:** Unit test
- **Scenario:** Accepts valid finite thresholds
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/UpdateSystemAlertDefaultsRequestTests.cs:13](../backend/tests/UpdateSystemAlertDefaultsRequestTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var request = new UpdateSystemAlertDefaultsRequest(highTemp, lowWater);

        Assert.Equal(expected, request.IsValid);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-59274755F2 | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Accepts_valid_finite_thresholds(highTemp: -10, lowWater: 20, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=739a441b-9759-ed89-794e-d882d19cbc78; [log](reports/summary/followup-final-test.log) |
| TC-BE-0F239EA654 | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Accepts_valid_finite_thresholds(highTemp: 0, lowWater: 0, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=6aaf7de1-e290-682d-a941-a777a088f7a2; [log](reports/summary/followup-final-test.log) |
| TC-BE-9D91573013 | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Accepts_valid_finite_thresholds(highTemp: 100, lowWater: 100, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=d8a5482c-0454-484a-c090-632f46ca6405; [log](reports/summary/followup-final-test.log) |
| TC-BE-1AE788C08C | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Accepts_valid_finite_thresholds(highTemp: 35, lowWater: 20, expected: True) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b7e5a44d-50ee-ef14-8e1a-bcb2d96cc00f; [log](reports/summary/followup-final-test.log) |

## UpdateSystemAlertDefaultsRequestTests.Boundary_water_level_at_hundred_is_valid

- **Module:** Alerts
- **Component:** UpdateSystemAlertDefaultsRequest
- **Test identity:** `IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Boundary_water_level_at_hundred_is_valid`
- **Test type:** Unit test
- **Scenario:** Boundary water level at hundred is valid
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/UpdateSystemAlertDefaultsRequestTests.cs:41](../backend/tests/UpdateSystemAlertDefaultsRequestTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.True(new UpdateSystemAlertDefaultsRequest(35.0, 100.0).IsValid);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-50722822B1 | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Boundary_water_level_at_hundred_is_valid | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b36b9582-86d3-f77c-686c-c1d705cec1cd; [log](reports/summary/followup-final-test.log) |

## UpdateSystemAlertDefaultsRequestTests.Boundary_water_level_at_zero_is_valid

- **Module:** Alerts
- **Component:** UpdateSystemAlertDefaultsRequest
- **Test identity:** `IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Boundary_water_level_at_zero_is_valid`
- **Test type:** Unit test
- **Scenario:** Boundary water level at zero is valid
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/UpdateSystemAlertDefaultsRequestTests.cs:35](../backend/tests/UpdateSystemAlertDefaultsRequestTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        Assert.True(new UpdateSystemAlertDefaultsRequest(35.0, 0.0).IsValid);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-9A67F591D7 | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Boundary_water_level_at_zero_is_valid | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=85dcc94d-5dc3-8a1c-871b-655b01ebfcad; [log](reports/summary/followup-final-test.log) |

## UpdateSystemAlertDefaultsRequestTests.Rejects_non_finite_or_out_of_range_thresholds

- **Module:** Alerts
- **Component:** UpdateSystemAlertDefaultsRequest
- **Test identity:** `IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Rejects_non_finite_or_out_of_range_thresholds`
- **Test type:** Unit test
- **Scenario:** Rejects non finite or out of range thresholds
- **Preconditions / isolation:** In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle.
- **Test file:** [backend/tests/UpdateSystemAlertDefaultsRequestTests.cs:27](../backend/tests/UpdateSystemAlertDefaultsRequestTests.cs)
- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.

```csharp
{
        var request = new UpdateSystemAlertDefaultsRequest(highTemp, lowWater);

        Assert.False(request.IsValid);
    }
```

| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |
| --- | --- | --- | --- | --- | --- |
| TC-BE-3711EC51F9 | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Rejects_non_finite_or_out_of_range_thresholds(highTemp: -∞, lowWater: 20) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c10ff61c-2711-7c38-a811-8662c7d223f4; [log](reports/summary/followup-final-test.log) |
| TC-BE-945CA99F51 | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Rejects_non_finite_or_out_of_range_thresholds(highTemp: 35, lowWater: -0.001) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4bbbf17b-a84d-582f-fb52-c2a754dc472a; [log](reports/summary/followup-final-test.log) |
| TC-BE-78394B728F | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Rejects_non_finite_or_out_of_range_thresholds(highTemp: 35, lowWater: 100.001) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=4b77c40c-b5d9-2be8-784d-c21c6f09b133; [log](reports/summary/followup-final-test.log) |
| TC-BE-5F636D2889 | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Rejects_non_finite_or_out_of_range_thresholds(highTemp: 35, lowWater: NaN) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=8f90882e-9664-1eed-4117-a36d6bbec4c9; [log](reports/summary/followup-final-test.log) |
| TC-BE-7F2C6F12DC | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Rejects_non_finite_or_out_of_range_thresholds(highTemp: NaN, lowWater: 20) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=c6a2e066-eb96-bb09-ce58-1ddaa26483c4; [log](reports/summary/followup-final-test.log) |
| TC-BE-7CAFAC4A07 | IOTAgriBackend.Tests.UpdateSystemAlertDefaultsRequestTests.Rejects_non_finite_or_out_of_range_thresholds(highTemp: ∞, lowWater: 20) | Assertions in body above, with parameters in this row. | All assertions completed successfully. | PASS | [TRX](reports/coverage/followup-final/backend-tests.trx) testId=b3462ec8-0006-c326-939d-67bafbc85cf2; [log](reports/summary/followup-final-test.log) |
