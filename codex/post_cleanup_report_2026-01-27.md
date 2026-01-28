# Post-Cleanup Report

Date: 2026-01-28 04:19:27 UTC

## Keep Identity
- keep_sub: `97b572b207892a97bdf3912705cf12bd9744ff38a7d9505ca48767cbd0ab07e1`
- keep_tenant: `0446ba0d-f10c-459a-8d1b-5988562164ca`

## memlink DB Counts
| facts | summaries | segments | embeddings | graph_nodes | graph_edges | jobs | job_runs | query_audit | tenants | tenant_mappings |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 5 | 5 | 0 | 38 | 0 | 0 | 2105 | 2105 | 18 | 1 | 0 |

## pronterlabs_chat DB Counts
| conversations | messages | outbox_events | tenants |
| --- | --- | --- | --- |
| 23 | 112 | 112 | 1 |

## Notes
- All other users, tenants, and related data were removed.
- Tenant databases (memlink_tenant_master, tenant_dev) were cleared.