# Build dryer.exe (PyInstaller one-file).
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

if (-not (Test-Path ".venv")) {
    python -m venv .venv
}
$Py = Join-Path $Root ".venv\Scripts\python.exe"
$Pip = Join-Path $Root ".venv\Scripts\pip.exe"

& $Pip install -q -e ".[dev]" pyinstaller
& $Py -m PyInstaller packaging\dryer.spec --noconfirm

Write-Host ""
Write-Host "Built: $Root\dist\dryer.exe"
