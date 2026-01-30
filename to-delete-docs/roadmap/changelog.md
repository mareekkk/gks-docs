# Changelog

## [0.1.0] - 2026-01-20
### Added
*   **Documentation Site**: Initial release of `gks-docs` repository.
*   **Trust Authority**: Integration of **Trust Kernel** service (`v1.0`) providing RS256 Token issuance and Trust Tiers.
*   **Architecture Definition**: Formalized Control Plane / Data Plane separation and the new **Authority Plane**.
*   **Identity Resolution**: Dispatcher now automatically resolves unknown "User" references in facts to the active conversational user ("You are...").
*   **OpenAI Compatibility**: Dispatcher fully supports `/v1/chat/completions`.

### Fixed
*   **Memlink Retrieval**: Fixed UUID validation and ingestion bugs for seamless memory recall.
*   **Bifrost Configuration**: Resolved dual-environment configuration mismatch in `docker-compose`.
