# GKS Pillars Cheat Sheet (Master Tenant Edition)
_Last updated: 2026-01-21_

This is a practical “where do I change what?” map for the **GKS 6‑pillar system** as we’ve discussed across this thread.

---

## 0) The mental model (plain English)

GKS is **not “just a DB with RAG.”**  
It’s a **governed AI runtime** where:

- **Identity** (who you are) is handled by an IdP (Authentik/OIDC when enabled).
- **Authority** (what you’re allowed to do) is issued by **Trust Kernel** as a **TrustToken** (tiered).
- **Dispatcher** is the gateway that **validates identity**, **exchanges for authority**, and **orchestrates** the request.
- **Bifrost** is the **policy + routing** layer that decides what to call (memory, tools, etc.) under the TrustToken.
- **Einbroch** is the **tool executor** where “side effects” live; it enforces **risk gates**.
- **Memlink** is the **memory/control plane** that stores and retrieves durable memory artifacts (facts, summaries, provenance, etc.) per tenant DB.

---

## 1) The 6 pillars and what each one owns

### 1) Dispatcher (Gateway / Orchestrator)
**Owns**
- Request entrypoint (`/v1/chat` etc.)
- Identity validation (OIDC JWT verify) and/or API key auth (if enabled)
- TrustToken acquisition (via Trust Kernel exchange) + caching
- Trace IDs, structured response formatting, error normalization
- Calls to Bifrost and Einbroch (hot path)

**You change Dispatcher when**
- You want to add a new **request mode** or response formatting
- You want better latency, retries, circuit breaking at the gateway
- You want “tools like time/weather” to be callable (usually via Bifrost/Einbroch integration, but Dispatcher may need to pass through headers/metadata and expose capability flags)

---

### 2) Trust Kernel (Authority / Trust Issuer)
**Owns**
- Trust tiers and TrustToken issuance (signing keys, verification material)
- Mapping: **Identity → (user_id, tenant_id, tier)** (the “bridge” contract)
- API key issuance/validation (if you keep API keys)
- Admin authorization basis (e.g., “T0/T1 on Master Tenant”)

**You change Trust Kernel when**
- You add Admin APIs (tenants, keys, audit)
- You add/adjust identity-to-authority mapping rules (NOT policy rules in tools)
- You need key rotation, signing algorithm fixes, stricter contract validation

---

### 3) Bifrost (Policy Engine + Router)
**Owns**
- Interpreting the incoming request under the **TrustToken**
- Selecting which downstream capabilities to invoke:
  - Memory retrieval (Memlink)
  - Tool execution (Einbroch)
  - Additional internal services (future)
- Enforcing **policy rules** (e.g., high-risk intents require T0/T1)

**You change Bifrost when**
- You add a **new policy rule**
- You add a **new route** or capability (e.g., new tool category)
- You need to ensure identity propagation is correct (no drift)

---

### 4) Einbroch (Tools / Side-Effects Executor)
**Owns**
- Tool registry (ToolSpec metadata incl. risk classification)
- Execution of tools (IO, side effects, external calls, etc.)
- **Hard risk enforcement** on tools (deny/require escalation)
- Producing structured “escalation required” responses for the gateway

**You change Einbroch when**
- You want to add a **new tool** (time/weather/location, web fetch, filesystem operations, etc.)
- You need to mark tools as **low vs high risk**
- You need better sandboxing or execution isolation

---

### 5) Memlink (Memory Plane / Durable Memory)
**Owns**
- Durable memory artifacts:
  - summaries, segment_summaries
  - memory_facts
  - provenance fields (trust_tier, signer_id, trace_id)
  - embeddings (if enabled)
- Retrieval APIs for facts/summaries
- Watcher/Worker pipelines that extract and maintain memory artifacts

**Important clarification (your preference)**
- **Tenant DBs are the memory storage.**
- The “Master Tenant” (aka **default tenant**) is the **first tenant DB**.
- Memlink may also act as a control-plane, but memory itself lives per tenant DB.

**You change Memlink when**
- You want to improve memory quality (extraction prompts/filters)
- You want to optimize retrieval and ranking (embeddings, thresholds)
- You want to add new artifact types (audit trails, provenance expansions)
- You want “what do you know about me?” to be stronger/more structured

---

### 6) Identity Provider (Authentik / OIDC) — optional but now working
**Owns**
- User authentication (password, MFA)
- Issuing OIDC tokens (JWT) to clients (OpenWebUI previously, Admin UI later)
- User lifecycle at the identity plane

