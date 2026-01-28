# Data Flow

## 1. Chat Execution Flow (Synchronous)

This flow describes how a user's message is processed in real-time to generate a response.

1.  **Ingress**: User sends message context via **PronterLabs Chat**.
2.  **Adaptation**: **Dispatcher** receives `POST /v1/chat`, generates a unique `request_id`, and creates the "Identity Context" (wrapping facts with "You are...").
3.  **Routing**:
    *   Dispatcher calls **Bifrost** (`POST /v1/route`).
    *   Bifrost acts as the Policy Definition Point (PDP).
    *   Bifrost queries **Memlink** for evidence (Facts/Summaries).
    *   Bifrost outputs a `RoutingDecision` (Allow/Deny, selected Agents, permitted Tools).
4.  **Enforcement**: Dispatcher validates the decision. If `deny`, it returns a refusal immediately.
5.  **Execution**:
    *   Dispatcher calls **Einbroch** (`POST /v1/execute`).
    *   Einbroch initializes the Agent (e.g., `agent.analyst`).
    *   Agent generates a Plan.
    *   Agent requests Tool usage.
    *   Einbroch **Verifies Trust Token**: Checks `RS256` signature and expiration.
    *   Einbroch validates Tool request against the `RoutingDecision` allowlist.
    *   Einbroch executes Tool (stateless, sandboxed).
    *   Einbroch returns `ExecutionResult` (Final Text + Trace).
6.  **Response**: Dispatcher formats the result into an OpenAI-compatible response and sends it to PronterLabs Chat.

## 2. Memory Ingestion Flow (Asynchronous)

This flow describes how short-term chat logs become long-term authoritative memory.

1.  **Persistence**: PronterLabs Chat saves the user message and assistant response to its PostgreSQL database (`chat` table).
2.  **Detection**: **Memlink Watcher** polls the database for new message rows.
3.  **Job Creation**: Watcher enqueues a `summarize` job in the `memlink_jobs` table.
4.  **Processing**:
    *   **Memlink Worker** picks up the job.
    *   Worker retrieves conversation history.
    *   Worker calls LLM to generate/update the **Rolling Summary**.
    *   Worker calls LLM to extract **Atomic Facts** (e.g., "User's name is Mark").
5.  **Storage**:
    *   Worker persists Facts to `memlink_memory_facts`.
    *   Worker persists Summaries to `memlink_chat_summaries`.
    *   (Optional) Worker generates Embeddings -> `memlink_embeddings`.

## 3. Retrieval Flow

This flow describes how memory is accessed during routing.

1.  **Query**: Bifrost sends a retrieval query to Memlink (`POST /v1/retrieve`) with the `tenant_id` and `user_id`.
2.  **Search**:
    *   Memlink performs semantic search (Vector).
    *   Memlink performs lookup by `chat_id` and `user_id`.
3.  **Verification**: Memlink filters results based on `confidence` score and `scope`.
4.  **Package**: Memlink returns an `EvidencePackage` containing:
    *   `evidence_status` (found/not_found).
    *   List of verifiable `evidence_items`.
