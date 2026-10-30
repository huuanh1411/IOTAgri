const { expect } = require('@playwright/test');
const { accounts } = require('./api.cjs');
async function semantics(page) {
  // Flutter's canvas is exposed to browser locators through its semantics tree.
  await page.waitForFunction(() => document.querySelector('flt-semantics-placeholder') || document.querySelector('flt-semantics'));
  const placeholder = page.locator('flt-semantics-placeholder');
  if (await placeholder.count()) await placeholder.evaluate(el => el.click());
  await expect(page.locator('flt-semantics').first()).toBeAttached();
}
async function openApp(page, route = '/auth') {
  await page.goto(route);
  await semantics(page);
}
async function fillLogin(page, account) {
  await enterText(page.getByRole('textbox', { name: 'ban@vidu.com', exact: true }), account.email);
  await enterText(page.getByRole('textbox', { name: 'Mật khẩu', exact: true }), account.password);
}
async function enterText(locator, value) {
  // Flutter's semantics input is a proxy. Real keyboard events update its
  // TextEditingController reliably; setting the DOM value via fill() may not.
  await locator.click();
  await locator.press('ControlOrMeta+A');
  await locator.pressSequentially(value, { delay: 15 });
  // Hint-based accessible names disappear after entry. Assert on the focused
  // editor instead of resolving the original placeholder locator again.
  await expect(locator.page().locator('input:focus, textarea:focus')).toHaveValue(value);
}
async function submitLogin(page, expected = 200) {
  const response = page.waitForResponse(r => r.url().endsWith('/api/auth/login') && r.request().method() === 'POST', { timeout: 20000 });
  await page.getByRole('button', { name: /Đăng nhập\s*→/ }).click();
  expect((await response).status()).toBe(expected);
}
async function loginUI(page, role = 'owner') {
  await openApp(page);
  await fillLogin(page, accounts()[role]);
  await submitLogin(page);
  await expect(page).toHaveURL(role === 'admin' ? /\/admin$/ : /\/home$/);
}
async function reveal(page, locator) {
  const viewport = page.viewportSize();
  await page.mouse.move(viewport.width / 2, viewport.height / 2);
  // Flutter omits offscreen semantics nodes. Scroll the real canvas until the
  // control exists before asking Playwright to bring its DOM proxy into view.
  await expect.poll(async () => {
    if (await locator.count()) return true;
    await page.mouse.wheel(0, 240);
    return false;
  }, { timeout: 10000, intervals: [250], message: 'Reveal Flutter control by scrolling' }).toBe(true);
  await locator.scrollIntoViewIfNeeded();
  await expect(locator).toBeVisible();
}
module.exports = { semantics, openApp, fillLogin, submitLogin, loginUI, enterText, reveal };
