# dev-env — Reproducible Development Environment

A single, version-controlled setup for a cross-platform (Windows / macOS / Linux) dev team.
It standardizes **Git, the editor, the shell, language runtimes, and package managers** so that
everyone — and CI — works in an identical environment.

> Applied directly to this machine on **2026-08-01**. Re-run any time to refresh.

---

## What's included

| Layer | Files | What it does |
|-------|-------|--------------|
| **Git** | `git/.gitconfig`, `git/.gitignore_global` | Aliases, `main` default branch, rebase-on-pull, LF normalization, GCM credential helper, verbose diffs. Global ignore for OS/editor/language noise. |
| **Editor (VS Code)** | `editor/vscode/settings.json`, `extensions.json`, `extensions.txt` | VS Code: semantic highlighting, IntelliSense, format-on-save, per-language formatters, debugging tweaks, Git Bash terminal, telemetry off. Recommended extensions list. |
| **Editor (Neovim)** | `editor/nvim/init.lua` + `lua/{config,plugins}/*.lua` | Lua config via lazy.nvim: LSP (mason), completion (nvim-cmp), treesitter, telescope, gitsigns, conform formatting, DAP. Shares the team `.editorconfig`. |
| **Templates** | `templates/go/`, `templates/rust/` | Ready-to-use project skeletons (go.mod / Cargo.toml, linters, Makefile, formatter configs). |
| **EditorConfig** | `.editorconfig` | **The team's formatting contract** — identical indentation/encoding/EOL in *every* editor (VS Code, Neovim, JetBrains…). |
| **Shell** | `shell/.bashrc`, `shell/aliases.sh`, `shell/Microsoft.PowerShell_profile.ps1`, `shell/starship.toml`, `shell/ohmyposh.omp.json` | Git Bash + PowerShell 7 productivity: aliases, fzf, starship/oh-my-posh prompts, version-manager hooks. |
| **Runtimes** | `runtime/.tool-versions`, `.node-version`, `global.json`, `rust-toolchain.toml` | Pinned Node / Python / Java via asdf; `.NET` via `global.json`; Rust via `rust-toolchain.toml`. |
| **Package managers** | `package-managers/scoopfile.json`, `Brewfile`, `setup.ps1`, `setup.sh` | One-command toolchain install — Scoop on Windows, Homebrew on macOS/Linux. |
| **Apply** | `scripts/apply.ps1`, `scripts/apply.sh`, `scripts/install-vscode-extensions.ps1` | Link the dotfiles into a user profile (backs up originals). |

---

## Quick start (this machine)

```powershell
# From the dev-env folder:
.\scripts\apply.ps1                              # link dotfiles into your profile
.\scripts\install-vscode-extensions.ps1          # add recommended VS Code extensions
# (optional) full toolchain install:
.\package-managers\setup.ps1
```

Restart your terminal afterwards. Your prompt, aliases, and Git aliases are live.

---

## Keeping everything off the C: drive (relocate to D:)

Git, VS Code, and Neovim always read their config from **fixed paths inside
`%USERPROFILE%`** (e.g. `C:\Users\<you>\.gitconfig`, `\Documents\PowerShell\...`,
`\AppData\...`). Those paths can't be moved — but the *real content* can live on
**D:\dev-env** while C: holds only a **link** pointing at it.

The machine in this repo already does exactly that: the authoritative copy was
`robocopy`-ed to **`D:\dev-env`**, and `scripts/apply.ps1` links it into the
profile. Edit files in `D:\dev-env`, re-run `apply.ps1`, done.

### How `apply.ps1` links (most robust → least)

| Item | Strategy | Result |
|------|----------|--------|
| **Directories** (e.g. Neovim `~/.config/nvim`) | `SymbolicLink` → **`Junction`** → copy | A Junction works **cross-drive with no elevation**, so the big config dirs leave C: even on a standard account. |
| **Files** (`.gitconfig`, `.bashrc`, …) | `SymbolicLink` → copy | A file can't be a Junction. True off-C: linking for files needs **Developer Mode** or running as Administrator. |

### Enable Developer Mode (recommended, Windows 10/11)

So that **files** also become real symlinks (not copies) and stay off C::

1. Settings → **Privacy & security** → **For developers** → turn on **Developer Mode**.
2. Re-run `.\scripts\apply.ps1` once. It converts the file copies into symlinks
   pointing at `D:\dev-env`.

> Without Developer Mode (standard user), directories are already Junctions
> (off C:), and only the small dotfiles are local copies — fully functional,
> just not linked. Enable Developer Mode for the pure-symlink setup.

### Verify

```powershell
# Neovim config should be a Junction (or Symlink) to D:\dev-env
Get-Item $env:USERPROFILE\.config\nvim | Select Mode, LinkType, Target
# Editing the source propagates immediately:
notepad D:\dev-env\git\.gitconfig      # (with Developer Mode, this IS ~/.gitconfig)
```

---

## How reproducibility works (the important part)

1. **`.editorconfig`** forces the same formatting in every editor, independent of personal settings.
2. **`runtime/.tool-versions`** (+ `global.json`, `rust-toolchain.toml`, `.node-version`) pins exact
   runtime versions. Run `asdf install` (or let fnm/pyenv/SDKMAN read the files) and everyone gets the same versions.
3. **`package-managers/*`** reproduce the *toolchain* (git, node, python, jdk, dotnet, go, rust, starship, fzf…)
   with one command on each OS.
4. **`scripts/apply.*`** make this repo the **single source of truth** — edit here, re-run to deploy.
   No more "works on my machine".

### Line endings
`git/.gitconfig` sets `core.autocrlf = input` and `.gitattributes` sets `* text=auto eol=lf`,
so all text is stored as LF in Git. Windows batch/PowerShell files are explicitly kept CRLF.

