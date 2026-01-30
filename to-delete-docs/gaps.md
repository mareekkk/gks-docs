# Architecture Gaps (Audit Phase)

## 1. No Automated Ingestion
**Severity: Critical**
- Chats occur but Memlink never knows about them.
- No component pushes to `memlink:job_stream`.
- System "didn't know new name for GKS" because it never extracted facts from the conversation where it was mentioned.

## 2. Non-Transactional Chat Persistence
**Severity: High**
- User message and Assistant message are saved in separate transactions.
- Risk of "User said X" being saved, but "AI outcome Y" being lost, leading to hallucinated context in future turns.
- No "Outbox" pattern to guarantee downstream processing.

## 3. Source of Truth Ambiguity
**Severity: Medium**
- Memlink worker expects a payload (legacy payload injection).
- Should transition to fetching canonical state from DB to ensure it processes exactly what was saved.

## 4. Lack of Idempotency
**Severity: Medium**
- If we enable ingestion, we need to ensure the same message isn't processed twice (e.g. on retry).
- Current Redis worker has some retry logic but needs robust deduping based on Message UUIDs.

## 5. Missing Conversation Titles
**Severity: Low**
- New conversations defaulted to "New Chat".
- No "auto-title" generation logic found in Dispatcher or Chat.
