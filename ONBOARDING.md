# Onboarding — new team member setup

Follow these steps once on a **fresh** machine (Windows, macOS, or Linux). Total time: ~10–15 min.

## 0. Prerequisites

- A terminal: **Windows Terminal** (Windows), Terminal/iTerm2 (macOS), GNOME Terminal (Linux).
- Git (installed by the bootstrap below if missing).
- Internet access.

## 1. Get the dotfiles repo

```bash
git clone <your-org>/dev-env.git ~/dev-env
# or copy this folder to a known location
```

## 2. Install the toolchain (one command)

**Windows (PowerShell 7, run as Administrator):**
```powershell
cd dev-env\package-managers
.\setup.ps1
```

**macOS / Linux (bash/zsh):**
```bash
cd dev-env/package-managers
bash setup.sh
```

This installs: git, node, python, jdk, dotnet, go, rust, starship, fzf, oh-my-posh, VS Code, etc.

## 2b. (Optional) Modern CLI tools

`apply.ps1` already wires `eza` / `bat` / `rg` / `fd` into your aliases and `delta` into Git — but the
binaries must be installed once. On Windows:

```powershell
winget install --id eza-community.eza         --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id sharkdp.bat                --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id BurntSushi.ripgrep.MSVC   --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id sharkdp.fd                 --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id dandavison.delta          --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id GitHub.cli                --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id jqlang.jq                  --exact --accept-package-agreements --accept-source-agreements --silent
```

macOS / Linux: `brew install eza bat ripgrep fd delta gh jq`.

## 2c. (Optional) Neovim

Prefer Neovim over VS Code? Install it, then re-run `apply.ps1` / `apply.sh` — the config in
`editor/nvim/` (lazy.nvim + LSP + completion + treesitter + telescope + DAP) deploys to
`~/.config/nvim` and shares the same team `.editorconfig`, so formatting stays identical.

```powershell
winget install --id Neovim.Neovim --exact --accept-package-agreements --accept-source-agreements --silent
```

## 2d. (Optional) WSL (Windows)

Want a Linux dev environment inside Windows? Install a distro, then bridge it to this setup:

```powershell
wsl --install -d Ubuntu
powershell -File dev-env\wsl\setup-wsl.ps1 -Distro Ubuntu
```
This copies `wsl/wsl.conf` into the distro and appends `wsl/wsl.profile` to `~/.profile`
(Git credentials + clipboard bridge). Paste `wsl/windows-terminal-profile.json` into Windows
Terminal `profiles.list`. Then run `bash dev-env/scripts/apply.sh` **inside WSL** to link dotfiles.

## 2e. (Optional) Docker CI base image

Build a CI image with the same runtime pins:

```bash
docker build -f docker/Dockerfile -t dev-env-ci:latest .
```
Point GitHub Actions at it (`container.image: dev-env-ci:latest`) so CI matches local versions.
See `docker/README.md`.

## 3. Link the dotfiles (one command)

**Windows:**
```powershell
cd dev-env\scripts
.\apply.ps1
```
**macOS / Linux:**
```bash
cd dev-env/scripts
bash apply.sh
```

Your existing `~/.gitconfig`, `~/.bashrc`, `~/.editorconfig`, PowerShell profile, and VS Code
settings are **backed up to `*.bak`** automatically before anything is changed.

## 4. Pin language runtimes

```bash
# Node / Python / Java via asdf (reads runtime/.tool-versions)
asdf install

# .NET: global.json is picked up automatically by the .NET SDK
# Rust: rust-toolchain.toml is picked up automatically by cargo/rustup
```

## 5. Recommended VS Code extensions

```powershell
cd dev-env\scripts
.\install-vscode-extensions.ps1
```

## 6. Restart your terminal

Close and reopen your terminal. You should see:
- A **starship / oh-my-posh** prompt showing git branch + runtime versions.
- Git aliases (`gst`, `gco`, `gl`, `gp`…) and shell aliases (`ll`, `..`, `mkcd`…).
- VS Code with format-on-save and the configured extensions.

## 7. Verify

```bash
git config --global user.name     # should be YOUR name
git st                             # should show a clean short status
node -v ; python -V ; java -version
code --version
```

## Keeping in sync

When the team updates the repo (new alias, new extension, new runtime pin):

```bash
git -C ~/dev-env pull
cd ~/dev-env/scripts && (.\apply.ps1  # or bash apply.sh)
```

Edit the **repo**, never your home files directly — that's what keeps everyone reproducible.
