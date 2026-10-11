#include <Adafruit_AHTX0.h>
#include <DNSServer.h>
#include <DallasTemperature.h>
#include <HTTPClient.h>
#include <OneWire.h>
#include <Preferences.h>
#include <PubSubClient.h>
#include <WebServer.h>
#include <WiFi.h>
#include <Wire.h>

// AEROGREEN / MKE-K01 ESP32-S3 N16 pin map.
// Both relay inputs must be driven through an NPN transistor. At the ESP pin,
// HIGH turns the transistor/relay on and LOW turns it off.
constexpr uint8_t TDS_PIN = 1;
constexpr uint8_t WATER_TRIG_PIN = 4;
constexpr uint8_t WATER_ECHO_PIN = 5;
constexpr uint8_t DS18B20_PIN = 6;
constexpr uint8_t I2C_SDA_PIN = 8;
constexpr uint8_t I2C_SCL_PIN = 9;
constexpr uint8_t PUMP_RELAY_PIN = 10;
constexpr uint8_t LIGHT_RELAY_PIN = 11;

// Measure these two values on the installed tank before enabling the pump.
constexpr float TANK_HEIGHT_CM = 30.0f;
constexpr float LOW_WATER_THRESHOLD_PERCENT = 20.0f;
constexpr float TDS_CALIBRATION_FACTOR = 1.0f;
constexpr float ADC_REFERENCE_V = 3.3f;
constexpr uint16_t ADC_MAX_VALUE = 4095;
constexpr uint16_t MAX_PUMP_DURATION_SECONDS = 600;

constexpr unsigned long ULTRASONIC_TIMEOUT_US = 30000;
constexpr unsigned long WATER_LEVEL_INTERVAL_MS = 500;
constexpr unsigned long AIR_SENSOR_INTERVAL_MS = 2000;
constexpr unsigned long DS18B20_CONVERSION_MS = 750;
constexpr unsigned long TDS_SAMPLE_INTERVAL_MS = 40;
constexpr unsigned long TELEMETRY_INTERVAL_MS = 10000;
constexpr unsigned long WIFI_RECONNECT_INTERVAL_MS = 10000;
constexpr unsigned long MQTT_RECONNECT_INTERVAL_MS = 5000;
constexpr size_t MQTT_BUFFER_BYTES = 768;
constexpr size_t MAX_COMMAND_PAYLOAD_BYTES = 512;
constexpr uint8_t TDS_SAMPLE_COUNT = 30;

struct SensorSnapshot {
  float airTemperatureC = NAN;
  float airHumidityPercent = NAN;
  float solutionTemperatureC = NAN;
  float tdsPpm = NAN;
  float waterDistanceCm = NAN;
  float waterLevelCm = NAN;
  float waterLevelPercent = NAN;
  bool airValid = false;
  bool solutionTemperatureValid = false;
  bool tdsValid = false;
  bool waterLevelValid = false;
  bool lowWater = true;
};

struct LastCommand {
  String id;
  bool requestedState = false;
  uint32_t durationSeconds = 0;
  bool success = false;
  String reason;
};

DNSServer dns;
WebServer server(80);
Preferences settings;
WiFiClient network;
PubSubClient mqtt(network);
Adafruit_AHTX0 dht20;
OneWire oneWire(DS18B20_PIN);
DallasTemperature ds18b20(&oneWire);

SensorSnapshot sensors;
LastCommand lastPumpCommand;
LastCommand lastLightCommand;

