# Pipeline Recovery Runbook

## Incident: Stuck Pending Jobs (Poison Pill)

**Symptoms:**
- `outbox_events` has high count of `pending` jobs.
- `memlink-worker` logs show repeated errors/crashes.
- Recent chats not appearing in memory/facts.

**Root Cause:**
- Invalid data (e.g. malformed UUIDs) in Redis Stream blocks the worker.
- Worker crash loop prevents processing newer events.

**Resolution Steps:**

1. **Verify Worker Logs**
   ```bash
   docker logs --tail 20 memlink-worker
   ```
   Look for `DatabaseError` or `invalid input syntax`.

2. **Purge Poison Pill (Redis)**
   If key violation is confirmed:
   ```bash
   docker exec memlink-worker redis-cli -h memlink-redis -a memlink_redis_pass DEL memlink:job_stream
   docker restart memlink-worker
   ```

3. **Purge Poison Pill (Postgres)**
   If job persists in DB:
   ```bash
   # Connect to Memlink DB
   psql ... -d memlink
   DELETE FROM job_outbox WHERE payload::text LIKE '%<bad-id>%';
   DELETE FROM memlink_jobs WHERE payload::text LIKE '%<bad-id>%';
   ```

4. **Restart Services**
   ```bash
   docker restart memlink-worker
   ```

## Incident: Relay Not Polling

**Symptoms:**
- `outbox_events` pending count increasing.
- Relay logs silent or container missing.

**Resolution:**
1. Check Relay Container:
   ```bash
   docker ps | grep relay
   ```
2. Check Logs:
   ```bash
   docker logs memlink-relay
   ```
3. Restart Stack:
   ```bash
   docker compose up -d memlink-relay
   ```