**You change Authentik when**
- You add a new OIDC client (admin dashboard, new chat UI)
- You adjust token scopes/lifetimes, JWKS, redirect URIs

---

## 2) “Master Tenant” vs “Default Tenant” terminology

In many systems “default tenant” means the first tenant.  
In your system, call it **Master Tenant** (same meaning):

- **Master Tenant = the first tenant DB** created for you (owner/operator).
- Admin privileges can be defined as **T0/T1 on Master Tenant**.
- Future tenants are separate DBs (or separate schemas) as your multi-tenant plan dictates.

---

## 3) Where do I implement X?

### A) “I want to add tools (time/location/weather, etc.)”
**Primary repo/pillar:** **Einbroch**  
**Secondary:** **Bifrost** (routing/policy), sometimes **Dispatcher** (expose result shape / headers)

Typical pattern:
1. Add tool implementation + ToolSpec in Einbroch (risk=low for time/weather).
2. Ensure Bifrost routes “tool intent” to Einbroch when appropriate.
3. Ensure Dispatcher forwards trace_id and returns consistent shape.

---

### B) “I want a new agent”
Clarify the term:
- If you mean a new **LLM persona/role** or workflow orchestration: usually **Dispatcher** (entry) + **Bifrost** (routing).
- If you mean “multi-agent graph” (agent 1/2/3) that coordinates tools: typically **Bifrost** owns the policy + orchestration logic, while **Dispatcher** remains thin.

So:
- **Routing/agent orchestration:** **Bifrost**
- **Gateway / prompt assembly / response shaping:** **Dispatcher**

---

### C) “I want to optimize memory”
**Primary:** **Memlink**  
Examples:
- fact extraction tuning, dedupe, source attribution
- retrieval ranking improvements
- embeddings backfill + vector search toggles
- provenance completeness (trust_tier, signer_id, trace_id)

---

### D) “I want to change who can do what”
**Primary:** **Trust Kernel** (tiers/authority issuance) + **Bifrost/Einbroch** (policy enforcement)

Rule of thumb:
- **Trust Kernel** decides “what tier are you?”
- **Bifrost/Einbroch** decide “does this action require a higher tier?”

---

### E) “I want to add a new tenant / manage API keys”
**Primary:** **Trust Kernel** (admin APIs + data model)  
**Secondary:** Admin Dashboard UI (new frontend service)

---

## 4) Migration/Operations sanity checks (quick)

When you move servers or change networks, verify:

1. **No split-brain Bifrost**
   - Only one Bifrost should be in the request path (the one Dispatcher targets).
2. **Networks**
   - Dispatcher → Bifrost reachable by service name
   - Bifrost → Memlink API reachable by service name
3. **Health endpoints**
   - /health on each pillar
4. **Identity/Authority**
   - Strict/Hybrid modes match your intent
   - Trust Kernel keys loaded correctly
5. **Retrieval**
   - “What is my main project?” returns GKS
   - “What is my company?” returns Canary Builds

---

## 5) Did the “connectivity repair” break the architecture?

**If** the repair did these two things, it is still aligned with your target architecture:

- **Removed duplicate/standalone Bifrost** so there is a single orchestrator path.
- **Connected the stacks via a shared network** so Dispatcher→Bifrost→Memlink works reliably.

**However**, two cautions:
- Setting explicit `container_name:` can **reduce scalability** (you can’t scale replicas easily, and it can cause name collisions). Prefer **network aliases** where possible.
- Joining Compose projects via an external network is fine, but keep naming consistent and document it.

---

## 6) Short answer: RAG vs Agent vs Agentic RAG — what are you?

You are best described as:

**“Agentic, governed memory runtime”**  
- You have **memory (Memlink)**, **tool execution (Einbroch)**, **policy routing (Bifrost)**, and a **tiered authority plane (Trust Kernel)**.
- Classic RAG is a **single retrieval + prompt** loop.
- You are a **governed orchestration layer** around retrieval + tools + provenance.

---

## 7) Quick product description to a normal person

One-liner options:
- “GKS is an AI system that remembers your work safely and can take actions—but only when it’s allowed to.”
- “It’s a ‘brain + security layer’ for AI: memory, tools, and permissions, all audited.”

If someone says “so it’s just a database with RAG”:
- “RAG is just pulling documents into a prompt. GKS adds durable memory, provenance, tool execution, and a tiered permission system so the AI can act safely and predictably.”

---