String apiUrl;
String mqttHost;
String deviceKey;
String savedSsid;
String savedPassword;
String readingsTopic;
String pumpCommandTopic;
String pumpStatusTopic;
String lightCommandTopic;
String lightStatusTopic;
int mqttPort = 0;
bool setupMode = false;
bool dht20Available = false;
bool pumpOn = false;
bool lightOn = false;
bool pumpTimerActive = false;
bool ds18b20ConversionPending = false;
uint32_t pumpOffAtMs = 0;
uint32_t ds18b20RequestedAtMs = 0;
uint32_t lastWaterLevelReadMs = 0;
uint32_t lastAirReadMs = 0;
uint32_t lastTdsSampleMs = 0;
uint32_t lastTelemetryMs = 0;
uint32_t lastWifiReconnectMs = 0;
uint32_t lastMqttReconnectMs = 0;
uint16_t tdsSamples[TDS_SAMPLE_COUNT] = {};
uint8_t tdsSampleIndex = 0;
uint8_t tdsSamplesCollected = 0;

bool elapsed(uint32_t now, uint32_t since, uint32_t interval) {
  return static_cast<uint32_t>(now - since) >= interval;
}

bool deadlineReached(uint32_t now, uint32_t deadline) {
  return static_cast<int32_t>(now - deadline) >= 0;
}

String jsonNumber(float value, uint8_t decimals = 1) {
  if (!isfinite(value)) return "null";

  char formatted[24];
  snprintf(formatted, sizeof(formatted), "%.*f", decimals, static_cast<double>(value));
  return formatted;
}

String hardwareId() {
  const uint64_t id = ESP.getEfuseMac();
  char value[17];
  snprintf(value, sizeof(value), "%08lX%08lX",
           static_cast<unsigned long>(id >> 32), static_cast<unsigned long>(id));
  return value;
}

int jsonValueStart(const String& json, const char* key) {
  const String marker = String("\"") + key + "\"";
  const int keyStart = json.indexOf(marker);
  if (keyStart < 0) return -1;

  int valueStart = json.indexOf(':', keyStart + marker.length());
  if (valueStart < 0) return -1;
  valueStart++;
  while (valueStart < static_cast<int>(json.length()) && isspace(static_cast<unsigned char>(json[valueStart]))) {
    valueStart++;
  }
  return valueStart;
}

String jsonString(const String& json, const char* key) {
  const int start = jsonValueStart(json, key);
  if (start < 0 || json[start] != '"') return "";
  const int end = json.indexOf('"', start + 1);
  return end < 0 ? "" : json.substring(start + 1, end);
}

int jsonInt(const String& json, const char* key) {
  const int start = jsonValueStart(json, key);
  return start < 0 ? 0 : json.substring(start).toInt();
}

bool jsonBool(const String& json, const char* key, bool& value) {
  const int start = jsonValueStart(json, key);
  if (start < 0) return false;
  if (json.startsWith("true", start)) {
    value = true;
    return true;
  }
  if (json.startsWith("false", start)) {
    value = false;
    return true;
  }
  return false;
}

bool jsonUnsigned(const String& json, const char* key, uint32_t& value) {
  const int start = jsonValueStart(json, key);
  if (start < 0 || json.startsWith("null", start)) return false;

  int end = start;
  while (end < static_cast<int>(json.length()) && isdigit(static_cast<unsigned char>(json[end]))) end++;
  if (end == start) return false;
  value = static_cast<uint32_t>(strtoul(json.substring(start, end).c_str(), nullptr, 10));
  return true;
}

void configureMqttTopics() {
  const String prefix = "devices/" + deviceKey;
  readingsTopic = prefix + "/readings";
  pumpCommandTopic = prefix + "/commands/pump";
  pumpStatusTopic = prefix + "/pump-status";
  // Additive firmware extension. The current backend only owns the pump topics.
  lightCommandTopic = prefix + "/commands/light";
  lightStatusTopic = prefix + "/light-status";
}

void setPumpOutput(bool on) {
  pumpOn = on;
  digitalWrite(PUMP_RELAY_PIN, on ? HIGH : LOW);
  if (!on) pumpTimerActive = false;
}

void setLightOutput(bool on) {
  lightOn = on;
  digitalWrite(LIGHT_RELAY_PIN, on ? HIGH : LOW);
}

const char* waterSafetyReason() {
  if (!sensors.waterLevelValid) return "WATER_LEVEL_SENSOR_INVALID";
  if (sensors.lowWater) return "LOW_WATER";
  return nullptr;
}

