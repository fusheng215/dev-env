# setup.ps1 — Windows one-shot dev-environment bootstrap (team reproducible)
# Run from an ADMINISTRATOR PowerShell 7 session:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\setup.ps1
# What it does: installs Scoop, adds buckets, installs the toolchain from
# scoopfile.json, sets up runtime version managers, then links dotfiles.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
$manifest = Join-Path $root 'scoopfile.json'

Write-Host "=== dev-env Windows bootstrap ===" -ForegroundColor Cyan

# 1) Scoop (portable, no admin needed for most apps)
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "[1/5] Installing Scoop..." -ForegroundColor Yellow
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
    Write-Host "[1/5] Scoop already present." -ForegroundColor Green
}

# 2) Buckets + apps
if (Test-Path $manifest) {
    $cfg = Get-Content $manifest -Raw | ConvertFrom-Json
    foreach ($b in $cfg.buckets) {
        scoop bucket add $b.name $b.repo 2>$null
    }
    foreach ($app in $cfg.apps) {
        Write-Host "  installing $app" -ForegroundColor DarkGray
        scoop install $app 2>$null
    }
}

# 3) PowerShell 7 modules for the prompt
Write-Host "[2/5] Installing oh-my-posh / PSReadLine / Terminal-Icons..." -ForegroundColor Yellow
Install-Module oh-my-posh -Scope CurrentUser -Force
Install-Module PSReadLine -Scope CurrentUser -Force -AllowClobber
Install-Module Terminal-Icons -Scope CurrentUser -Force

# 4) Runtime version managers (cross-platform)
Write-Host "[3/5] Setting up fnm (Node) + pyenv (Python) + SDKMAN (Java)..." -ForegroundColor Yellow
scoop install fnm 2>$null
if (Get-Command fnm -ErrorAction SilentlyContinue) { fnm install 22; fnm default 22 }

# 5) Link dotfiles into the user profile
Write-Host "[4/5] Linking dotfiles..." -ForegroundColor Yellow
& (Join-Path $root '..\scripts\apply.ps1')

Write-Host "[5/5] Done. Restart your terminal (Windows Terminal) to load the new config." -ForegroundColor Green
Write-Host "Tip: run scripts/install-vscode-extensions.ps1 to add recommended VS Code extensions." -ForegroundColor Magenta
