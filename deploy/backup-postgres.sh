#!/usr/bin/env bash
# Dump PostgreSQL (custom format + globals), encrypt with age, upload with rclone.
# Config via /etc/iotagri-backup.env: BACKUP_REMOTE, AGE_RECIPIENT, optional RETENTION_DAYS, APP_DIR.
set -euo pipefail

: "${BACKUP_REMOTE:?rclone destination, e.g. b2:iotagri-backups}"
: "${AGE_RECIPIENT:?age public key}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
APP_DIR="${APP_DIR:-/opt/iotagri}"

cd "$APP_DIR"
set -a; . ./.env.production; set +a

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

compose=(docker compose -f compose.production.yaml)

"${compose[@]}" exec -T postgres pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc \
  | age -r "$AGE_RECIPIENT" > "$tmp/db-$stamp.dump.age"
"${compose[@]}" exec -T postgres pg_dumpall -U "$POSTGRES_USER" --globals-only \
  | age -r "$AGE_RECIPIENT" > "$tmp/globals-$stamp.sql.age"

# An empty dump means pg_dump failed inside the pipe; refuse to upload it.
[ -s "$tmp/db-$stamp.dump.age" ] && [ -s "$tmp/globals-$stamp.sql.age" ]

rclone copy "$tmp" "$BACKUP_REMOTE"
# Retention is enforced at the destination, after a successful upload.
rclone delete "$BACKUP_REMOTE" --min-age "${RETENTION_DAYS}d"
echo "backup ok $stamp"
