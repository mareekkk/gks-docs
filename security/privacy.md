# Privacy & Isolation

## Multi-Tenancy
GKS is designed for multi-tenant SaaS environments.

### 1. Data Isolation
*   **Strategy**: **Database-per-Tenant**.
*   **Implementation**: Memlink manages a separate Postgres database for each `tenant_id`.
*   **Outcome**: Data from Tenant A cannot physically leak into Tenant B's queries, even via SQL injection.

### 2. Context Scoping
*   **Request Scope**: Every request flow (`Dispatcher` -> `Bifrost` -> `Einbroch`) carries the `tenant_id` and `user_id` as immutable context headers.
*   **Retrieval Scope**: Memlink queries are strictly filtered by these IDs.

## PII Handling
*   **Fact Extraction**: Memlink stores extracted facts. If PII is discussed, it moves to the `memlink_memory_facts` table.
*   **Control**: Users can request deletion of specific facts or wipe their `user_id` history via the `DELETE /v1/user/{id}` endpoint (Memlink).
