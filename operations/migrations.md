# Database Migrations

## Memlink Schema
Memlink uses a specialized migration runner (via `pnpm`).
*   **Location**: `memlink/migrations/` (SQL files).
*   **Running Migrations**:
    ```bash
    cd memlink
    pnpm migrate
    ```
*   **Docker Behavior**: The container automatically applies pending migrations on startup.

## Application State
Bifrost, Dispatcher, and Einbroch are **stateless**. They do not require database migrations.
*   **Policy Changes**: Bifrost policies are code/config. Deploying a new container version updates the policy.