void publishPumpStatus(const String& commandId, bool success, const char* reason) {
  if (!mqtt.connected()) return;

  String payload = "{";
  if (!commandId.isEmpty()) {
    payload += "\"commandId\":\"" + commandId + "\",";
  }
  payload += "\"isOn\":";
  payload += pumpOn ? "true" : "false";
  payload += ",\"success\":";
  payload += success ? "true" : "false";
  if (reason != nullptr) payload += ",\"reason\":\"" + String(reason) + "\"";
  if (pumpTimerActive) {
    const uint32_t now = millis();
    const uint32_t remainingMs = deadlineReached(now, pumpOffAtMs) ? 0 : pumpOffAtMs - now;
    payload += ",\"remainingSeconds\":" + String((remainingMs + 999) / 1000);
  }
  payload += "}";
  mqtt.publish(pumpStatusTopic.c_str(), payload.c_str(), true);
}

void publishLightStatus(const String& commandId, bool success, const char* reason) {
  if (!mqtt.connected()) return;

  String payload = "{";
  if (!commandId.isEmpty()) payload += "\"commandId\":\"" + commandId + "\",";
  payload += "\"isOn\":";
  payload += lightOn ? "true" : "false";
  payload += ",\"success\":";
  payload += success ? "true" : "false";
  if (reason != nullptr) payload += ",\"reason\":\"" + String(reason) + "\"";
  payload += "}";
  mqtt.publish(lightStatusTopic.c_str(), payload.c_str(), true);
}

void rememberCommand(LastCommand& record, const String& id, bool requestedState,
                     uint32_t durationSeconds, bool success, const char* reason) {
  record.id = id;
  record.requestedState = requestedState;
  record.durationSeconds = durationSeconds;
  record.success = success;
  record.reason = reason == nullptr ? "" : reason;
}

void handlePumpCommand(const String& payload) {
  const String commandId = jsonString(payload, "commandId");
  bool requestedOn = false;
  uint32_t durationSeconds = 0;
  const bool hasState = jsonBool(payload, "isOn", requestedOn);
  const bool hasDuration = jsonUnsigned(payload, "durationSeconds", durationSeconds);

  if (commandId.isEmpty() || commandId.length() > 64 || !hasState) {
    publishPumpStatus(commandId, false, "INVALID_COMMAND");
    return;
  }

  if (lastPumpCommand.id == commandId) {
    if (lastPumpCommand.requestedState != requestedOn ||
        (requestedOn && lastPumpCommand.durationSeconds != durationSeconds)) {
      publishPumpStatus(commandId, false, "COMMAND_ID_CONFLICT");
      return;
    }
    publishPumpStatus(commandId, lastPumpCommand.success,
                      lastPumpCommand.reason.isEmpty() ? nullptr : lastPumpCommand.reason.c_str());
    return;
  }

  if (requestedOn && (!hasDuration || durationSeconds == 0 || durationSeconds > MAX_PUMP_DURATION_SECONDS)) {
    rememberCommand(lastPumpCommand, commandId, requestedOn, durationSeconds, false, "INVALID_DURATION");
    publishPumpStatus(commandId, false, "INVALID_DURATION");
    return;
  }

  const char* safetyReason = requestedOn ? waterSafetyReason() : nullptr;
  if (safetyReason != nullptr) {
    setPumpOutput(false);
    rememberCommand(lastPumpCommand, commandId, requestedOn, durationSeconds, false, safetyReason);
    publishPumpStatus(commandId, false, safetyReason);
    return;
  }

  setPumpOutput(requestedOn);
  if (requestedOn) {
    pumpTimerActive = true;
    pumpOffAtMs = millis() + durationSeconds * 1000UL;
  }
  rememberCommand(lastPumpCommand, commandId, requestedOn, durationSeconds, true, nullptr);
  publishPumpStatus(commandId, true, nullptr);
}

