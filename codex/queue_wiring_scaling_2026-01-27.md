# Queue, Wiring, and Scaling Notes (Codex)

Date: 2026-01-27

## 1) Are we using both Postgres and Redis? Why?
Yes, both are used.
- **Postgres** is the **source of truth** (chat data, facts, tenants, audit logs).
- **Redis** is the **fast queue** for job processing (speed + retries).

**Why keep Postgres?**
Redis is fast for moving jobs, but it is not the permanent record. Postgres is the long‑term storage.

Analogy: Redis is the conveyor belt. Postgres is the warehouse.

---

## 2) Wiring risk — line drawing
```
[Auth Token]
     |
     v
[user_id / tenant_id]
     |
     v
[Chat DB: messages + outbox]  ---> (Relay) ---> [Redis Queue] ---> [Worker]
     |                                                        |
     |                                                        v
     +------------------------------------------------> [Memlink DB: facts]
                                                              |
                                                              v
                                                     [Retrieve by same user_id/tenant_id]
```

Wiring risk = any mismatch in IDs or databases along this line.

---

## 3) Better solution to #5 (no chat history passed)
**Best simple fix:** send the last 3–6 chat turns along with memlink facts.
If facts are missing, the model still sees recent context.

Analogy: even if the sticky note isn’t written yet, you still have the last page of notes.

---

## 4) Biggest problem: not finding the original DB
Yes—this is likely happening.
Common causes:
- **Auth sub changed** → new tenant created → empty memory.
- **Worker reads DB A, retrieval reads DB B.**
- **RLS mismatch** blocks facts.

**Auth sub** = the unique user ID from the identity provider (OIDC). If it changes, the system treats you as a new person.

**Best fix:**
- Lock a stable user mapping table for mark@canarybuilds.com.
- Lock tenant mapping (no auto‑provision on sub changes).
- Ensure worker and retrieval always use the same DB.

---

## 5) Suggestions to optimize & scale (Big Tech style)
- **Stable identity graph:** one canonical user_id per person.
- **Central event log:** durable and replayable.
- **Queue vs storage separation:** Redis/Kafka for speed, Postgres for truth.
- **End‑to‑end traceability:** strict audit chain.
- **Fallback context:** always include last N turns.

---

## 6) Line drawings — now vs ideal

### Current
```
Auth Token
   |
   v
auth_sub  --> (auto-tenant if missing)
   |
   v
Chat DB (messages/outbox)
   |
   +--> Redis Queue (if relay running)
             |
             v
         Worker writes facts -> Memlink DB
             |
             v
Retrieve (must match same user_id + tenant_id)
```

### Ideal
```
Auth Token
   |
   v
Identity Service (stable user_id mapping)
   |
   v
Tenant Resolver (locked tenant_id)
   |
   v
Event Log (durable)
   |
   +--> Queue (Redis/Kafka)
             |
             v
         Worker -> Facts Store (Postgres) + Cache (fast)
             |
             v
Retrieve (always same user_id/tenant_id)
   |
   v
Response with: (facts + last N turns)
```
