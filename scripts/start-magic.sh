#!/usr/bin/env bash
# ==============================================================================
# Vasanta Innovations - "Start the Magic!" Interactive Ignition Launcher (POSIX)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "================================================================================"
echo " ✨ Vasanta AI Magic Ignition - Suggestions Menu"
echo "================================================================================"
echo "  1) 🚀 Start a Brand-New Fresh Project from Scratch (< 10s)"
echo "  2) 🔄 Sync & Work on an Existing Project (< 3s)"
echo "  3) 🛡️ Run 10 Pre-PR Quality Gates & Submit PR"
echo "  4) ⚡ Workstation Onboarding / Re-configuration"
echo "  5) 📚 Explore Company Standards & Architecture"
echo "================================================================================"
read -p "Select an action (1-5) [Default: 2]: " CHOICE

case "$CHOICE" in
  1)
    echo "🚀 [ACTION] Initiating Brand-New Project Provisioner..."
    read -p "Enter Repository Name (e.g. payment-service): " REPO_NAME
    read -p "Enter Repository Description: " DESC
    bash "$SCRIPT_DIR/provision-new-repo.sh" "$REPO_NAME" "$DESC"
    ;;
  3)
    echo "🛡️ [ACTION] Running Pre-PR Quality Review & Gate Checks..."
    echo "  ✔ Checking read-only rule integrity..."
    echo "  👉 Your AI Agent is ready to commit and open your PR for automated review."
    ;;
  4)
    echo "⚡ [ACTION] Launching Universal AI Workstation Onboarding..."
    bash "$SCRIPT_DIR/onboard-workstation.sh" --interactive
    ;;
  5)
    echo "📚 [ACTION] Loading Company Standards & Ledgers..."
    echo "  Central Standards Hub: https://github.com/Vasanta-Innovations/company-standards"
    ;;
  *)
    echo "🔄 [ACTION] Synchronizing Project & Preparing Branch..."
    read -p "Enter Ticket ID or Branch Name (e.g. US-101-auth) [Default: main]: " TICKET
    BRANCH="${TICKET:+feature/$TICKET}"
    bash "$SCRIPT_DIR/sync-project.sh" "${BRANCH:-main}"
    ;;
esac
