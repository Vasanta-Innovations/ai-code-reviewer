# PR Creation & Pre-Push Verification Checklist

**Branch**: `{{BRANCH_NAME}}`  
**Target Base**: `main`  
**Date**: `{{DATE}}`

---

## 1. Pre-Push Verification Scans

| Scan | Objective | Status | Evidence / Details |
|---|---|:---:|---|
| **Credential & Secret Scan** | Zero `.env`, tokens, passwords, or keys staged | `PENDING` | `rg` scan output |
| **No-Masking Scan** | Zero unauthorized `page.route` mocks or conditional asserts | `PENDING` | Scan output |
| **Environment Portability Scan** | Zero hardcoded URLs, tenant IDs, or static accounts | `PENDING` | Scan output |
| **Leak Prevention Scan** | Zero internal rule IDs (`R1`, `G15`, `K4`) in commit text | `PENDING` | Scan output |
| **Diff Sizing Check** | Added + deleted lines < 1,000 (excluding lockfiles) | `PENDING` | `git diff --stat` output |
| **Impacted Test Run** | 100% pass on all affected specs with single worker | `PENDING` | Terminal run receipt |

---

## 2. Diff Sizing Receipt

- **Lines Added**: `0`
- **Lines Deleted**: `0`
- **Total Net Delta**: `0 lines`
- **Files Changed**: `0`

---

## 3. Draft PR Body

### Summary
- 

### Key Technical Changes
- 

### Test Evidence
- Verified locally via: `[Command]` (Result: `X passed`)
