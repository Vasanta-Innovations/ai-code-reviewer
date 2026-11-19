# ==============================================================================
# Vasanta Innovations - Workstation Onboarding Automation Engine
# ==============================================================================
# Sets up a new team member's machine based on their designation in under 30s:
# 1. Clones / verifies the role workspace template from Vasanta-Innovations.
# 2. Initializes the company-standards submodule.
# 3. Configures client-side Git guard hooks (main protection & rule locking).
# 4. Initializes the 28-day security heartbeat inactivity timer.
# 5. Enforces OS-level READ-ONLY protection on rules and onboarding prompts.
# 6. Outputs the role-specific Day-1 orientation checklist.
# ==============================================================================

param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("developer", "qa", "data", "devops", "pm", "design", "admin")]
    [string]$Designation = "developer",
    
    [string]$TargetDir = "",
    [string]$OrgName = "Vasanta-Innovations"
)

$ErrorActionPreference = "Stop"

$RoleMapping = @{
    "developer" = @{
        Repo = "developer-workspace"
        Title = "Full-Stack Software Engineer"
        Focus = "Application features, TypeScript/React/Node, 10 PR Quality Gates, Unit Tests"
    }
    "qa" = @{
        Repo = "qa-automation"
        Title = "QA & Test Automation Engineer"
        Focus = "Playwright E2E suites, test fixtures, synthetic testing, defect triage"
    }
    "data" = @{
        Repo = "data-engineering"
        Title = "Data & Analytics Engineer"
        Focus = "BigQuery pipelines, dbt data modeling, SQL transformations, data schemas"
    }
    "devops" = @{
        Repo = "devops-workspace"
        Title = "DevOps & Platform Engineer"
        Focus = "CI/CD workflows, 1-click repo provisioner, branch guards, cloud secrets"
    }
    "pm" = @{
        Repo = "project-management"
        Title = "Product & Project Manager"
        Focus = "User stories, backlog grooming, PR acceptance criteria, Sprint tracking"
    }
    "design" = @{
        Repo = "design-workspace"
        Title = "UI/UX Designer"
        Focus = "Design system tokens, Figma component specifications, UI review"
    }
    "admin" = @{
        Repo = "admin-workspace"
        Title = "IT & Engineering Administrator"
        Focus = "Organization governance, repository templates, secret audit, compliance"
    }
}

$roleInfo = $RoleMapping[$Designation]
$repoName = $roleInfo.Repo
$roleTitle = $roleInfo.Title

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " 🚀 Vasanta Innovations - 1-Click Workstation Onboarding Engine" -ForegroundColor Cyan
Write-Host " Role: $roleTitle" -ForegroundColor Yellow
Write-Host " Target Repository: $OrgName/$repoName" -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# Determine target directory
if (-not $TargetDir) {
    # Check if current directory is already the cloned workspace
    $currentDir = Get-Location
    $currentLeaf = Split-Path $currentDir -Leaf
    if ($currentLeaf -eq $repoName) {
        $TargetDir = $currentDir.Path
    } else {
        $TargetDir = Join-Path $currentDir $repoName
    }
}

# 1. Clone repository if not already present
if (-not (Test-Path (Join-Path $TargetDir ".git"))) {
    Write-Host "[1/5] Cloning $OrgName/$repoName template repository..." -ForegroundColor Yellow
    $cloneUrl = "https://github.com/$OrgName/$repoName.git"
    git clone $cloneUrl $TargetDir
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to clone repository from $cloneUrl"
        exit 1
    }
} else {
    Write-Host "[1/5] Existing repository verified at: $TargetDir" -ForegroundColor Green
}

Push-Location $TargetDir
try {
    # 2. Initialize and update submodules
    Write-Host "[2/5] Initializing company-standards submodule..." -ForegroundColor Yellow
    git submodule update --init --recursive 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✔ Submodule 'company-standards' attached and up-to-date." -ForegroundColor Green
    } else {
        Write-Host "⚠️ Notice: Submodule update skipped or standards already populated." -ForegroundColor Yellow
    }

    # 3. Configure Git Guard Hooks
    Write-Host "[3/5] Installing client-side guard hooks (pre-push & pre-commit)..." -ForegroundColor Yellow
    $setupHooksScript = Join-Path $TargetDir "scripts\setup-git-hooks.ps1"
    if (-not (Test-Path $setupHooksScript)) {
        $setupHooksScript = Join-Path $PSScriptRoot "setup-git-hooks.ps1"
    }

    if (Test-Path $setupHooksScript) {
        powershell -ExecutionPolicy Bypass -File $setupHooksScript | Out-Null
        Write-Host "✔ Pre-push (main protection) and pre-commit (rule locking) hooks installed." -ForegroundColor Green
    } else {
        git config core.hooksPath .githooks
    }

    # 4. Initialize 28-Day Security Heartbeat
    Write-Host "[4/5] Initializing 28-Day Security Heartbeat inactivity guard..." -ForegroundColor Yellow
    $heartbeatScript = Join-Path $TargetDir "scripts\security-heartbeat.ps1"
    if (Test-Path $heartbeatScript) {
        powershell -ExecutionPolicy Bypass -File $heartbeatScript -Action touch -WorkspaceRoot $TargetDir | Out-Null
        Write-Host "✔ Security heartbeat initialized. Workspace active for next 28 days." -ForegroundColor Green
    }

    # 5. Lock .cursor/rules and ONBOARDING_PROMPT.md as READ-ONLY
    Write-Host "[5/5] Locking engineering rules and prompt with OS READ-ONLY attributes..." -ForegroundColor Yellow
    $rulesDir = Join-Path $TargetDir ".cursor\rules"
    if (Test-Path $rulesDir) {
        attrib +R "$rulesDir\*.*" /S 2>$null
    }
    $promptFile = Join-Path $TargetDir "ONBOARDING_PROMPT.md"
    if (Test-Path $promptFile) {
        attrib +R $promptFile 2>$null
    }
    Write-Host "✔ Rules in '.cursor/rules/' and 'ONBOARDING_PROMPT.md' locked as READ-ONLY." -ForegroundColor Green

    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Green
    Write-Host " 🎉 ONBOARDING COMPLETE: Welcome to Vasanta Innovations!" -ForegroundColor Green
    Write-Host " Designation: $roleTitle" -ForegroundColor Green
    Write-Host " Workspace:   $TargetDir" -ForegroundColor Cyan
    Write-Host " Core Focus:  $($roleInfo.Focus)" -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 YOUR DAY-1 ORIENTATION CHECKLIST:" -ForegroundColor Yellow
    Write-Host "  1. Remember: This workspace is your READ-ONLY starter hub & template." -ForegroundColor White
    Write-Host "  2. For client/business features: Clone or create the active project repository." -ForegroundColor White
    Write-Host "  3. Always branch off 'main': git checkout -b feature/US-XXX-my-task" -ForegroundColor White
    Write-Host "  4. Push to PR: Automated AI Code Review will inspect your changes." -ForegroundColor White
    Write-Host "  5. Direct pushes to 'main' are strictly guarded and blocked." -ForegroundColor White
    Write-Host ""
} finally {
    Pop-Location
}
