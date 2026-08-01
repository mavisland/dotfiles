$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Log {
    param([string]$Message)
    Write-Host "[dotfiles] $Message"
}

. (Join-Path $scriptDir 'platform\windows.ps1')

Install-PlatformPackages

& (Join-Path $scriptDir 'install.ps1') @args
