const { randomUUID } = require('node:crypto');
const { request } = require('@playwright/test');
const { test, expect } = require('../support/fixtures.cjs');
const { json, accounts, login, apiURL } = require('../support/api.cjs');
const { verifiesEmail } = require('../support/contract.cjs');

async function history(api, id) { return json(await api.get(`/api/devices/${id}/pump-commands`)); }
function nearFutureSchedule() {
  const date = new Date(Date.now() + 10000);
  return { isEnabled: true, weekdayMask: 127, startTime: date.toISOString().slice(11, 19), durationSeconds: 3, timeZone: 'Etc/UTC' };
}

test('SYS-01 anonymous access and Google endpoint follow the selected auth contract', async ({}) => {
  const api = await request.newContext({ baseURL: apiURL });
  try {
    expect((await api.get('/api/devices/')).status()).toBe(401);
    expect((await api.get('/api/admin/users')).status()).toBe(401);
    expect((await api.post('/api/auth/google', { data: { idToken: 'forged-e2e-token' } })).status()).toBe(verifiesEmail ? 401 : 404);
  } finally { await api.dispose(); }
});

test('SYS-02 real login, token rotation, replay rejection and logout', async ({ actor }) => {
  expect((await json(await actor.api.get('/api/auth/profile'))).email).toBe(accounts().owner.email);
  const rotated = await json(await actor.api.post('/api/auth/refresh', { data: { refreshToken: actor.tokens.refreshToken } }));
  expect(rotated.refreshToken).not.toBe(actor.tokens.refreshToken);
  expect((await actor.api.post('/api/auth/refresh', { data: { refreshToken: actor.tokens.refreshToken } })).status()).toBe(401);
  await json(await actor.api.post('/api/auth/logout', { data: { refreshToken: rotated.refreshToken } }), 204);
  expect((await actor.api.post('/api/auth/refresh', { data: { refreshToken: rotated.refreshToken } })).status()).toBe(401);
});

test('SYS-03 users cannot enter admin APIs; bootstrap admin can', async ({ actor }) => {
  expect((await actor.api.get('/api/admin/users')).status()).toBe(403);
  const admin = await login(accounts().admin);
  try { expect((await admin.api.get('/api/admin/users')).status()).toBe(200); }
  finally { await admin.api.dispose(); }
});

test('SYS-04 device ownership protects readings, commands and deletion', async ({ device }) => {
  const other = await login(accounts().other);
  try {
    const list = await json(await other.api.get('/api/devices/'));
    expect(list.some(d => d.id === device.id)).toBe(false);
    for (const suffix of ['', '/readings', '/pump-commands', '/light/status', '/alerts', '/pump-schedules'])
      expect((await other.api.get(`/api/devices/${device.id}${suffix}`)).status()).toBe(404);
    expect((await other.api.post(`/api/devices/${device.id}/pump/commands`, { data: { commandId: randomUUID(), isOn: true, durationSeconds: 3 } })).status()).toBe(404);
    expect((await other.api.delete(`/api/devices/${device.id}`)).status()).toBe(404);
    expect(device.simulator.commands).toHaveLength(0);
  } finally { await other.api.dispose(); }
});

