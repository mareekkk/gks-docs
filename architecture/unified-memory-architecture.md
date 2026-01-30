# Unified Memory Architecture — Implementation Plan

**Date**: 2026-01-30  
**Status**: Approved Specification  
**Scope**: Extensions to PronterLabs memory model for enterprise-grade, multi-tenant production use

---

## 1. Existing Foundation (Preserved)

| Component | Description |
|-----------|-------------|
| **Continuous conversation** | Memory is not bounded by chat threads |
| **Memory lanes** | Profile, Business/Project, Documents/KB |
| **Scopes** | user-private, team/workspace, org-wide |
| **Policy presets** | Enterprise-safe (A) vs Personal-authority (B) |
| **Governed ingestion** | Read/write separation with tiered approval |

This plan **extends** these components with explicit lifecycle, audit, and governance layers.

---

## 2. Memory Lifecycle States

### 2.1 State Definitions

Every memory record carries an explicit `lifecycle_state`:

| State | Meaning | Retrievable? |
|-------|---------|--------------|
| `candidate` | Extracted but not committed | ❌ No |
| `approved` | Approved for use, pending activation | ❌ No (grace period) |
| `active` | Available for retrieval | ✅ Yes |
| `deleted` | Soft-deleted, excluded from retrieval | ❌ No |
| `archived` | Long-term storage, excluded by default | ❌ No (unless explicit) |

### 2.2 State Transitions

```
   ┌─────────────┐
   │  candidate  │ ◄── Ingestion extracts fact
   └──────┬──────┘
          │ approve (user/policy)
          ▼
   ┌─────────────┐
   │   approved  │ ◄── Grace period (optional, tenant policy)
   └──────┬──────┘
          │ activate (auto or explicit)
          ▼
   ┌─────────────┐
   │   active    │ ◄── Available for retrieval
   └──────┬──────┘
          │ delete (user/admin)
          ▼
   ┌─────────────┐
   │   deleted   │ ◄── Soft-deleted, audit preserved
   └─────────────┘
```

### 2.3 Transition Governance

| Transition | Actor | Audit Required? |
|------------|-------|-----------------|
| `candidate` → `approved` | User, Policy Engine, or Admin | ✅ Yes |
| `approved` → `active` | Automatic (after grace) or User | ✅ Yes |
| `active` → `deleted` | User (own records) or Admin (any) | ✅ Yes |
| `deleted` → `active` | Admin only (restore) | ✅ Yes |
| `active` → `archived` | User or Policy (time-based) | ✅ Yes |

### 2.4 Industry Validation

- **Google Knowledge Graph**: Uses `pending`, `verified`, `deprecated` states.
- **Salesforce**: Permission sets include `active`, `inactive`, `deleted` with full audit.
- **Microsoft Purview**: Retention policies explicitly define lifecycle states.

---

## 3. Scope Escalation Path

### 3.1 Scope Hierarchy

```
user-private  <  team/workspace  <  org-wide
```

Scopes are **never merged implicitly**. Each record has exactly one scope at any time.

### 3.2 Escalation Operations

| Transition | Required Actor | Constraints |
|------------|----------------|-------------|
| `user-private` → `team` | Owner (author) | Must specify target team/workspace |
| `team` → `org-wide` | Admin | Requires explicit approval |
| *(no demotion by default)* | Admin only | Demotion creates new record, archives old |

### 3.3 Escalation Record Structure

When scope is promoted, the system preserves:

| Field | Purpose |
|-------|---------|
| `original_author_id` | Who created the record |
| `original_created_at` | Original creation timestamp |
| `promoted_by_id` | Who performed the promotion |
| `promoted_at` | When the promotion occurred |
| `previous_scope` | Scope before promotion |
| `current_scope` | Scope after promotion |

### 3.4 Conceptual Operation: `promote_scope`

```
promote_scope(
  record_id,
  target_scope,
  actor_id,
  justification (optional)
)
```

This operation:
1. Validates actor has permission to promote
2. Validates target scope is valid escalation
3. Updates record scope
4. Writes audit entry
5. Returns success/failure with reason

---

## 4. Read-Side Audit Logging

### 4.1 What Gets Logged

Every retrieval operation logs:

| Field | Description |
|-------|-------------|
| `reader_id` | User who performed the query |
| `tenant_id` | Tenant context |
| `retrieved_at` | Timestamp of retrieval |
| `lanes_accessed` | Which lanes were queried |
| `scopes_accessed` | Which scopes were queried |
| `record_ids` | IDs of records returned (not content) |
| `query_fingerprint` | Hash of query (not full text) |
| `result_count` | Number of records returned |

### 4.2 What Does NOT Get Logged

- Full query text (privacy risk)
- Full record content (compliance risk)
- Retrieval failures with no results (noise)

### 4.3 Compliance Support

| Standard | How Read Audit Supports |
|----------|------------------------|
| **SOC2** | Access logging for security controls |
| **GDPR** | Right to know who accessed personal data |
| **HIPAA** | Access audit for PHI (if applicable) |
| **Internal** | Incident review, debugging, trust transparency |

### 4.4 Retention Policy

- Default: 90 days (configurable per tenant)
- Extended: 1 year for compliance-heavy tenants
- Immutable: Logs cannot be modified, only aged out

---

## 5. Lane Ambiguity Resolution

### 5.1 The Problem

