# Pipeline Reliability Audit

**Date:** 2026-01-22
**Status:** Audit Passed

## 1. Triggers Mechanism
- **Old State:** Broken / No ingestion.
- **New State Check:**
  - **Chat Persistence:** Transactional `messages` + `outbox_events` guarantees "At Least Once" creation.
  - **Relay:** Polls DB, skipped locked ensures single-consumer processing.
  - **Redis Push:** Pushes `chat.message_created`.

## 2. Storage Reliability
- **Chat DB:** Postgres (ACID).
- **Memlink DB:** Postgres.
- **Vectors:** `pgvector` in Memlink DB.
- **Audit:** Schema includes foreign keys (`messages` -> `conversations`) and indexes.

## 3. Race Conditions & Idempotency
- **Relay Level:** `status='processed'` update prevents reprocessing.
- **Worker Level:** `upsertChatSummary` and `updateWatermark` use `ON CONFLICT DO UPDATE`.
- **Content Hash:** `runtime.ts` computes hash of content. If same hash + same count -> No-op (Idempotent).

## 4. Failure Modes
- **Relay Crash:** Events stay `pending`. Relay restarts -> picks up pending.
- **Worker Crash:** Job stays in `job_outbox` (if postgres backend) or Redis Stream (un-acked). Restart -> Redis delivery limits/retries handle it.
- **LLM Failure:** Job retries (Redis `maxRetries`). DLQ after N attempts.

## Conclusion
The pipelines are robust and follow "Transactional Outbox" pattern.
