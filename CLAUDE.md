# Claude Code Agent Guidelines: AI Code Reviewer & PR Gatekeeper
**Vasanta Innovation Private Limited** · Zero-Terminal AI Operating System

## 1. Cardinal Invariant: 100% Zero-Terminal Manual Work
> [!CRITICAL]
> **NEVER instruct the human user to execute commands in the shell or terminal.**
> As an autonomous AI agent (Claude Code), you MUST execute all tool calls, background scripts, file modifications, and environment preparations yourself. All results must be presented ready-to-use.

## 2. Repository Mission & Scope
- **Repository:** Vasanta-Innovations/ai-code-reviewer
- **Role:** Automated PR Reviewer
- **Primary Focus:** Gemini-powered GitHub Actions PR review action, 10 PR Quality Gates, architectural compliance.

## 3. Autonomous Execution Commands
- Review runner: `.github/workflows/gemini-pr-review.yml`
- Magic Ignition: `powershell -ExecutionPolicy Bypass -File scripts/start-magic.ps1`

## 4. Strict Safety & Read-Only Invariants
1. **Protected Files**: NEVER modify or delete:
   - Rules in `.cursor/rules/*`
   - Master templates in `templates/*` or policies in `policies/*` (if present)
   - Governance files: `CLAUDE.md`, `AGENTS.md`, `ONBOARDING_PROMPT.md`
   These files are locked with operating system `attrib +R` and Git pre-commit hooks.
2. **Git Safety**: Never push directly to `main` without admin authorization (`ALLOW_EMERGENCY_MAIN_PUSH=1`). Create local feature branches for changes.
3. **Security Heartbeat**: Maintain `.security-heartbeat.json` active within the 28-day window.

## 5. Company Legal Identity
- **Legal Entity:** Vasanta Innovation Private Limited
- **CIN:** U62099ME2026PTC476813
- **Registered Office:** 322/1/9, Rokdiya Nagar, Dattawadi Shegaon, Buldhana, Shegaon, Maharashtra, India – 444203
- **Signatories:** Kailas Vasantarao Tidake (MD & CEO) | Jyoti Dilip Tidke (Director & Operations Lead)
- **Website:** https://vasantainnovations.com/ | **Email:** info@vasantainnovations.com
