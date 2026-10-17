#!/usr/bin/env bash
# Copy the Caddy-managed mqtt.aerogreen.vn certificate to Mosquitto and restart it when it changed.
# Run daily from root cron: 17 3 * * * /opt/iotagri/deploy/sync-mqtt-certs.sh
set -euo pipefail

cd "${APP_DIR:-/opt/iotagri}"
src=/data/caddy/certificates/acme-v02.api.letsencrypt.org-directory/mqtt.aerogreen.vn/mqtt.aerogreen.vn
dst=deploy/mosquitto-certs
compose=(docker compose --env-file .env.production -f compose.production.yaml)
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

"${compose[@]}" cp "caddy:$src.crt" "$tmp/server.crt"
"${compose[@]}" cp "caddy:$src.key" "$tmp/server.key"

cmp -s "$tmp/server.crt" "$dst/server.crt" 2>/dev/null && exit 0

mkdir -p "$dst"
install -m 600 -o 1883 -g 1883 "$tmp/server.key" "$dst/server.key"
install -m 644 -o 1883 -g 1883 "$tmp/server.crt" "$dst/server.crt"
"${compose[@]}" up -d mosquitto
"${compose[@]}" restart mosquitto
echo "mqtt cert synced"
