#!/usr/bin/env bash
# ==============================================================================
# Vasanta Innovations - Workstation Onboarding Automation Engine (POSIX)
# ==============================================================================

set -e

DESIGNATION="${1:-developer}"
TARGET_DIR="${2:-}"
ORG_NAME="Vasanta-Innovations"

case "$DESIGNATION" in
  developer)
    REPO_NAME="developer-workspace"
    ROLE_TITLE="Full-Stack Software Engineer"
    ROLE_FOCUS="Application features, TypeScript/React/Node, 10 PR Quality Gates, Unit Tests"
    ;;
  qa)
    REPO_NAME="qa-automation"
    ROLE_TITLE="QA & Test Automation Engineer"
    ROLE_FOCUS="Playwright E2E suites, test fixtures, synthetic testing, defect triage"
    ;;
  data)
    REPO_NAME="data-engineering"
    ROLE_TITLE="Data & Analytics Engineer"
    ROLE_FOCUS="BigQuery pipelines, dbt data modeling, SQL transformations, data schemas"
    ;;
  devops)
    REPO_NAME="devops-workspace"
    ROLE_TITLE="DevOps & Platform Engineer"
    ROLE_FOCUS="CI/CD workflows, 1-click repo provisioner, branch guards, cloud secrets"
    ;;
  pm)
    REPO_NAME="project-management"
    ROLE_TITLE="Product & Project Manager"
    ROLE_FOCUS="User stories, backlog grooming, PR acceptance criteria, Sprint tracking"
    ;;
  design)
    REPO_NAME="design-workspace"
    ROLE_TITLE="UI/UX Designer"
    ROLE_FOCUS="Design system tokens, Figma component specifications, UI review"
    ;;
  admin)
    REPO_NAME="admin-workspace"
    ROLE_TITLE="IT & Engineering Administrator"
    ROLE_FOCUS="Organization governance, repository templates, secret audit, compliance"
    ;;
  *)
    echo "Unknown designation: $DESIGNATION. Using 'developer'."
    REPO_NAME="developer-workspace"
    ROLE_TITLE="Full-Stack Software Engineer"
    ROLE_FOCUS="Application features, TypeScript/React/Node, 10 PR Quality Gates, Unit Tests"
    ;;
esac

echo ""
echo "================================================================================"
echo " 🚀 Vasanta Innovations - 1-Click Workstation Onboarding Engine"
echo " Role: $ROLE_TITLE"
echo " Target Repository: $ORG_NAME/$REPO_NAME"
echo "================================================================================"
echo ""

if [ -z "$TARGET_DIR" ]; then
  CURRENT_LEAF=$(basename "$PWD")
  if [ "$CURRENT_LEAF" = "$REPO_NAME" ]; then
    TARGET_DIR="$PWD"
  else
    TARGET_DIR="$PWD/$REPO_NAME"
  fi
fi

# 1. Clone repository if needed
if [ ! -d "$TARGET_DIR/.git" ]; then
  echo "[1/5] Cloning $ORG_NAME/$REPO_NAME template repository..."
  git clone "https://github.com/$ORG_NAME/$REPO_NAME.git" "$TARGET_DIR"
else
  echo "[1/5] Existing repository verified at: $TARGET_DIR"
fi

cd "$TARGET_DIR"

# 2. Submodule update
echo "[2/5] Initializing company-standards submodule..."
git submodule update --init --recursive 2>/dev/null || true

# 3. Configure hooks
echo "[3/5] Installing client-side guard hooks (pre-push & pre-commit)..."
git config core.hooksPath .githooks
chmod +x .githooks/* 2>/dev/null || true

# 4. Security heartbeat
echo "[4/5] Initializing 28-Day Security Heartbeat inactivity guard..."
if [ -f "scripts/security-heartbeat.sh" ]; then
  bash scripts/security-heartbeat.sh touch "$TARGET_DIR" 2>/dev/null || true
fi

# 5. Lock rules and prompt
echo "[5/5] Locking engineering rules and prompt as READ-ONLY..."
chmod 444 .cursor/rules/* 2>/dev/null || true
chmod 444 ONBOARDING_PROMPT.md 2>/dev/null || true

echo ""
echo "================================================================================"
echo " 🎉 ONBOARDING COMPLETE: Welcome to Vasanta Innovations!"
echo " Designation: $ROLE_TITLE"
echo " Workspace:   $TARGET_DIR"
echo " Core Focus:  $ROLE_FOCUS"
echo "================================================================================"
echo ""
