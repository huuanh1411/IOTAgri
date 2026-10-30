const { test: base, expect } = require('@playwright/test');
const { Pool } = require('pg');
const { accounts, login, json } = require('./api.cjs');
const { DeviceSimulator } = require('./device.cjs');
const test = base.extend({
  actor: async ({}, use) => {
    const actor = await login(accounts().owner);
    try { await use(actor); } finally { await actor.api.dispose(); }
  },
  db: async ({}, use) => {
    if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL is required. Use npm test to launch the isolated stack.');
    const pool = new Pool({ connectionString: process.env.DATABASE_URL });
    try { await use(pool); } finally { await pool.end(); }
  },
  device: async ({ actor }, use, info) => {
    const device = await json(await actor.api.post('/api/devices/', { data: { name: `E2E ${info.project.name} device` } }), 201);
    const simulator = new DeviceSimulator(device.deviceKey);
    try {
      await simulator.start();
      await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}`))).isOnline).toBe(true);
      await use({ ...device, simulator });
    } finally {
      await simulator.close();
      await info.attach('mqtt-commands', { body: JSON.stringify({ commands: simulator.commands, error: simulator.lastError }, null, 2), contentType: 'application/json' });
      await json(await actor.api.delete(`/api/devices/${device.id}`), 204);
    }
  },
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
