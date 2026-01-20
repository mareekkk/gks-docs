# Docker Compose Deployment

GKS is designed as a **Microservices Architecture**. For local development and simple deployments, we use Docker Compose.

## Stack Separation

To ensure stability, the architecture is split into two distinct stacks:

1.  **Memory Kernel Stack** (`memlink`): The stateful persistence layer.
2.  **Application Stack** (`dispatcher`, `bifrost`, `einbroch`): The stateless control/data plane.

## 1. Starting the Memory Kernel
See `memlink/README.md` for detailed instructions.

```bash
cd memlink
docker compose up -d
```
**This validates:**
*   Postgres is running.
*   Memlink API is reachable at `http://localhost:3000`.
*   Users/Tenants are seeded (if using dev mode).

## 2. Starting the Application Layer
The `dispatcher` repository contains the composition for the application layer.

```bash
cd dispatcher
docker compose up -d --build
```
This starts:
*   **Bifrost** (Internal :8000)
*   **Einbroch** (Internal :8000, Mapped :8002)
*   **Trust Kernel** (Internal :8000, Mapped :8004)
*   **Dispatcher** (Mapped :8003)

## Network Topology

*   `memlink_net`: An external bridge network that connects the App Layer to the Kernel.
*   `gks_net`: An internal network for Dispatcher <-> Bifrost <-> Einbroch communication.

## Verification
```bash
curl http://localhost:8003/v1/models
# Should return OpenAI-compatible model list
```
