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
                     │      (control plane)     │
                     │  - tenants/configs       │
                     │  - mappings              │
                     │  - jobs/audit            │
                     └─────────────┬────────────┘
                                   │
                                   │ tenant routing (active)
                                   v
                     ┌──────────────────────────┐
                     │       tenant_db          │
                     │   (shared tenant data)   │
                     │  - tenant_* tables       │
                     │  - facts/summaries       │
                     │  - embeddings/graph      │
                     └──────────────────────────┘
                                   │
                                   v
                     ┌──────────────────────────┐
                     │     Docker network       │
                     │     pronter_shared       │
                     │  (chat <-> memlink)      │
                     └──────────────────────────┘
```

Notes
- Facts/summaries now live in **tenant_db** (shared tenant data store).
- **memlink DB** is control plane only (tenants/configs/mappings + jobs/audit).
- Chat messages live in **pronterlabs_chat**.
- Service-to-service connectivity uses the **pronter_shared** Docker network.
