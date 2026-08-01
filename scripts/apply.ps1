# apply.ps1 — link the dev-env dotfiles into the current user profile (Windows)
# Run:  .\apply.ps1   (from the dev-env\scripts folder)
#
# Storage model (relocation to D:\):
#   The real dotfiles content lives wherever this script is located
#   (e.g. D:\dev-env). The C:\Users\<you>\... HOME paths become links that
#   point back to it, so Git / VS Code / Neovim keep reading from their fixed
#   C: paths while the actual files stay off the C: drive.
#
#   Link strategy (most robust -> least):
#     * Directories : SymbolicLink  ->  Junction  ->  Copy
#       (Junction works cross-drive WITHOUT elevation, so big config dirs
#        like Neovim leave C: even without Developer Mode.)
#     * Files      : SymbolicLink  ->  Copy
#       (A file cannot be a Junction; true off-C: linking for files needs
#        "Developer Mode" or running this script as Administrator.)
#
#   Every link is re-stated after creation to make sure it actually exists
#   on disk (some sandboxed / restricted environments report success but
#   silently drop the link).
#
# Idempotent & safe: existing targets are backed up to *.bak before replacing.

$ErrorActionPreference = 'Stop'
$scripts = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repo    = Split-Path -Parent $scripts
$HomeDir = $env:USERPROFILE

function Backup-IfExists($path) {
    if (Test-Path $path) {
        $bak = "$path.bak"
        if (-not (Test-Path $bak)) {
            Rename-Item $path $bak -Force
            Write-Host "  backed up $path -> $bak" -ForegroundColor DarkGray
        } else {
            # A previous backup already exists (e.g. re-run, or a restricted
            # environment where we cannot delete it). Preserve the current
            # file under a timestamped name instead of deleting anything.
            $ts  = Get-Date -Format 'yyyyMMdd-HHmmss'
            $alt = "$path.$ts.bak"
            Rename-Item $path $alt -Force
            Write-Host "  backed up $path -> $alt" -ForegroundColor DarkGray
        }
    }
}

# Returns $true if $to is a live link (SymbolicLink or Junction) pointing at $from.
function Test-Link($from, $to) {
    try {
        $i = Get-ChildItem -Force $to -ErrorAction Stop
        $isLink = ($i.LinkType -eq 'SymbolicLink' -or $i.LinkType -eq 'Junction')
        return ($isLink -and $i.Target -and (Resolve-Path $i.Target).Path -eq (Resolve-Path $from).Path)
    } catch {
        return $false
    }
}

function Remove-IfLinkPhantom($to) {
    # Some restricted/sandboxed filesystems report a successful link creation
    # but never materialize it, leaving a broken placeholder that blocks the
    # next attempt. If the link did not actually verify, remove it so the
    # fallback strategy gets a clean target. (Deletions may be blocked in
    # restricted environments -- ignore the failure and let the next strategy
    # try from whatever state remains.)
    if (Test-Path $to) {
        try { Remove-Item $to -Force -Recurse -ErrorAction SilentlyContinue } catch { }
    }
}

function New-Link($from, $to, $isDir) {
    # For directories we prefer a Junction FIRST: it works cross-drive WITHOUT
    # elevation (no Developer Mode needed) and is the most reliable way to keep
    # the real content off the C: drive on a standard user account.
    if ($isDir) {
        try {
            New-Item -ItemType Junction -Path $to -Target $from -Force | Out-Null
            if (Test-Link $from $to) { return 'Junction' }
        } catch { }
        Remove-IfLinkPhantom $to
    }
    # Symbolic link (cleaner / more portable; needs Developer Mode or admin for
    # non-elevated users). Tried for both files and directories.
    try {
        New-Item -ItemType SymbolicLink -Path $to -Target $from -Force | Out-Null
        if (Test-Link $from $to) { return 'SymbolicLink' }
    } catch { }
    Remove-IfLinkPhantom $to
    return $null
}

function Deploy($from, $to) {
    $dir = Split-Path -Parent $to
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    Backup-IfExists $to

    $isDir = (Get-Item $from).PSIsContainer
    $kind  = New-Link $from $to $isDir
    if ($kind) {
        Write-Host "  linked ($kind)  $to  ->  $from" -ForegroundColor Green
    } else {
        Copy-Item -Path $from -Destination $to -Force -Recurse
        Write-Host "  copied  $to  (links unsupported here; content still managed in $repo)" -ForegroundColor Yellow
    }
}

function Deploy-Copy($from, $to) {
    $dir = Split-Path -Parent $to
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    Backup-IfExists $to
    Copy-Item -Path $from -Destination $to -Force
    Write-Host "  copied  $to" -ForegroundColor Cyan
}

Write-Host "=== Linking dev-env dotfiles (source: $repo) ===" -ForegroundColor Cyan
Write-Host "=== HOME target: $HomeDir ===" -ForegroundColor Cyan

Deploy "$repo\git\.gitconfig"           "$HomeDir\.gitconfig"
Deploy "$repo\git\.gitignore_global"    "$HomeDir\.gitignore_global"
Deploy "$repo\.editorconfig"            "$HomeDir\.editorconfig"
Deploy "$repo\shell\.bashrc"            "$HomeDir\.bashrc"
Deploy "$repo\shell\aliases.sh"         "$HomeDir\.dotfiles-dev\aliases.sh"
Deploy "$repo\shell\starship.toml"      "$HomeDir\.dotfiles-dev\starship.toml"
Deploy "$repo\shell\starship.toml"      "$HomeDir\.config\starship.toml"
Deploy "$repo\shell\ohmyposh.omp.json"  "$HomeDir\.dotfiles-dev\ohmyposh.omp.json"

# PowerShell profile: always copy (it already lives on OneDrive/D:).
$psProfile = $PROFILE
if (-not $psProfile) { $psProfile = "$HomeDir\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" }
Deploy-Copy "$repo\shell\Microsoft.PowerShell_profile.ps1" $psProfile

# PowerShell 5.1 uses a different profile path (WindowsPowerShell). Deploy the
# same (now PSReadLine-version-guarded) profile there too, so the legacy host
# does not error on PredictionSource / PredictionViewStyle on load.
$ps51Profile = "$HomeDir\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
Deploy-Copy "$repo\shell\Microsoft.PowerShell_profile.ps1" $ps51Profile

# Neovim configuration (directory deploy -> Junction when symlinks unavailable)
Deploy "$repo\editor\nvim" "$HomeDir\.config\nvim"

Write-Host "`nAll done. Restart your terminal to load the new configuration." -ForegroundColor Green
Write-Host "To re-apply after editing the repo, just run this script again." -ForegroundColor Magenta
