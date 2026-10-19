const { request } = require('@playwright/test');
const { randomBytes } = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { e2eRoot } = require('./paths.cjs');

module.exports = async function setup() {
  const apiURL = process.env.API_URL || 'http://localhost:5261';
  const api = await request.newContext({ baseURL: apiURL });
  try {
    const health = await api.get('/health');
    if (!health.ok() || (await health.json()).status !== 'ready')
      throw new Error('Backend health is not ready');
    const fixture = {
      fullName: 'UI Test',
      email: `ui-${Date.now()}@example.test`,
      password: `UiTest!${randomBytes(12).toString('hex')}9`,
      apiURL,
    };
    const response = await api.post('/api/auth/register', { data: fixture });
    if (response.status() !== 201)
      throw new Error(
        `Could not prepare a local test account: HTTP ${response.status()}`,
      );
    const dir = path.join(e2eRoot, '.auth');
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(
      path.join(dir, 'fixture.json'),
      JSON.stringify(fixture, null, 2),
    );
  } finally {
    await api.dispose();
  }
};
