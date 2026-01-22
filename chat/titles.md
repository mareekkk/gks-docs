# Auto Titles Strategy

**Strategy:** Deterministic Truncation (Lite)
**Status:** Implemented

## Mechanism
When a new conversation is created (first user message), the system generates a title immediately.

- **Source:** First User Message Content
- **Algorithm:** `content.substring(0, 50)` + ellipsis
- **Execution:** Inside `POST /api/chat` transaction.
- **Cost:** 0 latency, 0 compute.

## Why this approach?
- **Speed:** Instant UI feedback.
- **Reliability:** No dependency on LLM or external services.
- **Consistency:** Same input always yields same title.

## Future Expansion
If higher quality titles are needed, a background job (triggered via `outbox_events`) can:
1. Read full conversation.
2. Generate LLM summary title.
3. Update `conversations.title`.
