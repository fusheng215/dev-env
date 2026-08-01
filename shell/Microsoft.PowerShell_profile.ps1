# ============================================================
#  PowerShell 7 profile  ($PROFILE)  — dev-env
#  Applied to: ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#  Mirrors the Git Bash setup; uses oh-my-posh + PSReadLine + fzf.
# ============================================================

# ---------- PSReadLine: better command-line editing ----------
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineOption -Colors @{
        Command            = 'Cyan'
        Parameter          = 'DarkCyan'
        String             = 'DarkGreen'
        Operator           = 'DarkYellow'
        Variable           = 'Green'
        Comment            = 'DarkGray'
        Prediction         = 'Dim'
    }
}

# ---------- oh-my-posh prompt (cross-shell, configurable) ----------
# Install via: scoop install oh-my-posh   (or winget install JanDeDobbeleer.OhMyPosh)
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$env:USERPROFILE\.dotfiles-dev\ohmyposh.omp.json" | Invoke-Expression
}
# Fallback: if the config isn't present yet, use a built-in theme.
elseif (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\agnoster.omp.json" | Invoke-Expression
}

# ---------- fzf (fuzzy finder) ----------
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border'
}

# ---------- aliases (mirror bash set) ----------
Set-Alias -Name g     -Value git
Set-Alias -Name gs    -Value git
Set-Alias -Name gd    -Value git
function ga    { git add $args }
function gaa   { git add -A $args }
function gc    { git commit -v $args }
function gca   { git commit -v -a $args }
function gcm   { git commit -m $args }
function gco   { git checkout $args }
function gcb   { git checkout -b $args }
function gb    { git branch -vv $args }
function gl    { git log --graph --oneline --decorate -10 $args }
function gp    { git push $args }
function gpl   { git pull --rebase --autostash $args }
function gf    { git fetch --all --prune $args }
function gst   { git stash $args }
function gstp  { git stash pop $args }

Set-Alias -Name n     -Value npm
Set-Alias -Name nr    -Value npm
function ni    { npm install $args }
function nid   { npm install -D $args }
function nx    { npx $args }
Set-Alias -Name p     -Value pnpm
function pi    { pnpm install $args }
Set-Alias -Name py    -Value python
Set-Alias -Name py3   -Value python
function serve { python -m http.server 8000 }

Set-Alias -Name d     -Value docker
Set-Alias -Name dc    -Value docker
function dps   { docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}" }
Set-Alias -Name k     -Value kubectl

Set-Alias -Name ll    -Value Get-ChildItem
function la   { Get-ChildItem -Force }
Set-Alias -Name ..    -Value Set-Location
function ...  { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
Set-Alias -Name c     -Value Clear-Host
Set-Alias -Name e     -Value Exit
Set-Alias -Name reload -Value '. $PROFILE'

# ---------- helpers ----------
function mkcd  { param([string]$d) New-Item -ItemType Directory -Force -Path $d | Out-Null; Set-Location $d }
function ginit {
    git init -b main; git add -A; git commit -m "Initial commit"
    Write-Host "Repo initialized on 'main'." -ForegroundColor Green
}
function Path-Show { $env:PATH -split ';' | ForEach-Object { $_ } }
Set-Alias -Name path -Value Path-Show

# ---------- dev runtime version managers ----------
# fnm (Node, cross-platform)
if (Get-Command fnm -ErrorAction SilentlyContinue) { fnm env --use-on-cd | Invoke-Expression }
# pyenv (Python, Windows)
if (Test-Path "$env:USERPROFILE\.pyenv\pyenv-win\bin\pyenv.bat") {
    $env:PATH = "$env:USERPROFILE\.pyenv\pyenv-win\bin;$env:USERPROFILE\.pyenv\pyenv-win\shims;$env:PATH"
}
# SDKMAN (Java) — Windows port
if (Test-Path "$env:USERPROFILE\.sdkman\bin\sdkman-init.ps1") {
    . "$env:USERPROFILE\.sdkman\bin\sdkman-init.ps1"
}
# Rust
if (Test-Path "$env:USERPROFILE\.cargo\env.ps1") { . "$env:USERPROFILE\.cargo\env.ps1" }

# ---------- exports ----------
$env:EDITOR = 'code --wait'

Write-Host "dev-env ready (PowerShell) — Node $(node -v 2>$null), Python $(python -V 2>&1 | Select-Object -Last 1)" -ForegroundColor Cyan
