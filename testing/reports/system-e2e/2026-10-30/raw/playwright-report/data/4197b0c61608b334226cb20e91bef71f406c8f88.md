# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: system.spec.cjs >> SYS-13 pump scheduler dispatches once and device acknowledges
- Location: tests/system.spec.cjs:127:1

# Error details

```
Error: expect(received).toBe(expected) // Object.is equality

Expected: 1
Received: 0

Call Log:
- Timeout 30000ms exceeded while waiting on the predicate
```

# Test source

```ts
  29  | 
  30  | test('SYS-03 users cannot enter admin APIs; bootstrap admin can', async ({ actor }) => {
  31  |   expect((await actor.api.get('/api/admin/users')).status()).toBe(403);
  32  |   const admin = await login(accounts().admin);
  33  |   try { expect((await admin.api.get('/api/admin/users')).status()).toBe(200); }
  34  |   finally { await admin.api.dispose(); }
  35  | });
  36  | 
  37  | test('SYS-04 device ownership protects readings, commands and deletion', async ({ device }) => {
  38  |   const other = await login(accounts().other);
  39  |   try {
  40  |     const list = await json(await other.api.get('/api/devices/'));
  41  |     expect(list.some(d => d.id === device.id)).toBe(false);
  42  |     for (const suffix of ['', '/readings', '/pump-commands', '/light/status', '/alerts', '/pump-schedules'])
  43  |       expect((await other.api.get(`/api/devices/${device.id}${suffix}`)).status()).toBe(404);
  44  |     expect((await other.api.post(`/api/devices/${device.id}/pump/commands`, { data: { commandId: randomUUID(), isOn: true, durationSeconds: 3 } })).status()).toBe(404);
  45  |     expect((await other.api.delete(`/api/devices/${device.id}`)).status()).toBe(404);
  46  |     expect(device.simulator.commands).toHaveLength(0);
  47  |   } finally { await other.api.dispose(); }
  48  | });
  49  | 
  50  | test('SYS-05 MQTT reading persists in PostgreSQL, API and dashboard', async ({ actor, device, db }) => {
  51  |   device.simulator.stopReadings();
  52  |   await device.simulator.publishReading({ temperature: 27.123 });
  53  |   await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/readings/?take=1`)))[0]?.temperature).toBe(27.123);
  54  |   const rows = await db.query('SELECT "Temperature", "SolutionTemperature" FROM "SensorReadings" WHERE "DeviceId"=$1 ORDER BY "RecordedAt" DESC LIMIT 1', [device.id]);
  55  |   expect(rows.rows[0]).toMatchObject({ Temperature: 27.123, SolutionTemperature: 23.8 });
  56  |   const overview = await json(await actor.api.get('/api/dashboard/overview'));
  57  |   expect(overview.find(d => d.deviceId === device.id)).toMatchObject({ isOnline: true, latestReading: { temperature: 27.123 } });
  58  | });
  59  | 
  60  | test('SYS-06 real PostgreSQL aggregation returns MQTT samples', async ({ actor, device }) => {
  61  |   const buckets = await json(await actor.api.get(`/api/devices/${device.id}/readings/aggregated?interval=hour`));
  62  |   expect(buckets.length).toBeGreaterThan(0);
  63  |   expect(buckets.reduce((n, b) => n + b.sampleCount, 0)).toBeGreaterThan(0);
  64  |   expect(buckets.at(-1).avgTemperature).toBe(25.4);
  65  | });
  66  | 
  67  | test('SYS-07 pump command reaches device, ACK is stored and command is idempotent', async ({ actor, device, db }) => {
  68  |   const command = { commandId: randomUUID(), isOn: true, durationSeconds: 3 };
  69  |   await json(await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: command }), 201);
  70  |   await expect.poll(async () => (await history(actor.api, device.id)).items.find(c => c.id === command.commandId)?.acknowledgedIsOn).toBe(true);
  71  |   expect(device.simulator.commands.filter(c => c.commandId === command.commandId)).toHaveLength(1);
  72  |   await json(await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: command }));
  73  |   expect((await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: { ...command, durationSeconds: 4 } })).status()).toBe(409);
  74  |   const result = await db.query('SELECT "Status", "AcknowledgedIsOn" FROM "PumpCommands" WHERE "Id"=$1', [command.commandId]);
  75  |   expect(result.rows).toEqual([{ Status: 1, AcknowledgedIsOn: true }]);
  76  |   expect(device.simulator.commands.filter(c => c.commandId === command.commandId)).toHaveLength(1);
  77  |   await expect.poll(async () => (await db.query('SELECT "IsPumpOn" FROM "Devices" WHERE "Id"=$1', [device.id])).rows[0].IsPumpOn).toBe(false);
  78  | });
  79  | 
  80  | test('SYS-08 pump off is acknowledged', async ({ actor, device }) => {
  81  |   const commandId = randomUUID();
  82  |   await json(await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: { commandId, isOn: false } }), 201);
  83  |   await expect.poll(async () => (await history(actor.api, device.id)).items.find(c => c.id === commandId)?.acknowledgedIsOn).toBe(false);
  84  |   expect(device.simulator.commands.find(c => c.commandId === commandId).isOn).toBe(false);
  85  | });
  86  | 
  87  | test('SYS-09 device rejection is recorded as failed with reason', async ({ actor, device }) => {
  88  |   device.simulator.rejectPump = true;
  89  |   const commandId = randomUUID();
  90  |   await json(await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: { commandId, isOn: true, durationSeconds: 3 } }), 201);
  91  |   await expect.poll(async () => (await history(actor.api, device.id)).items.find(c => c.id === commandId)?.failureReason).toBe('E2E_DEVICE_REJECTED');
  92  |   expect((await history(actor.api, device.id)).items.find(c => c.id === commandId).status).toBe(2);
  93  | });
  94  | 
  95  | test('SYS-10 missing device ACK stays pending until a real ACK arrives', async ({ actor, device }) => {
  96  |   device.simulator.acknowledge = false;
  97  |   const commandId = randomUUID();
  98  |   await json(await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: { commandId, isOn: true, durationSeconds: 3 } }), 201);
  99  |   await expect.poll(() => device.simulator.commands.some(c => c.commandId === commandId)).toBe(true);
  100 |   const pending = (await history(actor.api, device.id)).items.find(c => c.id === commandId);
  101 |   expect(pending.status).toBe(0);
  102 |   expect(pending.acknowledgedAt).toBeNull();
  103 |   await device.simulator.publish('pump-status', { commandId, isOn: true, success: true });
  104 |   await expect.poll(async () => (await history(actor.api, device.id)).items.find(c => c.id === commandId)?.status).toBe(1);
  105 | });
  106 | 
  107 | test('SYS-11 light on/off travels through the broker and status API', async ({ actor, device }) => {
  108 |   for (const isOn of [true, false]) {
  109 |     const commandId = randomUUID();
  110 |     await json(await actor.api.post(`/api/devices/${device.id}/light/commands`, { data: { commandId, isOn } }), 202);
  111 |     await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/light/status`)))).toMatchObject({ isOn, isAvailable: true });
  112 |     expect(device.simulator.commands.some(c => c.commandId === commandId && c.isOn === isOn)).toBe(true);
  113 |   }
  114 | });
  115 | 
  116 | test('SYS-12 unsafe readings create alerts, safe readings resolve them', async ({ actor, device, db }) => {
  117 |   device.simulator.stopReadings();
  118 |   await json(await actor.api.put(`/api/devices/${device.id}/alert-settings`, { data: { highTemperatureC: 30, lowWaterLevelPercent: 25 } }));
  119 |   await device.simulator.publishReading({ temperature: 40, waterLevel: 10 });
  120 |   await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/alerts`))).items.map(a => a.type).sort()).toEqual(['HIGH_TEMPERATURE', 'LOW_WATER_LEVEL']);
  121 |   expect((await db.query('SELECT COUNT(*)::int AS count FROM "DeviceAlerts" WHERE "DeviceId"=$1 AND "ResolvedAt" IS NULL', [device.id])).rows[0].count).toBe(2);
  122 |   await device.simulator.publishReading();
  123 |   await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}/alerts`))).totalCount).toBe(0);
  124 |   expect((await json(await actor.api.get(`/api/devices/${device.id}/alerts?status=resolved`))).totalCount).toBe(2);
  125 | });
  126 | 
  127 | test('SYS-13 pump scheduler dispatches once and device acknowledges', async ({ actor, device, db }) => {
  128 |   const schedule = await json(await actor.api.post(`/api/devices/${device.id}/pump-schedules`, { data: nearFutureSchedule() }), 201);
> 129 |   await expect.poll(() => device.simulator.commands.filter(c => c.source === 'scheduled').length, { timeout: 30000 }).toBe(1);
      |                                                                                                                       ^ Error: expect(received).toBe(expected) // Object.is equality
  130 |   await expect.poll(async () => (await history(actor.api, device.id)).items.find(c => c.source === 1)?.status).toBe(1);
  131 |   const result = await db.query('SELECT "DispatchedAt" FROM "PumpScheduleOccurrences" WHERE "ScheduleId"=$1', [schedule.id]);
  132 |   expect(result.rows).toHaveLength(1);
  133 |   expect(result.rows[0].DispatchedAt).not.toBeNull();
  134 |   await json(await actor.api.delete(`/api/devices/${device.id}/pump-schedules/${schedule.id}`), 204);
  135 | });
  136 | 
  137 | test('SYS-14 light scheduler sends both start and stop and persists occurrence', async ({ actor, device }) => {
  138 |   const schedule = await json(await actor.api.post(`/api/devices/${device.id}/light-schedules`, { data: nearFutureSchedule() }), 201);
  139 |   await expect.poll(() => device.simulator.commands.filter(c => c.topic.endsWith('/light')).map(c => c.isOn), { timeout: 35000 }).toEqual([true, false]);
  140 |   const saved = (await json(await actor.api.get(`/api/devices/${device.id}/light-schedules`))).find(s => s.id === schedule.id);
  141 |   expect(saved.lastDispatchedOccurrenceUtc).not.toBeNull();
  142 |   expect(saved.lastTurnedOffOccurrenceUtc).toBe(saved.lastDispatchedOccurrenceUtc);
  143 |   await json(await actor.api.delete(`/api/devices/${device.id}/light-schedules/${schedule.id}`), 204);
  144 | });
  145 | 
  146 | test('SYS-15 device becomes offline without telemetry and recovers', async ({ actor, device }) => {
  147 |   device.simulator.stopReadings();
  148 |   await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}`))).isOnline, { timeout: 45000, intervals: [1000] }).toBe(false);
  149 |   await device.simulator.publishReading();
  150 |   await expect.poll(async () => (await json(await actor.api.get(`/api/devices/${device.id}`))).isOnline).toBe(true);
  151 | });
  152 | 
  153 | test('SYS-16 user ticket, admin reply, user visibility and ownership', async ({ actor, device, db }) => {
  154 |   const { ticket } = await json(await actor.api.post('/api/tickets', { data: { subject: 'E2E pump support', message: 'Please inspect the pump', deviceId: device.id } }), 201);
  155 |   const admin = await login(accounts().admin);
  156 |   const other = await login(accounts().other);
  157 |   try {
  158 |     expect((await other.api.get(`/api/tickets/${ticket.id}`)).status()).toBe(404);
  159 |     const reply = await admin.api.post(`/api/admin/tickets/${ticket.id}/messages`, { data: { message: 'E2E support reply' } });
  160 |     expect(reply.ok()).toBe(true);
  161 |     const detail = await json(await actor.api.get(`/api/tickets/${ticket.id}`));
  162 |     expect(detail.messages.some(m => m.message === 'E2E support reply')).toBe(true);
  163 |     expect((await db.query('SELECT COUNT(*)::int AS count FROM "SupportTicketMessages" WHERE "TicketId"=$1', [ticket.id])).rows[0].count).toBe(2);
  164 |   } finally { await admin.api.dispose(); await other.api.dispose(); }
  165 | });
  166 | 
  167 | test('SYS-17 invalid commands and overlapping schedules do not reach MQTT', async ({ actor, device }) => {
  168 |   expect((await actor.api.post(`/api/devices/${device.id}/pump/commands`, { data: { commandId: randomUUID(), isOn: true, durationSeconds: 0 } })).status()).toBe(400);
  169 |   const data = { ...nearFutureSchedule(), isEnabled: true, startTime: new Date(Date.now() + 3600000).toISOString().slice(11, 19), durationSeconds: 30 };
  170 |   const schedule = await json(await actor.api.post(`/api/devices/${device.id}/pump-schedules`, { data }), 201);
  171 |   expect((await actor.api.post(`/api/devices/${device.id}/pump-schedules`, { data })).status()).toBe(400);
  172 |   await json(await actor.api.delete(`/api/devices/${device.id}/pump-schedules/${schedule.id}`), 204);
  173 |   expect(device.simulator.commands).toHaveLength(0);
  174 | });
  175 | 
```