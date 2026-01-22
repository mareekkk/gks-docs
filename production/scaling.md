# Scaling Strategy

## 1. Database Scaling
- **Chat DB:** High write throughput (users). Can be sharded by `tenant_id` or `user_id`.
- **Memlink DB:** Heavy read/write (vectors). Use Read Replicas for `worker` canonical fetches if load increases.
- **Connections:** Use `pgbouncer` for Relay and Worker connections.

## 2. Ingestion Scaling
- **Relay:** Single instance can handle thousands of events/sec if batch size increased.
  - *Scale Out:* Relays can be scaled horizontally if they use `SKIP LOCKED`.
- **Worker:** Stateless (mostly). Can scale horizontally.
  - **Constraint:** Redis Stream consumer groups allow parallel processing. Use `group: 'memlink-workers'`.

## 3. Vector Search
- **pgvector:** Good for ~10M vectors.
- **Beyond:** Move `memlink_embeddings` to dedicated vector DB (Milvus/Qdrant) if Postgres becomes bottleneck.
