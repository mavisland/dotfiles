$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
& "$repoRoot\scripts\bootstrap.ps1" @args