void handleLightCommand(const String& payload) {
  const String commandId = jsonString(payload, "commandId");
  bool requestedOn = false;
  if (commandId.isEmpty() || commandId.length() > 64 || !jsonBool(payload, "isOn", requestedOn)) {
    publishLightStatus(commandId, false, "INVALID_COMMAND");
    return;
  }

  if (lastLightCommand.id == commandId) {
    if (lastLightCommand.requestedState != requestedOn) {
      publishLightStatus(commandId, false, "COMMAND_ID_CONFLICT");
      return;
    }
    publishLightStatus(commandId, lastLightCommand.success,
                       lastLightCommand.reason.isEmpty() ? nullptr : lastLightCommand.reason.c_str());
    return;
  }

  setLightOutput(requestedOn);
  rememberCommand(lastLightCommand, commandId, requestedOn, 0, true, nullptr);
  publishLightStatus(commandId, true, nullptr);
}

void onMqttMessage(char* topic, byte* payloadBytes, unsigned int length) {
  if (length == 0 || length > MAX_COMMAND_PAYLOAD_BYTES) {
    Serial.println("Ignored empty or oversized MQTT command");
    return;
  }

  String payload;
  payload.reserve(length + 1);
  for (unsigned int i = 0; i < length; i++) payload += static_cast<char>(payloadBytes[i]);

  const String incomingTopic(topic);
  if (incomingTopic == pumpCommandTopic) handlePumpCommand(payload);
  else if (incomingTopic == lightCommandTopic) handleLightCommand(payload);
}

bool connectWifiBlocking(const String& ssid, const String& password) {
  Serial.printf("Connecting to Wi-Fi '%s'\n", ssid.c_str());
  WiFi.begin(ssid.c_str(), password.c_str());
  for (int i = 0; i < 40 && WiFi.status() != WL_CONNECTED; i++) delay(500);
  Serial.printf("Wi-Fi result: status=%d ip=%s\n", static_cast<int>(WiFi.status()),
                WiFi.localIP().toString().c_str());
  return WiFi.status() == WL_CONNECTED;
}

bool claimDevice(const String& code) {
  HTTPClient http;
  http.begin(apiUrl + "/api/device-provisioning/claims");
  http.addHeader("Content-Type", "application/json");
  const String body = "{\"code\":\"" + code + "\",\"hardwareId\":\"" + hardwareId() + "\"}";
  const int status = http.POST(body);
  const String response = http.getString();
  http.end();
  if (status != HTTP_CODE_OK) return false;

  bool useTls = false;
  if (!jsonBool(response, "useTls", useTls) || useTls) return false;
  deviceKey = jsonString(response, "deviceKey");
  mqttHost = jsonString(response, "mqttHost");
  mqttPort = jsonInt(response, "mqttPort");
  configureMqttTopics();
  return !deviceKey.isEmpty() && !mqttHost.isEmpty() && mqttPort > 0;
}

void saveSettings(const String& ssid, const String& password) {
  settings.begin("iotagri", false);
  settings.putString("ssid", ssid);
  settings.putString("pass", password);
  settings.putString("api", apiUrl);
  settings.putString("host", mqttHost);
  settings.putString("key", deviceKey);
  settings.putInt("port", mqttPort);
  settings.end();
}

String jsonEscape(const String& value) {
  String escaped;
  escaped.reserve(value.length() + 8);
  for (size_t i = 0; i < value.length(); i++) {
    const uint8_t character = static_cast<uint8_t>(value[i]);
    switch (character) {
      case '"': escaped += "\\\""; break;
      case '\\': escaped += "\\\\"; break;
      case '\b': escaped += "\\b"; break;
      case '\f': escaped += "\\f"; break;
      case '\n': escaped += "\\n"; break;
      case '\r': escaped += "\\r"; break;
      case '\t': escaped += "\\t"; break;
      default:
        if (character < 0x20) {
          char encoded[7];
          snprintf(encoded, sizeof(encoded), "\\u%04X", character);
          escaped += encoded;
        } else {
          escaped += static_cast<char>(character);
        }
    }
  }
  return escaped;
}

