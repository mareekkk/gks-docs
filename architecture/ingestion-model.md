# Architecture Decision: Ingestion Model

**Date:** 2026-01-22
**Decision:** Option A - Transactional Outbox

## Context
We need a reliable way to ingest chat conversations into Memlink for memory extraction. The current system has no automatic ingestion.

## Decision
We select the **Transactional Outbox** pattern.

## Implementation Plan

### 1. Database Schema (`pronterlabs_chat`)
Add table `outbox_events`:
- `id` (UUID)
- `event_type` (VARCHAR) e.g. 'chat.turn.completed'
- `payload` (JSONB)
- `status` (VARCHAR) 'pending' | 'processed' | 'failed'
- `created_at` (TIMESTAMP)

### 2. Chat Application (`pronterlabs-chat`)
Modify `POST /api/chat`:
- Inside the existing `BEGIN` ... `COMMIT` block for User Message:
  - Insert `outbox_events` row.
- Inside the *new* transaction for Assistant Message (which we must fix to be reliable):
  - Insert `outbox_events` row.

### 3. Relay Service (`pronterlabs-relay`)
Create a lightweight worker (Node.js/Python) that:
1. Polls `outbox_events` where status='pending'.
2. Pushes event to `memlink:job_stream` (Redis).
3. Updates status to 'processed'.
4. Handles locking to prevent double-processing (SKIP LOCKED).

## Why this choice?
- **Atomicity:** The event is only created if the chat message is successfully committed.
- **Reliability:** If Redis is down, events accumulate in DB. Relay processes them when Redis recovers.
- **Decoupling:** Chat App doesn't need to know about Redis config or Memlink internals.
