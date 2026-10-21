from pathlib import Path
import hashlib
import re
import ssl
import unittest


SKETCH = Path(__file__).resolve().parents[1] / "ESP32DeviceSetup.ino"
ROOT_CA_HEADER = Path(__file__).resolve().parents[1] / "ProductionRootCa.h"
ISRG_ROOT_X1_SHA256 = "96bcec06264976f37460779acf28c5a7cfe8a3c0aae11a8ffcee05c0bddf08c6"


class ProductionFirmwareContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = SKETCH.read_text(encoding="utf-8")

    def test_https_and_mqtt_use_verified_tls(self):
        self.assertIn("#include <WiFiClientSecure.h>", self.source)
        self.assertIn('constexpr char API_BASE_URL[] = "https://api.aerogreen.vn";', self.source)
        self.assertIn('constexpr char MQTT_PRODUCTION_HOST[] = "mqtt.aerogreen.vn";', self.source)
        self.assertIn("WiFiClientSecure network;", self.source)
        self.assertNotIn("WiFiClient network;", self.source)
        self.assertIn("network.setCACert(ISRG_ROOT_X1);", self.source)
        self.assertIn("http.begin(network, claimUrl)", self.source)
        self.assertIn("if (!jsonBool(response, \"useTls\", useTls) || !useTls)", self.source)
        self.assertNotIn("setInsecure", self.source)

        header = ROOT_CA_HEADER.read_text(encoding="utf-8")
        pem = re.search(
            r"-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----",
            header,
            re.DOTALL,
        )
        self.assertIsNotNone(pem)
        der = ssl.PEM_cert_to_DER_cert(pem.group(0))
        self.assertEqual(ISRG_ROOT_X1_SHA256, hashlib.sha256(der).hexdigest())

    def test_claim_credentials_are_complete_and_used_for_mqtt(self):
        for field in (
            "deviceKey",
            "mqttHost",
            "mqttPort",
            "useTls",
            "mqttUsername",
            "mqttPassword",
            "mqttClientId",
        ):
            self.assertIn(f'"{field}"', self.source)
        self.assertIn(
            "mqtt.connect(mqttClientId.c_str(), mqttUsername.c_str(), mqttPassword.c_str())",
            self.source,
        )

    def test_nvs_commit_is_two_slot_and_commit_last(self):
        self.assertIn("saveSettingsAtomically", self.source)
        self.assertIn('putBool("ready", true)', self.source)
        self.assertIn('putUChar("active", targetSlot)', self.source)
        self.assertIn("loadSettingsSlot", self.source)

    def test_scheduled_pump_commands_use_utc_expiry(self):
        self.assertIn("configTime(0, 0", self.source)
        self.assertIn('jsonString(payload, "source")', self.source)
        self.assertIn('jsonString(payload, "issuedAtUtc")', self.source)
        self.assertIn('jsonString(payload, "scheduledEndUtc")', self.source)
        self.assertIn('"SCHEDULE_EXPIRED"', self.source)
        self.assertIn("effectiveDurationSeconds", self.source)


if __name__ == "__main__":
    unittest.main()
