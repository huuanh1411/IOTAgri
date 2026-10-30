const mqtt = require('mqtt');
const { randomUUID } = require('node:crypto');
const normalReading = { temperature: 25.4, solutionTemperature: 23.8, humidity: 64, ph: 6.2, tds: 610, waterLevel: 82, lux: 420 };

class DeviceSimulator {
  constructor(deviceKey) {
    this.key = deviceKey;
    this.commands = [];
    this.timers = new Set();
    this.acknowledge = true;
    this.rejectPump = false;
    this.client = mqtt.connect(process.env.MQTT_URL || 'mqtt://mosquitto:1883', {
      clientId: `e2e-${randomUUID()}`, connectTimeout: 10000, reconnectPeriod: 0,
    });
  }
  async start() {
    await new Promise((resolve, reject) => {
      this.client.once('error', reject);
      this.client.once('connect', resolve);
    });
    this.client.on('error', error => { this.lastError = error.message; });
    this.client.on('message', (topic, buffer) => {
      this.handle(topic, buffer).catch(error => { this.lastError = error.message; });
    });
    await this.client.subscribeAsync(`devices/${this.key}/commands/+`, { qos: 1 });
    await this.publishReading();
    this.heartbeat = setInterval(() => this.publishReading().catch(error => { this.lastError = error.message; }), 5000);
  }
  async publishReading(values = {}) {
    await this.publish('readings', { ...normalReading, ...values });
  }
  stopReadings() { clearInterval(this.heartbeat); }
  async publish(suffix, data) {
    await this.client.publishAsync(`devices/${this.key}/${suffix}`, JSON.stringify(data), { qos: 1 });
  }
  async handle(topic, buffer) {
    const command = JSON.parse(buffer.toString());
    this.commands.push({ topic, ...command });
    if (!this.acknowledge) return;
    const kind = topic.endsWith('/pump') ? 'pump' : 'light';
    const success = !(kind === 'pump' && this.rejectPump);
    await this.publish(`${kind}-status`, { commandId: command.commandId, isOn: success && command.isOn, success, reason: success ? null : 'E2E_DEVICE_REJECTED' });
    if (kind === 'pump' && success && command.isOn && command.durationSeconds) {
      const timer = setTimeout(() => {
        this.timers.delete(timer);
        this.publish('pump-status', { isOn: false, success: true }).catch(error => { this.lastError = error.message; });
      }, command.durationSeconds * 1000);
      this.timers.add(timer);
    }
  }
  async close() {
    this.stopReadings();
    for (const timer of this.timers) clearTimeout(timer);
    await this.client.endAsync();
  }
}
module.exports = { DeviceSimulator, normalReading };
