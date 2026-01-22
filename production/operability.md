# Production Operability Guide

## 1. Services Overview

The new durable architecture introduces the following components:

- **PronterLabs Chat**: Next.js UI + API. Connects to `pronterlabs_chat` DB.
- **Memlink Worker**: Main ingestion engine. Connects to `memlink` DB AND `pronterlabs_chat` DB (Canonical Source).
- **Memlink Relay**: *NEW* service. Polls `pronterlabs_chat.outbox_events` and pushes to Redis.

## 2. Deployment

### Memlink Relay
Currently implemented as a script in `memlink/services/relay`.
In production, this should be a standalone container or a sidecar.

**Docker Compose (Recommended):**
```yaml
  memlink-relay:
    build:
      context: .
      dockerfile: Dockerfile.relay
    command: ["node", "services/relay/dist/index.js"]
    environment:
      - CHAT_DATABASE_URL=...
      - REDIS_URL=...
    restart: always
```

### Memlink Worker
Requires `CHAT_DATABASE_URL` environment variable.
Ensure network access to Chat DB.

## 3. Health Checks

- **Chat App**: `GET /api/health` (To be implemented) or basic `/`.
- **Worker**: `healthcheck` in docker-compose uses `kill -0 1` (process check).
- **Relay**: Monitor logs for "Processing X events". If it stops logging or crashes, restart.

## 4. Logging & Monitoring

- **Structured Logs**: Memlink uses `@memlink/logger` (JSON format).
- **Metrics**: Memlink exposes Prometheus metrics on port 9090 (if configured).
- **Key Metrics to Watch**:
    - `worker.queue.redis.read`: Rate of ingestion.
    - `worker.job.success` / `worker.job.failure`: Processing health.
    - `outbox_events` count (DB): If growing, Relay is down or slow.

## 5. Troubleshooting

**Issue:** Chat messages not appearing in Memlink.
**Check:**
1. Is `outbox_events` populated in Chat DB?
   - No -> Chat App transaction failed (check app logs).
   - Yes -> Check `status`.
     - `pending` -> Relay is down or stuck.
     - `processed` -> Relay worked. Check Worker logs.
     - `failed` -> Check `error` column.

**Issue:** Worker failing to fetch chat.
**Check:** Worker logs for `invalid input syntax` or connection errors to `pronterlabs_chat` DB.
