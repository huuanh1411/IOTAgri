#!/usr/bin/env bash
# Proves production MQTT allow/deny rules with disposable broker credentials.
set -euo pipefail

: "${MQTT_HOST:?}" "${MQTT_PORT:=8883}" "${MQTT_CA_FILE:?}"
: "${MQTT_API_USERNAME:=api}" "${MQTT_API_PASSWORD:?}" "${MQTT_API_CLIENT_ID:=iotagribackend-production}"
: "${VERIFY_DEVICE_A_USERNAME:?}" "${VERIFY_DEVICE_A_PASSWORD:?}" "${VERIFY_DEVICE_A_CLIENT_ID:?}"
: "${VERIFY_DEVICE_B_USERNAME:?}" "${VERIFY_DEVICE_B_PASSWORD:?}" "${VERIFY_DEVICE_B_CLIENT_ID:?}"

mqtts=(--cafile "$MQTT_CA_FILE" -h "$MQTT_HOST" -p "$MQTT_PORT" -W 5)
must_succeed() { "$@" >/dev/null; }
must_fail() { if "$@" >/dev/null 2>&1; then echo "unexpected success: $*" >&2; exit 1; fi; }
client_args() { printf '%s\0' -u "$1" -P "$2" -i "$3"; }

a_topic="devices/${VERIFY_DEVICE_A_USERNAME}"
b_topic="devices/${VERIFY_DEVICE_B_USERNAME}"

must_succeed mosquitto_pub "${mqtts[@]}" -u "$VERIFY_DEVICE_A_USERNAME" -P "$VERIFY_DEVICE_A_PASSWORD" -i "$VERIFY_DEVICE_A_CLIENT_ID" -t "$a_topic/readings" -m '{}'
must_succeed mosquitto_pub "${mqtts[@]}" -u "$VERIFY_DEVICE_A_USERNAME" -P "$VERIFY_DEVICE_A_PASSWORD" -i "$VERIFY_DEVICE_A_CLIENT_ID" -t "$a_topic/pump-status" -m '{}'
must_succeed mosquitto_pub "${mqtts[@]}" -u "$VERIFY_DEVICE_A_USERNAME" -P "$VERIFY_DEVICE_A_PASSWORD" -i "$VERIFY_DEVICE_A_CLIENT_ID" -t "$a_topic/light-status" -m '{}'
must_succeed mosquitto_pub "${mqtts[@]}" -u "$MQTT_API_USERNAME" -P "$MQTT_API_PASSWORD" -i "$MQTT_API_CLIENT_ID" -t "$a_topic/commands/pump" -m '{}'
must_succeed mosquitto_pub "${mqtts[@]}" -u "$MQTT_API_USERNAME" -P "$MQTT_API_PASSWORD" -i "$MQTT_API_CLIENT_ID" -t "$a_topic/commands/light" -m '{}'

must_fail mosquitto_pub "${mqtts[@]}" -u "$VERIFY_DEVICE_A_USERNAME" -P "$VERIFY_DEVICE_A_PASSWORD" -i "$VERIFY_DEVICE_A_CLIENT_ID" -t "$b_topic/readings" -m '{}'
must_fail mosquitto_sub "${mqtts[@]}" -u "$VERIFY_DEVICE_A_USERNAME" -P "$VERIFY_DEVICE_A_PASSWORD" -i "$VERIFY_DEVICE_A_CLIENT_ID" -t "$b_topic/commands/pump" -C 1
must_fail mosquitto_sub "${mqtts[@]}" -i anonymous -t "$a_topic/readings" -C 1
must_fail mosquitto_sub "${mqtts[@]}" -u "$VERIFY_DEVICE_A_USERNAME" -P wrong-password -i "$VERIFY_DEVICE_A_CLIENT_ID" -t "$a_topic/commands/pump" -C 1
must_fail mosquitto_sub -h "$MQTT_HOST" -p 1883 -u "$VERIFY_DEVICE_A_USERNAME" -P "$VERIFY_DEVICE_A_PASSWORD" -i "$VERIFY_DEVICE_A_CLIENT_ID" -t "$a_topic/commands/pump" -C 1 -W 5
must_fail mosquitto_sub --cafile "$MQTT_CA_FILE" -h invalid."$MQTT_HOST" -p "$MQTT_PORT" -u "$VERIFY_DEVICE_A_USERNAME" -P "$VERIFY_DEVICE_A_PASSWORD" -i "$VERIFY_DEVICE_A_CLIENT_ID" -t "$a_topic/commands/pump" -C 1 -W 5

echo "MQTT authorization verification passed"
