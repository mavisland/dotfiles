param()

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir '..')

Write-Host '[dotfiles] Validating PowerShell scripts'
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile((Join-Path $repoRoot 'scripts/install.ps1'), [ref]$tokens, [ref]$errors) | Out-Null
[System.Management.Automation.Language.Parser]::ParseFile((Join-Path $repoRoot 'scripts/bootstrap.ps1'), [ref]$tokens, [ref]$errors) | Out-Null
[System.Management.Automation.Language.Parser]::ParseFile((Join-Path $repoRoot 'scripts/platform/windows.ps1'), [ref]$tokens, [ref]$errors) | Out-Null

if ($errors) {
    $errors | ForEach-Object { $_.ToString() }
    exit 1
}

Write-Host '[dotfiles] Validating JSON config'
python -m json.tool (Join-Path $repoRoot 'config/vscode/settings.json') > $null
python -m json.tool (Join-Path $repoRoot 'config/terminal/windows-terminal/settings.json') > $null
python -m json.tool (Join-Path $repoRoot 'config/composer/.config/composer/composer.json') > $null

if (Get-Command composer -ErrorAction SilentlyContinue) {
    Write-Host '[dotfiles] Validating Composer config'
    $env:COMPOSER_HOME = Join-Path $repoRoot 'config/composer/.config/composer'
    composer validate --no-check-publish --no-interaction
}

if (Get-Command php -ErrorAction SilentlyContinue) {
    Write-Host '[dotfiles] Validating PHP override config'
    $env:PHP_INI_SCAN_DIR = Join-Path $repoRoot 'config/php/.config/php/conf.d'
    php --ri date > $null
}

Write-Host '[dotfiles] Checking terminal font configs'
if (-not (Test-Path (Join-Path $repoRoot 'config/terminal/iterm2/com.googlecode.iterm2.plist'))) {
    throw 'Missing iTerm2 plist'
}

if (-not (Test-Path (Join-Path $repoRoot 'config/terminal/windows-terminal/settings.json'))) {
    throw 'Missing Windows Terminal settings'
}

Write-Host '[dotfiles] Verification complete'