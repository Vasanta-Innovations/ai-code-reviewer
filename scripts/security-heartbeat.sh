#!/usr/bin/env bash
# ==============================================================================
# Vasanta Innovations - 28-Day Inactivity Security Heartbeat Guard (POSIX)
# ==============================================================================

set -e

ACTION="${1:-touch}"
MAX_DAYS=28
WORKSPACE_ROOT="${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
HEARTBEAT_FILE="$WORKSPACE_ROOT/.security-heartbeat.json"

if [ ! -d "$WORKSPACE_ROOT" ]; then
  echo "Error: Invalid workspace root: $WORKSPACE_ROOT" >&2
  exit 1
fi

CURRENT_UTC_SEC=$(date -u +%s)
CURRENT_UTC_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [ ! -f "$HEARTBEAT_FILE" ]; then
  REPO_NAME=$(basename "$WORKSPACE_ROOT")
  cat <<EOF > "$HEARTBEAT_FILE"
{
  "org": "Vasanta-Innovations",
  "repo": "$REPO_NAME",
  "last_active_timestamp": "$CURRENT_UTC_ISO",
  "max_inactive_days": $MAX_DAYS,
  "policy": "28-Day Dormancy Expiration - Automatic Company Data Scrub"
}
EOF
  echo "🛡️ [HEARTBEAT] Security heartbeat initialized for '$REPO_NAME' ($CURRENT_UTC_ISO)."
  exit 0
fi

# Extract timestamp using grep/sed/awk
LAST_ACTIVE_ISO=$(grep '"last_active_timestamp"' "$HEARTBEAT_FILE" | sed -E 's/.*: *"([^"]+)".*/\1/')

if command -v python3 >/dev/null 2>&1; then
  DAYS_INACTIVE=$(python3 -c "
import datetime
last = datetime.datetime.fromisoformat('$LAST_ACTIVE_ISO'.replace('Z', '+00:00'))
now = datetime.datetime.now(datetime.timezone.utc)
print(round((now - last).total_seconds() / 86400.0, 1))
")
else
  # Fallback to date calculation
  LAST_SEC=$(date -d "$LAST_ACTIVE_ISO" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_ACTIVE_ISO" +%s 2>/dev/null || echo "$CURRENT_UTC_SEC")
  DIFF_SEC=$((CURRENT_UTC_SEC - LAST_SEC))
  DAYS_INACTIVE=$((DIFF_SEC / 86400))
fi

IS_EXPIRED=$(python3 -c "print(1 if float('$DAYS_INACTIVE') > $MAX_DAYS else 0)" 2>/dev/null || [ "$DAYS_INACTIVE" -gt "$MAX_DAYS" ] && echo 1 || echo 0)

if [ "$ACTION" = "status" ]; then
  echo "🛡️ [HEARTBEAT STATUS] Inactive for: $DAYS_INACTIVE days (Policy limit: $MAX_DAYS days)."
  exit 0
fi

if [ "$IS_EXPIRED" -eq 1 ]; then
  echo ""
  echo "================================================================================"
  echo " 🚨 [SECURITY POLICY EXPIRED] Inactivity exceeds $MAX_DAYS-day limit ($DAYS_INACTIVE days inactive)!"
  echo "================================================================================"
  echo " As per Vasanta Innovations Information Security Policy Section 5:"
  echo " Personal/BYOD laptops retaining dormant company repositories must be purged."
  echo " Initiating automatic local workspace scrub..."
  echo "================================================================================"
  echo ""

  OFFBOARD_SCRIPT="$WORKSPACE_ROOT/scripts/offboard-workstation.sh"
  if [ -f "$OFFBOARD_SCRIPT" ]; then
    bash "$OFFBOARD_SCRIPT" --force --reason "28-Day Inactivity Expiration"
  else
    echo "⚠️ Offboard script missing. Scrubbing .cursor/rules/..."
    rm -rf "$WORKSPACE_ROOT/.cursor/rules"
  fi
  exit 1
fi

if [ "$ACTION" = "touch" ]; then
  # Refresh timestamp
  REPO_NAME=$(basename "$WORKSPACE_ROOT")
  cat <<EOF > "$HEARTBEAT_FILE"
{
  "org": "Vasanta-Innovations",
  "repo": "$REPO_NAME",
  "last_active_timestamp": "$CURRENT_UTC_ISO",
  "max_inactive_days": $MAX_DAYS,
  "policy": "28-Day Dormancy Expiration - Automatic Company Data Scrub"
}
EOF
fi

exit 0
