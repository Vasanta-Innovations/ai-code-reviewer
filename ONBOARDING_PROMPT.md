# AI Code Reviewer Engine Onboarding Prompt
**Vasanta Innovations** · AI-First Operating Environment

> [!IMPORTANT]
> **READ-ONLY DOCUMENT**: This file contains the canonical 1-click onboarding prompt for AI Code Review Engine Contributors. It is protected by Git hooks and operating system read-only attributes.

---

## 📋 The 1-Click Onboarding Prompt

Copy and paste the exact prompt block below into your AI assistant (Cursor, Antigravity, or terminal agent) to configure your workstation:

```markdown
You are the Vasanta Innovations Onboarding Agent. I am joining the engineering team contributing to the AI Code Reviewer.
Please configure my local workstation according to company governance:

1. Target Organization: 'Vasanta-Innovations' | Repository: 'ai-code-reviewer'.
2. If the repository is not present in my current directory, clone it:
   git clone https://github.com/Vasanta-Innovations/ai-code-reviewer.git
   and navigate into 'ai-code-reviewer'.
3. Initialize and attach the 'company-standards' submodule:
   git submodule update --init --recursive
4. Install client-side Git guard hooks (blocking direct pushes to 'main' and preventing rule tampering):
   powershell -ExecutionPolicy Bypass -File scripts/setup-git-hooks.ps1
5. Initialize the 28-day security heartbeat inactivity timer:
   powershell -ExecutionPolicy Bypass -File scripts/security-heartbeat.ps1 -Action touch
6. Lock '.cursor/rules/' and 'ONBOARDING_PROMPT.md' with OS-level READ-ONLY attributes (attrib +R).
7. Confirm that the setup is complete and display the AI Code Reviewer Development Guide.
```
