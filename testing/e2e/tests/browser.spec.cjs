const { randomUUID } = require('node:crypto');
const { test, expect } = require('../support/browser-fixtures.cjs');
const { verificationCode, json } = require('../support/api.cjs');
const { verifiesEmail, registrationStatus, authContract } = require('../support/contract.cjs');
const { openApp, fillLogin, submitLogin, loginUI, semantics, enterText, reveal } = require('../support/browser.cjs');

test(`WEB-01 registration and login through UI (${authContract})`, async ({ page, request, db }) => {
  const account = { email: `web-${randomUUID()}@example.test`, password: 'E2eBrowserOnly!123' };
  await openApp(page);
  await page.getByRole('button', { name: 'Đăng ký', exact: true }).click();
  await enterText(page.getByRole('textbox', { name: 'Họ và tên', exact: true }), 'E2E Browser');
  await fillLogin(page, account);
  await enterText(page.getByRole('textbox', { name: 'Xác nhận mật khẩu', exact: true }), account.password);
  const registration = page.waitForResponse(r => r.url().endsWith('/api/auth/register') && r.request().method() === 'POST');
  await page.getByRole('button', { name: /Tạo tài khoản\s*→/ }).click();
  expect((await registration).status()).toBe(registrationStatus);
  if (!verifiesEmail) {
    await expect(page).toHaveURL(/\/home$/);
    expect((await db.query('SELECT "Email", "FullName" FROM "AspNetUsers" WHERE "Email"=$1', [account.email])).rows)
      .toEqual([{ Email: account.email, FullName: 'E2E Browser' }]);
    await page.reload();
    await semantics(page);
    await expect(page).toHaveURL(/\/home$/);
    return;
  }
  const code = await verificationCode(request, account.email);
  await enterText(page.getByRole('textbox', { name: /Mã xác minh/ }), code);
  const verified = page.waitForResponse(r => r.url().endsWith('/api/auth/verify-email') && r.request().method() === 'POST');
  await page.getByRole('button', { name: 'Xác Minh', exact: true }).click();
  expect((await verified).status()).toBe(204);
  expect((await db.query('SELECT "EmailConfirmed" FROM "AspNetUsers" WHERE "Email"=$1', [account.email])).rows).toEqual([{ EmailConfirmed: true }]);
  await page.getByRole('button', { name: 'Đăng nhập', exact: true }).click();
  await fillLogin(page, account);
  await submitLogin(page);
  await expect(page).toHaveURL(/\/home$/);
});

test('WEB-02 real login and dashboard session survive reload; logout revokes session', async ({ page, diagnostics }) => {
  await loginUI(page);
  await expect.poll(() => diagnostics.some(r => r.url.endsWith('/api/dashboard/overview') && r.status === 200)).toBe(true);
  await page.reload();
  await semantics(page);
  await expect(page).toHaveURL(/\/home$/);
  await page.getByRole('button', { name: 'Khác', exact: true }).click();
  await page.getByRole('button', { name: 'Đăng xuất', exact: true }).click();
  const dialog = page.getByRole('alertdialog');
  const logout = page.waitForResponse(r => r.url().endsWith('/api/auth/logout') && r.request().method() === 'POST');
  await dialog.getByRole('button', { name: 'Đăng xuất', exact: true }).click();
  expect((await logout).status()).toBe(204);
  await expect(page).toHaveURL(/\/auth$/);
  await page.reload();
  await semantics(page);
  await expect(page.getByRole('button', { name: /Đăng nhập\s*→/ })).toBeVisible();
});

test('WEB-03 admin login routes to admin dashboard', async ({ page }) => {
  await loginUI(page, 'admin');
  await expect(page.getByText(/E2E Admin/).first()).toBeVisible();
});

test('WEB-04 MQTT telemetry and browser pump command complete the real system loop', async ({ page, actor, device, db }) => {
  await loginUI(page);
  await page.getByRole('button', { name: 'Thiết bị', exact: true }).click();
  await page.getByRole('button', { name: device.name }).click();
  await expect(page.getByText('25.4', { exact: false }).first()).toBeVisible();
  const manual = page.getByText('Thủ công', { exact: true });
  await reveal(page, manual);
  await manual.click();
  await page.getByRole('button', { name: 'Chuyển', exact: true }).click();
  const start = page.getByRole('button', { name: /BẬT BƠM$/ });
  await reveal(page, start);
  await start.click();
  const response = page.waitForResponse(r => r.url().includes(`/api/devices/${device.id}/pump/commands`) && r.request().method() === 'POST');
  await page.getByRole('button', { name: /30 giây/ }).click();
  const command = await (await response).json();
  await expect.poll(() => device.simulator.commands.some(c => c.commandId === command.id && c.isOn)).toBe(true);
  await expect.poll(async () => (await db.query('SELECT "AcknowledgedIsOn" FROM "PumpCommands" WHERE "Id"=$1', [command.id])).rows[0]?.AcknowledgedIsOn).toBe(true);
  await expect(page.getByRole('button', { name: /Dừng$/ })).toBeVisible({ timeout: 25000 });
  const off = page.waitForResponse(r => r.url().includes(`/api/devices/${device.id}/pump/commands`) && r.request().method() === 'POST');
  await page.getByRole('button', { name: /Dừng$/ }).click();
  const stopped = await (await off).json();
  await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/pump-commands`))).items.find(c => c.id === stopped.id)?.acknowledgedIsOn).toBe(false);
  const light = page.getByRole('switch', { name: /Điều khiển đèn/ });
  for (const isOn of [true, false]) {
    await reveal(page, light);
    const accepted = page.waitForResponse(r => r.url().endsWith(`/api/devices/${device.id}/light/commands`) && r.request().method() === 'POST');
    await light.click();
    expect((await accepted).status()).toBe(202);
    await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/light/status`)))).toMatchObject({ isOn, isAvailable: true });
    if (isOn) await expect(light).toBeChecked();
    else await expect(light).not.toBeChecked();
  }
});

test('WEB-05 invalid credentials and injected network failure keep user on login', async ({ page }) => {
  await openApp(page);
  await fillLogin(page, { email: 'missing@example.test', password: 'WrongPassword!123' });
  await submitLogin(page, 401);
  await expect(page).toHaveURL(/\/auth$/);
  await expect(page.getByText(/Email hoặc mật khẩu|không chính xác|không đúng/i).first()).toBeVisible();
  await page.route('**/api/auth/login', route => route.abort('connectionrefused'));
  await page.getByRole('button', { name: /Đăng nhập\s*→/ }).click();
  await expect(page.getByText(/kết nối|mạng/i).first()).toBeVisible();
  await expect(page).toHaveURL(/\/auth$/);
});
