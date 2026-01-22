# Architecture Audit Findings

## Current Architecture State

### PronterLabs Chat (`pronterlabs-chat`)
- **Type**: Client-side Next.js application (React).
- **Persistence**: **None**. Uses `useState` and ephemeral `chatId` (`chat-<timestamp>`). State is lost on refresh.
- **Backend**: Proxies `/api/chat` to `http://dispatcher-gateway:8000/v1/chat/completions`.
- **Integrations**: Does not communicate directly with Memlink or any Database.

### Dispatcher (`dispatcher`)
- **Role**: API Gateway & Orchestrator.
- **Memlink Integration**: Triggers Memlink extraction background task (`_trigger_extraction`) upon successful chat completion.
- **Method**: **Direct Payload Injection**. Sends the full message history (`messages`) in the payload to Memlink via `POST /v1/jobs`.
- **Identity**: Resolves trust tokens but passes data through.

### Memlink (`memlink`)
- **Ingestion**: `services/worker/src/runtime.ts` checks for `payload.messages`.
- **Logic**: If `payload.messages` exists, it uses them directly (skipping DB).
- **Legacy Path**: Contains `fetchChatRecord` which queries `openwebuiDb` (`chat` table). This path is currently bypassed when `messages` are provided.
- **Persistence**: Persists *derived* data (summaries, facts, graph), but relies on the input payload for source truth.

## Required Changes for Reversion

1.  **Persistence Layer**: `pronterlabs-chat` must implement a database persistence layer (Postgres). It cannot rely on `dispatcher` or Client State.
2.  **Flow Update**:
    - `pronterlabs-chat` must save messages to DB *before* and *after* AI generation.
    - `dispatcher` must STOP sending `messages` payload to Memlink, or `pronterlabs-chat` handles the trigger.
    - Given the race condition (Dispatcher triggering Memlink before Chat App saves Assistant response), `pronterlabs-chat` should likely be responsible for triggering Memlink (or `dispatcher` trigger must be delayed/removed).
    - *Decision*: We will move the Memlink trigger responsibility to `pronterlabs-chat` after it persists the complete turn.
3.  **Memlink Config**: Memlink's `openwebuiDb` connection (or Tenant DB) must point to the new Chat App Database.
4.  **Schema**: Need to recreate the `chat` table schema compatible with `memlink`'s expectation (or update `memlink` to match new schema).
    - Memlink expects `chat` table with `chat::json`, `title`, `user_id`. The `chat` column is a JSON blob containing `messages`.
    - *However*, Phase 2 task is "Design chat database schema: conversations, messages, participants". This implies a normalized schema, not just a JSON blob.
    - If we use a normalized schema (better), we must update `memlink` to read from that schema instead of the OpenWebUI JSON blob.

## Next Steps
Proceed to Phase 2: Data Model Restoration.
- Define normalized schema.
- Creating migration.
