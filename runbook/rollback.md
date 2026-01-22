# PronterLabs Rollback Runbook (Phase 0 Baseline)

**Date:** 2026-01-22
**Baseline Branch:** `hardening/2026-01-22-baseline`

## 1. Code Reversion

If a deployment fails or critical bugs are introduced, revert code to the baseline snapshot.

### For a specific repository (e.g., `memlink`)
```bash
cd memlink
git checkout hardening/2026-01-22-baseline
```

### For all repositories
```bash
# From pronterlabs root
./create_baseline.sh # This script creates branches, but we can write a revert script if needed.
# Manual revert loop:
for repo in auth-pront bifrost dispatcher einbroch gks-docs memlink pronterlabs-chat trust-kernel; do
    echo "Reverting $repo..."
    (cd $repo && git checkout hardening/2026-01-22-baseline)
done
```

## 2. Database Restoration

We have exported the schema for `memlink` and other critical DBs in `gks-docs/architecture/*.sql`.

### Memlink DB
To restore the schema (WARNING: Data loss if dropping tables!):

```bash
cat gks-docs/architecture/memlink_schema_dump_2026-01-22.sql | docker exec -i memlink-postgres psql -U memlink_user -d memlink
```

*Note: This is a schema-only dump. For full data recovery, rely on daily backups if available (check `backups/` dir).*

## 3. Environment Variable Rollback

If `.env` files were modified, restore them from backups or check the syntax against the `docker-compose.yml` baseline.

## 4. Service Restart

After reverting code and config:

```bash
docker compose down
docker compose up -d --build
```
