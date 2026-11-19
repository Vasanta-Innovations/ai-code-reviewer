# ==============================================================================
# Vasanta Innovations - Universal AI Workstation Onboarding Engine
# ==============================================================================
# Features an interactive GUI popup dialog (with console fallback) to select
# an employee's standardized AI Designation, then provisions the machine:
# 1. Clones / verifies the role workspace template from Vasanta-Innovations.
# 2. Initializes the company-standards submodule.
# 3. Configures client-side Git guard hooks (main protection & rule locking).
# 4. Initializes the 28-day security heartbeat inactivity timer.
# 5. Enforces OS-level READ-ONLY protection on rules and onboarding prompts.
# 6. Outputs the role-specific Day-1 orientation checklist.
# ==============================================================================

param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("developer", "qa", "data", "devops", "pm", "design", "admin", "")]
    [string]$Designation = "",
    
    [switch]$Interactive,
    [string]$TargetDir = "",
    [string]$OrgName = "Vasanta-Innovations"
)

$ErrorActionPreference = "Stop"

$RoleMapping = [ordered]@{
    "developer" = @{
        Key = "developer"
        Title = "AI Software Engineer"
        Repo = "developer-workspace"
        Focus = "Full-Stack features, TypeScript/React/Node, 10 PR Quality Gates, Unit Tests"
    }
    "qa" = @{
        Key = "qa"
        Title = "AI QA & Test Automation Engineer"
        Repo = "qa-automation"
        Focus = "Playwright E2E suites, synthetic test fixtures, defect triage automation"
    }
    "data" = @{
        Key = "data"
        Title = "AI Data & Analytics Engineer"
        Repo = "data-engineering"
        Focus = "BigQuery ELT pipelines, dbt data modeling, SQL transformations, data schemas"
    }
    "devops" = @{
        Key = "devops"
        Title = "AI DevOps & Platform Engineer"
        Repo = "devops-workspace"
        Focus = "CI/CD workflows, 1-click repo provisioner, branch guards, cloud secrets"
    }
    "pm" = @{
        Key = "pm"
        Title = "AI Product & Project Manager"
        Repo = "project-management"
        Focus = "User stories, backlog grooming, PR acceptance criteria, Sprint tracking"
    }
    "design" = @{
        Key = "design"
        Title = "AI UI/UX Designer"
        Repo = "design-workspace"
        Focus = "Design system tokens, Figma component specifications, UX accessibility"
    }
    "admin" = @{
        Key = "admin"
        Title = "AI Engineering Administrator"
        Repo = "admin-workspace"
        Focus = "Organization governance, repository templates, secret audit, compliance"
    }
}

