# Chat Schema Documentation

**Database:** `pronterlabs_chat`
**Host:** `memlink-postgres`
**Type:** PostgreSQL

## Tables

### 1. `conversations`
Stores high-level chat sessions.

| Column | Type | Default | Description |
|---|---|---|---|
| `id` | UUID | PK | Client-provided or generated Chat ID |
| `user_id` | TEXT | | Auth0 / OIDC Subject ID |
| `tenant_id` | TEXT | 'default' | Multi-tenancy isolation |
| `title` | TEXT | | Auto-generated title (Phase 5) |
| `created_at` | TIMESTAMPTZ | NOW() | |
| `updated_at` | TIMESTAMPTZ | NOW() | |

### 2. `messages`
Stores the actual chat log (Source of Truth).

| Column | Type | Default | Description |
|---|---|---|---|
| `id` | UUID | gen_random_uuid() | Unique Message ID |
| `conversation_id` | UUID | FK | Reference to Conversation |
| `role` | TEXT | | 'user' or 'assistant' |
| `content` | TEXT | | The message text |
| `metadata` | JSONB | '{}' | Extra details (model, trace_id, trust) |
| `created_at` | TIMESTAMPTZ | NOW() | |

### 3. `outbox_events`
Transactional Outbox for reliable event emission.

| Column | Type | Default | Description |
|---|---|---|---|
| `id` | UUID | gen_random_uuid() | Unique Event ID |
| `event_type` | TEXT | | e.g. 'chat.turn.completed' |
| `payload` | JSONB | | JSON data needed by consumer |
| `status` | TEXT | 'pending' | 'pending', 'processed', 'failed' |
| `created_at` | TIMESTAMPTZ | NOW() | |
| `processed_at` | TIMESTAMPTZ | | When consumer finished |
