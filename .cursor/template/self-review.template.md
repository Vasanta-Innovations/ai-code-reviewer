# Pre-PR Self-Review Gate Ledger

**Branch**: `{{BRANCH_NAME}}`  
*Rule: All 10 gates must pass before submitting code for human review.*

---

## The 10 Mandatory Quality Gates

| Gate | Category | Status | Verifiable Evidence |
|:---:|---|:---:|---|
| **1** | Verification Point & Requirement Coverage | `PENDING` | All expected results have non-vacuous assertions |
| **2** | Flakiness & Stability Inspection | `PENDING` | No `waitForTimeout`, no raw locators in specs |
| **3** | Environment Portability | `PENDING` | Zero hardcoded URLs or tenant IDs |
| **4** | No-Masking Compliance | `PENDING` | Live data used; zero happy-path mocks |
| **5** | Test Data Lifecycle & Teardown | `PENDING` | `uid()` unique names; cleanup on fixture |
| **6** | Skip & FIXME Compliance | `PENDING` | Zero undocumented skips; defect tickets linked |
| **7** | Tag Completeness & Shard Categorization | `PENDING` | Domain, tier, and priority tags assigned |
| **8** | Learned Review Checklist Sweep | `PENDING` | Zero violations against `review-learning-checklist` |
| **9** | PR Sizing & Standalone Integrity | `PENDING` | Net diff under 1,000 lines; standalone build |
| **10** | Test Collection & Runner Integrity | `PENDING` | Runner `--list` matches; zero `.only` tags |

---

## Gate Reviewer Sign-off

- **Self-Review Completed By**: `{{AGENT_OR_ENGINEER}}`
- **Result**: `PENDING`
- **Date**: `{{DATE}}`
