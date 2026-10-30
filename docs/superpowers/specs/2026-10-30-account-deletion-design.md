# Account Deletion Design

## Goal

Provide permanent self-service account deletion for standard Aerogreen users and a public English/Vietnamese explanation page required by Google Play.

## Scope

- Authenticated standard user can permanently delete their own account from Settings.
- Admin accounts cannot self-delete through this endpoint.
- Owned hardware is permanently deleted, as selected by the product owner.
- Public `https://aerogreen.vn/delete-account` page explains the process without login.
- The system retains a minimal deletion audit event for 30 days, then removes it.

## Backend

### Endpoint

Add authenticated `DELETE /api/auth/account`.

The endpoint derives the account identity from the access-token subject. It accepts no user ID, preventing deletion of another account. It rejects accounts in the `Admin` role with a safe `403` response.

### Transaction

For a standard user, one relational database transaction deletes:

1. Support-ticket messages authored by the user and messages belonging to the user's tickets.
2. Support tickets owned by the user.
3. Email-verification codes and refresh tokens.
4. Every device owned by the user. Existing cascade relationships remove each device's sensor readings, pump commands, pump schedules and occurrences, light schedules, and device alerts.
5. The Identity user and remaining Identity rows through the configured user relationships.

The transaction writes one `AccountDeletionAudit` record before user deletion. It holds only a generated deletion ID and deletion timestamp; it does not retain email, name, device identifiers, or user ID. A hosted cleanup service deletes audit records older than 30 days.

The endpoint returns `204 No Content` only after the transaction commits.

### Data integrity

The migration adds the deletion-audit table and indexes its timestamp. Existing support-ticket restrictions are respected by explicitly deleting related ticket records before the user. Device deletion uses existing cascade configuration so hardware configuration and all history are permanently removed.

## Flutter app

Settings gains a destructive **Delete account** action.

The flow displays an irreversible-effects dialog. The user must type uppercase `DELETE` exactly before confirmation becomes available. On confirmation, the app calls `DELETE /api/auth/account`.

- Success: clear local access/refresh tokens and transition to `/auth`.
- `403`: show that administrator accounts cannot self-delete.
- Network/server error: show error and keep current authenticated session.

All user-facing strings are localized in English and Vietnamese.

## Public deletion page

Add a login-free GoRouter route at `/delete-account` and render it in English or Vietnamese following app locale. It documents:

1. Sign in to Aerogreen.
2. Open More > Settings > Delete account.
3. Type `DELETE` and confirm.
4. Deleted data: account/profile, owned hardware/configuration, device and sensor history, schedules, alerts, refresh tokens, verification codes, and support tickets.
5. Retained data: a non-identifying security deletion record for 30 days, then deleted.
6. Contact: `xteam.aerogreen@gmail.com`.

Nginx SPA fallback already serves direct public paths; path URL strategy preserves `/delete-account` in Flutter.

## Tests and validation

- Backend endpoint tests: only owner can delete; admin refusal; transactional deletion of user, devices, child records, tickets, and tokens; deletion audit retention cleanup.
- Flutter tests: typed confirmation gating, error handling, logout/navigation on success, public route, English/Vietnamese policy content.
- Run backend and Flutter suites, analyzer, web build, and production Compose validation.

## Non-goals

- Account recovery or a grace period.
- Manual email deletion request workflow.
- Transfer of hardware to another account.
