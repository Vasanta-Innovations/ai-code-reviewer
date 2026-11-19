# ==============================================================================
# Vasanta Innovations - 28-Day Inactivity Security Heartbeat Guard
# ==============================================================================
# Automatically verifies workspace activity freshness.
# If inactive for > 28 days, triggers the safe offboarding wipe protocol.
# ==============================================================================

param (
    [ValidateSet("touch", "check", "status")]
    [string]$Action = "touch",
    [int]$MaxDays = 28,
    [string]$WorkspaceRoot = ""
)

$ErrorActionPreference = "Stop"

# Determine workspace root
if (-not $WorkspaceRoot) {
    try {
        $WorkspaceRoot = (git rev-parse --show-toplevel 2>$null).Trim()
    } catch {
        $WorkspaceRoot = $PSScriptRoot
    }
}

if (-not $WorkspaceRoot -or -not (Test-Path $WorkspaceRoot)) {
    Write-Error "Invalid or undefined workspace root: '$WorkspaceRoot'"
    exit 1
}

$HeartbeatFile = Join-Path $WorkspaceRoot ".security-heartbeat.json"

function Get-HeartbeatData {
    if (Test-Path $HeartbeatFile) {
        try {
            $content = Get-Content -Path $HeartbeatFile -Raw | ConvertFrom-Json
            return $content
        } catch {
            return $null
        }
    }
    return $null
}

function Save-HeartbeatData {
    param ($data)
    $json = $data | ConvertTo-Json -Depth 3
    Set-Content -Path $HeartbeatFile -Value $json -Force
}

$currentUtc = (Get-Date).ToUniversalTime()
$currentUtcIso = $currentUtc.ToString("o")

# Read existing heartbeat
$data = Get-HeartbeatData

if (-not $data) {
    # Initialize heartbeat
    $repoName = Split-Path $WorkspaceRoot -Leaf
    $data = @{
        org = "Vasanta-Innovations"
        repo = $repoName
        last_active_timestamp = $currentUtcIso
        max_inactive_days = $MaxDays
        policy = "28-Day Dormancy Expiration - Automatic Company Data Scrub"
    }
    Save-HeartbeatData $data
    Write-Host "[Guard] [HEARTBEAT] Security heartbeat initialized for '$repoName' ($currentUtcIso)." -ForegroundColor Cyan
    exit 0
}

# Parse last active timestamp
$lastActive = [DateTime]::Parse($data.last_active_timestamp).ToUniversalTime()
$inactiveSpan = $currentUtc - $lastActive
$daysInactive = [math]::Round($inactiveSpan.TotalDays, 1)

switch ($Action) {
    "status" {
        Write-Host "[Guard] [HEARTBEAT STATUS] Repository: $($data.repo) | Inactive for: $daysInactive days (Policy limit: $MaxDays days)." -ForegroundColor Cyan
        exit 0
    }

    "check" {
        if ($inactiveSpan.TotalDays -gt $MaxDays) {
            Write-Host ""
            Write-Host "================================================================================" -ForegroundColor Red
            Write-Host " 🚨 [SECURITY POLICY EXPIRED] Inactivity exceeds $MaxDays-day limit ($daysInactive days inactive)!" -ForegroundColor Red
            Write-Host "================================================================================" -ForegroundColor Red
            Write-Host " As per Vasanta Innovations Information Security Policy Section 5:" -ForegroundColor Yellow
            Write-Host " Personal/BYOD laptops retaining dormant company repositories must be purged." -ForegroundColor Yellow
            Write-Host " Initiating automatic local workspace scrub..." -ForegroundColor Yellow
            Write-Host "================================================================================" -ForegroundColor Red
            Write-Host ""

            # Locate offboard script
            $offboardScript = Join-Path $WorkspaceRoot "scripts\offboard-workstation.ps1"
            if (-not (Test-Path $offboardScript)) {
                $offboardScript = Join-Path $PSScriptRoot "offboard-workstation.ps1"
            }

            if (Test-Path $offboardScript) {
                & $offboardScript -WorkspacePath $WorkspaceRoot -Force -Reason "28-Day Inactivity Expiration"
            } else {
                Write-Host "[WARN] Offboarding script not found locally. Removing rules and locking workspace..." -ForegroundColor Yellow
                $rulesPath = Join-Path $WorkspaceRoot ".cursor\rules"
                if (Test-Path $rulesPath) {
                    Remove-Item -Path $rulesPath -Recurse -Force
                }
            }
            exit 1
        }
        exit 0
    }

    "touch" {
        if ($inactiveSpan.TotalDays -gt $MaxDays) {
            # Inactive > 28 days: block and scrub
            Write-Host "🚨 [SECURITY VIOLATION] Workspace expired ($daysInactive days inactive). Scrubbing company assets." -ForegroundColor Red
            $offboardScript = Join-Path $WorkspaceRoot "scripts\offboard-workstation.ps1"
            if (-not (Test-Path $offboardScript)) {
                $offboardScript = Join-Path $PSScriptRoot "offboard-workstation.ps1"
            }
            if (Test-Path $offboardScript) {
                & $offboardScript -WorkspacePath $WorkspaceRoot -Force -Reason "28-Day Inactivity Expiration"
            }
            exit 1
        }

        # Otherwise refresh timestamp
        $data.last_active_timestamp = $currentUtcIso
        Save-HeartbeatData $data
        exit 0
    }
}
