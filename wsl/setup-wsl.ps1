param([string]$Distro = 'Ubuntu')
$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Host ('Deploying wsl.conf into WSL distro: ' + $Distro)
Get-Content ($here + '\wsl.conf') | wsl -d $Distro sudo tee /etc/wsl.conf > $null
Write-Host ('Deployed /etc/wsl.conf. Restart WSL: wsl --terminate ' + $Distro)
$user = (wsl -d $Distro -- id -un).Trim()
$snippet = Get-Content ($here + '\wsl.profile') -Raw
$test = (wsl -d $Distro -- bash -c 'grep -q "dev-env WSL integration" ~/.profile 2>/dev/null && echo yes || echo no').Trim()
if ($test -ne 'yes') {
  $snippet | wsl -d $Distro -- bash -c 'cat >> ~/.profile'
  Write-Host ('Appended WSL integration to ~/' + $user + '/.profile')
} else {
  Write-Host 'WSL integration already present in ~/.profile'
}
Write-Host 'Done.'
