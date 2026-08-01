$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir '..')

function Write-Log {
    param([string]$Message)
    Write-Host "[dotfiles] $Message"
}

Write-Log 'Windows bootstrap placeholder is ready.'
Write-Log "Repository root: $repoRoot"
Write-Log 'Next step will add package install, symlink, and app settings support.'
