
## Trust Kernel
*   **Type**: Service (Authority)
*   **Responsibility**: Identity Assertion, Trust Tokens, Escalation Management.
*   **Inputs**: Shared Secret + User/Tenant Context.
*   **Outputs**: Signed Trust Tokens (`RS256` JWT).
*   **Owned Data**: `trust_escalations`, `trust_tiers` (Config).
*   **Dependencies**: None (Root of Trust).

## Bifrost
*   **Type**: Service (Orchestrator)
*   **Responsibility**: Intent classification, Policy enforcement, Routing decisions.
*   **Inputs**: `UserChatRequest`, `SystemPolicy`.
*   **Outputs**: `RoutingDecision`.
*   **Owned Data**: None (Stateless). Policy definitions are configuration.
*   **Dependencies**: Memlink (for evidence).

## Einbroch
*   **Type**: Service (Executor)
*   **Responsibility**: Agent execution, Tool sandboxing, Audit logging.
*   **Inputs**: `ExecuteRequest` (containing `RoutingDecision`).
*   **Outputs**: `ExecutionResult` (text + trace).
*   **Owned Data**: None (Stateless).
*   **Dependencies**: LLM Provider, Tool Runtime.

## Memlink
*   **Type**: Service (Kernel)
*   **Responsibility**: Long-term memory, Fact extraction, Evidence gating.
*   **Inputs**: Chat Logs (Ingestion), Retrieval Queries.
*   **Outputs**: `EvidencePackage`, `Summary`, `MemoryFact`.
*   **Owned Data**:
    *   `memlink_memory_facts` (Authoritative Facts)
    *   `memlink_chat_summaries` (Rolling Summaries)
    *   `memlink_embeddings` (Vectors)
*   **Dependencies**: Postgres (Kernel DB, Tenant DBs), Redis (Queue).

## Dispatcher
*   **Type**: Service (Gateway)
*   **Responsibility**: Protocol adaptation (OpenAI <-> GKS), Token streaming, Context injection.
*   **Inputs**: `OpenAIChatRequest` or `UserChatRequest`.
*   **Outputs**: `OpenAIChatCompletion` or `DispatcherResponse`.
*   **Owned Data**: None (Stateless).
*   **Dependencies**: Bifrost, Einbroch.

## PronterLabs Chat
*   **Type**: Service (Frontend)
*   **Responsibility**: User Interface, History persistence, User Management.
*   **Inputs**: User keystrokes.
*   **Outputs**: API calls to Dispatcher.
*   **Owned Data**: `auth_user`, `chat_history`.
*   **Dependencies**: Dispatcher.
