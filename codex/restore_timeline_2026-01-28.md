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
