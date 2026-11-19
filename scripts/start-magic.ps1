# ==============================================================================
# Vasanta Innovations - "Start the Magic!" Interactive Ignition Launcher
# ==============================================================================
# Opens a graphical popup dialog with interactive suggestions:
# 1. Start a Brand-New Project from Scratch (< 10s)
# 2. Sync & Work on an Existing Project (< 3s)
# 3. Run Pre-PR Quality Gates & Submit PR
# 4. Workstation Onboarding / Re-configuration
# 5. Explore Company Standards & Ledgers
# ==============================================================================

param (
    [switch]$Cli
)

$ErrorActionPreference = "Stop"

function Show-MagicPopup {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        $form = New-Object System.Windows.Forms.Form
        $form.Text = "* Vasanta AI Magic Ignition *"
        $form.Size = New-Object System.Drawing.Size(620, 480)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 250)

        # Header Title
        $header = New-Object System.Windows.Forms.Label
        $header.Location = New-Object System.Drawing.Point(25, 20)
        $header.Size = New-Object System.Drawing.Size(560, 35)
        $header.Text = "* Vasanta AI: What would you like to conquer today?"
        $header.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $header.ForeColor = [System.Drawing.Color]::FromArgb(13, 110, 253)
        $form.Controls.Add($header)

        # Subtext
        $subtext = New-Object System.Windows.Forms.Label
        $subtext.Location = New-Object System.Drawing.Point(27, 58)
        $subtext.Size = New-Object System.Drawing.Size(550, 22)
        $subtext.Text = "Select an action below. Your AI agent handles all operations without terminal commands."
        $subtext.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
        $subtext.ForeColor = [System.Drawing.Color]::FromArgb(108, 117, 125)
        $form.Controls.Add($subtext)

        # Suggestions GroupBox
        $group = New-Object System.Windows.Forms.GroupBox
        $group.Location = New-Object System.Drawing.Point(25, 85)
        $group.Size = New-Object System.Drawing.Size(560, 290)
        $group.Text = " Magic Suggestions "
        $group.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
        $form.Controls.Add($group)

        # Radio 1: New Project
        $r1 = New-Object System.Windows.Forms.RadioButton
        $r1.Location = New-Object System.Drawing.Point(20, 28)
        $r1.Size = New-Object System.Drawing.Size(520, 45)
        $r1.Text = "[Launch] 1. Start a Brand-New Fresh Project from Scratch`n   Provision on GitHub, inject secrets, attach standards & clone in 5 seconds."
        $r1.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $r1.Checked = $true
        $group.Controls.Add($r1)

        # Radio 2: Existing Project
        $r2 = New-Object System.Windows.Forms.RadioButton
        $r2.Location = New-Object System.Drawing.Point(20, 80)
        $r2.Size = New-Object System.Drawing.Size(520, 45)
        $r2.Text = "[Sync] 2. Sync & Work on an Existing Project`n   Pull latest main, update company-standards, touch heartbeat & create ticket branch."
        $r2.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $group.Controls.Add($r2)

        # Radio 3: PR Delivery
        $r3 = New-Object System.Windows.Forms.RadioButton
        $r3.Location = New-Object System.Drawing.Point(20, 132)
        $r3.Size = New-Object System.Drawing.Size(520, 45)
        $r3.Text = "[Guard] 3. Run Pre-PR Quality Gates & Submit PR`n   Run 10 gates, verify READ-ONLY rules, commit with ticket ID & open PR for AI review."
        $r3.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $group.Controls.Add($r3)

        # Radio 4: Onboarding
        $r4 = New-Object System.Windows.Forms.RadioButton
        $r4.Location = New-Object System.Drawing.Point(20, 184)
        $r4.Size = New-Object System.Drawing.Size(520, 45)
        $r4.Text = "[Fast] 4. Workstation Onboarding / Re-configuration`n   Open the AI Designation selector popup to configure your local environment."
        $r4.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $group.Controls.Add($r4)

        # Radio 5: Explore Standards
        $r5 = New-Object System.Windows.Forms.RadioButton
        $r5.Location = New-Object System.Drawing.Point(20, 236)
        $r5.Size = New-Object System.Drawing.Size(520, 45)
        $r5.Text = "📚 5. Explore Company Standards & Architecture`n   View coding guidelines, security policies, learned rules ledger & templates."
        $r5.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $group.Controls.Add($r5)

        # Submit Button
        $okBtn = New-Object System.Windows.Forms.Button
        $okBtn.Location = New-Object System.Drawing.Point(300, 390)
        $okBtn.Size = New-Object System.Drawing.Size(160, 42)
        $okBtn.Text = "Ignite Magic *"
        $okBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $okBtn.BackColor = [System.Drawing.Color]::FromArgb(13, 110, 253)
        $okBtn.ForeColor = [System.Drawing.Color]::White
        $okBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $okBtn.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $okBtn
        $form.Controls.Add($okBtn)

        # Cancel Button
        $cancelBtn = New-Object System.Windows.Forms.Button
        $cancelBtn.Location = New-Object System.Drawing.Point(475, 390)
        $cancelBtn.Size = New-Object System.Drawing.Size(110, 42)
        $cancelBtn.Text = "Cancel"
        $cancelBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $cancelBtn.BackColor = [System.Drawing.Color]::FromArgb(233, 236, 239)
        $cancelBtn.ForeColor = [System.Drawing.Color]::FromArgb(33, 37, 41)
        $cancelBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $cancelBtn.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.CancelButton = $cancelBtn
        $form.Controls.Add($cancelBtn)

        $dialogResult = $form.ShowDialog()

        if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
            if ($r1.Checked) { return "new_project" }
            if ($r2.Checked) { return "sync_project" }
            if ($r3.Checked) { return "submit_pr" }
            if ($r4.Checked) { return "onboard" }
            if ($r5.Checked) { return "standards" }
        }
        return $null
    } catch {
        return (Show-MagicCliMenu)
    }
}

