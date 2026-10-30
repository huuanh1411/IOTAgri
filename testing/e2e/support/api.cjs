const { expect, request } = require('@playwright/test');
const fs = require('node:fs');
const path = require('node:path');
const fixturePath = path.join(__dirname, '../.auth/accounts.json');
const apiURL = process.env.API_URL || 'http://api:8080';
const mailURL = process.env.MAIL_URL || 'http://mailpit:8025';

async function json(response, status = 200) {
  expect(response.status(), `${response.request?.()?.url?.() || response.url()} returned ${await response.text()}`).toBe(status);
  return status === 204 || status === 202 ? null : response.json();
}
async function verificationCode(api, email) {
  let code;
  await expect.poll(async () => {
    const listing = await api.get(`${mailURL}/api/v1/messages`);
    expect(listing.ok()).toBeTruthy();
    const { messages = [] } = await listing.json();
    const item = messages.find(m => m.To?.some(to => to.Address === email));
    if (!item) return false;
    const body = await json(await api.get(`${mailURL}/api/v1/message/${item.ID}`));
    code = (body.Text || '').match(/\b\d{6}\b/)?.[0];
    return !!code;
  }, { timeout: 20000, message: `Verification email delivered to ${email}` }).toBe(true);
  return code;
}
async function login(account) {
  const api = await request.newContext({ baseURL: apiURL });
  try {
    const tokens = await json(await api.post('/api/auth/login', { data: account }));
    const client = await request.newContext({ baseURL: apiURL, extraHTTPHeaders: { Authorization: `Bearer ${tokens.accessToken}` } });
    return { api: client, tokens };
  } finally { await api.dispose(); }
}
function accounts() { return JSON.parse(fs.readFileSync(fixturePath, 'utf8')); }
module.exports = { json, verificationCode, login, accounts, fixturePath, apiURL };
