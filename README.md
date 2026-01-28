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
*   **Not a Chat UI**: GKS is a backend infrastructure; it pairs with frontends like PronterLabs Chat.
*   **Not a Black Box**: Every decision, retrieval, and execution step is audit-logged and traceable.
*   **Not a Vector DB Wrapper**: It uses a structured domain model (facts, summaries, segments) first, with vectors as an optimization.

# GKS: Governed Knowledge System

**The Enterprise-Grade Cognitive Architecture for Regulated Environments.**

GKS is a production-hardened AI platform designed for high-stakes environments where determinism, compliance, and user agency are non-negotiable. It replaces opaque "AI magic" with a transparent, tiered authority model, ensuring that every AI action is authenticated, authorized, and auditable.

## The Four Pillars of GKS

### 1. The Gateway (Bifrost)
**Identity & Orchestration.**
Bifrost is the unified entry point for all AI interactions. It handles:
- **Zero-Trust Authentication**: HMAC/JWT-based identity verification before any model inference.
- **Deterministic Orchestration**: Routes intents to specific, single-purpose Agents (Analyst, Coder, Reviewer) rather than a generic "do-it-all" LLM.
- **Circuit Breaking**: Automatically degrades functionality (e.g., disables memory or tools) to preserve core chat availability during outages.

### 2. The Cognitive Grid (Memlink)
**Total Recall & Identity Awareness.**
Memlink is not just a vector database; it is a user-aware Memory Kernel.
- **GraphRAG**: Automatically builds a Knowledge Graph of user entities and relationships.
- **Strict Provenance**: Every memory fact is tagged with `signer_id` and `trust_tier`, ensuring the AI never "hallucinates" trust where it doesn't exist.
- **Tenant Isolation**: Multi-tenant by design, ensuring data sovereignty for SaaS deployments.

### 3. The Execution Plane (Einbroch)
**Safe & Deterministic Action.**
Einbroch is the rigorous enforcement layer for AI capabilities.
- **Tool Sandbox**: Tools are executed in isolation with strict input validation.
- **Human-in-the-Loop**: "High-Risk" actions (e.g., modifying database state, sending emails) require explicit confirmation and elevated Trust Tokens.
- **Fail-Safe**: If a tool or policy check fails, the system defaults to a safe "Deny" state.

### 4. The Authority Plane (Trust Kernel)
**Legitimacy & Governance.**
The absolute source of truth for AI agency.
- **Trust Tiers**: Assigns cryptographic Tiers (T0-T3) to every request.
    - `T0 (Root)`: System-critical operations.
    - `T1 (Verified)`: Authenticated human actions with strict MFA/Verification.
    - `T2 (Asserted)`: Standard session-based interactions.
    - `T3 (Anonymous)`: Read-only or highly restricted access.
- **Policy-as-Code**: Access control policies are defined as code, versioned, and immutably enforced.

## Production Readiness

- **Latency Optimized**: Average request overhead <50ms.
- **Observability**: OpenTelemetry tracing across all microservices (Bifrost → Memlink → Einbroch).
- **Resilience**: Stateless architecture with horizontal scalability for all compute nodes.

---
*Deployed by industry leaders for mission-critical AI workloads.*

GKS prevents monolithic sprawl by separating responsibilities into discrete, independent services:

1.  **[Memlink](./architecture/components.md#memlink)**: The **Memory Kernel**. Ingests chats, extracts facts, and provides the authoritative data plane.
2.  **[Bifrost](./architecture/components.md#bifrost)**: The **Orchestrator**. Handles intent recognition, routing, and policy enforcement (Control Plane).
3.  **[Einbroch](./architecture/components.md#einbroch)**: The **Executor**. A stateless service that safely runs agents and tools as directed by Bifrost.
4.  **[Trust Kernel](./architecture/components.md#trust-kernel)**: The **Authority**. Issues and validates Trust Tokens for all system components.
5.  **[Dispatcher](./architecture/components.md#dispatcher)**: The **Gateway**. Adapts external protocols (OpenAI API) into GKS internal workflows (Pattern A).
6.  **[PronterLabs Chat](./architecture/components.md#pronterlabs-chat)**: The **Frontend**. Provides the chat interface and user management layer.
