$env:EDITOR = 'micro'
$env:VISUAL = 'micro'
$env:GIT_EDITOR = 'micro'

function global:prompt {
	$locationPart = (Get-Location).Path
	$branchPart = ''

	if (Get-Command git -ErrorAction SilentlyContinue) {
		$branchName = git rev-parse --abbrev-ref HEAD 2>$null
		if ($LASTEXITCODE -eq 0 -and $branchName -and $branchName -ne 'HEAD') {
			$branchPart = " ($branchName)"
		}
	}

	return "PS $locationPart$branchPart> "
}

Set-Alias ll Get-ChildItem
Set-Alias la Get-ChildItem
Set-Alias l Get-ChildItem
Set-Alias c Clear-Host