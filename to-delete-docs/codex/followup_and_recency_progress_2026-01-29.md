# Follow-up + Recency Retrieval Progress Log (2026-01-29)

Purpose: document the ongoing implementation of conversation state, follow-up resolution, and two-pass retrieval in Dispatcher/Bifrost, with canary gating.

## Current status
- Work in progress. Code changes exist but are not yet rebuilt/redeployed.
- Feature flags are default OFF in compose; canary allowlist is set for akadmin.

## Progress timeline

### 1) Baseline assessment (done)
- Identified that PronterLabs Chat injects a "Relevant Memory" system message from memlink retrieval in `pronterlabs-chat/src/app/api/chat/route.ts`.
- Determined this legacy injection must be suppressed for canary users once new follow-up/recency logic is enabled.

### 2) Dispatcher: model + config expansion (done)
Files:
- `pronterlabs/dispatcher/src/models.py`
  - Added: `chat_id`, `user_email` to `RequestContext`.
  - Added: `ChatTurn` model.
  - Added: `messages: List[ChatTurn]` to `UserChatRequest`.
- `pronterlabs/dispatcher/src/config.py`
  - Added feature flags and canary allowlist settings.
  - Added resolver settings, Redis URL, tenant DB URL.

Why:
- Pass chatId/userEmail into the pipeline.
- Allow canary‑gated behavior and safe rollout.

### 3) Dispatcher: new context modules (done)
Files:
- `pronterlabs/dispatcher/src/context/conversation_state.py`
  - ConversationState model, Redis/in-memory store, state key builder, lightweight state updates.
- `pronterlabs/dispatcher/src/context/followup_resolver.py`
  - Heuristic resolver + optional OpenAI resolver.
  - Added JSON parsing hardening (strip code fences, extract JSON object if wrapped).
- `pronterlabs/dispatcher/src/context/recency.py`
  - Tenant DB pool + fetch recent summaries from `tenant_chat_summaries`.
  - Uses `set_config` for RLS variables (tenant/user).
  - Logs and fails open if DB connection fails.

### 4) Dispatcher: API pipeline integration (done)
Files:
- `pronterlabs/dispatcher/src/api.py`
  - Extracts identity claims and canary gating.
  - Builds message history (excluding "Relevant Memory" system message).
  - Disables legacy injection for canary users (two_pass/followup enabled or allowlist).
  - Loads/updates conversation state.
  - Runs follow‑up resolver and rewrites query if needed.
  - Clarify gate returns a clarification response when the resolver flags ambiguity.
  - Two‑pass retrieval: fetches recency summaries from tenant DB (short‑term context).
  - Injects follow‑up metadata + recency context into the final prompt input.
  - Updates conversation state after assistant reply.

### 5) Dispatcher: startup/shutdown hooks (done)
Files:
- `pronterlabs/dispatcher/src/main.py`
  - Initializes conversation_state store on startup.
  - Initializes recency DB pool (if TENANT_DB_URL configured).
  - Closes resources on shutdown.

### 6) Bifrost: chatId propagation (done)
Files:
- `pronterlabs/bifrost/bifrost/input_normalizer.py`
  - Adds `chat_id` to normalized context.
- `pronterlabs/bifrost/server.py`
  - Uses `context.chat_id` for Memlink `chatId` if present (falls back to request_id).

Note:
- `bifrost/auth.py` and `bifrost/policy_engine.py` have unrelated changes that pre‑existed in the working tree and are being kept.

### 7) Dependency updates (done)
Files:
- `pronterlabs/dispatcher/pyproject.toml`
  - Added: `asyncpg`, `redis`.
- `pronterlabs/dispatcher/poetry.lock`
  - Updated via Poetry (generated in /tmp/poetry-venv).

### 8) Runtime config (done in compose)
File:
- `pronterlabs/dispatcher/docker-compose.yml`
  - Added: feature flags (OFF), canary allowlist, Redis/tenant DB URLs.
  - Added dispatcher to `memlink_net`.

## Known gaps / pending tasks
- Rebuild and restart dispatcher (and optionally bifrost) to load new code + env.
- Validate tenant DB connectivity from dispatcher container.
- Run a canary test session and confirm:
  - follow-up resolution works (no “context collapse”)
  - recency summaries appear (short‑term context)
  - facts retrieval still uses existing RLS + memlink pathway

## Notes about legacy “Relevant Memory” injection
- For canary users or when follow‑up/recency is enabled, the system should not prepend the legacy “Relevant Memory” system message. This avoids double‑injecting context and improves retrieval consistency.
- Non‑canary users remain on the legacy path (no change).

## Suggested canary test flow (manual)
1) Send a short question + a follow-up:
   - Q1: "What is a white paper?"
   - Q2: "What about for software?"
2) Confirm follow‑up uses the previous topic in the response.
3) Add a personal fact, wait for worker, ask a recall question.
4) Confirm two‑pass retrieval doesn’t regress existing memory recall.

## Rollback plan (high level)
- Toggle feature flags OFF in `dispatcher/docker-compose.yml` (already default).
- Rebuild/redeploy dispatcher to revert to legacy behavior.
- If needed, revert the dispatcher commit and rebuild.

## File list (modified/added)
- `pronterlabs/dispatcher/src/models.py`
- `pronterlabs/dispatcher/src/config.py`
- `pronterlabs/dispatcher/src/context/conversation_state.py`
- `pronterlabs/dispatcher/src/context/followup_resolver.py`
- `pronterlabs/dispatcher/src/context/recency.py`
- `pronterlabs/dispatcher/src/api.py`
- `pronterlabs/dispatcher/src/main.py`
- `pronterlabs/dispatcher/pyproject.toml`
- `pronterlabs/dispatcher/poetry.lock`
- `pronterlabs/dispatcher/docker-compose.yml`
- `pronterlabs/bifrost/bifrost/input_normalizer.py`
- `pronterlabs/bifrost/server.py`

