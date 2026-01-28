# Database Layout (Line Drawing)

```
                     ┌──────────────────────────┐
                     │         Users / UI       │
                     └─────────────┬────────────┘
                                   │
                                   v
                     ┌──────────────────────────┐
                     │    pronterlabs_chat DB   │
                     │  (conversations, msgs,   │
                     │   outbox_events)         │
                     └─────────────┬────────────┘
                                   │
                        outbox -> jobs/relay
                                   │
                                   v
                     ┌──────────────────────────┐
                     │       memlink DB         │
                     │  (control plane + facts  │
                     │   right now)             │
                     │  - tenants/configs       │
                     │  - jobs/audit            │
                     │  - facts/summaries       │
                     └─────────────┬────────────┘
                                   │
                                   │ (optional tenant routing)
                                   v
                     ┌──────────────────────────┐
                     │  tenant DBs (per-tenant) │
                     │  memlink_tenant_master   │
                     │  tenant_dev              │
                     │  (future/optional data   │
                     │   persistence target)    │
                     └──────────────────────────┘
```

Notes
- Today, facts/summaries are stored in **memlink DB** (control plane + data).
- Tenant DBs exist for **future/optional per-tenant persistence**.
- Chat messages live in **pronterlabs_chat**.
