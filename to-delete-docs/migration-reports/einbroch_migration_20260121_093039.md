# Einbroch Migration Report

**Timestamp**: 20260121_093039
**Migration Status**: **FAILED** (Aborted per "Stop on Ambiguity" policy)

## 1. Migration Summary
The migration was aborted during the **Discovery Phase**. No authoritative Einbroch deployment could be identified on the OLD VPS (lighthalzen).

## 2. Discovery Evidence
### Source Path
- **Root**: `/home/mark/llm-server/einbroch`
- **Status**: Exists (Confirmed)

### Container inventory
- **Active Containers**: `0`
- **Method**: Checked for containers with `com.docker.compose.project.working_dir` starting with `/home/mark/llm-server/einbroch`.
- **Result**: No matching containers found. `grep` for "einbroch" in all container names also returned no matches likely related to this pillar (only `dispatcher-einbroch` on destination, which is unrelated).

### File Inventory
- **Compose Files**: **NONE**
  - Searched recursively for `docker-compose.yml`, `docker-compose.yaml`.
  - Result: 0 files found.
- **Other Files**:
  - `install_einbroch.sh`, `Makefile`, `Dockerfile` found.
  - `install_einbroch.sh` explicitly directs to `install_dispatcher.sh` for full stack build, suggesting Einbroch is a component of Dispatcher, not a standalone pillar.

## 3. Analysis
The user request requires a "100% cold-clone" of an existing Einbroch pillar. However, no standalone Einbroch pillar exists on the source. The code present seems to be a submodule or component intended to be built/run via the Dispatcher pipeline, which is explicitly out-of-scope ("Do NOT touch... Dispatcher").

## 4. Verdict
**FAILED**. Migration cannot proceed without a valid source deployment (Compose project).

## 5. Safe to Decommission Old Einbroch?
**NO**. No data or services were migrated.