test('SYS-05 MQTT reading persists in PostgreSQL, API and dashboard', async ({ actor, device, db }) => {
  device.simulator.stopReadings();
  await device.simulator.publishReading({ temperature: 27.123 });
  await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/readings/?take=1`)))[0]?.temperature).toBe(27.123);
  const rows = await db.query('SELECT "Temperature", "SolutionTemperature" FROM "SensorReadings" WHERE "DeviceId"=$1 ORDER BY "RecordedAt" DESC LIMIT 1', [device.id]);
  expect(rows.rows[0]).toMatchObject({ Temperature: 27.123, SolutionTemperature: 23.8 });
  const overview = await json(await actor.api.get('/api/dashboard/overview'));
  expect(overview.find(d => d.deviceId === device.id)).toMatchObject({ isOnline: true, latestReading: { temperature: 27.123 } });
});

test('SYS-06 real PostgreSQL aggregation returns MQTT samples', async ({ actor, device }) => {
  const buckets = await json(await actor.api.get(`/api/devices/${device.id}/readings/aggregated?interval=hour`));
  expect(buckets.length).toBeGreaterThan(0);
  expect(buckets.reduce((n, b) => n + b.sampleCount, 0)).toBeGreaterThan(0);
  expect(buckets.at(-1).avgTemperature).toBe(25.4);
});

test('SYS-07 pump command reaches device, ACK is stored and command is idempotent', async ({ actor, device, db }) => {
  const command = { commandId: randomUUID(), isOn: true, durationSeconds: 3 };
  await json(await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: command }), 201);
  await expect.poll(async () => (await history(actor.api, device.id)).items.find(c => c.id === command.commandId)?.acknowledgedIsOn).toBe(true);
  expect(device.simulator.commands.filter(c => c.commandId === command.commandId)).toHaveLength(1);
  await json(await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: command }));
  expect((await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: { ...command, durationSeconds: 4 } })).status()).toBe(409);
  const result = await db.query('SELECT "Status", "AcknowledgedIsOn" FROM "PumpCommands" WHERE "Id"=$1', [command.commandId]);
  expect(result.rows).toEqual([{ Status: 1, AcknowledgedIsOn: true }]);
  expect(device.simulator.commands.filter(c => c.commandId === command.commandId)).toHaveLength(1);
  await expect.poll(async () => (await db.query('SELECT "IsPumpOn" FROM "Devices" WHERE "Id"=$1', [device.id])).rows[0].IsPumpOn).toBe(false);
});

test('SYS-08 pump off is acknowledged', async ({ actor, device }) => {
  const commandId = randomUUID();
  await json(await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: { commandId, isOn: false } }), 201);
  await expect.poll(async () => (await history(actor.api, device.id)).items.find(c => c.id === commandId)?.acknowledgedIsOn).toBe(false);
  expect(device.simulator.commands.find(c => c.commandId === commandId).isOn).toBe(false);
});

test('SYS-09 device rejection is recorded as failed with reason', async ({ actor, device }) => {
  device.simulator.rejectPump = true;
  const commandId = randomUUID();
  await json(await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: { commandId, isOn: true, durationSeconds: 3 } }), 201);
  await expect.poll(async () => (await history(actor.api, device.id)).items.find(c => c.id === commandId)?.failureReason).toBe('E2E_DEVICE_REJECTED');
  expect((await history(actor.api, device.id)).items.find(c => c.id === commandId).status).toBe(2);
});

test('SYS-10 missing device ACK stays pending until a real ACK arrives', async ({ actor, device }) => {
  device.simulator.acknowledge = false;
  const commandId = randomUUID();
  await json(await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: { commandId, isOn: true, durationSeconds: 3 } }), 201);
  await expect.poll(() => device.simulator.commands.some(c => c.commandId === commandId)).toBe(true);
  const pending = (await history(actor.api, device.id)).items.find(c => c.id === commandId);
  expect(pending.status).toBe(0);
  expect(pending.acknowledgedAt).toBeNull();
  await device.simulator.publish('pump-status', { commandId, isOn: true, success: true });
  await expect.poll(async () => (await history(actor.api, device.id)).items.find(c => c.id === commandId)?.status).toBe(1);
});

test('SYS-11 light on/off travels through the broker and status API', async ({ actor, device }) => {
  for (const isOn of [true, false]) {
    const commandId = randomUUID();
    await json(await actor.api.post(`/api/devices/${device.id}/light/commands`, { data: { commandId, isOn } }), 202);
    await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/light/status`)))).toMatchObject({ isOn, isAvailable: true });
    expect(device.simulator.commands.some(c => c.commandId === commandId && c.isOn === isOn)).toBe(true);
  }
});

test('SYS-12 unsafe readings create alerts, safe readings resolve them', async ({ actor, device, db }) => {
  device.simulator.stopReadings();
  await json(await actor.api.put(`/api/devices/${device.id}/alert-settings`, { data: { highTemperatureC: 30, lowWaterLevelPercent: 25 } }));
  await device.simulator.publishReading({ temperature: 40, waterLevel: 10 });
  await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/alerts`))).items.map(a => a.type).sort()).toEqual(['HIGH_TEMPERATURE', 'LOW_WATER_LEVEL']);
  expect((await db.query('SELECT COUNT(*)::int AS count FROM "DeviceAlerts" WHERE "DeviceId"=$1 AND "ResolvedAt" IS NULL', [device.id])).rows[0].count).toBe(2);
  await device.simulator.publishReading();
  await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/alerts`))).totalCount).toBe(0);
  expect((await json(await actor.api.get(`/api/devices/${device.id}/alerts?status=resolved`))).totalCount).toBe(2);
});

