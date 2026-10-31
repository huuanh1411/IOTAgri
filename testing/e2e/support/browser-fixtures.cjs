const { test: base, expect } = require('./fixtures.cjs');
const test = base.extend({
  diagnostics: [async ({ page }, use, info) => {
    const errors = [];
    const responses = [];
    page.on('pageerror', e => errors.push(e.message));
    page.on('response', r => {
      if (r.url().includes('/api/')) responses.push({ method: r.request().method(), url: r.url(), status: r.status() });
    });
    await use(responses);
    await info.attach('browser-diagnostics', { body: JSON.stringify({ errors, responses }, null, 2), contentType: 'application/json' });
    if (!page.isClosed()) {
      await info.attach('screen', { body: await page.screenshot(), contentType: 'image/png' });
      await info.attach('semantics', { body: await page.locator('body').ariaSnapshot(), contentType: 'text/plain' });
    }
    expect(errors, 'No uncaught browser exceptions').toEqual([]);
  }, { auto: true }],
});
module.exports = { test, expect };
