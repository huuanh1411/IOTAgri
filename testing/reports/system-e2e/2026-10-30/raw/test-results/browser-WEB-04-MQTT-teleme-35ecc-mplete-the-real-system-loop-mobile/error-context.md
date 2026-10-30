# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: browser.spec.cjs >> WEB-04 MQTT telemetry and browser pump command complete the real system loop
- Location: tests/browser.spec.cjs:51:1

# Error details

```
TimeoutError: page.waitForResponse: Timeout 15000ms exceeded while waiting for event "response"
```

```
TimeoutError: locator.click: Timeout 15000ms exceeded.
Call log:
  - waiting for getByRole('button', { name: /30 giây/ })

```

# Page snapshot

```yaml
- generic [ref=e4] [cursor=pointer]:
  - generic:
    - generic:
      - generic:
        - generic:
          - generic:
            - button [ref=e5]:
              - button "Quay lại" [ref=e6]
            - heading "E2E mobile device" [level=2] [ref=e7]
            - button [ref=e8]
            - generic:
              - group:
                - generic [ref=e9]: E2E mobile device Online Kết nối ổn định Cập nhật 18:07
                - generic [ref=e11]: Cảm biến
                - generic:
                  - generic:
                    - generic:
                      - button "Nhiệt độ không khí 25.4 °C" [ref=e13]
                      - button "Độ ẩm 64.0 %" [ref=e14]
                      - button "Nhiệt độ dung dịch 23.8 °C" [ref=e15]
                      - button "TDS 610.0 ppm" [ref=e16]
                      - button "Mực nước 82.0 %" [ref=e17]
                      - button "Ánh sáng 420.0 lx" [ref=e18]
                - button "Điều khiển bơm Bơm đang tắt BẬT BƠM" [ref=e20]:
                  - radiogroup:
                    - button "Tự động" [ref=e21]
                    - button "Thủ công" [active] [ref=e22]
                - switch "Điều khiển đèn Đèn đang tắt" [ref=e24]
                - button "Lịch tưới Sửa Chưa có lịch tự động." [ref=e26]
                - button "Lịch sử 24 giờ 2 lần ghi · Nhiệt độ" [ref=e28]
                - button "Cảnh báo Không có cảnh báo đang mở." [ref=e30]
          - button "Trang chủ" [ref=e31]
          - button "Cảnh báo" [ref=e32]
          - button "Chọn giống" [ref=e33]
          - button "Thiết bị" [ref=e34]
          - button "Khác" [ref=e35]
```

# Test source

