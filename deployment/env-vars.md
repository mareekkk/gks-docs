# Environment Variables

## Shared Variables
| Variable | Description | Default / Example |
| :--- | :--- | :--- |
| `OPENAI_API_KEY` | Required for LLM calls (Einbroch/Memlink). | `sk-...` |
| `DEV_TENANT_ID` | UUID for the development tenant. | `c2c3637d-6975-4d30-a4dc-a6ed6409c2e7` |
| `AUTH_MODE` | Authentication Strategy (dev_static/hmac). | `dev_static` |

## Service Specific

### Bifrost
| Variable | Description |
| :--- | :--- |
| `MEMLINK_URL` | URL to Memlink API (`http://memlink-api:3000/v1/retrieve`). |
| `MEMLINK_MODE` | `http` (default). |

### Dispatcher
| Variable | Description |
| :--- | :--- |
| `BIFROST_URL` | URL to Bifrost (`http://bifrost:8000`). |
| `EINBROCH_URL` | URL to Einbroch (`http://einbroch:8000`). |

### Einbroch
| Variable | Description |
| :--- | :--- |
| `SANDBOX_MODE` | `strict` (default). |

## Secrets Management
*   **Production**: Do *not* commit `.env` files. Use Secret Managers (AWS Secrets Manager, Vault) and inject as environment variables at runtime.
*   **Local**: Copy `.env.example` -> `.env` in each repository.
