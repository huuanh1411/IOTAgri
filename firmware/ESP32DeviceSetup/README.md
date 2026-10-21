# ESP32-S3 production firmware

This sketch targets the AEROGREEN MKE-K01 ESP32-S3 N16 controller. It uses the
production API and MQTT endpoints only:

- HTTPS claim: `https://api.aerogreen.vn`
- MQTT over TLS: `mqtt.aerogreen.vn:8883`
- Trust anchor: ISRG Root X1; certificate and hostname validation stay enabled

## Build dependencies

- Arduino ESP32 core `esp32:esp32@3.3.12`
- Adafruit AHTX0 `2.0.6`
- DallasTemperature `4.0.6`
- OneWire `2.3.8`
- PubSubClient `2.8.0`

Compile with Arduino CLI:

```sh
arduino-cli compile --fqbn esp32:esp32:esp32s3 firmware/ESP32DeviceSetup
```

Flash only while both relay-controlled loads are disconnected or made safe:

```sh
arduino-cli upload --fqbn esp32:esp32:esp32s3 -p YOUR_SERIAL_PORT firmware/ESP32DeviceSetup
```

## Provisioning after flashing

The old single-namespace settings are intentionally not migrated because they
do not contain production MQTT credentials. After flashing:

1. Create a new provisioning code in the app.
2. Join the `IOTAgri-Setup` Wi-Fi network from the phone.
3. Submit the Wi-Fi credentials and new code from the app.
4. The device synchronizes UTC using NTP, claims through verified HTTPS, and
   accepts only a complete TLS response for `mqtt.aerogreen.vn:8883`.
5. Wi-Fi and device credentials are written to an inactive NVS slot, verified,
   then activated with a final slot-pointer write.

Do not print or copy the returned MQTT password. A claim response is one-time;
if the NVS commit reports failure, create a new provisioning code and repeat.

Scheduled pump commands require synchronized UTC. A command delivered after
`scheduledEndUtc` is rejected, and a late but still-valid command runs only for
the remaining part of its fixed UTC window. Pump water-level protection and the
local duration cutoff continue to apply.
