# Status Tracking — Master Templates

Blank templates for per-branch status tracking. Copy these to initialize state for an active branch; never edit these templates directly.

```
.cursor/template/            ← Master templates (never hold live branch data)
.cursor/state/<branch>/      ← Active state files for a specific branch
```

## Branch Initialization

When starting work on a branch:

```bash
BRANCH=$(git branch --show-current 2>/dev/null || echo "active-task")
STATE=".cursor/state/$BRANCH"
mkdir -p "$STATE"

for f in MASTER_STATUS comment-fix pr-creation self-review pr-review ci-e2e blockers progress; do
  [ -f "$STATE/$f.md" ] || cp ".cursor/template/$f.template.md" "$STATE/$f.md"
done
[ -f "$STATE/state.json" ] || cp ".cursor/template/state.template.json" "$STATE/state.json"
```

Copy only the templates relevant to the active task (e.g., a branch generating new tests does not need `comment-fix.md` until review feedback arrives).

## Status Vocabulary

Five values only: `PENDING`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `SKIPPED`.

- **At most ONE `IN_PROGRESS` task per file.**
- **`DONE` requires verifiable evidence in the Evidence column.**
- **`BLOCKED` requires a matching entry in `blockers.md`.**
- **Updates must be written immediately when state transitions occur.**

## State Files Overview

| Template File | Purpose & Tracking Scope |
|---|---|
| `MASTER_STATUS.template.md` | High-level lifecycle rollup across all phases. |
| `state.template.json` | Machine-readable metadata (Branch, commit SHAs, test counts, PR URL). |
| `progress.template.md` | Append-only event log capturing every completed step with timestamps. |
| `blockers.template.md` | Escalation tracker for blocked items, attempts made, and owner. |
| `comment-fix.template.md` | Review comment tracker with commit SHAs and drafted replies. |
| `pr-creation.template.md` | Pre-push verification checklist, diff stats, and drafted PR description. |
| `self-review.template.md` | The 10 Mandatory Quality Gates with per-gate verification proof. |
| `pr-review.template.md` | Peer review analysis, requirement verification points, and 3x stability audit. |
| `ci-e2e.template.md` | CI/CD pipeline monitoring, failing test triage, and rerun justifications. |
