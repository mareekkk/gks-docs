# Contracts & Interfaces

## 1. Gateway Interface (Dispatcher)
*   **Protocol**: HTTP / JSON
*   **Standard**: OpenAI Chat Completions API
*   **Endpoints**:
    *   `POST /v1/chat/completions`: Standard streaming/blocking chat.
    *   `POST /v1/chat`: Internal rich metadata endpoint.

## 2. Routing Contract (Bifrost)
*   **Input**: `UserChatRequest` (User query + Context).
*   **Output**: `RoutingDecision` (JSON).
*   **Key Fields**:
    *   `intent`: Classification of the user's goal.
    *   `policy.status`: `allow` | `deny`.
    *   `agents`: List of selected agents.
    *   `tools.allowed`: Strict allowlist of tool names (`util.echo`, etc.).

## 3. Execution Contract (Einbroch)
*   **Input**: `ExecuteRequest`.
*   **Must Include**: The full `RoutingDecision` signed/passed by Dispatcher.
*   **Constraint**: Einbroch *cannot* execute tools not listed in the `RoutingDecision`.
*   **Output**: `ExecutionResult`.
*   **Key Fields**:
    *   `status`: `ok` | `error` | `denied`.
    *   `output.final_text`: The model's response.
    *   `execution_trace`: Step-by-step audit log of agent thought process.

## 4. Memory Contract (Memlink)
*   **Input**: `RetrievalRequest`.
*   **Key Fields**: `query`, `context` (`tenant_id`, `user_id`).
*   **Output**: `EvidencePackage`.
*   **Strictness**: Return `not_found` explicitly instead of hallucinating.
*   **Key Fields**:
    *   `evidence_status`: `found` | `not_found` | `partial`.
    *   `evidence_items`: List of source-backed facts.

## 5. Shared Domain Models
*   **TenantID**: UUID. Scopes all data.
*   **UserID**: UUID. Scopes user privacy.
*   **RequestID**: UUID. Traced end-to-end.
