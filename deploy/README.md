# Production deployment notes

Run exactly one `api` replica. `MqttIngestionService` and `PumpScheduleDispatchService` run inside the API process, so a second replica would double-ingest readings and double-dispatch pump commands.

## First VPS deployment

Copy the repository to `/opt/iotagri`, create `.env.production` from `.env.production.example`, replace every example secret, and add DNS A records for `app.aerogreen.vn`, `api.aerogreen.vn`, and `mqtt.aerogreen.vn`. Then run:

```
chmod +x deploy/deploy-production.sh deploy/bootstrap-mqtt-dynsec.sh deploy/sync-mqtt-certs.sh deploy/verify-mqtt-security.sh
./deploy/deploy-production.sh
```

After Caddy issues the `mqtt.aerogreen.vn` certificate, run `./deploy/sync-mqtt-certs.sh`, then `./deploy/bootstrap-mqtt-dynsec.sh`, then `docker compose --env-file .env.production -f compose.production.yaml up -d`.

## PostgreSQL backup

Backup target setup is deferred until VPS deployment.

Files: `backup-postgres.sh`, `iotagri-backup.service`, `iotagri-backup.timer`.

### One-time setup on the VPS

1. Install tools: `apt install age rclone`.
2. Generate an age key on a trusted machine, not the VPS: `age-keygen -o backup.key`. Keep `backup.key` offline. Only the public key goes on the VPS.
3. Configure an rclone remote with write-only or least-privilege credentials: `rclone config`.
4. Create `/etc/iotagri-backup.env` (mode 600, root-owned, never in Git):

   ```
   BACKUP_REMOTE=<remote>:<bucket-or-path>
   AGE_RECIPIENT=<age public key>
   RETENTION_DAYS=30
   APP_DIR=/opt/iotagri
   ```

5. Install and start:

   ```
   cp deploy/iotagri-backup.service deploy/iotagri-backup.timer deploy/iotagri-backup-failure@.service /etc/systemd/system/
   chmod +x deploy/backup-postgres.sh
   systemctl daemon-reload
   systemctl enable --now iotagri-backup.timer
   systemctl start iotagri-backup.service   # run once now
   ```

### Failure reporting

A failed run leaves `iotagri-backup.service` in the `failed` state. Check with `systemctl is-failed iotagri-backup.service`. Hook an external monitor or `OnFailure=` unit to notify you.

### Restore drill (repeat regularly; record each result)

1. Download the newest `db-*.dump.age` with `rclone copy`.
2. Decrypt on a trusted machine: `age -d -i backup.key db-<stamp>.dump.age > db.dump`.
3. Start a disposable PostgreSQL: `docker run --rm -d --name restore-test -e POSTGRES_PASSWORD=x postgres:17-alpine`.
4. Validate and restore:

   ```
   pg_restore --list db.dump
   docker cp db.dump restore-test:/db.dump
   docker exec restore-test createdb -U postgres iotagri
   docker exec restore-test pg_restore -U postgres -d iotagri /db.dump
   ```

5. Point a scratch API at it and call `/health`.
6. Record timestamp, object name, and result below.

| Date | Object | Result |
|------|--------|--------|
| | | |

## Release evidence

Record each production release without secrets, dump files, private keys, or broker credentials.

| Gate | UTC time | Command/result | Artifact/reference | Owner |
|---|---|---|---|---|
| Compose configuration | | | | |
| Firewall and external port scan (80, 443, 8883 only) | | | | |
| HTTP redirect and HTTPS `/health` | | | | |
| API/PostgreSQL public isolation | | | | |
| MQTT authorization verifier | | | | |
| Mosquitto restart retains Dynamic Security state | | | | |
| Encrypted backup upload | | | | |
| `pg_restore --list` and scratch API health | | | | |
| ESP32 TLS claim and MQTT proof | | | | |
