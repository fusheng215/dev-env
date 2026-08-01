# ---- dev-env WSL integration ----
# Share Git credentials with the Windows Git Credential Manager
if [ -x '/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe' ]; then
  git config --global credential.helper '/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe'
fi

# Use the Windows clipboard from Neovim / terminal
if command -v clip.exe >/dev/null 2>&1; then
  export CLIP="$(command -v clip.exe)"
fi

# Identify the WSL distro for the prompt
if [ -z "${WSL_DISTRO_NAME:-}" ] && [ -r /etc/os-release ]; then
  export WSL_DISTRO_NAME="$(. /etc/os-release 2>/dev/null; echo "${ID:-linux}")"
fi
