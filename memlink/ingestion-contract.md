# Memlink Ingestion Contract

**Status:** DB-Canonical (Transactional Outbox)
**Date:** 2026-01-22

## Overview
Memlink no longer relies on payload messages. It treats the `pronterlabs_chat` database as the Source of Truth.

## The Pipeline

1. **Commit:** Chat App commits user/assistant messages to DB + `outbox_events` in a single transaction.
2. **Relay:** A worker polls `outbox_events` and pushes `chat.message_created` to Redis `memlink:job_stream`.
3. **Ingest:** Memlink Worker picks up the job.
4. **Fetch:** Memlink Worker queries `conversations` and `messages` tables (Canonical Fetch).
5. **Process:** Summarizer/Extractor runs on the fetched history.

## Idempotency
- **Relay Level:** `outbox_events.status` ensures simple events are processed once per row.
- **Worker Level:** `job_watermarks` tracks `message_count` and `checksum` (hash of message IDs).
- **Behavior:** If a job is re-processed but the content hash hasn't changed, Memlink skips expensive LLM re-summarization.

## Fallback
Legacy payload injection is DISABLED in favor of DB fetch.
If DB fetch returns null (race condition?), the job is skipped/failed, ensuring we don't hallucinate empty state.
