# Roadmap Phases

## Phase 0: Foundation (Completed)
**Goal**: Establish the "Source of Truth" for memory.
*   [x] **Memlink Kernel**: Ingestion, Summarization, Fact Extraction.
*   [x] **Basic Retrieval**: Vector + SQL search.
*   [x] **Dockerization**: Basic Compose setup.

## Phase 1: Orchestration & Governance (Completed)
**Goal**: Safe execution and OpenAI compatibility.
*   [x] **Bifrost**: Intent Routing and Policy Decision Point.
*   [x] **Einbroch**: Stateless Executor and Policy Enforcement.
*   [x] **Dispatcher**: OpenAI Protocol Adapter.
*   [x] **Identity Resolution**: "You are Mark" context injection.
*   [x] **Trust Kernel**: Authority Service (Tokens, Tiers, Escalation).
*   [ ] **Toolpack Expansion**: Add more tools beyond `util`.

## Phase 2: Scale & SaaS (Future)
**Goal**: Multi-tenant isolation and commercial features.
*   [ ] **Tenant Isolation**: Full database-per-tenant automation.
*   [ ] **Redis Queues**: Replace Postgres-based job queue for high throughput.
*   [ ] **Billing Integration**: Metering usage per tenant.
*   [ ] **Remote Execution**: Run Einbroch agents on separate clusters.
