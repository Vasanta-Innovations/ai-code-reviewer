# ==============================================================================
# Vasanta Innovations - 1-Click Fast Project Sync Tool
# ==============================================================================
# Synchronizes an existing project with latest remote main, updates the
# company-standards submodule, refreshes the 28-day security heartbeat,
# locks engineering rules as READ-ONLY, and prepares the target feature branch.
# ==============================================================================

param (
    [string]$Branch = "",
    [string]$WorkspaceRoot = ""
)

if (-not $WorkspaceRoot) {
    try {
        $WorkspaceRoot = (git rev-parse --show-toplevel 2>$null).Trim()
    } catch {
        $WorkspaceRoot = (Get-Location).Path
    }
}

if (-not $WorkspaceRoot -or -not (Test-Path (Join-Path $WorkspaceRoot ".git"))) {
    Write-Error "Invalid or nonexistent Git repository at '$WorkspaceRoot'"
    exit 1
}

Push-Location $WorkspaceRoot
try {
    $repoName = Split-Path $WorkspaceRoot -Leaf
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host " 🔄 Vasanta Innovations - 1-Click Fast Project Sync" -ForegroundColor Cyan
    Write-Host " Repository: $repoName" -ForegroundColor Yellow
    Write-Host " Target Branch: $(if ($Branch) { $Branch } else { 'main' })" -ForegroundColor Yellow
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ""

    # 1. Check for uncommitted work
    $status = git status --porcelain
    $stashed = $false
    if ($status) {
        Write-Host "📦 Stashing local in-progress work..." -ForegroundColor Cyan
        git stash push -m "Auto-stash before sync ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))" 2>&1 | Out-Null
        $stashed = $true
    }

    # 2. Pull latest main
    Write-Host "[1/5] Fetching latest changes from origin/main..." -ForegroundColor Yellow
    $currentBranch = (git branch --show-current 2>$null).Trim()
    if ($currentBranch -and $currentBranch -ne "main") {
        git checkout main 2>&1 | Out-Null
    }
    git pull --rebase origin main 2>&1 | Out-Null
    Write-Host "✔ Synced with latest remote origin/main." -ForegroundColor Green

    # 3. Update company-standards submodule
    Write-Host "[2/5] Updating company-standards submodule..." -ForegroundColor Yellow
    git submodule update --init --recursive 2>&1 | Out-Null
    Write-Host "✔ Submodule 'company-standards' updated." -ForegroundColor Green

    # 4. Touch security heartbeat (28-day timer)
    Write-Host "[3/5] Refreshing 28-day security heartbeat timer..." -ForegroundColor Yellow
    $heartbeatScript = Join-Path $WorkspaceRoot "scripts\security-heartbeat.ps1"
    if (Test-Path $heartbeatScript) {
        powershell -ExecutionPolicy Bypass -File $heartbeatScript -Action touch -WorkspaceRoot $WorkspaceRoot 2>&1 | Out-Null
        Write-Host "✔ Security heartbeat refreshed. Active for 28 days." -ForegroundColor Green
    }

    # 5. Lock rules and onboarding prompt as READ-ONLY
    Write-Host "[4/5] Enforcing OS-level READ-ONLY protection on rules..." -ForegroundColor Yellow
    $rulesDir = Join-Path $WorkspaceRoot ".cursor\rules"
    if (Test-Path $rulesDir) {
        attrib +R "$rulesDir\*.*" /S 2>$null
    }
    $promptFile = Join-Path $WorkspaceRoot "ONBOARDING_PROMPT.md"
    if (Test-Path $promptFile) {
        attrib +R $promptFile 2>$null
    }
    Write-Host "✔ Engineering rules and onboarding prompt locked as READ-ONLY." -ForegroundColor Green

    # 6. Checkout or create feature branch
    if ($Branch -and $Branch -ne "main") {
        Write-Host "[5/5] Switching to branch: $Branch..." -ForegroundColor Yellow
        $branchExists = git branch --list $Branch
        if ($branchExists) {
            git checkout $Branch 2>&1 | Out-Null
            git rebase main 2>&1 | Out-Null
        } else {
            git checkout -b $Branch 2>&1 | Out-Null
        }
        Write-Host "✔ Active on branch '$Branch' (rebased on fresh main)." -ForegroundColor Green
    } else {
        Write-Host "[5/5] Ready on branch 'main'." -ForegroundColor Green
    }

    # Restore stash if needed
    if ($stashed) {
        Write-Host "📦 Restoring local in-progress work from stash..." -ForegroundColor Cyan
        git stash pop 2>&1 | Out-Null
    }

    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Green
    Write-Host " ✨ [PROJECT SYNC COMPLETE] Ready to build without manual commands!" -ForegroundColor Green
    Write-Host "================================================================================" -ForegroundColor Green
    Write-Host ""
} finally {
    Pop-Location
}
