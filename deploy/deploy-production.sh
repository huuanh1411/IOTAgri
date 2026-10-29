#!/usr/bin/env bash
set -euo pipefail

cd "${APP_DIR:-/opt/iotagri}"
[ -f .env.production ] || { echo '.env.production missing'; exit 1; }
set -a; . ./.env.production; set +a

: "${API_HOST:?}" "${MQTT_HOST:?}" "${ACME_EMAIL:?}"
for host in "$API_HOST" "$MQTT_HOST"; do
  getent ahostsv4 "$host" >/dev/null || { echo "DNS missing for $host"; exit 1; }
done

for value in POSTGRES_PASSWORD JWT_KEY ADMIN_BOOTSTRAP_PASSWORD MQTT_ADMIN_PASSWORD MQTT_API_PASSWORD EMAIL_VERIFICATION_PEPPER; do
  [ -n "${!value:-}" ] || { echo "$value must be set"; exit 1; }
  [ "${!value}" != change-me ] || { echo "$value still has example value"; exit 1; }
done

docker compose --env-file .env.production -f compose.production.yaml config >/dev/null
docker compose --env-file .env.production -f compose.production.yaml up -d caddy
echo 'Caddy started. Wait for certificates, then run sync-mqtt-certs.sh, bootstrap-mqtt-dynsec.sh, and docker compose up -d.'
