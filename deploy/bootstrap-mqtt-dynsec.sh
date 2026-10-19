#!/usr/bin/env bash
# One-time: create Dynamic Security state, default-deny ACLs, device and api roles, api client.
# Needs MQTT_ADMIN_PASSWORD and MQTT_API_PASSWORD in .env.production. Run from the VPS.
set -euo pipefail

cd "${APP_DIR:-/opt/iotagri}"
set -a; . ./.env.production; set +a
: "${MQTT_ADMIN_PASSWORD:?}" "${MQTT_API_PASSWORD:?}"

compose=(docker compose --env-file .env.production -f compose.production.yaml)

# First boot reads MOSQUITTO_DYNSEC_PASSWORD (compose.production.yaml) to create the admin user.
"${compose[@]}" up -d mosquitto
sleep 3

ctl() { "${compose[@]}" exec -T mosquitto mosquitto_ctrl -h 127.0.0.1 -p 1883 -u admin -P "$MQTT_ADMIN_PASSWORD" dynsec "$@"; }
ensure() {
  local output
  if output="$(ctl "$@" 2>&1)"; then return; fi
  if grep -qi 'already exists' <<<"$output"; then return; fi
  printf '%s\n' "$output" >&2
  return 1
}

# Plugin 2.1 ships a demo client with read/write on '#'.
ctl deleteClient democlient || true

for acl in publishClientSend publishClientReceive subscribe unsubscribe; do
  ctl setDefaultACLAccess "$acl" deny
done

ensure createRole device
ensure addRoleACL device publishClientSend 'devices/%u/readings' allow 10
ensure addRoleACL device publishClientSend 'devices/%u/pump-status' allow 10
ensure addRoleACL device publishClientSend 'devices/%u/light-status' allow 10
ensure addRoleACL device subscribePattern 'devices/%u/commands/pump' allow 10
ensure addRoleACL device publishClientReceive 'devices/%u/commands/pump' allow 10
ensure addRoleACL device subscribePattern 'devices/%u/commands/light' allow 10
ensure addRoleACL device publishClientReceive 'devices/%u/commands/light' allow 10

ensure createRole api
ensure addRoleACL api subscribePattern 'devices/+/readings' allow 10
ensure addRoleACL api subscribePattern 'devices/+/pump-status' allow 10
ensure addRoleACL api subscribePattern 'devices/+/light-status' allow 10
ensure addRoleACL api publishClientReceive 'devices/+/readings' allow 10
ensure addRoleACL api publishClientReceive 'devices/+/pump-status' allow 10
ensure addRoleACL api publishClientReceive 'devices/+/light-status' allow 10
ensure addRoleACL api publishClientSend 'devices/+/commands/pump' allow 10
ensure addRoleACL api publishClientSend 'devices/+/commands/light' allow 10

ensure createClient api -c iotagribackend-production -p "$MQTT_API_PASSWORD"
ensure addClientRole api api 10
echo "dynsec bootstrap ok"
