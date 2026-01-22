# GKS Connectivity Audit Report
**Date:** 2026-01-21 10:14:00 UTC
**Evaluator:** Senior Infra Verification Agent

## 1. Executive Summary

| Metric | Status | Notes |
| :--- | :--- | :--- |
| **Overall Status** | **FAIL** | Critical network isolation issues on NEW VPS. |
| **OLD VPS (Lighthalzen)** | **UNKNOWN** | SSH Access Denied (Host key/Permission specific error). |
| **NEW VPS (Prontera)** | **FAIL** | Dispatcher stack isolated from Memlink stack. |
| **Einbroch Status** | **STANDALONE** | Running as container `dispatcher-einbroch-1`. Reachable. |

**Critical Finding:**
The `dispatcher` stack and `memlink` stack are running on separate Docker networks (`dispatcher_gks_net` vs `memlink_default`) without connectivity. Reliability issues in `bifrost` (Internal) are caused by its inability to reach `memlink`.

---

## 2. Runtime Map (NEW VPS - Prontera)

### Project: `dispatcher`
*   **Working Dir:** `/home/marek/pronterlabs/dispatcher`
*   **Network:** `dispatcher_gks_net`
*   **Containers:**
    *   `dispatcher-dispatcher-1` (Healthy)
    *   `dispatcher-trust-kernel-1` (Healthy)
    *   `dispatcher-einbroch-1` (Healthy)
    *   `dispatcher-bifrost-1` (**UNHEALTHY**)
    *   `pronterlabs-chat` (Attached to `dispatcher_gks_net`)

### Project: `bifrost` (Standalone)
*   **Working Dir:** `/home/marek/pronterlabs/bifrost`
*   **Network:** `memlink_default`
*   **Containers:**
    *   `bifrost-bifrost-1` (Healthy)

### Project: `memlink`
*   **Working Dir:** (Inferred)
*   **Network:** `memlink_default`
*   **Containers:**
    *   `memlink-memlink-api-1`
    *   `memlink-redis-1`
    *   `memlink-postgres-1`
    *   `memlink-ollama-1` (**UNHEALTHY**)

### Project: `authentik`
*   **Network:** `docker_default`
*   **Containers:** `docker-server-1`, `docker-worker-1`

---

## 3. Dependency Graph & Connectivity (NEW VPS)

**Verified from `dispatcher-dispatcher-1` context:**

| Source | Target | Host:Port | Net Check | Http Check | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Dispatcher | Bifrost (Internal) | `bifrost:8000` | **PASS** | **PASS** | **WARN** (Container Unhealthy) |
| Dispatcher | Einbroch | `einbroch:8000` | **PASS** | **PASS** | **OK** |
| Dispatcher | Trust Kernel | `trust-kernel:8000` | **PASS** | (Inferred) | **OK** |
| Dispatcher | Memlink | `memlink-memlink-api-1` | **FAIL** | **FAIL** | **CRITICAL FAIL** |

**Observation:**
*   **Bifrost Split Brain:** There are two Bifrost instances. Dispatcher is wired to the *Internal* one (`dispatcher-bifrost-1`), which is isolated from Memlink. The *Standalone* one (`bifrost-bifrost-1`) works but is unused by Dispatcher.
*   **Einbroch:** Correctly wired and reachable as `http://einbroch:8000`.

---

## 4. OLD vs NEW Comparison

**Lighthalzen (OLD):** `SKIPPED` - Unable to verify. SSH authentication failed despite key presence. Likely configuration drift or permission issue.

**Comparison:**
Cannot perform direct runtime comparison. However, the NEW architecture has clear defects (network partitioning) that likely deviate from a working OLD state.

---

## 5. Findings & Recommendations

### Issues
1.  **Network Partitioning:** `dispatcher` containers cannot talk to `memlink` containers.
2.  **Duplicate Bifrost:** `bifrost` is running in both stacks. The one Dispatcher uses (`dispatcher-bifrost-1`) is broken due to missing Memlink connectivity.
3.  **SSH Access:** Lost access to OLD VPS.

### Actionable Recommendations (Config Only)
1.  **Unify Networks:** Update `docker-compose.yml` in `dispatcher` to join `memlink_default` network (external).
2.  **Consolidate Bifrost:** either:
    *   Point Dispatcher to the standalone Bifrost (`bifrost-bifrost-1`) if on same network.
    *   OR Fix Internal Bifrost by adding it to `memlink_default`.
3.  **Memlink Ollama:** Investigate why `memlink-ollama-1` is unhealthy.

*No code changes were performed during this audit.*
