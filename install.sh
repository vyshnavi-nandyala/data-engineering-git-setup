#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  Data Engineering Git Setup — Installer (macOS)
#  Usage: bash install.sh [--dry-run] [--force]
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

DRY_RUN=false
FORCE=false
for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
    [[ "$arg" == "--force"   ]] && FORCE=true
done

info()    { echo -e "${CYAN}ℹ${RESET}  $1"; }
success() { echo -e "${GREEN}✔${RESET}  $1"; }
warning() { echo -e "${YELLOW}⚠${RESET}  $1"; }
error()   { echo -e "${RED}✖${RESET}  $1"; }
step()    { echo -e "\n${BOLD}${CYAN}── $1 ──${RESET}"; }

copy_file() {
    local src="$1" dst="$2" label="$3"
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would copy $src → $dst"
        return
    fi
    if [[ -f "$dst" && "$FORCE" != true ]]; then
        warning "$label already exists at $dst"
        read -rp "         Overwrite? [y/N] " answer
        [[ "${answer,,}" != "y" ]] && { info "Skipped $label"; return; }
    fi
    cp "$src" "$dst"
    success "Installed $label → $dst"
}

echo -e "\n${BOLD}${CYAN}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║   Data Engineering Git Setup — Installer    ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"
[[ "$DRY_RUN" == true ]] && warning "DRY-RUN mode — no files will be changed\n"

# ── 1. .gitconfig ─────────────────────────────────────────────
step "1. Git configuration"
GITCONFIG_SRC="$SCRIPT_DIR/.gitconfig"
GITCONFIG_DST="$HOME/.gitconfig"

if [[ -f "$GITCONFIG_DST" && "$FORCE" != true && "$DRY_RUN" != true ]]; then
    warning "~/.gitconfig already exists. Merging aliases and settings only."
    # Append the [alias] block from our config if not already present
    if ! grep -q '\[alias\]' "$GITCONFIG_DST"; then
        echo "" >> "$GITCONFIG_DST"
        cat "$GITCONFIG_SRC" >> "$GITCONFIG_DST"
        success "Appended DE config to existing ~/.gitconfig"
    else
        warning "~/.gitconfig already has [alias] section. Run with --force to overwrite."
        info    "You can manually merge from: $GITCONFIG_SRC"
    fi
else
    copy_file "$GITCONFIG_SRC" "$GITCONFIG_DST" ".gitconfig"
fi

# Update name/email if placeholders
if [[ "$DRY_RUN" != true ]]; then
    CURRENT_NAME=$(git config --global user.name 2>/dev/null || true)
    CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || true)
    if [[ "$CURRENT_NAME" == "Your Name" || -z "$CURRENT_NAME" ]]; then
        read -rp "  Enter your name  : " NAME
        [[ -n "$NAME" ]] && git config --global user.name "$NAME"
    fi
    if [[ "$CURRENT_EMAIL" == "you@example.com" || -z "$CURRENT_EMAIL" ]]; then
        read -rp "  Enter your email : " EMAIL
        [[ -n "$EMAIL" ]] && git config --global user.email "$EMAIL"
    fi
fi

# ── 2. .gitmessage ────────────────────────────────────────────
step "2. Commit message template"
copy_file "$SCRIPT_DIR/.gitmessage" "$HOME/.gitmessage" ".gitmessage"
if [[ "$DRY_RUN" != true ]]; then
    git config --global commit.template "$HOME/.gitmessage"
    success "Set commit.template = ~/.gitmessage"
fi

# ── 3. Pre-commit hook ────────────────────────────────────────
step "3. Global pre-commit hook"
HOOKS_DIR="$HOME/.git-hooks"
if [[ "$DRY_RUN" != true ]]; then
    mkdir -p "$HOOKS_DIR"
    copy_file "$SCRIPT_DIR/hooks/pre-commit" "$HOOKS_DIR/pre-commit" "pre-commit hook"
    chmod +x "$HOOKS_DIR/pre-commit"
    git config --global core.hooksPath "$HOOKS_DIR"
    success "Set core.hooksPath = $HOOKS_DIR (applies to all repos)"
fi

# ── 4. .gitignore-data-engineering ───────────────────────────
step "4. Global .gitignore"
GLOBAL_IGNORE="$HOME/.gitignore-data-engineering"
copy_file "$SCRIPT_DIR/.gitignore-data-engineering" "$GLOBAL_IGNORE" ".gitignore-data-engineering"
if [[ "$DRY_RUN" != true ]]; then
    git config --global core.excludesFile "$GLOBAL_IGNORE"
    success "Set core.excludesFile = $GLOBAL_IGNORE"
fi

# ── 5. Verify ─────────────────────────────────────────────────
step "5. Verification"
if [[ "$DRY_RUN" != true ]]; then
    echo ""
    echo -e "  ${BOLD}Git version:${RESET}      $(git --version)"
    echo -e "  ${BOLD}User name:${RESET}        $(git config --global user.name)"
    echo -e "  ${BOLD}User email:${RESET}       $(git config --global user.email)"
    echo -e "  ${BOLD}Default branch:${RESET}   $(git config --global init.defaultBranch)"
    echo -e "  ${BOLD}Commit template:${RESET}  $(git config --global commit.template)"
    echo -e "  ${BOLD}Hooks path:${RESET}       $(git config --global core.hooksPath)"
    echo -e "  ${BOLD}Color UI:${RESET}         $(git config --global color.ui)"
fi

echo -e "\n${BOLD}${GREEN}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║   Installation complete!                    ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"
echo "  Try these commands in any repo:"
echo -e "  ${CYAN}git de-log${RESET}       — pretty commit graph"
echo -e "  ${CYAN}git de-status${RESET}    — enhanced status"
echo -e "  ${CYAN}git de-branch${RESET}    — colored branch list"
echo -e "  ${CYAN}git de-pipeline${RESET}  — pipeline-related commits"
echo -e "  ${CYAN}git graph${RESET}        — one-line ASCII graph"
echo -e "  ${CYAN}git de-commit${RESET}    — commit with template\n"
