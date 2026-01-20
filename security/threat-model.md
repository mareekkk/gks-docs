# Threat Model

## Trust Boundaries
1.  **Public Internet -> Dispatcher**: Untrusted. Requires Authentication (future) or relies on upstream Gateway.
2.  **Dispatcher -> Bifrost/Einbroch**: Trusted Internal Network.
3.  **App Layer -> Memlink**: Authenticated via HMAC/API Key.

## Key Risks & Mitigations

| Risk | Mitigation | Component |
| :--- | :--- | :--- |
| **Spoofing/Impersonation** | **Trust Tokens**: RS256 signed identity assertion (T0-T3 Tiers). <br> **Fail-Closed**: Einbroch rejects unsigned/invalid requests. | Trust Kernel / Einbroch |
| **Prompt Injection** | **Identity Resolution**: "User" is strictly framed as "You". <br> **Intent Classification**: Malicious intent blocked by Bifrost. | Dispatcher / Bifrost |
| **Tool Abuse** | **Allowlisting**: Tools must be explicitly allowed per request. <br> **Read-Only Default**: Sensitive tools are opt-in. | Einbroch |
| **Hallucination** | **Evidence Gating**: Retrieval refuses to answer without found evidence. | Memlink |
| **Cross-Tenant Leak** | **DB Isolation**: Physical separation of data. | Memlink |
