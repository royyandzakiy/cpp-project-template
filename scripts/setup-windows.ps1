#requires -Version 5.1
<#
  scripts/setup-windows.ps1 — install the native Windows C++ toolchain via winget.
  Idempotent. For developers who use neither WSL nor containers (clang-cl / MSVC path).

    pwsh -File scripts/setup-windows.ps1
    pwsh -File scripts/setup-windows.ps1 -WithVcpkg
#>
param([switch]$WithVcpkg)
$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "winget not found. Install 'App Installer' from the Microsoft Store, then re-run."
}

function Install-WinGet([string]$Id) {
  if (winget list --id $Id --exact 2>$null | Select-String -SimpleMatch $Id) {
    Write-Host "  = $Id (already installed)"
  } else {
    Write-Host "  + installing $Id"
    winget install --id $Id --exact --silent --accept-package-agreements --accept-source-agreements
  }
}

Write-Host "==> toolchain (LLVM/clang-cl, CMake, Ninja, Git, Python, ccache)"
Install-WinGet 'LLVM.LLVM'
Install-WinGet 'Kitware.CMake'
Install-WinGet 'Ninja-build.Ninja'
Install-WinGet 'Git.Git'
Install-WinGet 'Python.Python.3.12'
Install-WinGet 'Ccache.Ccache'

Write-Host "==> conan 2 (the project's default package manager)"
if (Get-Command python -ErrorAction SilentlyContinue) {
  python -m pip install --upgrade conan
  conan profile detect --force *> $null
} else {
  Write-Warning "python not on PATH yet — open a NEW terminal, then: pip install conan; conan profile detect"
}

if ($WithVcpkg) {
  Write-Host "==> vcpkg (optional)"
  if (-not (Test-Path 'C:\vcpkg')) {
    git clone https://github.com/microsoft/vcpkg.git C:\vcpkg
    & C:\vcpkg\bootstrap-vcpkg.bat -disableMetrics
  }
  [Environment]::SetEnvironmentVariable('VCPKG_ROOT', 'C:\vcpkg', 'User')
}

Write-Host ""
Write-Host "IMPORTANT: clang-cl AND msvc presets need the MSVC headers + Windows SDK."
Write-Host "  Install 'Desktop development with C++' via the Visual Studio Installer"
Write-Host "  (or: winget install Microsoft.VisualStudio.2022.BuildTools)."
Write-Host ""
Write-Host "Then: cmake --preset clang-cl-debug && cmake --build --preset clang-cl-debug"
