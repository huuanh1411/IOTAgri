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
});
module.exports = { test, expect };