void addSetupCorsHeaders() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.sendHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  server.sendHeader("Access-Control-Allow-Headers", "Content-Type");
  server.sendHeader("Access-Control-Allow-Private-Network", "true");
  server.sendHeader("Cache-Control", "no-store");
}

void sendSetupJson(int status, const String& body) {
  addSetupCorsHeaders();
  server.send(status, "application/json; charset=utf-8", body);
}

void handleSetupOptions() {
  addSetupCorsHeaders();
  server.send(204, "text/plain", "");
}

void handleSetupStatus() {
  sendSetupJson(200, "{\"hardwareId\":\"" + jsonEscape(hardwareId()) +
                         "\",\"setupMode\":true,\"accessPoint\":\"IOTAgri-Setup\"}");
}

void handleNetworkScan() {
  const int count = WiFi.scanNetworks(false, true);
  if (count < 0) {
    sendSetupJson(500, "{\"error\":\"ESP could not scan Wi-Fi networks.\"}");
    return;
  }

  String response = "{\"networks\":[";
  for (int i = 0; i < count; i++) {
    if (i > 0) response += ',';
    response += "{\"ssid\":\"" + jsonEscape(WiFi.SSID(i)) + "\",\"rssi\":" +
                String(WiFi.RSSI(i)) + "}";
  }
  response += "]}";
  WiFi.scanDelete();
  sendSetupJson(200, response);
}

void handleProvisionRequest(bool jsonResponse) {
  const String ssid = server.arg("wifi");
  const String password = server.arg("pass");
  apiUrl = server.arg("api");
  const String code = server.arg("code");
  apiUrl.trim();

  if (ssid.isEmpty() || apiUrl.isEmpty() || code.isEmpty()) {
    if (jsonResponse) sendSetupJson(400, "{\"error\":\"Missing Wi-Fi, backend URL, or claim code.\"}");
    else server.send(400, "text/plain", "Missing Wi-Fi, backend URL, or claim code.");
    return;
  }

  if (!connectWifiBlocking(ssid, password)) {
    const String message = "Wi-Fi connection failed. Check SSID, password, and 2.4 GHz availability.";
    if (jsonResponse) {
      sendSetupJson(400, "{\"error\":\"" + message + "\",\"wifiStatus\":" +
                             String(static_cast<int>(WiFi.status())) + "}");
    } else {
      server.send(400, "text/plain", message);
    }
    return;
  }

  if (!claimDevice(code)) {
    const String message = "Claim failed. Check the code, backend URL, and MQTT TLS setting.";
    if (jsonResponse) sendSetupJson(400, "{\"error\":\"" + message + "\"}");
    else server.send(400, "text/plain", message);
    return;
  }

  saveSettings(ssid, password);
  if (jsonResponse) sendSetupJson(200, "{\"ok\":true,\"message\":\"Connected. Device will restart now.\"}");
  else server.send(200, "text/plain", "Connected. Device will restart now.");
  delay(1000);
  ESP.restart();
}

void startPortal() {
  setupMode = true;
  setPumpOutput(false);
  setLightOutput(false);
  WiFi.mode(WIFI_AP_STA);
  WiFi.softAP("IOTAgri-Setup");
  dns.start(53, "*", WiFi.softAPIP());
  server.on("/", HTTP_GET, [] {
    server.send(200, "text/html", R"html(
      <h2>IOTAgri device setup</h2><form method='post' action='/save'>
      Wi-Fi name <input name='wifi' required><br>Wi-Fi password <input name='pass' type='password'><br>
      Backend URL <input name='api' value='http://192.168.1.100:8080' required><br>
      Claim code <input name='code' required><br><button>Connect</button></form>)html");
  });
  server.on("/save", HTTP_POST, [] { handleProvisionRequest(false); });
  server.on("/api/status", HTTP_GET, handleSetupStatus);
  server.on("/api/status", HTTP_OPTIONS, handleSetupOptions);
  server.on("/api/networks", HTTP_GET, handleNetworkScan);
  server.on("/api/networks", HTTP_OPTIONS, handleSetupOptions);
  server.on("/api/provision", HTTP_POST, [] { handleProvisionRequest(true); });
  server.on("/api/provision", HTTP_OPTIONS, handleSetupOptions);
  server.begin();
  Serial.printf("Setup Wi-Fi: IOTAgri-Setup; open http://%s\n", WiFi.softAPIP().toString().c_str());
}

