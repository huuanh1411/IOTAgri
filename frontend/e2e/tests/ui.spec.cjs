const { test: base, expect } = require('@playwright/test');
const fs = require('node:fs');
const path = require('node:path');

const test = base.extend({
  diagnostics: [
    async ({ page }, use, testInfo) => {
      const events = [];
      page.on('console', (m) => {
        if (m.type() === 'error')
          events.push({ type: 'console', message: m.text() });
      });
      page.on('pageerror', (e) =>
        events.push({ type: 'pageerror', message: e.message }),
      );
      page.on('requestfailed', (r) =>
        events.push({
          type: 'requestfailed',
          url: r.url(),
          error: r.failure(),
        }),
      );
      page.on('response', (r) => {
        if (r.url().includes('/api/'))
          events.push({
            type: 'api',
            method: r.request().method(),
            url: r.url(),
            status: r.status(),
          });
      });
      await use(events);
      await testInfo.attach('browser-diagnostics', {
        body: JSON.stringify(events, null, 2),
        contentType: 'application/json',
      });
      if (!page.isClosed())
        await testInfo.attach('accessibility-tree', {
          body: await page.locator('body').ariaSnapshot(),
          contentType: 'text/plain',
        });
      expect(
        events.filter((e) => e.type === 'pageerror'),
        'No uncaught JavaScript exceptions',
      ).toEqual([]);
    },
    { auto: true },
  ],
});

async function openApp(page) {
  await page.goto('/');
  await page
    .locator('flt-semantics-placeholder')
    .waitFor({ state: 'attached', timeout: 25000 });
  await page.locator('flt-semantics-placeholder').evaluate((el) => el.click());
  await expect(
    page.getByRole('button', { name: 'Đăng Nhập', exact: true }),
  ).toBeVisible();
}

async function snapshot(page, info, name) {
  // Flutter paints its route/card transitions on canvas (up to 400 ms),
  // so Playwright's CSS animation handling cannot settle these frames.
  await page.waitForTimeout(450);
  await info.attach(name, {
    body: await page.screenshot(),
    contentType: 'image/png',
  });
}

