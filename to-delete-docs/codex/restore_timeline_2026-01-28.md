# Restore Timeline (PronterLabs Chat)

This timeline documents rollback points and the exact commands to restore each state.

## 0) Discard **local UI refresh + recent chat wiring** (working tree only)
**Description:** Removes uncommitted UI/recents changes and returns the chat app repo to `e914e15`.

**Restore (discard working tree + untracked files):**
```
git -C /home/marek/pronterlabs/pronterlabs-chat reset --hard e914e15
git -C /home/marek/pronterlabs/pronterlabs-chat clean -fd
```

---

## 0.1) Restore to **UI refresh + recent chat wiring** (latest, `8e4a050`)
**Description:** Restores the chat app to the latest UI refresh and recent‑chat wiring.

**Hard reset (rewrites history):**
```
git -C /home/marek/pronterlabs/pronterlabs-chat reset --hard 8e4a050
git -C /home/marek/pronterlabs/pronterlabs-chat push origin main --force
```

**Safe revert (preserves history):**
```
git -C /home/marek/pronterlabs/pronterlabs-chat revert 8e4a050
git -C /home/marek/pronterlabs/pronterlabs-chat push origin main
```

---

## 0.2) Restore to **layout/dock refresh + chat bubbles** (latest, `bf73af6`)
**Description:** Restores the updated layout, dock behavior, centered composer, and user chat bubbles.

**Hard reset (rewrites history):**
```
git -C /home/marek/pronterlabs/pronterlabs-chat reset --hard bf73af6
git -C /home/marek/pronterlabs/pronterlabs-chat push origin main --force
```

**Safe revert (preserves history):**
```
git -C /home/marek/pronterlabs/pronterlabs-chat revert bf73af6
git -C /home/marek/pronterlabs/pronterlabs-chat push origin main
```

---

## 1) Revert to **before the loading‑screen fix** (back to `f6487f4` state)
**Description:** Removes the latest loading/auth refinements and returns to the initial silent‑preload implementation.

**Safe revert (preserves history):**
```
git -C /home/marek/pronterlabs/pronterlabs-chat revert e914e15
git -C /home/marek/pronterlabs/pronterlabs-chat push origin main
```

**Hard reset (rewrites history):**
```
git -C /home/marek/pronterlabs/pronterlabs-chat reset --hard f6487f4
git -C /home/marek/pronterlabs/pronterlabs-chat push origin main --force
```

---

## 2) Revert to **before any silent‑auth changes** (back to `d397a6a` state)
**Description:** Removes all silent‑auth changes and returns to the pre‑silent‑auth chat flow.

**Safe revert (preserves history):**
```
git -C /home/marek/pronterlabs/pronterlabs-chat revert e914e15 f6487f4
git -C /home/marek/pronterlabs/pronterlabs-chat push origin main
```

**Hard reset (rewrites history):**
```
git -C /home/marek/pronterlabs/pronterlabs-chat reset --hard d397a6a
git -C /home/marek/pronterlabs/pronterlabs-chat push origin main --force
```

---

## 3) Restore to **current fixed state** (latest, `e914e15`)
**Description:** Resets the repo to the current stable state with silent‑auth fixes and the “Loading your workspace…” screen.

**Hard reset (rewrites history):**
```
git -C /home/marek/pronterlabs/pronterlabs-chat reset --hard e914e15
git -C /home/marek/pronterlabs/pronterlabs-chat push origin main --force
```

---

## 4) Authentik iframe fix (Nginx header change)
**Description:** Allows Authentik to be framed by chat/dashboard so silent‑auth does not time out.

**Applied change:** `/etc/nginx/sites-enabled/auth.pronterlabs.com.conf`

**Restore (remove iframe allowance):**
```
# Remove these lines under the auth.pronterlabs.com server block:
#   proxy_hide_header X-Frame-Options;
#   add_header Content-Security-Policy "frame-ancestors 'self' https://chat.pronterlabs.com https://dashboard.pronterlabs.com" always;

sudo nginx -t
sudo systemctl reload nginx
```

---

## 5) Bifrost healthcheck fix (port 8000, `eb300ac`)
**Description:** Fixes the Bifrost container healthcheck to probe `http://127.0.0.1:8000/health` (actual server port).

**Safe revert (preserves history):**
```
git -C /home/marek/pronterlabs/bifrost revert eb300ac
git -C /home/marek/pronterlabs/bifrost push origin hardening/2026-01-22-baseline
```

**Hard reset (rewrites history):**
```
git -C /home/marek/pronterlabs/bifrost reset --hard eb300ac^
git -C /home/marek/pronterlabs/bifrost push origin hardening/2026-01-22-baseline --force
```

---