function Show-DesignationPopup {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Vasanta Innovations - Workstation Onboarding"
        $form.Size = New-Object System.Drawing.Size(560, 320)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 250)

        # Header Label
        $header = New-Object System.Windows.Forms.Label
        $header.Location = New-Object System.Drawing.Point(20, 15)
        $header.Size = New-Object System.Drawing.Size(510, 40)
        $header.Text = "Select your AI Designation to configure your local workstation:"
        $header.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $header.ForeColor = [System.Drawing.Color]::FromArgb(33, 37, 41)
        $form.Controls.Add($header)

        # Subtext Label
        $subtext = New-Object System.Windows.Forms.Label
        $subtext.Location = New-Object System.Drawing.Point(22, 55)
        $subtext.Size = New-Object System.Drawing.Size(500, 25)
        $subtext.Text = "This will clone your starter hub, configure guard hooks, and lock engineering rules."
        $subtext.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
        $subtext.ForeColor = [System.Drawing.Color]::FromArgb(108, 117, 125)
        $form.Controls.Add($subtext)

        # Dropdown ComboBox
        $comboBox = New-Object System.Windows.Forms.ComboBox
        $comboBox.Location = New-Object System.Drawing.Point(25, 95)
        $comboBox.Size = New-Object System.Drawing.Size(495, 30)
        $comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
        $comboBox.Font = New-Object System.Drawing.Font("Segoe UI", 10.5)

        foreach ($role in $RoleMapping.Values) {
            $displayItem = "$($role.Title) ($($role.Repo))"
            $comboBox.Items.Add($displayItem) | Out-Null
        }
        $comboBox.SelectedIndex = 0
        $form.Controls.Add($comboBox)

        # Focus description label
        $descLabel = New-Object System.Windows.Forms.Label
        $descLabel.Location = New-Object System.Drawing.Point(25, 140)
        $descLabel.Size = New-Object System.Drawing.Size(495, 50)
        $descLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
        $descLabel.ForeColor = [System.Drawing.Color]::FromArgb(73, 80, 87)
        $descLabel.Text = $RoleMapping["developer"].Focus
        $form.Controls.Add($descLabel)

        $comboBox.Add_SelectedIndexChanged({
            $selectedIdx = $comboBox.SelectedIndex
            $keys = @($RoleMapping.Keys)
            $selectedKey = $keys[$selectedIdx]
            $descLabel.Text = $RoleMapping[$selectedKey].Focus
        })

        # Submit Button
        $okBtn = New-Object System.Windows.Forms.Button
        $okBtn.Location = New-Object System.Drawing.Point(270, 215)
        $okBtn.Size = New-Object System.Drawing.Size(150, 42)
        $okBtn.Text = "Configure Machine"
        $okBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
        $okBtn.BackColor = [System.Drawing.Color]::FromArgb(13, 110, 253)
        $okBtn.ForeColor = [System.Drawing.Color]::White
        $okBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $okBtn.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $okBtn
        $form.Controls.Add($okBtn)

        # Cancel Button
        $cancelBtn = New-Object System.Windows.Forms.Button
        $cancelBtn.Location = New-Object System.Drawing.Point(430, 215)
        $cancelBtn.Size = New-Object System.Drawing.Size(90, 42)
        $cancelBtn.Text = "Cancel"
        $cancelBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
        $cancelBtn.BackColor = [System.Drawing.Color]::FromArgb(233, 236, 239)
        $cancelBtn.ForeColor = [System.Drawing.Color]::FromArgb(33, 37, 41)
        $cancelBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $cancelBtn.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.CancelButton = $cancelBtn
        $form.Controls.Add($cancelBtn)

        $dialogResult = $form.ShowDialog()

        if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
            $selectedIdx = $comboBox.SelectedIndex
            $keys = @($RoleMapping.Keys)
            return $keys[$selectedIdx]
        } else {
            return $null
        }
    } catch {
        return (Show-DesignationCliMenu)
    }
}

function Show-DesignationCliMenu {
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host " 🤖 Select Your AI Designation:" -ForegroundColor Yellow
    Write-Host "================================================================================" -ForegroundColor Cyan
    $i = 1
    $keys = @($RoleMapping.Keys)
    foreach ($key in $keys) {
        $r = $RoleMapping[$key]
        Write-Host "  [$i] $($r.Title) - ($($r.Repo))" -ForegroundColor White
        Write-Host "      Focus: $($r.Focus)" -ForegroundColor DarkGray
        $i++
    }
    Write-Host "================================================================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Enter designation number (1-7) [Default: 1]"
    if (-not $choice) { $choice = "1" }
    $choiceNum = [int]$choice
    if ($choiceNum -ge 1 -and $choiceNum -le $keys.Count) {
        return $keys[$choiceNum - 1]
    }
    return "developer"
}

# Determine designation
if ($Interactive -or [string]::IsNullOrWhiteSpace($Designation)) {
    # Check if UI environment is available
    if ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
        $selected = Show-DesignationPopup
        if (-not $selected) {
            Write-Host "❌ Onboarding cancelled by user." -ForegroundColor Red
            exit 0
        }
        $Designation = $selected
    } else {
        $Designation = Show-DesignationCliMenu
    }
}

$roleInfo = $RoleMapping[$Designation]
$repoName = $roleInfo.Repo
$roleTitle = $roleInfo.Title

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " 🚀 Vasanta Innovations - 1-Click AI Workstation Onboarding Engine" -ForegroundColor Cyan
Write-Host " Selected AI Designation: $roleTitle" -ForegroundColor Yellow
Write-Host " Target Repository:      $OrgName/$repoName" -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# Determine target directory
if (-not $TargetDir) {
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
