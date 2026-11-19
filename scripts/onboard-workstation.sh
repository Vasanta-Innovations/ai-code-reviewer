#!/usr/bin/env bash
# ==============================================================================
# Vasanta Innovations - Universal AI Workstation Onboarding Engine (POSIX)
# ==============================================================================

set -e

DESIGNATION="${1:-}"
TARGET_DIR="${2:-}"
ORG_NAME="Vasanta-Innovations"

if [ -z "$DESIGNATION" ] || [ "$DESIGNATION" = "--interactive" ] || [ "$DESIGNATION" = "-i" ]; then
  echo ""
  echo "================================================================================"
  echo " 🤖 Select Your AI Designation:"
  echo "================================================================================"
  echo "  1) AI Software Engineer (developer-workspace)"
  echo "  2) AI QA & Test Automation Engineer (qa-automation)"
  echo "  3) AI Data & Analytics Engineer (data-engineering)"
  echo "  4) AI DevOps & Platform Engineer (devops-workspace)"
  echo "  5) AI Product & Project Manager (project-management)"
  echo "  6) AI UI/UX Designer (design-workspace)"
  echo "  7) AI Engineering Administrator (admin-workspace)"
  echo "================================================================================"
  read -p "Enter designation number (1-7) [Default: 1]: " CHOICE
  case "$CHOICE" in
    2) DESIGNATION="qa" ;;
    3) DESIGNATION="data" ;;
    4) DESIGNATION="devops" ;;
    5) DESIGNATION="pm" ;;
    6) DESIGNATION="design" ;;
    7) DESIGNATION="admin" ;;
    *) DESIGNATION="developer" ;;
  esac
fi

case "$DESIGNATION" in
  developer)
    REPO_NAME="developer-workspace"
    ROLE_TITLE="AI Software Engineer"
    ROLE_FOCUS="Full-Stack features, TypeScript/React/Node, 10 PR Quality Gates, Unit Tests"
    ;;
  qa)
    REPO_NAME="qa-automation"
    ROLE_TITLE="AI QA & Test Automation Engineer"
    ROLE_FOCUS="Playwright E2E suites, synthetic test fixtures, defect triage automation"
    ;;
  data)
    REPO_NAME="data-engineering"
    ROLE_TITLE="AI Data & Analytics Engineer"
    ROLE_FOCUS="BigQuery ELT pipelines, dbt data modeling, SQL transformations, data schemas"
    ;;
  devops)
    REPO_NAME="devops-workspace"
    ROLE_TITLE="AI DevOps & Platform Engineer"
    ROLE_FOCUS="CI/CD workflows, 1-click repo provisioner, branch guards, cloud secrets"
    ;;
  pm)
    REPO_NAME="project-management"
    ROLE_TITLE="AI Product & Project Manager"
    ROLE_FOCUS="User stories, backlog grooming, PR acceptance criteria, Sprint tracking"
    ;;
  design)
    REPO_NAME="design-workspace"
    ROLE_TITLE="AI UI/UX Designer"
    ROLE_FOCUS="Design system tokens, Figma component specifications, UX accessibility"
    ;;
  admin)
    REPO_NAME="admin-workspace"
    ROLE_TITLE="AI Engineering Administrator"
    ROLE_FOCUS="Organization governance, repository templates, secret audit, compliance"
    ;;
  *)
    REPO_NAME="developer-workspace"
    ROLE_TITLE="AI Software Engineer"
    ROLE_FOCUS="Full-Stack features, TypeScript/React/Node, 10 PR Quality Gates, Unit Tests"
    ;;
esac

echo ""
echo "================================================================================"
echo " 🚀 Vasanta Innovations - 1-Click AI Workstation Onboarding Engine"
echo " Selected AI Designation: $ROLE_TITLE"
echo " Target Repository:      $ORG_NAME/$REPO_NAME"
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
