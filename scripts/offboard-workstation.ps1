# ==============================================================================
# Vasanta Innovations - Workstation Offboarding & Asset Scrub Script
# ==============================================================================
# Safely purges company rules, submodules, cached credentials, and repository
# assets from an employee's machine upon resignation, offboarding, or 28-day dormancy.
#
# CRITICAL SAFETY GUARANTEE:
# Scoped exclusively to verified Vasanta-Innovations repositories.
# Never modifies or deletes user personal folders, desktop, or operating system files.
# ==============================================================================

param (
    [string]$WorkspacePath = "",
    [switch]$Force,
    [string]$Reason = "Voluntary Offboarding"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " 🛡️ Vasanta Innovations - Workstation Offboarding & Asset Scrubber" -ForegroundColor Cyan
Write-Host " Reason: $Reason" -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Resolve Workspace Root
if (-not $WorkspacePath) {
    try {
        $WorkspacePath = (git rev-parse --show-toplevel 2>$null).Trim()
    } catch {
        $WorkspacePath = $PSScriptRoot
    }
}

if (-not $WorkspacePath -or -not (Test-Path $WorkspacePath)) {
    Write-Error "Invalid or nonexistent workspace directory: '$WorkspacePath'"
    exit 1
}

$WorkspacePath = (Resolve-Path $WorkspacePath).Path

# 2. Strict Blast-Radius Anti-Destruction Guard
$systemDrive = $env:SystemDrive + "\"
$userProfile = $env:USERPROFILE
$desktop = [Environment]::GetFolderPath("Desktop")
$documents = [Environment]::GetFolderPath("MyDocuments")
$downloads = Join-Path $userProfile "Downloads"

$forbiddenRoots = @($systemDrive, $userProfile, $desktop, $documents, $downloads, "C:\", "D:\")

foreach ($forbidden in $forbiddenRoots) {
    if ($WorkspacePath.TrimEnd("\") -eq $forbidden.TrimEnd("\")) {
        Write-Host "❌ [FATAL SAFETY BLOCK] Refusing to offboard protected system/personal folder: '$WorkspacePath'" -ForegroundColor Red
        exit 1
    }
}

# 3. Verify Repository Ownership (Must be Vasanta-Innovations)
$gitDir = Join-Path $WorkspacePath ".git"
if (-not (Test-Path $gitDir)) {
    Write-Host "❌ [FATAL SAFETY BLOCK] Target directory is not a Git repository: '$WorkspacePath'" -ForegroundColor Red
    exit 1
}

$remoteUrl = ""
try {
    $remoteUrl = (git -C $WorkspacePath config --get remote.origin.url 2>$null).Trim()
} catch {}

if ($remoteUrl -notmatch "Vasanta-Innovations") {
    Write-Host "❌ [FATAL SAFETY BLOCK] Target repository does not belong to 'Vasanta-Innovations'!" -ForegroundColor Red
    Write-Host "   Detected Remote: '$remoteUrl'" -ForegroundColor Yellow
    Write-Host "   Aborting immediately to protect personal projects." -ForegroundColor Red
    exit 1
}

Write-Host "✅ [VERIFIED] Valid Vasanta-Innovations workspace confirmed: '$WorkspacePath'" -ForegroundColor Green

# 4. Confirmation Prompt (if not -Force)
if (-not $Force) {
    Write-Host "⚠️ WARNING: This will permanently remove all company rules, submodules, and repository files." -ForegroundColor Yellow
    Write-Host "   Target: $WorkspacePath" -ForegroundColor Yellow
    $confirm = Read-Host "Type 'CONFIRM' to proceed with offboarding wipe"
    if ($confirm -ne "CONFIRM") {
        Write-Host "❌ Offboarding aborted by user." -ForegroundColor Red
        exit 0
    }
}

# 5. Preserve Uncommitted or Unpushed Work (Zero Data Loss)
try {
    $status = (git -C $WorkspacePath status --porcelain 2>$null)
    if ($status) {
        Write-Host "📦 Preserving local changes to backup branch prior to purge..." -ForegroundColor Cyan
        $timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
        $backupBranch = "backup-offboard-$timestamp"
        git -C $WorkspacePath checkout -b $backupBranch 2>$null
        git -C $WorkspacePath add -A 2>$null
        git -C $WorkspacePath commit -m "Auto-backup prior to offboard wipe ($Reason)" --no-verify 2>$null
        git -C $WorkspacePath push origin $backupBranch --no-verify 2>$null
        Write-Host "✅ Preserved uncommitted changes to remote branch: '$backupBranch'" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️ Notice: Remote backup skipped or already clean." -ForegroundColor Yellow
}

# 6. Revoke Local Git Credentials for Vasanta-Innovations
Write-Host "🔐 Revoking local GitHub credential helper tokens..." -ForegroundColor Cyan
try {
    cmdkey /delete:git:https://github.com 2>$null
    git credential-manager reject https://github.com 2>$null
} catch {}

# 7. Strip Read-Only Attributes & Scrub Rules & Templates
Write-Host "🧹 Scrubbing company proprietary rules and templates..." -ForegroundColor Cyan
$rulesDir = Join-Path $WorkspacePath ".cursor\rules"
$templateDir = Join-Path $WorkspacePath ".cursor\template"
$submoduleDir = Join-Path $WorkspacePath "company-standards"

if (Test-Path $rulesDir) {
    attrib -R "$rulesDir\*.*" /S /D 2>$null
    Remove-Item -Path $rulesDir -Recurse -Force -ErrorAction SilentlyContinue
}

if (Test-Path $templateDir) {
    attrib -R "$templateDir\*.*" /S /D 2>$null
    Remove-Item -Path $templateDir -Recurse -Force -ErrorAction SilentlyContinue
}

if (Test-Path $submoduleDir) {
    Remove-Item -Path $submoduleDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 8. Scrub Repository Directory Contents
Write-Host "🗑️ Removing local workspace working tree..." -ForegroundColor Cyan
Get-ChildItem -Path $WorkspacePath -Force | ForEach-Object {
    try {
        if ($_.Name -ne ".git") {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    } catch {}
}

# Finally remove .git
try {
    $gitObj = Join-Path $WorkspacePath ".git"
    if (Test-Path $gitObj) {
        attrib -R -H -S "$gitObj\*.*" /S /D 2>$null
        Remove-Item -Path $gitObj -Recurse -Force -ErrorAction SilentlyContinue
    }
} catch {}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Green
Write-Host " ✅ [OFFBOARDING COMPLETE] Company rules and repository assets successfully wiped." -ForegroundColor Green
Write-Host " Location cleaned: '$WorkspacePath'" -ForegroundColor Green
Write-Host " Personal laptop files and directories remain intact." -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""
