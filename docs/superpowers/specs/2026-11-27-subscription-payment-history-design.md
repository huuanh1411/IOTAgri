# Subscription Payment History Design

## Goal

Finish the existing record-only crop-subscription flow. Users can create and resume a bank-transfer payment request, see its final state in history, and inspect prior requests. An active subscription does not unlock or block product features.

## Scope

- Load the VietQR image from its final SVG URL, avoiding the PNG-to-SVG redirect that fails browser CORS checks.
- Persist expiry for overdue pending payments as `Expired` when subscription records are read or a new checkout is requested.
- Stop payment-status polling once a payment becomes active or expires.
- Show subscription history in the existing subscription screen.
- Stop retaining unbounded raw SePay webhook payloads after processing.
- Document and test production callback configuration and externally verifiable acceptance checks.

Excluded: entitlement enforcement, plans, recurring billing, invoices, renewal reminders, notifications, provider proxying, and a new crop-profile feature.

## State model

`CropSubscription.Status` has three states:

- `Pending`: valid only before `PaymentExpiresAt`.
- `Active`: set only by a validated SePay webhook; `ExpiresAt` remains informational for future product work.
- `Expired`: a payment request that was still pending at or after its payment deadline.

Expiry is lazy and deterministic. Before list results are returned or create checks for an open subscription, the API changes overdue pending records to `Expired` and saves only when a change occurred. No hosted cleanup process is needed. Only unexpired `Pending` and unexpired `Active` records prevent a new request for a device.

The API does not infer payment from a client request. The SePay webhook remains the sole transition to `Active` and must pass HMAC, timestamp, account, amount, and duplicate-transaction checks.

## Backend

The current endpoint group remains unchanged:

- `GET /api/subscriptions/` lists only authenticated caller-owned history in newest-first order.
- `POST /api/subscriptions/devices/{deviceId}` creates a new request or returns the existing unexpired request.
- `POST /api/payments/sepay/webhook` stays anonymous because SePay calls it, but remains signed and validated.

The create and list handlers share a small private expiry helper. It operates only on pending records, so an active subscription cannot be altered by time-based cleanup.

The entity and migration remove `SePayRawPayload`. The persisted audit facts are subscription ID, internal payment code, exact requested amount, accepted SePay transaction ID, paid time, and status. This is enough to explain the payment state without indefinitely retaining an external raw payload.

## Frontend

The existing subscription screen remains the single subscription surface:

1. It loads device choices and subscription history on entry.
2. Checkout keeps current behavior: create/resume a request, then show QR and transfer details.
3. The QR URL uses `compact2.svg`, the direct response that sends permissive image CORS headers. The app continues using `Image.network`; it never fetches or processes QR bytes.
4. The five-second refresh timer ends on `Active` or when `PaymentExpiresAt` passes. A manual refresh remains available for a non-expired pending request.
5. History shows crop name, device identifier/name when available from existing client data, price, status, submitted time, and expiry/paid time. It has no management action because subscriptions are record-only.

The existing API contract models already carry fields needed for these states. UI copy is added only for history and expired status.

## Production operations

Deployment configuration retains `SUBSCRIPTION_MONTHLY_PRICE_VND`, bank identity values, and `SEPAY_WEBHOOK_SECRET`. Production documentation specifies:

- Callback URL: `https://api.aerogreen.vn/api/payments/sepay/webhook`.
- SePay callback secret must equal `SEPAY_WEBHOOK_SECRET` on the VPS.
- The webhook sends `X-SePay-Timestamp` and `X-SePay-Signature`; requests outside five minutes or with an invalid HMAC are rejected.
- Manual proof: create a payment request, make a test/live transfer with exact amount and transfer content, verify callback returns success, then verify status becomes `Active` through the authenticated list API and app.

No repository test can validate third-party dashboard configuration or a bank transfer. Those remain an operator checklist.

## Tests

Backend focused tests cover:

- List and create persist `Expired` for overdue pending records.
- An expired request no longer blocks a replacement checkout.
- Valid webhook activates an unexpired pending record, while expired webhook payment is rejected.
- Raw webhook payload is not stored.

Flutter focused tests cover:

- QR uses direct SVG URL.
- Payment polling stops at expiry and active state.
- Subscription history renders pending, active, and expired records.

Production configuration tests keep the callback anonymous, confirm required environment settings, and preserve CORS restrictions.

## Acceptance conditions

- Browser QR request has no PNG-to-SVG redirect.
- A pending payment becomes `Expired` in returned and persisted history after its deadline.
- Expired payment does not poll and does not prevent a replacement request.
- Payment history is reachable from existing subscription UI.
- Valid signed SePay callback remains able to activate only the matching unexpired payment.
- Production operator can configure and manually verify webhook delivery without repository secrets.
