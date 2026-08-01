param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

function Test-WingetAvailable {
	return [bool](Get-Command winget -ErrorAction SilentlyContinue)
}

function Install-Winget {
	Write-Host '[dotfiles] winget is missing; attempting to install App Installer'

	$release = Invoke-RestMethod -Uri 'https://api.github.com/repos/microsoft/winget-cli/releases/latest' -Headers @{ 'User-Agent' = 'dotfiles-bootstrap' }
	$asset = $release.assets | Where-Object { $_.name -match 'Microsoft\.DesktopAppInstaller_.*\.msixbundle$' } | Select-Object -First 1

	if (-not $asset) {
		Write-Host '[dotfiles] Could not locate an App Installer package in the latest winget release.'
		return $false
	}

	$tempFile = Join-Path $env:TEMP $asset.name
	Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempFile

	try {
		Add-AppxPackage -Path $tempFile
	}
	catch {
		Write-Host '[dotfiles] App Installer installation failed.'
		return $false
	}

	return (Test-WingetAvailable)
}

function Install-PlatformPackages {
	if (-not (Test-WingetAvailable)) {
		if (-not (Install-Winget)) {
			Write-Host '[dotfiles] winget is still unavailable after install attempt.'
		}
	}

	if (Test-WingetAvailable) {
		Write-Host '[dotfiles] Installing Windows packages with winget'
		winget source update
		winget install --id Git.Git --exact --accept-source-agreements --accept-package-agreements
		winget install --id cURL.cURL --exact --accept-source-agreements --accept-package-agreements
		winget install --id GitHub.cli --exact --accept-source-agreements --accept-package-agreements
		winget install --id Microsoft.VisualStudioCode --exact --accept-source-agreements --accept-package-agreements
		# NanaZip is the Windows archive tool used here instead of 7-Zip.
		winget install --id M2Team.NanaZip --exact --accept-source-agreements --accept-package-agreements
		winget install --id BurntSushi.ripgrep --exact --accept-source-agreements --accept-package-agreements
		winget install --id sharkdp.fd --exact --accept-source-agreements --accept-package-agreements
		winget install --id zyedidia.micro --exact --accept-source-agreements --accept-package-agreements
		# Laragon manages PHP, MySQL, Apache, and Nginx on Windows.
		winget install --id LeNgocKhoa.Laragon --exact --accept-source-agreements --accept-package-agreements
		winget install --id SQLite.SQLite --exact --accept-source-agreements --accept-package-agreements
		winget install --id DBeaver.DBeaver.Community --exact --accept-source-agreements --accept-package-agreements
		Install-Composer
		Install-NerdFont
		Install-VSCodeExtensions
		return
	}

	if (Get-Command choco -ErrorAction SilentlyContinue) {
		Write-Host '[dotfiles] Installing Windows packages with Chocolatey'
		# Keep the Chocolatey fallback aligned with the winget package choices.
		choco install git curl gh vscode nanazip ripgrep fd micro laragon sqlite dbeaver -y
		Install-Composer
		Install-NerdFont
		Install-VSCodeExtensions
		return
	}

	Write-Host '[dotfiles] Neither winget nor Chocolatey is available. Skipping package installation.'
}

function Install-Composer {
	if (Get-Command composer -ErrorAction SilentlyContinue) {
		Write-Host '[dotfiles] Composer is already available.'
		return
	}

	if (-not (Get-Command php -ErrorAction SilentlyContinue)) {
		Write-Host '[dotfiles] PHP is required before installing Composer.'
		return
	}

	Write-Host '[dotfiles] Installing Composer via the official installer'
	$installerPath = Join-Path $env:TEMP 'composer-setup.exe'
	Invoke-WebRequest -Uri 'https://getcomposer.org/Composer-Setup.exe' -OutFile $installerPath
	Start-Process -FilePath $installerPath -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART' -Wait
}

function Install-NerdFont {
	$fontUrl = 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip'
	$fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
	$tempDir = Join-Path $env:TEMP ('FiraCodeNerdFont-' + [guid]::NewGuid().ToString())

	if (-not (Test-Path $fontDir)) {
		New-Item -ItemType Directory -Force -Path $fontDir | Out-Null
	}

	New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
	$zipPath = Join-Path $tempDir 'FiraCode.zip'
	Invoke-WebRequest -Uri $fontUrl -OutFile $zipPath
	Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

	Get-ChildItem -Path $tempDir -Filter '*.ttf' -Recurse | ForEach-Object {
		Copy-Item -Force $_.FullName (Join-Path $fontDir $_.Name)
	}

	Remove-Item -Recurse -Force $tempDir
}

function Install-VSCodeExtensions {
	$extensionsFile = Join-Path $repoRoot 'config\vscode\extensions.txt'

	if (-not (Test-Path $extensionsFile)) {
		Write-Host '[dotfiles] VS Code extensions list not found; skipping extension install.'
		return
	}

	if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
		Write-Host '[dotfiles] code CLI is not available; skipping VS Code extension install.'
		return
	}

	Write-Host '[dotfiles] Installing VS Code extensions'
	Get-Content $extensionsFile | ForEach-Object {
		$extension = $_.Trim()
		if (-not [string]::IsNullOrWhiteSpace($extension)) {
			Write-Host "[dotfiles] Installing VS Code extension: $extension"
			code --install-extension $extension --force
		}
	}
	Write-Host '[dotfiles] VS Code extensions installed successfully'
}