void serviceWifi(uint32_t now) {
  if (setupMode || WiFi.status() == WL_CONNECTED || savedSsid.isEmpty()) return;
  if (!elapsed(now, lastWifiReconnectMs, WIFI_RECONNECT_INTERVAL_MS)) return;

  lastWifiReconnectMs = now;
  Serial.println("Wi-Fi disconnected; reconnecting");
  WiFi.disconnect();
  WiFi.begin(savedSsid.c_str(), savedPassword.c_str());
}

void serviceMqtt(uint32_t now) {
  if (setupMode || WiFi.status() != WL_CONNECTED) return;
  if (mqtt.connected()) {
    mqtt.loop();
    return;
  }
  if (!elapsed(now, lastMqttReconnectMs, MQTT_RECONNECT_INTERVAL_MS)) return;

  lastMqttReconnectMs = now;
  char clientId[32];
  snprintf(clientId, sizeof(clientId), "iotagr-%s", hardwareId().c_str());
  if (!mqtt.connect(clientId)) {
    Serial.printf("MQTT retry later (%d)\n", mqtt.state());
    return;
  }

  mqtt.subscribe(pumpCommandTopic.c_str(), 1);
  mqtt.subscribe(lightCommandTopic.c_str(), 1);
  Serial.println("MQTT connected and command topics subscribed");
  publishPumpStatus("", true, "STATE_SYNC");
  publishLightStatus("", true, "STATE_SYNC");
}

void requestWaterTemperature(uint32_t now) {
  ds18b20.requestTemperatures();
  ds18b20RequestedAtMs = now;
  ds18b20ConversionPending = true;
}

void serviceWaterTemperature(uint32_t now) {
  if (!ds18b20ConversionPending) {
    requestWaterTemperature(now);
    return;
  }
  if (!elapsed(now, ds18b20RequestedAtMs, DS18B20_CONVERSION_MS)) return;

  const float value = ds18b20.getTempCByIndex(0);
  sensors.solutionTemperatureValid = isfinite(value) && value != DEVICE_DISCONNECTED_C && value >= 0.0f && value <= 60.0f;
  sensors.solutionTemperatureC = sensors.solutionTemperatureValid ? value : NAN;
  requestWaterTemperature(now);
}

void serviceAirSensor(uint32_t now) {
  if (!elapsed(now, lastAirReadMs, AIR_SENSOR_INTERVAL_MS)) return;
  lastAirReadMs = now;
  if (!dht20Available) {
    sensors.airValid = false;
    sensors.airTemperatureC = NAN;
    sensors.airHumidityPercent = NAN;
    return;
  }

  sensors_event_t humidity;
  sensors_event_t temperature;
  dht20.getEvent(&humidity, &temperature);
  sensors.airValid = isfinite(temperature.temperature) && isfinite(humidity.relative_humidity) &&
                     humidity.relative_humidity >= 0.0f && humidity.relative_humidity <= 100.0f;
  sensors.airTemperatureC = sensors.airValid ? temperature.temperature : NAN;
  sensors.airHumidityPercent = sensors.airValid ? humidity.relative_humidity : NAN;
}

void enforcePumpSafety() {
  const char* reason = waterSafetyReason();
  if (!pumpOn || reason == nullptr) return;

  setPumpOutput(false);
  Serial.printf("Pump stopped by local safety: %s\n", reason);
  publishPumpStatus("", false, reason);
}