## 6) Dispatcher canary allowlist update (akadmin, `5d167fe`)
**Description:** Adds `akadmin` to the follow‑up canary allowlist in dispatcher compose.

**Safe revert (preserves history):**
```
git -C /home/marek/pronterlabs/dispatcher revert 5d167fe
git -C /home/marek/pronterlabs/dispatcher push origin master
```

**Hard reset (rewrites history):**
```
git -C /home/marek/pronterlabs/dispatcher reset --hard 5d167fe^
git -C /home/marek/pronterlabs/dispatcher push origin master --force
```

---

## 7) Trust‑Kernel JWKS reachability fix (auth.pronterlabs.com host mapping)
**Description:** Ensures Trust‑Kernel can fetch JWKS from Authentik by resolving `auth.pronterlabs.com` to the Docker host gateway (not 127.0.0.1). This is required for `/v1/auth/exchange` to succeed and canary matching to work.

**Operational rollback (if mapping is added via docker-compose):**
```
# Remove the extra_hosts mapping for auth.pronterlabs.com in dispatcher/docker-compose.yml
# Then recreate the trust-kernel container:
docker compose -f /home/marek/pronterlabs/dispatcher/docker-compose.yml up -d trust-kernel
```

---

## 8) Trust‑Kernel OIDC audience alignment (client_id)
**Description:** Aligns Trust‑Kernel `OIDC_AUDIENCE` with the Authentik client_id used by PronterLabs Chat so `/v1/auth/exchange` validates tokens.

**Operational rollback:**
```
# Restore OIDC_AUDIENCE to the previous value (e.g., pronterlabs-dashboard)
# Then recreate trust-kernel:
docker compose -f /home/marek/pronterlabs/dispatcher/docker-compose.yml up -d trust-kernel
```

---

## 9) Bifrost Memlink URL fix (use /v1/retrieve)
**Description:** Ensures Bifrost hits the correct Memlink endpoint so evidence is returned (facts/summaries flow back into responses).

**Operational rollback:**
```
# Restore MEMLINK_URL to the previous value in dispatcher/docker-compose.yml:
#   MEMLINK_URL=http://memlink-api:3000
# Then recreate the bifrost container:
docker compose -f /home/marek/pronterlabs/dispatcher/docker-compose.yml up -d --build --no-deps bifrost
```

---

## 10) Pre‑fix baseline for **False Escalation** changes (Bifrost + Dispatcher)
**Description:** Restore point before applying the structured‑envelope + policy scoping fix for false “Human approval required” escalations.

**Safe revert (preserves history):**
```
git -C /home/marek/pronterlabs/bifrost revert <commit_after_eb300ac>
git -C /home/marek/pronterlabs/bifrost push origin hardening/2026-01-22-baseline

git -C /home/marek/pronterlabs/dispatcher revert <commit_after_7ad051b>
git -C /home/marek/pronterlabs/dispatcher push origin master
```

**Hard reset (rewrites history):**
```
git -C /home/marek/pronterlabs/bifrost reset --hard eb300ac
git -C /home/marek/pronterlabs/bifrost push origin hardening/2026-01-22-baseline --force

git -C /home/marek/pronterlabs/dispatcher reset --hard 7ad051b
git -C /home/marek/pronterlabs/dispatcher push origin master --force
```

---

## 11) Unified Memory Architecture — Phase 1 Baseline (2026-01-30)
**Description:** Restore point before implementing Phase 1 (Lane Assignment) of the unified memory architecture. Database schema already has all required columns (`lifecycle_state`, `primary_lane`, `secondary_lanes`, `scope`, `workspace_id`). This baseline captures the state before lane classification logic is added to the worker.

**Memlink Repository:**
- **Branch**: `main`
- **Commit**: `80ac04acd4ce6c2d71ee6df7d35929c8b4ebfe3e`
- **Status**: Uncommitted changes present (workspace/RLS work in progress)

**GKS-Docs Repository:**
- **Branch**: `main`
- **Commit**: `090ceed4c1c87c36432c51ac4d076add571162f9`
- **Status**: Clean

**Restore Memlink to clean state (discard uncommitted changes):**
```
git -C /home/marek/pronterlabs/memlink reset --hard 80ac04a
git -C /home/marek/pronterlabs/memlink clean -fd
docker compose -f /home/marek/pronterlabs/memlink/docker-compose.yml restart memlink-worker memlink-api
```

**Restore GKS-Docs:**
```
git -C /home/marek/pronterlabs/gks-docs reset --hard 090ceed
```

**Implementation Plan**: See `/home/marek/.gemini/antigravity/brain/3cd1ceb7-36cc-4725-b211-ee41bb7f9d5a/phase1_lane_assignment_plan.md`
