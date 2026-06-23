#!/usr/bin/env bash
# scripts/setup-ubuntu.sh — provision the C++ toolchain in an Ubuntu / WSL2 distro.
#
# Idempotent: safe to re-run. This is the SINGLE source of truth for the Linux toolchain —
# the devcontainer's Dockerfile runs this same script, so the WSL path and the container
# path never drift.
#
#   bash scripts/setup-ubuntu.sh              # toolchain + clang + conan (PKG_MANAGER default)
#   bash scripts/setup-ubuntu.sh --with-vcpkg # also clone + bootstrap vcpkg into ~/vcpkg
set -euo pipefail

WITH_VCPKG=0
for arg in "$@"; do
  case "$arg" in
    --with-vcpkg) WITH_VCPKG=1 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

SUDO=""
if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; fi
export DEBIAN_FRONTEND=noninteractive

echo "==> apt: base C++ toolchain"
$SUDO apt-get update -y
$SUDO apt-get install -y --no-install-recommends \
  build-essential cmake ninja-build ccache mold pkg-config \
  clang clangd clang-format clang-tidy lld lldb gdb \
  git curl zip unzip tar ca-certificates \
  python3 python3-pip pipx

echo "==> gcc-16 (best effort — kept if your distro has it)"
if ! $SUDO apt-get install -y g++-16 gcc-16 2>/dev/null; then
  echo "    g++-16 not in this distro's repos — skipping (default gcc/clang remain)."
fi

echo "==> conan 2 (the project's default package manager)"
if ! command -v conan >/dev/null 2>&1; then
  if [ "$(id -u)" -eq 0 ]; then
    # Container build (root): install system-wide so the runtime user sees it.
    export PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin
    pipx install conan
  else
    pipx ensurepath || true
    pipx install conan
    export PATH="$HOME/.local/bin:$PATH"
  fi
fi
conan profile detect >/dev/null 2>&1 || true   # creates the default profile on first run

if [ "$WITH_VCPKG" -eq 1 ]; then
  echo "==> vcpkg (optional)"
  if [ ! -d "$HOME/vcpkg" ]; then
    git clone https://github.com/microsoft/vcpkg.git "$HOME/vcpkg"
    "$HOME/vcpkg/bootstrap-vcpkg.sh" -disableMetrics
  fi
  if ! grep -q 'VCPKG_ROOT=' "$HOME/.bashrc" 2>/dev/null; then
    {
      echo 'export VCPKG_ROOT="$HOME/vcpkg"'
      echo 'export PATH="$VCPKG_ROOT:$PATH"'
    } >> "$HOME/.bashrc"
  fi
fi

echo ""
echo "Done."
echo "  clang : $(clang --version | head -1)"
echo "  cmake : $(cmake --version | head -1)"
echo "  conan : $(conan --version 2>/dev/null || echo 'open a new shell to pick up PATH')"
echo ""
echo "In VS Code: 'Reopen in WSL', then:"
echo "  cmake --preset clang-linux-debug && cmake --build --preset clang-linux-debug"
