# GKS Architecture Cheatsheet
_Last updated: 2026-01-20_

This document answers one question clearly:

> **“If I want to change X in GKS, which repo do I touch?”**

---

## Core Mental Model

GKS is **not** a single agent or RAG system.

It is a **governed AI platform** with **explicit planes**:

| Plane | Purpose |
|-----|-------|
| Identity Plane | Who are you? (external) |
| Authority Plane | What are you allowed to do? |
| Orchestration Plane | What should happen next? |
| Execution Plane | Actually do the thing |
| Memory Plane | Durable, governed knowledge |
| UI Plane | Human interaction |

---

## Repo → Responsibility Map (TL;DR)

| If you want to… | Work on this repo |
|---------------|------------------|
| Add a new tool | **Einbroch** |
| Add a new “agent brain” / planner | **Bifrost** |
| Add background workers / extractors | **Memlink** |
| Improve memory quality or storage | **Memlink** |
| Change login / auth flow | **Dispatcher + Trust Kernel** |
| Change permissions / tiers | **Trust Kernel** |
| Change routing / policy logic | **Bifrost** |
| Improve latency / reliability | Dispatcher / Memlink / Bifrost |
| Change chat UX or persona | OpenWebUI (temporary) |

---

## Repo-by-Repo Breakdown

---

### 🧠 Dispatcher — *Gateway & Identity Bridge*
**Role:**  
Entry point. Validates identity and translates it into authority.

**You touch Dispatcher when you want to:**
- Validate OIDC tokens (Authentik)
- Exchange Identity → TrustToken
- Enforce `IDENTITY_MODE` (shadow / hybrid / strict)
- Handle headers, tracing, retries
- Control prompt injection (memory formatting, truncation)
- Add API-level performance optimizations

**Dispatcher does NOT:**
- Decide *what* tool to use
- Store memory
- Execute tools

---

### 🛡 Trust Kernel — *Authority Plane*
**Role:**  
The **only** system allowed to decide *who can do what*.

**You touch Trust Kernel when you want to:**
- Change Trust Tiers (T1/T2/T3)
- Map users → tenants
- Issue or validate TrustTokens
- Implement API Keys
- Control escalation rules
- Decide tenant ownership (master tenant, future multi-tenant)

**Trust Kernel does NOT:**
- Execute tools
- Route requests
- Store user memory content

---

### 🧭 Bifrost — *Orchestration & Policy*
**Role:**  
The “brain” that decides **what happens next**.

**You touch Bifrost when you want to:**
- Add a new agent/planner
- Change intent classification
- Decide which tool to call
- Apply policy-by-tier rules
- Degrade gracefully if memory is unavailable
- Route requests to Einbroch or Memlink

**Bifrost does NOT:**
- Execute tools
- Store memory long-term
- Authenticate users directly

---

### ⚙️ Einbroch — *Execution Plane*
**Role:**  
Where tools actually run.

**You touch Einbroch when you want to:**
- Add a new tool (weather, time, filesystem, APIs)
- Define tool schemas and risk levels
- Enforce “high-risk tool” blocks
- Sandbox execution
- Control execution timeouts

**Examples of Einbroch tools:**
- Time / Location / Weather
- File system access
- External API calls
- Side-effecting actions

---

### 🧠 Memlink — *Memory Control Plane*
**Role:**  
Durable, governed memory pipelines — **not identity storage**.

**You touch Memlink when you want to:**
- Improve memory retrieval quality
- Tune embeddings / hybrid search
- Adjust summarization or extraction logic
- Run background workers / watchers
- Backfill or reindex data
- Optimize DB, Redis, queues

**Important:**  
Memlink **does not own tenancy**.  
Tenants live in **separate tenant databases**.  
Memlink is a **control plane**, not a user profile DB.

---

### 🖥 OpenWebUI — *Temporary UI Plane*
**Role:**  
User interface only.

**You touch OpenWebUI when you want to:**
- Change chat UI behavior
- Configure OIDC login
- Adjust frontend UX
- Test flows before your custom UI replaces it

**Long-term:**  
OpenWebUI is replaceable. GKS logic does **not** live here.

---

## Common Scenarios (Examples)

### “I want to add a Weather tool”
1. Implement tool in **Einbroch**
2. Allow routing in **Bifrost**
3. No changes needed in Trust Kernel unless risk-tiered

---

### “I want a new agent that plans multi-step tasks”
- **Bifrost**

---

### “The AI doesn’t remember facts well”
- **Memlink**
- Possibly Dispatcher (prompt formatting)
- Possibly Bifrost (policy-based retrieval)

---

### “Login works but permissions are wrong”
- **Trust Kernel**
- Possibly Dispatcher (token exchange)

---

### “System should still work if memory is down”
- **Bifrost** (policy)
- **Dispatcher** (timeouts / fallbacks)

---

## Golden Rules

- **Identity ≠ Authority**
- **Authority ≠ Memory**
- **Memory ≠ UI**
- **Tools never decide policy**
- **Trust Kernel is the final arbiter**
- **Dispatcher is a bridge, not a brain**
- **Memlink is not a tenant DB**

---

## One-Line Summary

> **Dispatcher lets you in.  
> Trust Kernel tells you what you’re allowed to do.  
> Bifrost decides what should happen.  
> Einbroch does it.  
> Memlink remembers it.**

---

_End of cheatsheet_
