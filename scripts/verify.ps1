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

Write-Host '[dotfiles] Verification complete'