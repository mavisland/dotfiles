param()

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir '..')

function Write-Log {
    param([string]$Message)
    Write-Host "[dotfiles] $Message"
}

function Install-File {
    param(
        [string]$Source,
        [string]$Target
    )

    $targetParent = Split-Path -Parent $Target
    if (-not (Test-Path $targetParent)) {
        New-Item -ItemType Directory -Force -Path $targetParent | Out-Null
    }

    if (Test-Path $Target) {
        $backup = "$Target.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Log "Backing up $Target to $backup"
        Move-Item -Force $Target $backup
    }

    Write-Log "Copying $Source -> $Target"
    Copy-Item -Force $Source $Target
}

Write-Log 'Installing core dotfiles'
Install-File -Source (Join-Path $repoRoot 'config/git/.gitconfig') -Target (Join-Path $HOME '.gitconfig')
Install-File -Source (Join-Path $repoRoot 'config/editor/.editorconfig') -Target (Join-Path $HOME '.editorconfig')
Install-File -Source (Join-Path $repoRoot 'config/shell/.bashrc') -Target (Join-Path $HOME '.bashrc')

Write-Log 'Core install complete'