# Local Development

Prerequisites:
*   Docker & Docker Compose
*   Node.js 20+ (Memlink)
*   Python 3.10+ (Bifrost/Einbroch/Dispatcher)

## Monorepo-ish Structure
The repositories share a parent folder (`llm-server/`).
```
/llm-server/
  memlink/
  bifrost/
  einbroch/
  dispatcher/
  openwebui/
```

## Running Components Individually

### Python Services (Bifrost, Einbroch, Dispatcher)
Each uses `poetry` for dependency management.

```bash
cd <service>
poetry install
poetry run uvicorn src.main:app --reload
```

*   **Trust Kernel**: Port `8004`
*   **Dispatcher**: Port `8003`
*   **Einbroch**: Port `8002`
*   **Bifrost**: Port `8000`

### Node Services (Memlink)
Uses `pnpm`.

```bash
cd memlink
pnpm install
pnpm dev
```

## Hot-Reload Workflow
1.  Run `memlink` via Docker (stable dependency).
2.  Run the service you are editing (e.g., `bifrost`) locally via `poetry run`.
3.  Point other services to your local instance (adjust URLs in `.env`).
