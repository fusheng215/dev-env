#!/usr/bin/env bash
# setup.sh — macOS / Linux one-shot dev-environment bootstrap (team reproducible)
# Usage:  bash setup.sh
# Installs Homebrew if missing, runs `brew bundle` from the Brewfile,
# sets up asdf runtime version managers, then links dotfiles.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$ROOT/.." && pwd)"

echo "=== dev-env macOS/Linux bootstrap ==="

# 1) Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "[1/4] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add to PATH for this session (Apple Silicon / Intel)
  [ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [ -f /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
else
  echo "[1/4] Homebrew already present."
fi

# 2) Toolchain via Brewfile
echo "[2/4] Installing toolchain from Brewfile..."
brew bundle --file="$ROOT/Brewfile"

# 3) asdf runtime version managers
echo "[3/4] Installing asdf plugins + runtimes..."
if command -v asdf >/dev/null 2>&1; then
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git 2>/dev/null || true
  asdf plugin add python  https://github.com/danhper/asdf-python.git       2>/dev/null || true
  asdf plugin add java   https://github.com/halcyon/asdf-java.git          2>/dev/null || true
  cp "$REPO/runtime/.tool-versions" "$HOME/.tool-versions"
  asdf install
fi

# 4) Link dotfiles
echo "[4/4] Linking dotfiles..."
bash "$REPO/scripts/apply.sh"

echo "Done. Open a new terminal to load the config."
echo "Tip: code --install-extension from editor/vscode/extensions.txt for recommended extensions."