```ts
  1  | const { randomUUID } = require('node:crypto');
  2  | const { test, expect } = require('../support/fixtures.cjs');
  3  | const { verificationCode, json } = require('../support/api.cjs');
  4  | const { openApp, fillLogin, submitLogin, loginUI, semantics, enterText, reveal } = require('../support/browser.cjs');
  5  | 
  6  | test('WEB-01 registration through UI, email delivery, verification and login', async ({ page, request, db }) => {
  7  |   const account = { email: `web-${randomUUID()}@example.test`, password: '<redacted-test-credential>' };
  8  |   await openApp(page);
  9  |   await page.getByRole('button', { name: 'Đăng ký', exact: true }).click();
  10 |   await enterText(page.getByRole('textbox', { name: 'Họ và tên', exact: true }), 'E2E Browser');
  11 |   await fillLogin(page, account);
  12 |   await enterText(page.getByRole('textbox', { name: 'Xác nhận mật khẩu', exact: true }), account.password);
  13 |   const registration = page.waitForResponse(r => r.url().endsWith('/api/auth/register') && r.request().method() === 'POST');
  14 |   await page.getByRole('button', { name: /Tạo tài khoản\s*→/ }).click();
  15 |   expect((await registration).status()).toBe(202);
  16 |   const code = await verificationCode(request, account.email);
  17 |   await enterText(page.getByRole('textbox', { name: /Mã xác minh/ }), code);
  18 |   const verified = page.waitForResponse(r => r.url().endsWith('/api/auth/verify-email') && r.request().method() === 'POST');
  19 |   await page.getByRole('button', { name: 'Xác Minh', exact: true }).click();
  20 |   expect((await verified).status()).toBe(204);
  21 |   expect((await db.query('SELECT "EmailConfirmed" FROM "AspNetUsers" WHERE "Email"=$1', [account.email])).rows).toEqual([{ EmailConfirmed: true }]);
  22 |   await page.getByRole('button', { name: 'Đăng nhập', exact: true }).click();
  23 |   await fillLogin(page, account);
  24 |   await submitLogin(page);
  25 |   await expect(page).toHaveURL(/\/home$/);
  26 | });
  27 | 
  28 | test('WEB-02 real login and dashboard session survive reload; logout revokes session', async ({ page, diagnostics }) => {
  29 |   await loginUI(page);
  30 |   await expect.poll(() => diagnostics.some(r => r.url.endsWith('/api/dashboard/overview') && r.status === 200)).toBe(true);
  31 |   await page.reload();
  32 |   await semantics(page);
  33 |   await expect(page).toHaveURL(/\/home$/);
  34 |   await page.getByRole('button', { name: 'Khác', exact: true }).click();
  35 |   await page.getByRole('button', { name: 'Đăng xuất', exact: true }).click();
  36 |   const dialog = page.getByRole('alertdialog');
  37 |   const logout = page.waitForResponse(r => r.url().endsWith('/api/auth/logout') && r.request().method() === 'POST');
  38 |   await dialog.getByRole('button', { name: 'Đăng xuất', exact: true }).click();
  39 |   expect((await logout).status()).toBe(204);
  40 |   await expect(page).toHaveURL(/\/auth$/);
  41 |   await page.reload();
  42 |   await semantics(page);
  43 |   await expect(page.getByRole('button', { name: /Đăng nhập\s*→/ })).toBeVisible();
  44 | });
  45 | 
  46 | test('WEB-03 admin login routes to admin dashboard', async ({ page }) => {
  47 |   await loginUI(page, 'admin');
  48 |   await expect(page.getByText(/E2E Admin/).first()).toBeVisible();
  49 | });
  50 | 
  51 | test('WEB-04 MQTT telemetry and browser pump command complete the real system loop', async ({ page, actor, device, db }) => {
  52 |   await loginUI(page);
  53 |   await page.getByRole('button', { name: 'Thiết bị', exact: true }).click();
  54 |   await page.getByRole('button', { name: device.name }).click();
  55 |   await expect(page.getByText('25.4', { exact: false }).first()).toBeVisible();
  56 |   const manual = page.getByText('Thủ công', { exact: true });
  57 |   await reveal(page, manual);
  58 |   await manual.click();
  59 |   await page.getByRole('button', { name: 'Chuyển', exact: true }).click();
  60 |   const start = page.getByRole('button', { name: /BẬT BƠM$/ });
  61 |   await reveal(page, start);
  62 |   await start.click();
  63 |   const response = page.waitForResponse(r => r.url().includes(`/api/devices/${device.id}/pump/commands`) && r.request().method() === 'POST');
> 64 |   await page.getByRole('button', { name: /30 giây/ }).click();
     |                                                       ^ TimeoutError: locator.click: Timeout 15000ms exceeded.
  65 |   const command = await (await response).json();
  66 |   await expect.poll(() => device.simulator.commands.some(c => c.commandId === command.id && c.isOn)).toBe(true);
  67 |   await expect.poll(async () => (await db.query('SELECT "AcknowledgedIsOn" FROM "PumpCommands" WHERE "Id"=$1', [command.id])).rows[0]?.AcknowledgedIsOn).toBe(true);
  68 |   await expect(page.getByRole('button', { name: /Dừng$/ })).toBeVisible({ timeout: 25000 });
  69 |   const off = page.waitForResponse(r => r.url().includes(`/api/devices/${device.id}/pump/commands`) && r.request().method() === 'POST');
  70 |   await page.getByRole('button', { name: /Dừng$/ }).click();
  71 |   const stopped = await (await off).json();
  72 |   await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/pump-commands`))).items.find(c => c.id === stopped.id)?.acknowledgedIsOn).toBe(false);
  73 |   const light = page.getByRole('switch', { name: /Điều khiển đèn/ });
  74 |   for (const isOn of [true, false]) {
  75 |     await reveal(page, light);
  76 |     const accepted = page.waitForResponse(r => r.url().endsWith(`/api/devices/${device.id}/light/commands`) && r.request().method() === 'POST');
  77 |     await light.click();
  78 |     expect((await accepted).status()).toBe(202);
  79 |     await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/light/status`)))).toMatchObject({ isOn, isAvailable: true });
  80 |     if (isOn) await expect(light).toBeChecked();
  81 |     else await expect(light).not.toBeChecked();
  82 |   }
  83 | });
  84 | 
  85 | test('WEB-05 invalid credentials and injected network failure keep user on login', async ({ page }) => {
  86 |   await openApp(page);
  87 |   await fillLogin(page, { email: 'missing@example.test', password: 'WrongPassword!123' });
  88 |   await submitLogin(page, 401);
  89 |   await expect(page).toHaveURL(/\/auth$/);
  90 |   await expect(page.getByText(/Email hoặc mật khẩu|không chính xác|không đúng/i).first()).toBeVisible();
  91 |   await page.route('**/api/auth/login', route => route.abort('connectionrefused'));
  92 |   await page.getByRole('button', { name: /Đăng nhập\s*→/ }).click();
  93 |   await expect(page.getByText(/kết nối|mạng/i).first()).toBeVisible();
  94 |   await expect(page).toHaveURL(/\/auth$/);
  95 | });
  96 | 
```