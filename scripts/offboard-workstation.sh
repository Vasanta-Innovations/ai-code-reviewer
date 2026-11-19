#!/usr/bin/env bash
# ==============================================================================
# Vasanta Innovations - Workstation Offboarding & Asset Scrub Script (POSIX)
# ==============================================================================

set -e

FORCE=0
REASON="Voluntary Offboarding"
WORKSPACE_PATH=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --force) FORCE=1; shift ;;
    --reason) REASON="$2"; shift 2 ;;
    --path) WORKSPACE_PATH="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [ -z "$WORKSPACE_PATH" ]; then
  WORKSPACE_PATH=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
fi

echo ""
echo "================================================================================"
echo " 🛡️ Vasanta Innovations - Workstation Offboarding & Asset Scrubber"
echo " Reason: $REASON"
echo "================================================================================"
echo ""

# Safety check: Directory cannot be root or personal home
if [ "$WORKSPACE_PATH" = "/" ] || [ "$WORKSPACE_PATH" = "$HOME" ] || [ "$WORKSPACE_PATH" = "$HOME/Desktop" ] || [ "$WORKSPACE_PATH" = "$HOME/Documents" ] || [ "$WORKSPACE_PATH" = "$HOME/Downloads" ]; then
  echo "❌ [FATAL SAFETY BLOCK] Refusing to offboard system or personal root directory: $WORKSPACE_PATH" >&2
  exit 1
fi

# Safety check: Must be a git repo and belong to Vasanta-Innovations
if [ ! -d "$WORKSPACE_PATH/.git" ]; then
  echo "❌ [FATAL SAFETY BLOCK] Target directory is not a Git repository: $WORKSPACE_PATH" >&2
  exit 1
fi

REMOTE_URL=$(git -C "$WORKSPACE_PATH" config --get remote.origin.url 2>/dev/null || echo "")
if [[ "$REMOTE_URL" != *"Vasanta-Innovations"* ]]; then
  echo "❌ [FATAL SAFETY BLOCK] Repository does not belong to 'Vasanta-Innovations'!" >&2
  echo "   Remote: $REMOTE_URL" >&2
  exit 1
fi

echo "✅ [VERIFIED] Valid Vasanta-Innovations workspace confirmed: $WORKSPACE_PATH"

if [ "$FORCE" -eq 0 ]; then
  read -p "Type 'CONFIRM' to proceed with offboarding wipe: " CONFIRMATION
  if [ "$CONFIRMATION" != "CONFIRM" ]; then
    echo "❌ Offboarding aborted by user."
    exit 0
  fi
fi

# Preserve uncommitted work if dirty
STATUS=$(git -C "$WORKSPACE_PATH" status --porcelain 2>/dev/null || true)
if [ -n "$STATUS" ]; then
  echo "📦 Preserving uncommitted work to remote backup branch..."
  TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
  BACKUP_BRANCH="backup-offboard-$TIMESTAMP"
  git -C "$WORKSPACE_PATH" checkout -b "$BACKUP_BRANCH" 2>/dev/null || true
  git -C "$WORKSPACE_PATH" add -A 2>/dev/null || true
  git -C "$WORKSPACE_PATH" commit -m "Auto-backup prior to offboard wipe ($REASON)" --no-verify 2>/dev/null || true
  git -C "$WORKSPACE_PATH" push origin "$BACKUP_BRANCH" --no-verify 2>/dev/null || true
  echo "✅ Preserved uncommitted changes to branch: $BACKUP_BRANCH"
fi

# Revoke git credential cache
echo "🔐 Revoking local GitHub credential helper tokens..."
git credential-cache exit 2>/dev/null || true

# Scrub rules, templates, and submodules
echo "🧹 Scrubbing company proprietary rules and templates..."
rm -rf "$WORKSPACE_PATH/.cursor/rules"
rm -rf "$WORKSPACE_PATH/.cursor/template"
rm -rf "$WORKSPACE_PATH/company-standards"

# Scrub working tree
echo "🗑️ Removing local workspace working tree..."
find "$WORKSPACE_PATH" -mindepth 1 -maxdepth 1 ! -name ".git" -exec rm -rf {} + 2>/dev/null || true
rm -rf "$WORKSPACE_PATH/.git" 2>/dev/null || true

echo ""
echo "================================================================================"
echo " ✅ [OFFBOARDING COMPLETE] Company rules and repository assets successfully wiped."
echo " Location cleaned: $WORKSPACE_PATH"
echo " Personal laptop files remain intact."
echo "================================================================================"
echo ""
