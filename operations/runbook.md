# Operations Runbook

## Health Checks
Each service exposes a `/health` endpoint.

```bash
# Gateway
curl -f http://localhost:8003/health

# Executor
curl -f http://localhost:8002/health

# Orchestrator
curl -f http://localhost:8000/health

# Kernel
curl -f http://localhost:3000/health
```

## Service Restart Procedure
If the system becomes unresponsive:

1.  **Restart Application Layer**:
    ```bash
    cd dispatcher && docker compose restart
    ```
2.  **Restart Kernel (If DB/Memory issues)**:
    ```bash
    cd memlink && docker compose restart
    ```

## Logs
*   **Structured Logs**: All services emit JSON logs to stdout (except in local dev reload mode).
*   **Viewing Logs**:
    ```bash
    docker compose logs -f --tail=100
    ```
*   **Key Log Patterns to Watch**:
    *   `"level": "error"`
    *   `"event": "refusal"` (Bifrost denying requests)
    *   `"event": "tool_denied"` (Einbroch blocking unauthorized tools)
