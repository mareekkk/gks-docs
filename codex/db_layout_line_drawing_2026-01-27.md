# Database Layout (Line Drawing)

```
     ┌─────────────────────┐
     │   Users / UI / App  │
     └──────────┬──────────┘
                │
                v
     ┌─────────────────────┐
     │   memlink API       │
     │  (retrieval/write)  │
     └──────────┬──────────┘
                │
                │ reads chat + writes jobs
                v
┌──────────────────────────────┐          ┌─────────────────────────────┐
│   pronterlabs_chat DB         │          │   Redis stream (optional)   │
│  conversations, messages      │          │   memlink:job_stream        │
│  outbox_events (chat side)    │          └──────────────┬──────────────┘
└──────────┬───────────────────┘                         │
           │ watcher polls                                 │
           v                                              │
┌──────────────────────────────┐                          │
│        memlink watcher        │                          │
│  enqueues job_outbox rows      │                          │
└──────────┬───────────────────┘                          │
           │                                              │
           v                                              v
┌──────────────────────────────────────────────────────────────────────┐
│                          memlink DB                                 │
│  control plane only: memlink_tenants, memlink_tenant_configs,        │
│  memlink_tenant_mappings, job_outbox, job_runs, job_watermarks,      │
│  memlink_jobs, memlink_query_audit (read audit)                      │
└──────────┬───────────────────────────────────────────────────────────┘
           │ tenant_db routing via tenant config databaseUrl
           v
┌──────────────────────────────────────────────────────────────────────┐
│                         tenant_db (authoritative)                    │
│  tenant_* tables (canonical):                                         │
│   - tenant_chat_summaries                                              │
│   - tenant_segment_summaries                                           │
│   - tenant_memory_facts                                                │
│   - tenant_embeddings                                                  │
│   - tenant_graph_nodes / tenant_graph_edges                            │
│   - tenant_query_audit                                                 │
│  memlink_* views (compat):                                             │
│   - memlink_chat_summaries, memlink_segment_summaries,                 │
│     memlink_memory_facts, memlink_embeddings,                          │
│     memlink_graph_nodes, memlink_graph_edges, memlink_query_audit      │
└──────────────────────────────────────────────────────────────────────┘
```

Notes
- All **tenant data** lives in `tenant_db` (authoritative). Memlink DB is **control-plane only**.
- `memlink_*` views in `tenant_db` keep existing code paths stable while using tenant_* tables.
- Retrieval/write path uses the tenant’s `databaseUrl` for routing.

---

## RLS Scope + Workspace Flow (Line Drawing)

```
User Request
   │
   │  tenant_id + user_id in auth/session
   │  (optional) workspace_id header
   v
memlink API
   │
   ├─ resolve scope:
   │    - explicit scope param >
   │    - workspace_id present => scope=workspace
   │    - else scope=user_private
   │
   ├─ set RLS session vars on tenant_db:
   │    SET app.tenant_id = <tenant_id>
   │    SET app.user_id   = <user_id>
   │
   v
tenant_db (RLS enforced)
   │
   ├─ user_private
   │    WHERE tenant_id = app.tenant_id
   │      AND user_id   = app.user_id
   │
   ├─ workspace
   │    WHERE tenant_id = app.tenant_id
   │      AND scope = 'workspace'
   │      AND workspace_id IN (
   │          SELECT workspace_id
   │          FROM memlink_workspace_memberships
   │          WHERE user_id = app.user_id
   │            AND status = 'active'
   │      )
   │
   └─ org
        WHERE tenant_id = app.tenant_id
        AND scope = 'org'
```

Notes
- Retrieval never widens scope implicitly; empty results must be handled explicitly by the caller.
- Workspace access depends on active membership in `memlink_workspace_memberships`.
- Org scope requires only tenant_id and is blocked unless explicitly requested.

---

## Retrieval Audit Flow (Line Drawing)

```
User Query
   │
   │  tenant_id + user_id
   │  query text (not stored verbatim)
   v
memlink API
   │
   ├─ compute query_fingerprint = hash(query)
   ├─ retrieve from tenant_db (RLS scoped)
   │
   ├─ write read-audit row (tenant_db):
   │    tenant_query_audit
   │    - tenant_id, chat_id, reader_id
   │    - query_fingerprint (not full query)
   │    - record_ids (UUIDs only)
   │    - scopes_accessed / lanes_accessed
   │    - result_count
   │
   └─ return facts + summaries to caller
```

Notes
- Read audit stores hashes + record IDs, not raw query text or full content.
- Audit rows live in tenant_db to match tenant-only data policy.
