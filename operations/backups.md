# Backups and Recovery

## Critical Data Stores
There are two primary databases that require backups:

1.  **Memlink Kernel DB** (Postgres): Stores all authoritative facts, summaries, and embeddings.
    *   **Risk**: High. Loss means total amnesia.
2.  **OpenWebUI DB** (Postgres): Stores chat history and user accounts.
    *   **Risk**: Medium. Loss means users lose chat logs, but cognitive memory relies on Memlink.

## Backup Procedure (Standard Postgres)
Use `pg_dump` against the running containers.

```bash
# Backup Memlink
docker exec -t memlink-postgres-1 pg_dump -U postgres memlink > memlink_backup_$(date +%F).sql

# Backup OpenWebUI
docker exec -t openwebui-db-1 pg_dump -U postgres openwebui > openwebui_backup_$(date +%F).sql

# Backup Trust Keys (CRITICAL)
# Trust Kernel keys are stored on disk. Loss = Loss of Trust Authority.
tar -czvf trust_keys_backup_$(date +%F).tar.gz trust-kernel/src/keys/
```

## Restoration
```bash
cat memlink_backup.sql | docker exec -i memlink-postgres-1 psql -U postgres memlink
```
