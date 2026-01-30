# Trust-Kernel Migration Report (FAILURE)

**Timestamp:** 2026-01-21T10:38:00Z
**Status:** FAILED / ABORTED
**Reason:** Discovery Mismatch / Ambiguity

## 1. Discovery Evidence (lighthalzen)
- **Target Root:** /home/mark/llm-server/trust-kernel
- **Directory Exists:** YES
- **Compose Files Found:** NO (Checked docker-compose.yml, compose.yml, recursively)
- **Running Containers (Matching Root):** NONE
- **Stopped Containers (Matching Root):** NONE

## 2. Ambiguity & Conflict
- A container named 'trust-kernel' IS running, but its working directory is:
  /home/mark/llm-server/pronterlabs/dashboard
- This violates the OLD_TRUST_KERNEL_ROOT hard scope rule (/home/mark/llm-server/trust-kernel).
- Rule 4 (No guessing) and Rule 6 (Stop on ambiguity) invoked.

## 3. Verdict
Migration ABORTED. No files were copied, no services were stopped.

## 4. Next Steps
- Verify the correct OLD_TRUST_KERNEL_ROOT.
- If the service matches the dashboard path, update the request with the correct root.
