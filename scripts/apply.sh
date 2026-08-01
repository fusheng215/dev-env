#!/usr/bin/env bash
# apply.sh — symlink the dev-env dotfiles into the current user profile (macOS / Linux)
# Run:  bash apply.sh   (from the dev-env/scripts folder)
# Idempotent & safe: existing files are backed up to *.bak before being replaced.

set -euo pipefail
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPTS/.." && pwd)"
HOME_DIR="$HOME"

backup_if_exists() { [ -e "$1" ] && cp -a "$1" "$1.bak" && echo "  backed up $1"; }

deploy() {
  local from="$1" to="$2"
  mkdir -p "$(dirname "$to")"
  backup_if_exists "$to"
  ln -sf "$from" "$to"
  echo "  linked $to -> $from"
}

echo "=== Linking dev-env dotfiles into $HOME_DIR ==="

deploy "$REPO/git/.gitconfig"          "$HOME_DIR/.gitconfig"
deploy "$REPO/git/.gitignore_global"   "$HOME_DIR/.gitignore_global"
deploy "$REPO/.editorconfig"           "$HOME_DIR/.editorconfig"
deploy "$REPO/shell/.bashrc"           "$HOME_DIR/.bashrc"
deploy "$REPO/shell/aliases.sh"        "$HOME_DIR/.dotfiles-dev/aliases.sh"
deploy "$REPO/shell/starship.toml"     "$HOME_DIR/.config/starship.toml"
deploy "$REPO/shell/starship.toml"     "$HOME_DIR/.dotfiles-dev/starship.toml"
deploy "$REPO/shell/ohmyposh.omp.json" "$HOME_DIR/.dotfiles-dev/ohmyposh.omp.json"

PS_PROFILE="${POWERSHLL_PROFILE:-$HOME_DIR/.config/powershell/Microsoft.PowerShell_profile.ps1}"
deploy "$REPO/shell/Microsoft.PowerShell_profile.ps1" "$PS_PROFILE"

# Neovim configuration (directory symlink)
NVIM_DIR="$HOME_DIR/.config/nvim"
backup_if_exists "$NVIM_DIR"
ln -sfn "$REPO/editor/nvim" "$NVIM_DIR"
echo "  linked $NVIM_DIR -> $REPO/editor/nvim"

# VS Code settings (user-level)
VS_SETTINGS="$HOME_DIR/.config/Code/User/settings.json"
mkdir -p "$(dirname "$VS_SETTINGS")"
backup_if_exists "$VS_SETTINGS"
ln -sf "$REPO/editor/vscode/settings.json" "$VS_SETTINGS"
echo "  linked $VS_SETTINGS"

# WSL integration (only when running inside WSL)
if [ -n "${WSL_DISTRO_NAME:-}" ]; then
  WSL_SNIPPET="$REPO/wsl/wsl.profile"
  if [ -f "$WSL_SNIPPET" ] && ! grep -q 'dev-env WSL integration' "$HOME/.profile" 2>/dev/null; then
    cat "$WSL_SNIPPET" >> "$HOME/.profile"
    echo "  appended WSL integration to $HOME/.profile"
  fi
fi

echo -e "\nAll done. Restart your terminal to load the new configuration."