void serviceWaterLevel(uint32_t now) {
  if (!elapsed(now, lastWaterLevelReadMs, WATER_LEVEL_INTERVAL_MS)) return;
  lastWaterLevelReadMs = now;

  digitalWrite(WATER_TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(WATER_TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(WATER_TRIG_PIN, LOW);

  const unsigned long duration = pulseIn(WATER_ECHO_PIN, HIGH, ULTRASONIC_TIMEOUT_US);
  if (duration == 0 || TANK_HEIGHT_CM <= 0.0f) {
    sensors.waterLevelValid = false;
    sensors.waterDistanceCm = NAN;
    sensors.waterLevelCm = NAN;
    sensors.waterLevelPercent = NAN;
    sensors.lowWater = true;
    enforcePumpSafety();
    return;
  }

  const float distanceCm = duration * 0.0343f / 2.0f;
  const float levelCm = constrain(TANK_HEIGHT_CM - distanceCm, 0.0f, TANK_HEIGHT_CM);
  const float levelPercent = levelCm * 100.0f / TANK_HEIGHT_CM;
  sensors.waterLevelValid = isfinite(distanceCm);
  sensors.waterDistanceCm = sensors.waterLevelValid ? distanceCm : NAN;
  sensors.waterLevelCm = sensors.waterLevelValid ? levelCm : NAN;
  sensors.waterLevelPercent = sensors.waterLevelValid ? levelPercent : NAN;
  sensors.lowWater = !sensors.waterLevelValid || levelPercent <= LOW_WATER_THRESHOLD_PERCENT;
  enforcePumpSafety();
}

void serviceTds(uint32_t now) {
  if (!elapsed(now, lastTdsSampleMs, TDS_SAMPLE_INTERVAL_MS)) return;
  lastTdsSampleMs = now;
  tdsSamples[tdsSampleIndex] = analogRead(TDS_PIN);
  tdsSampleIndex = (tdsSampleIndex + 1) % TDS_SAMPLE_COUNT;
  if (tdsSamplesCollected < TDS_SAMPLE_COUNT) tdsSamplesCollected++;

  if (tdsSamplesCollected < 10 || !sensors.solutionTemperatureValid) {
    sensors.tdsValid = false;
    sensors.tdsPpm = NAN;
    return;
  }

  uint32_t total = 0;
  for (uint8_t i = 0; i < tdsSamplesCollected; i++) total += tdsSamples[i];
  const float averageRaw = static_cast<float>(total) / tdsSamplesCollected;
  const float voltage = averageRaw * ADC_REFERENCE_V / ADC_MAX_VALUE;
  const float compensationCoefficient = 1.0f + 0.02f * (sensors.solutionTemperatureC - 25.0f);
  if (compensationCoefficient <= 0.0f) {
    sensors.tdsValid = false;
    sensors.tdsPpm = NAN;
    return;
  }

  const float compensationVoltage = voltage / compensationCoefficient;
  float tds = (133.42f * compensationVoltage * compensationVoltage * compensationVoltage -
               255.86f * compensationVoltage * compensationVoltage +
               857.39f * compensationVoltage) * 0.5f * TDS_CALIBRATION_FACTOR;
  if (tds < 0.0f) tds = 0.0f;
  sensors.tdsValid = isfinite(tds);
  sensors.tdsPpm = sensors.tdsValid ? tds : NAN;
}

void servicePumpTimer(uint32_t now) {
  if (!pumpTimerActive || !deadlineReached(now, pumpOffAtMs)) return;
  setPumpOutput(false);
  Serial.println("Pump duration completed; pump is OFF");
  publishPumpStatus("", true, "DURATION_COMPLETE");
}

void publishTelemetry(uint32_t now) {
  if (!mqtt.connected() || !elapsed(now, lastTelemetryMs, TELEMETRY_INTERVAL_MS)) return;
  lastTelemetryMs = now;

  String payload;
  payload.reserve(480);
  payload = "{\"temperature\":" + jsonNumber(sensors.airTemperatureC);
  payload += ",\"solutionTemperature\":" + jsonNumber(sensors.solutionTemperatureC);
  payload += ",\"humidity\":" + jsonNumber(sensors.airHumidityPercent);
  payload += ",\"ph\":null";
  payload += ",\"tds\":" + jsonNumber(sensors.tdsPpm, 0);
  payload += ",\"waterLevel\":" + jsonNumber(sensors.waterLevelPercent);
  payload += ",\"lux\":null";
  payload += ",\"waterDistanceCm\":" + jsonNumber(sensors.waterDistanceCm);
  payload += ",\"waterLevelCm\":" + jsonNumber(sensors.waterLevelCm);
  payload += ",\"waterLevelValid\":";
  payload += sensors.waterLevelValid ? "true" : "false";
  payload += ",\"lowWater\":";
  payload += sensors.lowWater ? "true" : "false";
  payload += ",\"pumpState\":";
  payload += pumpOn ? "true" : "false";
  payload += ",\"lightState\":";
  payload += lightOn ? "true" : "false";
  payload += ",\"wifiRssi\":" + String(WiFi.RSSI());
  payload += "}";

  Serial.println(mqtt.publish(readingsTopic.c_str(), payload.c_str())
                   ? "Telemetry published"
                   : "Telemetry publish failed");
}

void setup() {
  Serial.begin(115200);

  // Set safe levels before switching the GPIOs to output mode.
  digitalWrite(PUMP_RELAY_PIN, LOW);
  digitalWrite(LIGHT_RELAY_PIN, LOW);
  pinMode(PUMP_RELAY_PIN, OUTPUT);
  pinMode(LIGHT_RELAY_PIN, OUTPUT);
  pinMode(WATER_TRIG_PIN, OUTPUT);
  digitalWrite(WATER_TRIG_PIN, LOW);
  pinMode(WATER_ECHO_PIN, INPUT);

  analogReadResolution(12);
  analogSetPinAttenuation(TDS_PIN, ADC_11db);
  Wire.begin(I2C_SDA_PIN, I2C_SCL_PIN);
  dht20Available = dht20.begin(&Wire);
  if (!dht20Available) Serial.println("DHT20/AHT20 not found; air readings will be null");

  ds18b20.begin();
  ds18b20.setWaitForConversion(false);
  requestWaterTemperature(millis());

  settings.begin("iotagri", true);
  savedSsid = settings.getString("ssid");
  savedPassword = settings.getString("pass");
  apiUrl = settings.getString("api");
  mqttHost = settings.getString("host");
  deviceKey = settings.getString("key");
  mqttPort = settings.getInt("port");
  settings.end();
  configureMqttTopics();

  mqtt.setServer(mqttHost.c_str(), mqttPort);
  mqtt.setCallback(onMqttMessage);
  mqtt.setBufferSize(MQTT_BUFFER_BYTES);
  mqtt.setKeepAlive(30);
  mqtt.setSocketTimeout(5);

  WiFi.mode(WIFI_STA);
  if (savedSsid.isEmpty() || deviceKey.isEmpty() || mqttHost.isEmpty() || mqttPort <= 0 ||
      !connectWifiBlocking(savedSsid, savedPassword)) {
    startPortal();
  } else {
    Serial.printf("Wi-Fi connected: %s\n", WiFi.localIP().toString().c_str());
  }
}

void loop() {
  const uint32_t now = millis();

  // Local sensing and pump protection always run, even with no Wi-Fi/backend.
  serviceWaterTemperature(now);
  serviceAirSensor(now);
  serviceWaterLevel(now);
  serviceTds(now);
  servicePumpTimer(now);
  enforcePumpSafety();

  if (setupMode) {
    dns.processNextRequest();
    server.handleClient();
    return;
  }

  serviceWifi(now);
  serviceMqtt(now);
  publishTelemetry(now);
}