async function login(page) {
  const fixture = JSON.parse(
    fs.readFileSync(path.join(__dirname, '../.auth/fixture.json'), 'utf8'),
  );
  await openApp(page);
  await page
    .getByRole('textbox', { name: 'ban@vidu.com', exact: true })
    .fill(fixture.email);
  await page
    .getByRole('textbox', { name: 'Mật khẩu', exact: true })
    .fill(fixture.password);
  const response = page.waitForResponse(
    (r) =>
      r.url().endsWith('/api/auth/login') && r.request().method() === 'POST',
  );
  await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
  expect(
    (await response).status(),
    'Real backend accepts the test account',
  ).toBe(200);
  await expect(page).toHaveURL(/#\/home$/);
}

async function insideViewport(locator, page) {
  await expect(locator).toBeVisible();
  const box = await locator.boundingBox();
  expect(box, 'Element has a rendered rectangle').not.toBeNull();
  const size = page.viewportSize();
  expect(box.x, 'Element is not clipped at the left').toBeGreaterThanOrEqual(
    -1,
  );
  expect(box.y, 'Element is not clipped at the top').toBeGreaterThanOrEqual(-1);
  expect(box.x + box.width, 'Element fits viewport width').toBeLessThanOrEqual(
    size.width + 1,
  );
  expect(
    box.y + box.height,
    'Element fits viewport height',
  ).toBeLessThanOrEqual(size.height + 1);
}

test('UI-01: login renders and the submit button is reachable', async ({
  page,
}, info) => {
  await openApp(page);
  await expect(page.getByRole('textbox')).toHaveCount(2);
  const button = page.getByRole('button', { name: 'Đăng nhập →', exact: true });
  await button.scrollIntoViewIfNeeded();
  await insideViewport(button, page);
  await snapshot(page, info, 'login');
});

test('UI-02: empty login shows field validation without sending an API request', async ({
  page,
  diagnostics,
}, info) => {
  await openApp(page);
  await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
  await expect(
    page.getByText('Email không hợp lệ', { exact: true }).last(),
  ).toBeVisible();
  await expect(
    page.getByText('Vui lòng nhập mật khẩu', { exact: true }).last(),
  ).toBeVisible();
  expect(
    diagnostics.filter(
      (e) => e.type === 'api' && e.url.endsWith('/api/auth/login'),
    ),
  ).toHaveLength(0);
  await snapshot(page, info, 'login-validation');
});

test('UI-03: registration validates weak and mismatched passwords', async ({
  page,
  diagnostics,
}, info) => {
  await openApp(page);
  await page.getByRole('button', { name: 'Đăng Ký', exact: true }).click();
  await expect(page.getByRole('textbox')).toHaveCount(4);
  await page
    .getByRole('textbox', { name: 'Họ và tên', exact: true })
    .fill('UI Test');
  await page
    .getByRole('textbox', { name: 'ban@vidu.com', exact: true })
    .fill('validation@example.test');
  await page
    .getByRole('textbox', { name: 'Mật khẩu', exact: true })
    .fill('weak');
  await page
    .getByRole('textbox', { name: 'Xác nhận mật khẩu', exact: true })
    .fill('different');
  await page
    .getByRole('button', { name: 'Tạo tài khoản →', exact: true })
    .click();
  await expect(
    page.getByText('Mật khẩu không khớp', { exact: true }).last(),
  ).toBeVisible();
  await expect(page.getByText(/Mật khẩu cần có:/).last()).toBeVisible();
  expect(
    diagnostics.filter(
      (e) => e.type === 'api' && e.url.endsWith('/api/auth/register'),
    ),
  ).toHaveLength(0);
  await snapshot(page, info, 'registration-validation');
});

test('UI-04: rejected credentials show feedback and remain on login', async ({
  page,
}, info) => {
  await openApp(page);
  await page
    .getByRole('textbox', { name: 'ban@vidu.com', exact: true })
    .fill('missing-ui-user@example.test');
  await page
    .getByRole('textbox', { name: 'Mật khẩu', exact: true })
    .fill('WrongPassword!9');
  const response = page.waitForResponse((r) =>
    r.url().endsWith('/api/auth/login'),
  );
  await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
  expect((await response).status()).toBe(401);
  await expect(page).toHaveURL(/#\/auth$/);
  await expect(
    page
      .getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i)
      .last(),
  ).toBeVisible();
  await snapshot(page, info, 'rejected-login');
});

test('UI-05: real login loads dashboard and survives a browser reload', async ({
  page,
  diagnostics,
}, info) => {
  await login(page);
  await expect(page.getByText(/Vườn của UI|UI.s Garden/)).toBeVisible();
  await expect
    .poll(() =>
      diagnostics.some(
        (e) =>
          e.type === 'api' &&
          e.url.endsWith('/api/dashboard/overview') &&
          e.status === 200,
      ),
    )
    .toBeTruthy();
  await expect(page.getByText(/KHỎE MẠNH/)).toBeVisible();
  await snapshot(page, info, 'dashboard');
  await page.reload();
  await page.locator('flt-semantics-placeholder').evaluate((el) => el.click());
  await expect(page).toHaveURL(/#\/home$/);
  await expect(page.getByText(/Vườn của UI|UI.s Garden/)).toBeVisible();
  await expect(page.getByText(/KHỎE MẠNH/)).toBeVisible();
  await snapshot(page, info, 'restored-session');
});

test('UI-06: alerts and plant selection tabs open with reachable navigation', async ({
  page,
}, info) => {
  await login(page);
  await page.getByRole('button', { name: 'Cảnh báo', exact: true }).click();
  await expect(page).toHaveURL(/#\/alerts$/);
  await expect(
    page.getByRole('tab', { name: 'Tất cả', exact: true }),
  ).toBeVisible();
  await snapshot(page, info, 'alerts');
  await page.getByRole('button', { name: 'Chọn giống', exact: true }).click();
  await expect(page).toHaveURL(/#\/pick$/);
  await expect(
    page.getByRole('button', { name: /Bắt Đầu Trồng/ }).first(),
  ).toBeVisible();
  await insideViewport(
    page.getByRole('button', { name: 'Khác', exact: true }),
    page,
  );
  await snapshot(page, info, 'plant-picker');
});

test('UI-07: account and settings remain usable on the viewport', async ({
  page,
}, info) => {
  await login(page);
  await page.getByRole('button', { name: 'Khác', exact: true }).click();
  await expect(page.getByText(/UI Test/)).toBeVisible();
  await snapshot(page, info, 'account');
  await insideViewport(
    page.getByRole('button', { name: 'Đăng xuất', exact: true }),
    page,
  );
  await page.getByRole('button', { name: /Tùy chỉnh/ }).click();
  await expect(
    page.getByRole('radio', { name: 'English', exact: true }),
  ).toBeVisible();
  await snapshot(page, info, 'settings');
});

test('UI-08: logout clears the session and returns to login after reload', async ({
  page,
}, info) => {
  await login(page);
  await page.getByRole('button', { name: 'Khác', exact: true }).click();
  await page.getByRole('button', { name: 'Đăng xuất', exact: true }).click();
  await expect(page.getByRole('alertdialog')).toBeVisible();
  const response = page.waitForResponse((r) =>
    r.url().endsWith('/api/auth/logout'),
  );
  await page
    .getByRole('alertdialog')
    .getByRole('button', { name: 'Đăng xuất', exact: true })
    .click();
  expect((await response).ok()).toBeTruthy();
  await expect(page).toHaveURL(/#\/auth$/);
  await page.reload();
  await page.locator('flt-semantics-placeholder').evaluate((el) => el.click());
  await expect(
    page.getByRole('button', { name: 'Đăng Nhập', exact: true }),
  ).toBeVisible();
  await expect(page).toHaveURL(/#\/auth$/);
  await snapshot(page, info, 'logged-out');
});

test('UI-09: a backend outage displays an error instead of authenticating', async ({
  page,
}, info) => {
  await openApp(page);
  await page.route('**/api/auth/login', (route) =>
    route.abort('connectionrefused'),
  );
  await page
    .getByRole('textbox', { name: 'ban@vidu.com', exact: true })
    .fill('outage@example.test');
  await page
    .getByRole('textbox', { name: 'Mật khẩu', exact: true })
    .fill('UiTest!Password9');
  await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
  await expect(
    page
      .getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i)
      .last(),
  ).toBeVisible();
  await expect(page).toHaveURL(/#\/auth$/);
  await expect(
    page.getByRole('button', { name: 'Đăng nhập →', exact: true }),
  ).toBeEnabled();
  await snapshot(page, info, 'backend-outage');
});

test('UI-10: help and harvest history screens can be opened', async ({
  page,
}, info) => {
  await login(page);
  await page.getByRole('button', { name: 'Khác', exact: true }).click();
  await page.getByRole('button', { name: /Trợ giúp & Hỗ trợ/ }).click();
  await expect(
    page.getByRole('button', { name: 'Chat với chúng tôi', exact: true }),
  ).toBeVisible();
  await snapshot(page, info, 'help');
  await page.getByRole('button', { name: '', exact: true }).first().click();
  await expect(
    page.getByRole('button', { name: /Lịch sử thu hoạch/ }),
  ).toBeVisible();
  await page.getByRole('button', { name: /Lịch sử thu hoạch/ }).click();
  await expect(page.getByText(/Nhật ký thu hoạch/)).toBeVisible();
  await snapshot(page, info, 'harvest-history');
});

test('UI-11: Vietnamese settings are reflected in the dashboard greeting', async ({
  page,
}, info) => {
  await login(page);
  await page.getByRole('button', { name: 'Khác', exact: true }).click();
  await page.getByRole('button', { name: /Tùy chỉnh/ }).click();
  await expect(
    page.getByRole('radio', { name: 'Tiếng Việt', exact: true }),
  ).toBeChecked();
  await snapshot(page, info, 'vietnamese-selected');
  await page.getByRole('button', { name: 'Trang chủ', exact: true }).click();
  await expect(page).toHaveURL(/#\/home$/);
  await expect(page.getByText(/Vườn của UI/)).toBeVisible();
  await snapshot(page, info, 'vietnamese-dashboard');
});
