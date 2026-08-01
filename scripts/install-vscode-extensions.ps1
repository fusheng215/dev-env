# install-vscode-extensions.ps1
# Installs the recommended VS Code extensions listed in extensions.txt.
# Usage (PowerShell):  .\install-vscode-extensions.ps1
# Safe to re-run: already-installed extensions are skipped.

$ErrorActionPreference = 'Continue'
$list = Join-Path $PSScriptRoot 'extensions.txt'

if (-not (Test-Path $list)) {
    Write-Error "extensions.txt not found next to this script."
    exit 1
}

# Ensure `code` is on PATH (Windows Store stub or direct install).
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    $codePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
    if (Test-Path $codePath) { $env:PATH += ";$(Split-Path $codePath)" }
}

$exts = Get-Content $list | Where-Object { $_.Trim() -ne '' -and -not $_.StartsWith('#') }
$total = $exts.Count
$i = 0
foreach ($ext in $exts) {
    $i++
    Write-Host "[$i/$total] Installing $ext ..." -ForegroundColor Cyan
    code --install-extension $ext --force 2>$null
}
Write-Host "`nDone. Installed/verified $total extensions." -ForegroundColor Green
