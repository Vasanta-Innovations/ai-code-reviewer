# Universal AI Workstation Onboarding Prompt
**Vasanta Innovations** · AI-First Operating Environment

> [!IMPORTANT]
> **READ-ONLY DOCUMENT**: This file contains the canonical 1-click interactive onboarding prompt for all team members at Vasanta Innovations. It is protected by Git hooks and operating system read-only attributes.

---

## 🚀 The Single Universal Prompt (All AI Designations)

Copy and paste the exact prompt block below into your AI assistant (Cursor, Antigravity, Claude Code, or terminal agent). An interactive selection popup dialog will open, allowing you to choose your **AI Designation** and configure your entire machine automatically:

```markdown
You are the Vasanta Innovations Universal Onboarding Agent.
Please initiate the interactive workstation onboarding setup for my machine:

1. Launch the interactive designation selector popup:
   powershell -ExecutionPolicy Bypass -File scripts/onboard-workstation.ps1 -Interactive
   (or 'bash scripts/onboard-workstation.sh --interactive' on macOS/Linux)
2. According to my selected AI Designation, clone the starter workspace template, attach 'company-standards', and configure client-side Git hooks.
3. Initialize the 28-day security heartbeat timer and lock '.cursor/rules/' and 'ONBOARDING_PROMPT.md' with OS-level READ-ONLY attributes (attrib +R).
4. Verify my workspace readiness and display my role-specific Day-1 orientation checklist.
5. Always answer, explain, and guide in simple, step-by-step Indian English so any team member can follow easily.
```

---

## 👥 Supported AI Designations in the Selector:

| # | Standardized AI Designation | Template Workspace | Primary Focus |
| :-: | :--- | :--- | :--- |
| **1** | 💻 **AI Software Engineer** | `developer-workspace` | Full-Stack features, TypeScript/React/Node, 10 PR Quality Gates |
| **2** | 🧪 **AI QA & Test Automation Engineer** | `qa-automation` | Playwright E2E suites, synthetic test fixtures, defect triage |
| **3** | 📊 **AI Data & Analytics Engineer** | `data-engineering` | BigQuery ELT pipelines, dbt data modeling, SQL schemas |
| **4** | ⚙️ **AI DevOps & Platform Engineer** | `devops-workspace` | CI/CD workflows, 1-click repo provisioner, branch guards |
| **5** | 📋 **AI Product & Project Manager** | `project-management` | User stories, backlog grooming, PR acceptance criteria |
| **6** | 🎨 **AI UI/UX Designer** | `design-workspace` | Design system tokens, Figma component specifications |
| **7** | 🛡️ **AI Engineering Administrator** | `admin-workspace` | Organization governance, repository templates, compliance |
| **8** | 👥 **AI HR Operations Specialist** | `hr-operations` | Corporate policies, offer/internship/relieving letters, NDAs |
| **9** | 📢 **AI Talent & Brand Marketing Specialist** | `talent-brand-media` | Social media campaigns, 1:1 posts, 9:16 reels, carousels, copy |
| **10** | 💼 **AI Client Commercials Specialist** | `client-operations` | B2B quotations, GST tax invoices, SOW agreements, MSAs, UAT |
