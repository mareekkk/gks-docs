# Governed Knowledge System (GKS)

**GKS** is a modular, production-grade infrastructure for **AI memory, cognition, and governed execution**. It transforms ephemeral chat streams into authoritative, durable knowledge and ensures that AI agent actions are strictly controlled by policy.

## Core Problem
Standard LLM chat applications suffer from:
1.  **Amnesia**: Conversations are lost or forgotten once the context window slides.
2.  **Hallucination**: Agents invent facts when historical data is missing.
3.  **Unsafe Execution**: Granting agents tool access without strict governance is dangerous.
4.  **Siloed Knowledge**: Insights trapped in one chat session are inaccessible to others.

## Capabilities
*   **Authoritative Memory**: Automatically extracts and verifies facts from conversations, storing them in a dedicated memory kernel.
*   **Evidence-Gated Retrieval**: Refuses to answer precision-required queries (e.g., IDs, keys) unless verified evidence exists.
*   **Governed Execution**: Enforces strict policy checks (RBAC, side-effect confirmation) before executing any tool or agent action.
*   **Universal Orchestration**: Provides a unified API compatible with standard clients (OpenAI format) while abstracting complex agentic workflows.
*   **Multi-Tenancy**: Physically isolates data and policies per tenant.

## Non-Goals
*   **Not a Chat UI**: GKS is a backend infrastructure; it pairs with frontends like OpenWebUI.
*   **Not a Black Box**: Every decision, retrieval, and execution step is audit-logged and traceable.
*   **Not a Vector DB Wrapper**: It uses a structured domain model (facts, summaries, segments) first, with vectors as an optimization.

## Component Architecture

GKS prevents monolithic sprawl by separating responsibilities into discrete, independent services:

1.  **[Memlink](./architecture/components.md#memlink)**: The **Memory Kernel**. Ingests chats, extracts facts, and provides the authoritative data plane.
2.  **[Bifrost](./architecture/components.md#bifrost)**: The **Orchestrator**. Handles intent recognition, routing, and policy enforcement (Control Plane).
3.  **[Einbroch](./architecture/components.md#einbroch)**: The **Executor**. A stateless service that safely runs agents and tools as directed by Bifrost.
4.  **[Dispatcher](./architecture/components.md#dispatcher)**: The **Gateway**. Adapts external protocols (OpenAI API) into GKS internal workflows (Pattern A).
5.  **[OpenWebUI](./architecture/components.md#openwebui)**: The **Frontend**. Provides the chat interface and user management layer.
