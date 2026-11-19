#!/usr/bin/env bash
# ==============================================================================
# Vasanta Innovations - 1-Click Fast Project Sync Tool (POSIX)
# ==============================================================================

set -e

BRANCH="${1:-}"
WORKSPACE_ROOT="${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

if [ ! -d "$WORKSPACE_ROOT/.git" ]; then
  echo "Error: Invalid Git repository at $WORKSPACE_ROOT" >&2
  exit 1
fi

cd "$WORKSPACE_ROOT"
REPO_NAME=$(basename "$WORKSPACE_ROOT")

echo ""
echo "================================================================================"
echo " 🔄 Vasanta Innovations - 1-Click Fast Project Sync"
echo " Repository: $REPO_NAME"
echo " Target Branch: ${BRANCH:-main}"
echo "================================================================================"
echo ""

# 1. Stash dirty work
STASHED=0
if [ -n "$(git status --porcelain)" ]; then
  echo "📦 Stashing local work..."
  git stash push -m "Auto-stash before sync" >/dev/null 2>&1 || true
  STASHED=1
fi

# 2. Pull main
echo "[1/5] Fetching latest changes from origin/main..."
git checkout main >/dev/null 2>&1 || true
git pull --rebase origin main

# 3. Update submodules
echo "[2/5] Updating company-standards submodule..."
git submodule update --init --recursive >/dev/null 2>&1 || true

# 4. Security heartbeat
echo "[3/5] Refreshing 28-day security heartbeat timer..."
if [ -f "scripts/security-heartbeat.sh" ]; then
  bash scripts/security-heartbeat.sh touch "$WORKSPACE_ROOT" >/dev/null 2>&1 || true
fi

# 5. Lock rules
echo "[4/5] Enforcing READ-ONLY protection on rules..."
chmod 444 .cursor/rules/* 2>/dev/null || true
chmod 444 ONBOARDING_PROMPT.md 2>/dev/null || true

# 6. Branch checkout
if [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ]; then
  echo "[5/5] Switching to branch: $BRANCH..."
  if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
    git checkout "$BRANCH" >/dev/null 2>&1
    git rebase main >/dev/null 2>&1 || true
  else
    git checkout -b "$BRANCH" >/dev/null 2>&1
  fi
  echo "✔ Active on branch '$BRANCH'."
else
  echo "[5/5] Ready on branch 'main'."
fi

# Restore stash
if [ "$STASHED" -eq 1 ]; then
  echo "📦 Restoring local work from stash..."
  git stash pop >/dev/null 2>&1 || true
fi

echo ""
echo "================================================================================"
echo " ✨ [PROJECT SYNC COMPLETE] Ready to build without manual commands!"
echo "================================================================================"
echo ""
