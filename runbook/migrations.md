# Database Migrations Runbook

**Target DB:** `pronterlabs_chat`
**Host:** `memlink-postgres`
**User:** `memlink_user`

## How to Apply Migrations

Migrations are currently manual SQL scripts located in `pronterlabs-chat/migrations/`.

1. **Verify Connection:**
   ```bash
   docker exec -it memlink-postgres psql -U memlink_user -d pronterlabs_chat -c "\dt"
   ```

2. **Apply Migration:**
   ```bash
   cat pronterlabs-chat/migrations/001_init.sql | docker exec -i memlink-postgres psql -U memlink_user -d pronterlabs_chat
   ```

3. **Verify Result:**
   Check if new tables (`outbox_events`) exist.
   ```bash
   docker exec -it memlink-postgres psql -U memlink_user -d pronterlabs_chat -c "SELECT * FROM outbox_events LIMIT 1;"
   ```

## Rollback
To revert the migration (WARNING: DESTRUCTIVE):
```sql
DROP TABLE outbox_events;
DROP TABLE messages;
DROP TABLE conversations;
```
