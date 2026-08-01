$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir '..')

function Write-Log {
    param([string]$Message)
    Write-Host "[dotfiles] $Message"
}

& (Join-Path $scriptDir 'install.ps1') @args
