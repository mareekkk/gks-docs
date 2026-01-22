# Migration Report: chat.pronterlabs.com

**Timestamp (UTC):** 2026-01-21 09:49:00
**Source Host:** lighthalzen
**Destination Host:** prontera
**Domain:** chat.pronterlabs.com

## 1. Migration Summary
- **Status:** SUCCESS (Container) / PARTIAL (Public Reachability)
- **Downtime:** ~20 minutes
- **Method:** Cold Clone (Rsync + Docker Save/Load)

## 2. Discovery Evidence (OLD VPS)
- **Upstream:** `http://localhost:8081`
- **Docker Container:** `pronterlabs-chat` (ID: af649e1c8841)
- **Project:** `pronterlabs-chat`
- **WORKDIR:** `/home/mark/llm-server/pronterlabs-chat`
- **Config:** `docker-compose.yml` (Version 2.40.0)

## 3. Integrity Check
- **docker-compose.yml SHA256:** `d1dd5bb92427e097083e20849523582a1f7ce304bc7a807846360b1aba53e873` (MATCH)
- **.env SHA256:** `5e9ba8f2c7b7bd3cbfa3d3d8b7805c84fb2619b59245f6bef2b98279a8f8d17a` (MATCH)
- **Secret Files:** None detected.

## 4. Storage Migration
- **Volumes:** None (State is stateless or external DB).
- **Bind Mounts:** None (All files in WORKDIR).
- **Restore Status:** PASS.

## 5. Image Migration
- **Image:** `pronterlabs-chat-chat-frontend` (Custom)
- **Exported/Imported:** YES.

## 6. Verification Results
- **Container Status:** UP (Port 8081)
- **Localhost Connectivity (New VPS):** PASS (`curl localhost:8081` returns 200 OK)
- **Public Connectivity:** FAIL (502 Bad Gateway)
  - **Root Cause:** Host Nginx on `prontera` cannot talk to upstream 8081 despite container listening. Suspect firewall or permission issue on host Nginx (Permission Denied for logging prevents debug).
  - **Note:** Container IS running and healthy.

## 7. Final Verdict
- **Migration:** SUCCESS (Data & Runtime)
- **Production Ready:** NO (Requires Nginx/Firewall fix)
- **Safe to Decommission Old:** NO (Until public traffic flows)
- **Recommended Action:** Investigate `prontera` host Nginx logs (requires sudo) or Check UFW/SELinux.
