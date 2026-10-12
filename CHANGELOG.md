# Changelog

Notable changes to this template, grouped chronologically by commit history (condensed — not every
commit). Newest first.

## 2026-10-12 — Core library + thin app layout
- Restructured into `src/core` (`MyLib`, always built, holds all logic) and `src/app` (`MyApp`, a
  thin `main()` over `MyLib`). `greeter` moved into `MyLib`; `BUILD_LIB` and the four lib-only
  presets are gone.
- `MyLib` is now STATIC by default (`BUILD_LIB_SHARED=ON` for a DLL). Install/export/staging moved
  to `cmake/install.cmake`, opt-in via `INSTALL_LIB`.
- One `unit_tests` binary links `MyLib` (replaces `unit_tests` + `app_tests`), so coverage no
  longer depends on a build option. `coverage.cmake` now runs before the targets so `MyLib` is
  instrumented.

## 2026-06-26 → 06-27 — App/library split & subproject support
- Split into two targets: `MyApp` (standalone app) and `MyLib` (shared-by-default / static via
  `BUILD_LIB_SHARED`), each toggleable with `BUILD_APP` / `BUILD_LIB`.
- `MyLib` ships an installable CMake package: `generate_export_header` (`MYLIB_EXPORT`),
  `MyLibConfig.cmake` + version file, auto-staged to `generated_lib/<platform>/<config>/`.
- `PROJECT_IS_TOP_LEVEL` guards + `PROJECT_SOURCE_DIR` paths so the project works via
  `add_subdirectory()`.
- Added an `app_tests` target demonstrating dependency injection with a mocked interface (gmock).
- cmake-conan switched from submodule to FetchContent; per-config-correct multi-config dependency
  handling; per-OS/compiler CI badges.
- Fixed: package-manager setup ordering before `project()` (a mis-order resolved the wrong vcpkg `fmt`
  and crashed MSVC Debug only).

## 2026-06-25 — Hardening, modularization & coverage
- Refactored the monolithic `CMakeLists.txt` into focused `cmake/` modules.
- Added compiler hardening defaults and a `build all` path.
- Added code coverage (llvm-cov / gcovr), a `coverage` target, CI report + badges, and a `classify`
  component to showcase partial branch coverage.
- `version.txt` as single source of truth; completed the remaining presets.

## 2026-06-24 — Package managers, CI & sanitizer tests
- Unified `PKG_MANAGER` macro (vcpkg | conan | none) with graceful Conan→vcpkg fallback.
- Added GitHub Actions CI, devcontainers, and `BUILD_TESTING` toggle.
- Full sanitizer test suite (ASan/TSan/MSan in one file), including Windows ASan for MSVC and clang-cl.
- Separated output bin folders per compiler.

## 2026-06-23 — Template foundation rework
- Standard project files, pre-commit hook, editor setup, better debugging support.
- Added Conan support and PCH; integrated codebase-memory indexing.
- Removed cppcheck/IWYU; cleaned up clangd false-positive diagnostics.

## 2026-06-10 → 06-22 — Presets, profilers & examples
- Built out CMakePresets (Windows/Linux/macOS base presets, inheritance, conditionals).
- vcpkg manifest mode as default; local vcpkg root handling.
- Added all sanitizer/profiler integrations (Tracy/Perfetto) with examples; brief IWYU experiment.
- Cleaned up `project_options.cmake` and header separators; fixed project-name macro.

## 2026-05 — Template-ization
- Made sanitizers optional; reframed the README as a reusable template; moved to clang-18.

## 2026-04 — Initial scaffolding
- Project init with MinGW preset and CI workflow.
- vcpkg setup with manifest-mode check; `fmt`; clang-tidy, cppcheck, cmake-format.
- First compiler sanitizers, ASan flags, and Tracy integration; professional README structure.
