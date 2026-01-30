# Failure Modes & Recovery

## 1. Chat Persist Failure
- **Symptom:** User sees "Error sending message".
- **Cause:** DB Down.
- **Recovery:** DB Restart. No data lost (transaction rolled back).

## 2. Relay Failure
- **Symptom:** Memlink doesn't "remember" new chats.
- **Cause:** Relay crash / Redis down.
- **Recovery:** Restart Relay. It picks up `pending` events from DB (Backpressure handled by DB).

## 3. Worker Failure
- **Symptom:** Summarization lags.
- **Cause:** Worker crash / OOM / LLM Rate Limit.
- **Recovery:** Restart Worker. Redis un-acked messages are reclaimed by other workers or retried.

## 4. LLM Hallucination / Data Corruption
- **Symptom:** Wrong facts.
- **Mitigation:** Use `trust_tier` in schema.
- **Recovery:** Manually delete bad facts from `memlink_facts` table. Re-run summarization (trigger via `memlink-cli` or similar).
