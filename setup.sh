#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  setup.sh — Verify and show current DE git configuration
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✔${RESET}  $1"; }
warn() { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
miss() { echo -e "  ${RED}✖${RESET}  $1"; }

echo -e "\n${BOLD}${CYAN}Data Engineering Git Setup — Status Check${RESET}\n"

# ── Git version ───────────────────────────────────────────────
GIT_VERSION=$(git --version 2>/dev/null | awk '{print $3}')
MAJOR=$(echo "$GIT_VERSION" | cut -d. -f1)
MINOR=$(echo "$GIT_VERSION" | cut -d. -f2)
echo -e "${BOLD}Git version:${RESET} $GIT_VERSION"
if [[ "$MAJOR" -gt 2 || ("$MAJOR" -eq 2 && "$MINOR" -ge 28) ]]; then
    ok "Git >= 2.28 (supports defaultBranch)"
else
    warn "Git < 2.28 — upgrade recommended: brew upgrade git"
fi

# ── Core settings ─────────────────────────────────────────────
echo -e "\n${BOLD}Core Settings:${RESET}"
check_setting() {
    local key="$1" expected="$2"
    local value
    value=$(git config --global "$key" 2>/dev/null || echo "NOT SET")
    if [[ "$value" == "$expected" || "$expected" == "*" ]]; then
        ok "$key = $value"
    elif [[ "$value" == "NOT SET" ]]; then
        miss "$key is not set (expected: $expected)"
    else
        warn "$key = $value (expected: $expected)"
    fi
}

check_setting "init.defaultBranch" "main"
check_setting "color.ui"           "always"
check_setting "pull.rebase"        "true"
check_setting "push.default"       "current"
check_setting "fetch.prune"        "true"
check_setting "help.autocorrect"   "10"
check_setting "commit.template"    "*"
check_setting "core.hooksPath"     "*"
check_setting "core.excludesFile"  "*"

# ── Identity ──────────────────────────────────────────────────
echo -e "\n${BOLD}Identity:${RESET}"
NAME=$(git config --global user.name 2>/dev/null || echo "NOT SET")
EMAIL=$(git config --global user.email 2>/dev/null || echo "NOT SET")
[[ "$NAME" != "NOT SET" && "$NAME" != "Your Name" ]] && ok "user.name  = $NAME" || miss "user.name  not configured"
[[ "$EMAIL" != "NOT SET" && "$EMAIL" != "you@example.com" ]] && ok "user.email = $EMAIL" || miss "user.email not configured"

# ── DE aliases ────────────────────────────────────────────────
echo -e "\n${BOLD}Data Engineering Aliases:${RESET}"
DE_ALIASES=(de-status de-log de-branch de-diff de-commit de-push de-review de-pipeline de-data de-schema graph standup today)
for alias in "${DE_ALIASES[@]}"; do
    if git config --global "alias.$alias" &>/dev/null; then
        ok "git $alias"
    else
        miss "git $alias (not installed)"
    fi
done

# ── Pre-commit hook ───────────────────────────────────────────
echo -e "\n${BOLD}Pre-commit Hook:${RESET}"
HOOKS_PATH=$(git config --global core.hooksPath 2>/dev/null || echo "")
if [[ -n "$HOOKS_PATH" && -f "$HOOKS_PATH/pre-commit" && -x "$HOOKS_PATH/pre-commit" ]]; then
    ok "pre-commit hook installed at $HOOKS_PATH/pre-commit"
else
    miss "pre-commit hook not found — run install.sh"
fi

# ── Files ─────────────────────────────────────────────────────
echo -e "\n${BOLD}Config Files:${RESET}"
[[ -f "$HOME/.gitconfig"                   ]] && ok "~/.gitconfig exists"            || miss "~/.gitconfig missing"
[[ -f "$HOME/.gitmessage"                  ]] && ok "~/.gitmessage exists"            || miss "~/.gitmessage missing — run install.sh"
[[ -f "$HOME/.gitignore-data-engineering"  ]] && ok "~/.gitignore-data-engineering"   || miss "~/.gitignore-data-engineering missing"

echo -e "\n${BOLD}${CYAN}Quick start commands (run in any repo):${RESET}"
echo -e "  ${CYAN}git de-log${RESET}      – pretty commit graph"
echo -e "  ${CYAN}git de-status${RESET}   – enhanced status + stashes"
echo -e "  ${CYAN}git graph${RESET}       – one-line ASCII graph"
echo -e "  ${CYAN}git de-pipeline${RESET} – pipeline-related commits"
echo -e "  ${CYAN}git standup${RESET}     – commits from last 7 days"
echo ""
