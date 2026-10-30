const { request, expect } = require('@playwright/test');
const fs = require('node:fs');
const path = require('node:path');
const { randomUUID } = require('node:crypto');
const { json, verificationCode, fixturePath, apiURL } = require('./api.cjs');
module.exports = async () => {
  const api = await request.newContext({ baseURL: apiURL });
  try {
    expect((await json(await api.get('/health'))).status).toBe('ready');
    const accounts = { admin: { email: 'admin@example.test', password: 'E2eAdminOnly!123' } };
    for (const role of ['owner', 'other']) {
      const account = { email: `${role}-${randomUUID()}@example.test`, password: 'E2eUserOnly!123', fullName: `E2E ${role}` };
      await json(await api.post('/api/auth/register', { data: account }), 202);
      expect((await api.post('/api/auth/login', { data: account })).status()).toBe(403);
      const code = await verificationCode(api, account.email);
      await json(await api.post('/api/auth/verify-email', { data: { email: account.email, code } }), 204);
      accounts[role] = account;
    }
    fs.mkdirSync(path.dirname(fixturePath), { recursive: true });
    fs.writeFileSync(fixturePath, JSON.stringify(accounts));
  } finally { await api.dispose(); }
};
