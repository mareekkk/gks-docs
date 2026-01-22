# Einbroch File Sync Report

**Timestamp**: 20260121_094021
**Status**: **SUCCESS**

## 1. Migration Summary
Successfully mirrored file structure from `lighthalzen` to `prontera`.
- **Source**: `lighthalzen:/home/mark/llm-server/einbroch`
- **Destination**: `prontera:/home/marek/pronterlabs/einbroch`
- **Method**: 2-hop Rsync (Source -> Transit -> Dest) to handle protocol compatibility.

## 2. Integrity Verification
**Result**: **PASS** (Exact Match)

### Metrics
| Metric | Lighthalzen (OLD) | Prontera (NEW) |
| :--- | :--- | :--- |
| **File Count** | 10,479 | 10,479 |
| **Total Bytes** | 202,021,499 | 202,021,499 |
| **Global SHA256** | `20d7a5afca6980de551e97d240850781ec183fdb493b934fef6eb044e6285822` | `20d7a5afca6980de551e97d240850781ec183fdb493b934fef6eb044e6285822` |

### Proof Process
1.  **Count**: `find . -type f | wc -l`
2.  **Bytes**: `du -sb .`
3.  **Hash**: `find . -type f -exec sha256sum {} + | sort -k 2 | sha256sum`

## 3. Errors / Notes
- Direct `rsync` between remotes failed due to protocol mismatch, resolved via local transit sync.
- No files were modified. Destination was synchronized with `--delete` to ensure exact mirror.
