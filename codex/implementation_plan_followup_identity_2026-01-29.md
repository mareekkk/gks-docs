# Implementation Plan: Follow‑Up + Recency + Canary Identity (2026‑01‑29)

Purpose: fix canary identification, prevent legacy memory injection from overriding topic, and enable follow‑up/recency retrieval in a controlled rollout. This doc records the plan and the full context.

## Executive summary
The feature is not behaving as intended because the **legacy “Relevant Memory” injection still runs** and **identity exchange fails (503)**, so the canary allowlist is not matched. We must:
1) make identity exchange reliable so canary matching works,
2) disable legacy memory injection for canary users to avoid topic hijacking, and
3) complete the stack: **conversation state**, **follow‑up resolver**, and **two‑pass retrieval** with safe fallbacks for old Memlink tables.

## Current symptoms
- The assistant answers using personal facts (chef, FIFO, etc.) even when the topic is white papers.
- Logs show `Relevant Memory` is still injected into the prompt.
- Dispatcher logs show `trust-kernel /v1/auth/exchange` returns **503**, so claims (sub/email) are not available.

## Root causes (from logs)
1) **Identity exchange failing**: 503 from Trust Kernel prevents dispatcher from matching canary allowlist by `sub` or `email`.
2) **Legacy memory injection active**: `pronterlabs-chat` still calls memlink and injects `Relevant Memory` for every message.
3) **Canary gating relies on claims**: if `sub/email` can’t be decoded, canary is not recognized, even if the list contains `akadmin`.

## Goals
- Reliable identity exchange so canary matching works.
- Canary users get the new follow‑up/recency pipeline.
- Legacy memory injection does not override the current topic for canary users.
- Conversation state is updated every turn (per chat) and feeds the resolver.
- Two‑pass retrieval uses recency first, then long‑term facts (tenant/user scoped).
- Safe rollout with clear rollback.

## Constraints
- No breaking changes to existing non‑canary behavior.
- No schema changes required for this phase.
- Feature flags default OFF; canary allowlist overrides OFF for test users.

---

## Implementation plan (staged)

### Phase 0 — Stabilize identity exchange (blocking)
**Objective:** ensure Trust Kernel exchange is healthy so we can read `sub`/`email` and match canary.

Steps:
1) Verify Trust Kernel health from dispatcher:
   - Check `dispatcher-gateway` logs for `auth/exchange` errors.
2) Inspect Trust Kernel service health (in docker):
   - Confirm `dispatcher-authority` is healthy.
3) If 503 persists, restart Trust Kernel stack:
   - Restart `dispatcher-authority` and re‑test.
4) If still 503, inspect Trust Kernel logs for upstream errors.

Success criteria:
- Dispatcher logs show `auth/exchange` is 200 OK.
- Can read claims: `sub`, `email`, `tenant_id`.

Rollback:
- None (service restart only).

---

### Phase 1 — Canary recognition & legacy injection control
**Objective:** ensure canary user triggers new pipeline and avoids legacy memory injection.

Steps:
1) Confirm canary allowlist includes:
   - `97b572b207...` (sub)
   - `mark@canarybuilds.com`
   - `akadmin` (username for fallback; only works if claims exist)
2) Verify dispatcher logic:
   - For canary users: skip legacy `Relevant Memory` prepend and run follow‑up/recency path.
3) Confirm `pronterlabs-chat` still injects `Relevant Memory` (legacy), but dispatcher **ignores it** for canary users.

Success criteria:
- Dispatcher log input **does NOT** show the `Relevant Memory` block when canary user is present.
- Follow‑up resolver logs appear for canary user.

Rollback:
- Remove canary entries from `FOLLOWUP_CANARY_USERS` or set flags OFF.

---

### Phase 2 — Enable conversation state + follow‑up resolver (canary only)
**Objective:** make short follow‑ups reuse previous topic context.

Steps:
1) Enable per‑user canary behavior (already done via allowlist).
2) Verify follow‑up resolver produces `rewritten_query` for short follow‑ups.
3) If follow‑up resolver fails, verify heuristic fallback is used.

Success criteria:
- Asking “What about for software?” after “What is a white paper?” yields a continuation, not a new unrelated question.

Rollback:
- Remove canary allowlist or turn off `FEATURE_FOLLOWUP_RESOLVER`.

---

### Phase 3 — Two‑pass retrieval (segment recency + long‑term facts)
**Objective:** add short‑term segment context and long‑term fact retrieval without breaking memory isolation.

Steps:
1) Confirm dispatcher can reach tenant DB:
   - `TENANT_DB_URL` reachable from dispatcher.
2) Resolve which tables exist (compat with old Memlink):
   - Prefer `memlink_segment_summaries` / `memlink_memory_facts`.
   - Fallback to `tenant_segment_summaries` / `tenant_memory_facts`.
   - Final fallback: `chat_segment_summaries` / `memory_facts` (chat‑local only).
3) Recency query returns top‑k segments ordered by updated_at (strong recency bias).
4) Fact query uses the rewritten query and enforces tenant/user scope via RLS.
5) Merge logic injects `RECENT_CONTEXT` and relevant facts into the prompt.

Success criteria:
- Short‑term summary appears in injected context for canary.
- Long‑term facts still retrieved as before (no regression).

Rollback:
- Disable `FEATURE_TWO_PASS_RETRIEVAL` or remove canary allowlist.

---

### Phase 4 — Sidebar page (context stack)
**Objective:** expose a short “context stack” page from the sidebar that describes the three layers.

Steps:
1) Add a sidebar link (Context → Active Context).
2) Create a `/context` page with the 3‑layer summary.
3) Ensure navigation does not affect chat functionality.

Success criteria:
- Sidebar link opens the page.
- Chat still loads normally.

Rollback:
- Remove the link and page.

---

### Phase 5 — Canary validation test plan
**Manual test sequence (canary user only):**
1) Ask: “What is a white paper?”
2) Ask: “What about for software?”
3) Confirm assistant uses the white‑paper context.
4) Ask a personal recall question to validate facts retrieval still works.

Expected outcome:
- Follow‑up is contextual; facts are not overriding the topic unless relevant.

---

## Observability checklist
- Dispatcher logs show:
  - auth exchange 200
  - follow‑up resolution output
  - no `Relevant Memory` prepend for canary
  - recency + memory fact retrieval runs (or fails open)
- Bifrost logs show:
  - `chatId` set from `X-Chat-Id`
- PronterLabs chat logs show:
  - still injecting `Relevant Memory` (legacy); OK for non‑canary

---

## Rollback plan
1) Disable canary allowlist (remove user from `FOLLOWUP_CANARY_USERS`).
2) Set feature flags OFF (already default).
3) Restart dispatcher.
4) If needed, revert dispatcher commits (use restore timeline doc).

---

## Open risks
- Trust Kernel 503 prevents canary matching.
- Legacy memory injection can still bias the prompt if canary is not matched.
- If tenant DB is unavailable, recency falls back safely but reduces quality.
- Old Memlink tables may not include tenant/user columns; fallback must stay chat‑local.

## Confidence
Estimated confidence: **95%** provided:
- feature flags remain gated during rollout,
- tenant DB is reachable from dispatcher, and
- RLS variables are set for tenant/user in two‑pass retrieval.

---

## Files & settings touched (reference)
- `pronterlabs/dispatcher/src/api.py`
- `pronterlabs/dispatcher/src/context/*`
- `pronterlabs/dispatcher/docker-compose.yml`
- `FOLLOWUP_CANARY_USERS`, `TENANT_DB_URL`, `REDIS_URL`