test('SYS-13 pump scheduler dispatches once and device acknowledges', async ({ actor, device, db }) => {
  const schedule = await json(await actor.api.post(`/api/devices/${device.id}/pump-schedules`, { data: nearFutureSchedule() }), 201);
  await expect.poll(() => device.simulator.commands.filter(c => c.source === 'scheduled').length, { timeout: 30000 }).toBe(1);
  await expect.poll(async () => (await history(actor.api, device.id)).items.find(c => c.source === 1)?.status).toBe(1);
  const result = await db.query('SELECT "DispatchedAt" FROM "PumpScheduleOccurrences" WHERE "ScheduleId"=$1', [schedule.id]);
  expect(result.rows).toHaveLength(1);
  expect(result.rows[0].DispatchedAt).not.toBeNull();
  await json(await actor.api.delete(`/api/devices/${device.id}/pump-schedules/${schedule.id}`), 204);
});

test('SYS-14 light scheduler sends both start and stop and persists occurrence', async ({ actor, device }) => {
  const schedule = await json(await actor.api.post(`/api/devices/${device.id}/light-schedules`, { data: nearFutureSchedule() }), 201);
  await expect.poll(() => device.simulator.commands.filter(c => c.topic.endsWith('/light')).map(c => c.isOn), { timeout: 35000 }).toEqual([true, false]);
  const saved = (await json(await actor.api.get(`/api/devices/${device.id}/light-schedules`))).find(s => s.id === schedule.id);
  expect(saved.lastDispatchedOccurrenceUtc).not.toBeNull();
  expect(saved.lastTurnedOffOccurrenceUtc).toBe(saved.lastDispatchedOccurrenceUtc);
  await json(await actor.api.delete(`/api/devices/${device.id}/light-schedules/${schedule.id}`), 204);
});

test('SYS-15 device becomes offline without telemetry and recovers', async ({ actor, device }) => {
  device.simulator.stopReadings();
  await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}`))).isOnline, { timeout: 45000, intervals: [1000] }).toBe(false);
  await device.simulator.publishReading();
  await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}`))).isOnline).toBe(true);
});

test('SYS-16 user ticket, admin reply, user visibility and ownership', async ({ actor, device, db }) => {
  const { ticket } = await json(await actor.api.post('/api/tickets', { data: { subject: 'E2E pump support', message: 'Please inspect the pump', deviceId: device.id } }), 201);
  const admin = await login(accounts().admin);
  const other = await login(accounts().other);
  try {
    expect((await other.api.get(`/api/tickets/${ticket.id}`)).status()).toBe(404);
    const reply = await admin.api.post(`/api/admin/tickets/${ticket.id}/messages`, { data: { message: 'E2E support reply' } });
    expect(reply.ok()).toBe(true);
    const detail = await json(await actor.api.get(`/api/tickets/${ticket.id}`));
    expect(detail.messages.some(m => m.message === 'E2E support reply')).toBe(true);
    expect((await db.query('SELECT COUNT(*)::int AS count FROM "SupportTicketMessages" WHERE "TicketId"=$1', [ticket.id])).rows[0].count).toBe(2);
  } finally { await admin.api.dispose(); await other.api.dispose(); }
});

test('SYS-17 invalid commands and overlapping schedules do not reach MQTT', async ({ actor, device }) => {
  expect((await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: { commandId: randomUUID(), isOn: true, durationSeconds: 0 } })).status()).toBe(400);
  const data = { ...nearFutureSchedule(), isEnabled: true, startTime: new Date(Date.now() + 3600000).toISOString().slice(11, 19), durationSeconds: 30 };
  const schedule = await json(await actor.api.post(`/api/devices/${device.id}/pump-schedules`, { data }), 201);
  expect((await actor.api.post(`/api/devices/${device.id}/pump-schedules`, { data })).status()).toBe(400);
  await json(await actor.api.delete(`/api/devices/${device.id}/pump-schedules/${schedule.id}`), 204);
  expect(device.simulator.commands).toHaveLength(0);
});
