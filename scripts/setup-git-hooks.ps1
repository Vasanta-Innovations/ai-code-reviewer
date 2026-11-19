<#
.SYNOPSIS
    Configures client-side pre-push branch protection, pre-commit rule protection,
    and 28-day security heartbeat inactivity guards.
.EXAMPLE
    .\setup-git-hooks.ps1
#>

[CmdletBinding()]
param()

$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) {
    $repoRoot = Get-Location
}

$hooksDir = Join-Path $repoRoot ".githooks"
if (-not (Test-Path $hooksDir)) {
    New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
}

# 1. Pre-Push Hook (Heartbeat verification & branch protection)
$prePushContent = @'
#!/bin/sh
z40="0000000000000000000000000000000000000000"

# 1. Verify 28-Day Inactivity Security Heartbeat
if [ -f "scripts/security-heartbeat.ps1" ] && command -v powershell >/dev/null 2>&1; then
  powershell -ExecutionPolicy Bypass -File "scripts/security-heartbeat.ps1" -Action touch
  if [ $? -ne 0 ]; then
    echo "❌ [SECURITY BLOCKED] 28-Day inactivity policy triggered."
    exit 1
  fi
elif [ -f "scripts/security-heartbeat.sh" ]; then
  bash "scripts/security-heartbeat.sh" touch
  if [ $? -ne 0 ]; then
    echo "❌ [SECURITY BLOCKED] 28-Day inactivity policy triggered."
    exit 1
  fi
fi

# 2. Guard Main Branch Protection
while read local_ref local_sha remote_ref remote_sha
do
    if [ "$remote_ref" = "refs/heads/main" ] || [ "$remote_ref" = "refs/heads/develop" ]; then
        if [ "$local_sha" = "$z40" ]; then
            echo "❌ [BLOCKED] Deleting branch '$remote_ref' is strictly forbidden!"
            exit 1
        fi
        if [ "$ALLOW_EMERGENCY_MAIN_PUSH" = "1" ]; then
            echo "⚠️ [WARNING] Emergency main push permitted via ALLOW_EMERGENCY_MAIN_PUSH=1."
            exit 0
        fi
        echo ""
        echo "================================================================================"
        echo " ❌ [BLOCKED] Direct push to '$remote_ref' is forbidden by Vasanta Standards!"
        echo "================================================================================"
        echo " All changes must go through a Pull Request for AI inspection & peer review."
        echo ""
        echo " 👉 How to contribute your changes:"
        echo "    1. Create a feature branch:"
        echo "       git checkout -b feature/US-XXX-my-feature"
        echo "    2. Push your feature branch:"
        echo "       git push -u origin feature/US-XXX-my-feature"
        echo "    3. Open a Pull Request on GitHub for AI & human review:"
        echo "       https://github.com/Vasanta-Innovations"
        echo "================================================================================"
        echo ""
        exit 1
    fi
done
exit 0
'@

Set-Content -Path (Join-Path $hooksDir "pre-push") -Value $prePushContent

# 2. Pre-Commit Hook (Heartbeat verification & Read-Only rule/prompt protection)
$preCommitContent = @'
#!/bin/sh

# 1. Verify 28-Day Inactivity Security Heartbeat
if [ -f "scripts/security-heartbeat.ps1" ] && command -v powershell >/dev/null 2>&1; then
  powershell -ExecutionPolicy Bypass -File "scripts/security-heartbeat.ps1" -Action touch
  if [ $? -ne 0 ]; then
    echo "❌ [SECURITY BLOCKED] 28-Day inactivity policy triggered."
    exit 1
  fi
elif [ -f "scripts/security-heartbeat.sh" ]; then
  bash "scripts/security-heartbeat.sh" touch
  if [ $? -ne 0 ]; then
    echo "❌ [SECURITY BLOCKED] 28-Day inactivity policy triggered."
    exit 1
  fi
fi

# 2. Guard Read-Only Rules & Onboarding Prompt
if git diff --cached --name-only | grep -E "^(\.cursor/rules/|ONBOARDING_PROMPT\.md)"; then
  if [ "$ALLOW_ADMIN_RULE_UPDATE" = "1" ]; then
    echo "⚠️ [ADMIN OVERRIDE] Rule/Prompt modification permitted via ALLOW_ADMIN_RULE_UPDATE=1."
    exit 0
  fi
  echo ""
  echo "================================================================================"
  echo " ❌ [BLOCKED] Rules in '.cursor/rules/' and 'ONBOARDING_PROMPT.md' are strictly READ-ONLY!"
  echo "================================================================================"
  echo " Modifying, tampering with, or loosening engineering rules or prompts is prohibited."
  echo " All standards are managed centrally by Tech Leads via 'company-standards'."
  echo "================================================================================"
  echo ""
  exit 1
fi
exit 0
'@

Set-Content -Path (Join-Path $hooksDir "pre-commit") -Value $preCommitContent
git config core.hooksPath .githooks

# 3. Lock .cursor/rules and ONBOARDING_PROMPT.md with Read-Only attribute on Windows
$rulesDir = Join-Path $repoRoot ".cursor\rules"
if (Test-Path $rulesDir) {
    attrib +R "$rulesDir\*.*" /S 2>$null
}
$promptFile = Join-Path $repoRoot "ONBOARDING_PROMPT.md"
if (Test-Path $promptFile) {
    attrib +R $promptFile 2>$null
}

Write-Host "✔ Git hooks (.githooks/pre-push & pre-commit) successfully configured!" -ForegroundColor Green
Write-Host "✔ Direct pushes to 'main', rule/prompt tampering, and 28-day dormancy are guarded." -ForegroundColor Green
