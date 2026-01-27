# Memory Facts Diagnosis (Codex)

Date: 2026-01-27 14:21:26 UTC

Context
- User: mark@canarybuilds.com (akadmin)
- Symptom: facts appear after a delay; sometimes only name/Yolanda show up.
- UI behavior: when facts exist, answers include them; when facts are missing, the model refuses.

Screenshot analysis (plain)
- Screenshot 1: After "my name is mark", the system later answers "Your name is Mark" but only that. Then after "my mother’s name is Yolanda", it promises to remember it.
- Screenshot 2: In a later chat, the system answers with both "Mark" and "Yolanda".
- Interpretation: memory pipeline is working but delayed; only stored facts are surfaced.

Answers
1) Is the system fully working?
- Mostly, but not fully reliable. The pipeline works when every component is running and IDs match. If any component (relay/queue/identity wiring) is off, facts will not appear.
- Analogy: a delivery chain where every courier must show up. One missing courier = no package.

2) How long does the worker need to process and provide facts?
- Typical: ~10–40 seconds.
- Worst case: 1–2 minutes if queue is busy or LLM calls are slow.
- Reason: polling/relay delay + worker idle delay + LLM time.
- Analogy: mailroom pickup every few seconds, then sorting, then delivery. If trucks are late, you wait longer.

3) Redis vs Postgres (queue behavior)
- Postgres queue: simple and fewer moving parts, but slower and less resilient at scale.
- Redis queue: fast and resilient (retries/DLQ), but requires a relay to move outbox events into Redis. If relay is down, nothing gets processed.
- Analogy: Postgres is manual sticky notes; Redis is a conveyor belt—but someone must place boxes on it.

4) Wiring risk (plain)
- Wiring risk means IDs or DBs don’t line up, so facts are stored in one place and looked up in another.
- Common risks:
  - Different user_id/tenant_id between write and read (RLS blocks retrieval).
  - New tenant auto-created if auth sub changes → empty memory.
  - Worker reading a different DB than the chat app writes to.
- Analogy: you wrote a letter to mailbox A but you check mailbox B.

4b) Wiring risk (deeper)
- The chain must match end-to-end: auth token → user_id → tenant_id → outbox event → worker → memlink facts → retrieval.
- If any ID changes (new auth sub, new tenant, new DB), facts disappear due to strict RLS and scoping.
- Analogy: if your apartment number changes mid-delivery, the doorman can’t hand you the package.

5) More detail on “#5” (no chat history passed)
- The dispatcher only sees the last user message plus memlink facts. It does not see full chat history.
- If facts are not ready yet, the assistant has no memory context.
- Analogy: the assistant only reads sticky notes on the desk. If the note isn’t written yet, it “forgets.”

6) User akadmin has more facts but only sees Mark + Yolanda
- Likely routed to a new tenant/user scope or a different DB/schema. This creates a fresh, empty memory view.
- Auto-provisioning creates a new tenant if the auth sub changed or lookup failed.
- Analogy: you moved to a new building; your old mail stays at the old building.

Short takeaway
- Memory works, but it is asynchronous and sensitive to identity/DB wiring. If any link is misaligned, facts vanish from retrieval.