---

## Cross-platform notes

- **Windows**: uses Scoop (portable, no admin), Git Credential Manager, Git Bash + PowerShell 7.
  PowerShell profile may live under OneDrive `Documents\WindowsPowerShell` (it does on this machine) — `$PROFILE` resolves it automatically.
- **macOS / Linux**: uses Homebrew + `brew bundle`, asdf, and symlinks (`apply.sh`).
- **Prompts**: `starship` (bash/zsh) and `oh-my-posh` (PowerShell) are both configured from repo files;
  if the binary isn't installed yet, a safe fallback prompt is used — nothing breaks.

---

## Modern CLI tools (optional but recommended)

These replace the default `ls` / `cat` / `grep` / `find` with faster, prettier, cross-platform
equivalents. They are already wired into `shell/aliases.sh` behind `command -v` guards, so they
**fall back gracefully** on machines that don't have them (team-safe). `delta` is wired into
`git/.gitconfig` as the diff pager, and `fd`/`rg` power several shell helpers.

Install on Windows (winget):
```powershell
winget install --id BurntSushi.ripgrep.MSVC --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id sharkdp.fd                --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id sharkdp.bat               --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id eza-community.eza         --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id dandavison.delta          --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id GitHub.cli                --exact --accept-package-agreements --accept-source-agreements --silent
winget install --id jqlang.jq                 --exact --accept-package-agreements --accept-source-agreements --silent
```

| Tool | Replaces | Alias in this repo |
|------|----------|--------------------|
| `eza`  | `ls`   | `ll`, `la`, `lt`, `tree` |
| `bat`  | `cat`  | `cat` |
| `ripgrep` (`rg`) | `grep` | `rg` (recursive, respects `.gitignore`) |
| `fd`   | `find` | `f` |
| `delta`| git diff pager | (set as `core.pager` in `.gitconfig`) |
| `gh`   | `git` + GitHub API | `gh` |
| `jq`   | — | `jq` (pretty-print JSON) |

macOS / Linux: `brew install eza bat ripgrep fd delta gh jq` (or add them to the `Brewfile`).

---

## WSL development environment (Windows)

Run Linux toolchains inside Windows with filesystem/interop integration. See `wsl/`:
- `wsl.conf` — automount metadata, interop, network (deploy to `/etc/wsl.conf`).
- `wsl.profile` — snippet for `~/.profile`: bridges Git credentials to the Windows Git Credential Manager and uses the Windows clipboard.
- `setup-wsl.ps1` — one-command deploy: `powershell -File dev-env\\wsl\\setup-wsl.ps1 -Distro Ubuntu` (copies `wsl.conf` into the distro and appends `wsl.profile` to `~/.profile`).
- `windows-terminal-profile.json` — paste this into Windows Terminal `profiles.list`.

Because `apply.sh` is shared, running it **inside WSL** also auto-appends the WSL integration snippet to `~/.profile`, so your dotfiles + prompt work identically in WSL and on native Linux.

## Docker CI base image

`docker/` builds an image with the **same pinned runtimes** as `runtime/.tool-versions`, `runtime/global.json`, and `runtime/rust-toolchain.toml`, plus the CLI tools. CI therefore runs on exactly what developers have locally — no version drift.

```bash
docker build -f docker/Dockerfile -t dev-env-ci:latest .   # from repo root
```

Use it in GitHub Actions via `container.image: ghcr.io/your-org/dev-env-ci:latest` (see `docker/README.md` for the full recipe and publish steps). Rebuild the image whenever the runtime pins change so CI stays in lockstep.

## Customizing (without breaking the team)

- **Personal Git identity** lives in `git/.gitconfig` `[user]` — keep your own name/email there.
- **Extra aliases**: add to `shell/aliases.sh` (bash) — the PowerShell profile mirrors them.
- **Don't edit `~/.gitconfig` / `~/.bashrc` directly** — edit the repo and re-run `apply.*`,
  otherwise your changes are lost next time someone applies the repo.

---

## File tree

```
dev-env/
├─ .editorconfig            # team formatting contract
├─ .gitattributes           # LF enforcement
├─ README.md
├─ ONBOARDING.md
├─ git/
│  ├─ .gitconfig
│  └─ .gitignore_global
├─ editor/
│  ├─ vscode/
│  │  ├─ settings.json
│  │  ├─ extensions.json
│  │  └─ extensions.txt
│  └─ nvim/
│     ├─ init.lua
│     └─ lua/{config,plugins}/*.lua
├─ shell/
│  ├─ .bashrc
│  ├─ aliases.sh
│  ├─ Microsoft.PowerShell_profile.ps1
│  ├─ starship.toml
│  └─ ohmyposh.omp.json
├─ runtime/
│  ├─ .tool-versions
│  ├─ .node-version
│  ├─ global.json
│  └─ rust-toolchain.toml
├─ package-managers/
│  ├─ scoopfile.json
│  ├─ Brewfile
│  ├─ setup.ps1
│  └─ setup.sh
├─ templates/
│  ├─ go/      (go.mod, main.go, .golangci.yml, Makefile)
│  └─ rust/    (Cargo.toml, src/main.rs, rustfmt.toml, .cargo/config.toml)
├─ wsl/
│  ├─ wsl.conf
│  ├─ wsl.profile
│  ├─ setup-wsl.ps1
│  └─ windows-terminal-profile.json
├─ docker/
│  ├─ Dockerfile
│  ├─ build.sh
│  └─ README.md
└─ scripts/
   ├─ apply.ps1
   ├─ apply.sh
   └─ install-vscode-extensions.ps1
```