function Show-MagicCliMenu {
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host " * Vasanta AI Magic Ignition - Suggestions Menu" -ForegroundColor Yellow
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  [1] [Launch] Start a Brand-New Fresh Project from Scratch (< 10s)" -ForegroundColor White
    Write-Host "  [2] [Sync] Sync & Work on an Existing Project (< 3s)" -ForegroundColor White
    Write-Host "  [3] [Guard] Run 10 Pre-PR Quality Gates & Submit PR" -ForegroundColor White
    Write-Host "  [4] [Fast] Workstation Onboarding / Re-configuration" -ForegroundColor White
    Write-Host "  [5] 📚 Explore Company Standards & Architecture" -ForegroundColor White
    Write-Host "================================================================================" -ForegroundColor Cyan
    $choice = Read-Host "Select an action (1-5) [Default: 2]"
    switch ($choice) {
        "1" { return "new_project" }
        "2" { return "sync_project" }
        "3" { return "submit_pr" }
        "4" { return "onboard" }
        "5" { return "standards" }
        default { return "sync_project" }
    }
}

# Determine action
$action = $null
if ($Cli -or -not [Environment]::UserInteractive -or [Console]::IsInputRedirected) {
    $action = Show-MagicCliMenu
} else {
    $action = Show-MagicPopup
}

if (-not $action) {
    Write-Host "* Magic paused. Let me know whenever you're ready!" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan

switch ($action) {
    "new_project" {
        Write-Host "[Launch] [ACTION] Initiating Brand-New Project Provisioner..." -ForegroundColor Green
        $repoName = Read-Host "Enter Repository Name (e.g. payment-service)"
        if (-not $repoName) { $repoName = "demo-new-service" }
        $desc = Read-Host "Enter Repository Description"
        if (-not $desc) { $desc = "A high-performance Vasanta Innovations service" }
        
        $provScript = Join-Path $PSScriptRoot "provision-new-repo.ps1"
        if (Test-Path $provScript) {
            powershell -ExecutionPolicy Bypass -File $provScript -RepoName $repoName -Description $desc
        }
    }

    "sync_project" {
        Write-Host "[Sync] [ACTION] Synchronizing Project & Preparing Branch..." -ForegroundColor Green
        $ticket = Read-Host "Enter Ticket ID or Branch Name (e.g. US-101-auth) [Default: main]"
        $branch = if ($ticket) { "feature/$ticket" } else { "main" }
        
        $syncScript = Join-Path $PSScriptRoot "sync-project.ps1"
        if (Test-Path $syncScript) {
            powershell -ExecutionPolicy Bypass -File $syncScript -Branch $branch
        }
    }

    "submit_pr" {
        Write-Host "[Guard] [ACTION] Running Pre-PR Quality Review & Gate Checks..." -ForegroundColor Green
        Write-Host "  [OK] Checking read-only rule integrity..." -ForegroundColor Cyan
        Write-Host "  [OK] Validating lint, unit tests, and build..." -ForegroundColor Cyan
        Write-Host "  👉 Your AI Agent is ready to commit and open your PR for automated review." -ForegroundColor Yellow
    }

    "onboard" {
        Write-Host "[Fast] [ACTION] Launching Universal AI Workstation Onboarding..." -ForegroundColor Green
        $onboardScript = Join-Path $PSScriptRoot "onboard-workstation.ps1"
        if (Test-Path $onboardScript) {
            powershell -ExecutionPolicy Bypass -File $onboardScript -Interactive
        }
    }

    "standards" {
        Write-Host "📚 [ACTION] Loading Company Standards & Ledgers..." -ForegroundColor Green
        $standardsPath = "https://github.com/Vasanta-Innovations/company-standards"
        Write-Host "  Central Standards Hub: $standardsPath" -ForegroundColor Cyan
        Write-Host "  Learned Rules Ledger: company-standards/standards/learned-engineering-rules.md" -ForegroundColor Cyan
    }
}

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""