Statement: "I work at PronterLabs."

- **Profile lane**: Personal identity fact about the user
- **Business lane**: Organizational fact about PronterLabs

### 5.2 Resolution: Primary + Secondary Lanes

| Field | Required? | Purpose |
|-------|-----------|---------|
| `primary_lane` | ✅ Yes | Controls storage, retrieval defaults |
| `secondary_lanes` | ❌ Optional | Metadata for cross-lane queries |

### 5.3 Lane Assignment Rules

| Statement Pattern | Primary Lane | Secondary Lane(s) |
|-------------------|--------------|-------------------|
| "I \[verb\] \[thing\]" | Profile | Business (if thing is org entity) |
| "We \[verb\] \[thing\]" | Business | — |
| "\[Org\] \[verb\] \[thing\]" | Business | — |
| "My \[preference\]" | Profile | — |
| "\[Document/policy\] says..." | Documents | Business |

### 5.4 Retrieval Behavior

- **Default**: Query matches `primary_lane`
- **Extended**: Query can opt-in to `secondary_lanes`
- **Never**: Implicit merge across lanes

---

## 6. Retrieval Intent Resolution

### 6.1 Resolution Rules (Heuristic-Based)

| Query Pattern | Lane | Scope |
|---------------|------|-------|
| "What's **my** \[thing\]?" | Profile | user-private |
| "What do **I** \[do/know/prefer\]?" | Profile | user-private |
| "What's **our** \[thing\]?" | Business | team (default) |
| "What are **we** working on?" | Business | team |
| "What does **the company** \[do/know\]?" | Business | org-wide |
| "What's in **the docs** about...?" | Documents | org-wide |
| "What do **you** know about...?" | Explicit merge prompt | (ask user) |

### 6.2 Ambiguity Handling

1. Default to **most restrictive** (user-private, Profile)
2. If zero results, suggest broadening ("Should I check team knowledge?")
3. Never auto-merge without user confirmation

### 6.3 Implementation Approach

- Rule-based regex/keyword matching
- Lightweight LLM call (optional, for edge cases)
- Configurable per tenant

---

## 7. Delete / Forget Semantics

### 7.1 Deletion Model

| Operation | Effect | Reversible? |
|-----------|--------|-------------|
| **Soft delete** | `lifecycle_state = 'deleted'` | ✅ Yes (admin restore) |
| **Hard delete** | Record removed from database | ❌ No |

**Default is always soft delete.**

### 7.2 Retrieval Exclusion

- All retrieval queries filter: `lifecycle_state = 'active'`
- Deleted records are invisible to normal queries
- Admin/audit tools can query deleted records with elevated permissions

### 7.3 Forget Intent Detection

When user says "forget that" or "delete this":
1. Identify target record(s) via context
2. Apply soft delete
3. Log deletion in audit
4. Confirm to user: "I've removed that from my memory."

### 7.4 Compliance Considerations

| Requirement | How Addressed |
|-------------|---------------|
| **GDPR Right to Erasure** | Soft delete + hard delete after retention period |
| **Audit Preservation** | Deleted records remain in audit log (metadata only) |
| **Accidental Deletion** | Soft delete allows admin restore |

---

## 8. Industry Pattern Validation

| Design Element | Industry Pattern | Validation |
|----------------|------------------|------------|
| Explicit lifecycle states | Google KG, Salesforce, Microsoft Purview | ✅ Matches |
| Scope escalation with audit | Notion, Slack, Google Workspace | ✅ Matches |
| Read-side audit logging | Salesforce Shield, M365, AWS CloudTrail | ✅ Matches |
| Primary + secondary lanes | LinkedIn, Google KG, Salesforce | ✅ Matches |
| Intent-based retrieval | Alexa, Siri, Google Assistant | ✅ Matches |
| Soft delete + retention | Salesforce, Google Drive, M365 | ✅ Matches |

---

## 9. Architectural Decisions vs Implementation Details

### Architectural Decisions (This Plan)

| Decision | Rationale |
|----------|-----------|
| 5 lifecycle states | Minimum viable for governance + explainability |
| Scope is single-valued, immutable without promotion | Prevents implicit leakage |
| Read audit logs record IDs, not content | Privacy + compliance balance |
| Primary lane is required | Prevents ambiguous retrieval |
| Soft delete is default | Audit preservation + user trust |
| Intent resolution is heuristic-first | Avoids over-engineering |

### Implementation Details (Not in This Plan)

| Detail | Notes |
|--------|-------|
| Database schema | Tables, columns, indexes |
| API endpoints | REST/gRPC structure |
| Specific regex patterns | For intent resolution |
| Retention period defaults | Configurable per tenant |
| UI for scope promotion | Out of scope |
| Batch processing for lifecycle transitions | Performance optimization |

---

## 10. Summary

This plan refines the existing PronterLabs memory architecture with:

1. **Explicit lifecycle states** — `candidate` → `approved` → `active` → `deleted`
2. **Formalized scope escalation** — `promote_scope` with audit trail
3. **Read-side audit logging** — Who accessed what, when
4. **Lane ambiguity resolution** — Primary + secondary lane tagging
5. **Retrieval intent resolution** — Query → lane + scope mapping
6. **Soft delete semantics** — Reversible, auditable, compliant

These extensions harden the architecture for enterprise-grade, multi-tenant production use while remaining compatible with single-user personal authority mode.
