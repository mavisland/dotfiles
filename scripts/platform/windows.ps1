param()

$ErrorActionPreference = 'Stop'

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
		winget install --id 7zip.7zip --exact --accept-source-agreements --accept-package-agreements
		winget install --id BurntSushi.ripgrep --exact --accept-source-agreements --accept-package-agreements
		winget install --id sharkdp.fd --exact --accept-source-agreements --accept-package-agreements
		winget install --id zyedidia.micro --exact --accept-source-agreements --accept-package-agreements
		winget install --id PHP.PHP.8.4 --exact --accept-source-agreements --accept-package-agreements
		winget install --id SQLite.SQLite --exact --accept-source-agreements --accept-package-agreements
		winget install --id PostgreSQL.PostgreSQL.17 --exact --accept-source-agreements --accept-package-agreements
		winget install --id Oracle.MySQLShell --exact --accept-source-agreements --accept-package-agreements
		winget install --id DBeaver.DBeaver.Community --exact --accept-source-agreements --accept-package-agreements
		winget install --id MySQL.MySQLWorkbench --exact --accept-source-agreements --accept-package-agreements
		Install-Composer
		return
	}

	if (Get-Command choco -ErrorAction SilentlyContinue) {
		Write-Host '[dotfiles] Installing Windows packages with Chocolatey'
		choco install git curl gh vscode 7zip ripgrep fd micro php sqlite postgresql mysql-shell dbeaver -y
		Install-Composer
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
	Start-Process -FilePath $installerPath -ArgumentList '/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART' -Wait
}
