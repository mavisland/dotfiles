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

    if ((Test-Path $Target) -and (Get-FileHash $Source).Hash -eq (Get-FileHash $Target).Hash) {
        Write-Log "Skipping $Target; already matches $Source"
        return
    }

    if (Test-Path $Target) {
        $backup = "$Target.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Log "Backing up $Target to $backup"
        Move-Item -Force $Target $backup
    }

    Write-Log "Copying $Source -> $Target"
    Copy-Item -Force $Source $Target
}

function Install-SSHConfig {
    $sshSource = Join-Path $repoRoot 'config/ssh/.ssh/config'
    $sshTarget = Join-Path $HOME '.ssh\config'
    $sshParent = Split-Path -Parent $sshTarget

    if (-not (Test-Path $sshParent)) {
        New-Item -ItemType Directory -Force -Path $sshParent | Out-Null
    }

    if ((Test-Path $sshTarget) -and (Get-FileHash $sshSource).Hash -eq (Get-FileHash $sshTarget).Hash) {
        Write-Log "Skipping $sshTarget; already matches $sshSource"
        return
    }

    if (Test-Path $sshTarget) {
        $backup = "$sshTarget.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Log "Backing up $sshTarget to $backup"
        Move-Item -Force $sshTarget $backup
    }

    Write-Log "Copying $sshSource -> $sshTarget"
    Copy-Item -Force $sshSource $sshTarget
}

function Install-ComposerConfig {
    $composerSource = Join-Path $repoRoot 'config/composer/.config/composer/composer.json'
    $composerTarget = Join-Path $HOME '.config\composer\composer.json'
    $composerParent = Split-Path -Parent $composerTarget

    if (-not (Test-Path $composerParent)) {
        New-Item -ItemType Directory -Force -Path $composerParent | Out-Null
    }

    if ((Test-Path $composerTarget) -and (Get-FileHash $composerSource).Hash -eq (Get-FileHash $composerTarget).Hash) {
        Write-Log "Skipping $composerTarget; already matches $composerSource"
        return
    }

    if (Test-Path $composerTarget) {
        $backup = "$composerTarget.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Log "Backing up $composerTarget to $backup"
        Move-Item -Force $composerTarget $backup
    }

    Write-Log "Copying $composerSource -> $composerTarget"
    Copy-Item -Force $composerSource $composerTarget
}

function Install-PhpConfig {
    $phpSource = Join-Path $repoRoot 'config/php/.config/php/conf.d/99-dotfiles.ini'
    $phpTarget = Join-Path $HOME '.config\php\conf.d\99-dotfiles.ini'
    $phpParent = Split-Path -Parent $phpTarget

    if (-not (Test-Path $phpParent)) {
        New-Item -ItemType Directory -Force -Path $phpParent | Out-Null
    }

    if ((Test-Path $phpTarget) -and (Get-FileHash $phpSource).Hash -eq (Get-FileHash $phpTarget).Hash) {
        Write-Log "Skipping $phpTarget; already matches $phpSource"
        return
    }

    if (Test-Path $phpTarget) {
        $backup = "$phpTarget.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Log "Backing up $phpTarget to $backup"
        Move-Item -Force $phpTarget $backup
    }

    Write-Log "Copying $phpSource -> $phpTarget"
    Copy-Item -Force $phpSource $phpTarget
}

function Install-ComposerPackages {
    $composerHome = Join-Path $HOME '.config\composer'

    if (-not (Get-Command composer -ErrorAction SilentlyContinue)) {
        Write-Log 'composer is not available; skipping global package install'
        return
    }

    Write-Log 'Installing global Composer packages'
    Push-Location $composerHome
    try {
        composer install --no-interaction --prefer-dist --no-progress
    }
    finally {
        Pop-Location
    }
}

function Install-PowerShellProfile {
    $profilePath = Join-Path $HOME 'Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
    $profileSource = Join-Path $repoRoot 'config/powershell/Microsoft.PowerShell_profile.ps1'

    $profileParent = Split-Path -Parent $profilePath
    if (-not (Test-Path $profileParent)) {
        New-Item -ItemType Directory -Force -Path $profileParent | Out-Null
    }

    if ((Test-Path $profilePath) -and (Get-FileHash $profileSource).Hash -eq (Get-FileHash $profilePath).Hash) {
        Write-Log "Skipping $profilePath; already matches $profileSource"
        return
    }

    if (Test-Path $profilePath) {
        $backup = "$profilePath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Log "Backing up $profilePath to $backup"
        Move-Item -Force $profilePath $backup
    }

    Write-Log "Copying $profileSource -> $profilePath"
    Copy-Item -Force $profileSource $profilePath
}

function Get-WindowsTerminalSettingsPath {
    $candidatePaths = @(
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
    )

    foreach ($candidatePath in $candidatePaths) {
        if (Test-Path $candidatePath) {
            return $candidatePath
        }
    }

    return $null
}

function Install-WindowsTerminalSettings {
    $targetPath = Get-WindowsTerminalSettingsPath
    if (-not $targetPath) {
        Write-Log 'Windows Terminal settings file was not found; skipping terminal profile install.'
        return
    }

    $terminalSource = Join-Path $repoRoot 'config/terminal/windows-terminal/settings.json'
    $terminalParent = Split-Path -Parent $targetPath
    if (-not (Test-Path $terminalParent)) {
        New-Item -ItemType Directory -Force -Path $terminalParent | Out-Null
    }

    if ((Test-Path $targetPath) -and (Get-FileHash $terminalSource).Hash -eq (Get-FileHash $targetPath).Hash) {
        Write-Log "Skipping $targetPath; already matches $terminalSource"
        return
    }

    if (Test-Path $targetPath) {
        $backup = "$targetPath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Log "Backing up $targetPath to $backup"
        Move-Item -Force $targetPath $backup
    }

    Write-Log "Copying $terminalSource -> $targetPath"
    Copy-Item -Force $terminalSource $targetPath
}

function Install-VSCodeSettings {
    $settingsSource = Join-Path $repoRoot 'config/vscode/settings.json'
    $settingsPath = Join-Path $env:APPDATA 'Code\User\settings.json'
    $settingsParent = Split-Path -Parent $settingsPath

    if (-not (Test-Path $settingsParent)) {
        New-Item -ItemType Directory -Force -Path $settingsParent | Out-Null
    }

    if ((Test-Path $settingsPath) -and (Get-FileHash $settingsSource).Hash -eq (Get-FileHash $settingsPath).Hash) {
        Write-Log "Skipping $settingsPath; already matches $settingsSource"
        return
    }

    if (Test-Path $settingsPath) {
        $backup = "$settingsPath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Log "Backing up $settingsPath to $backup"
        Move-Item -Force $settingsPath $backup
    }

    Write-Log "Copying $settingsSource -> $settingsPath"
    Copy-Item -Force $settingsSource $settingsPath
}

Write-Log 'Installing core dotfiles'
Install-File -Source (Join-Path $repoRoot 'config/git/.gitconfig') -Target (Join-Path $HOME '.gitconfig')
Install-File -Source (Join-Path $repoRoot 'config/editor/.editorconfig') -Target (Join-Path $HOME '.editorconfig')
Install-File -Source (Join-Path $repoRoot 'config/shell/.bashrc') -Target (Join-Path $HOME '.bashrc')
Install-SSHConfig
Install-ComposerConfig
Install-PhpConfig
Install-ComposerPackages
Install-PowerShellProfile
Install-WindowsTerminalSettings
Install-VSCodeSettings

Write-Log 'Core install complete'