# C++ Project Template

A cross-platform C++23 project template with CMake Presets, vcpkg, sanitizers, static analysis, and CI out of the box.

Targets Windows (MSVC, Clang-CL, MinGW) and Linux (GCC, Clang). Requires CMake 3.23+.

---

## Prerequisites

- CMake 3.23+
- vcpkg -- auto-detected from PATH and common install locations. See [vcpkg setup](#vcpkg-setup) if not found.
- A C++23-capable compiler

---

## Quick Start

```bash
# Configure (preset is filtered to your platform automatically)
cmake --preset clang-linux-debug    # Linux
cmake --preset msvc-debug           # Windows

# Build
cmake --build --preset clang-linux-debug

# Run tests
ctest --preset test-clang-linux-debug
```

---

## Project Structure

```
.
├── cmake/                        # CMake utility modules (internal)
│   ├── analyzers_optimizers.cmake
│   ├── config_vcpkg.cmake
│   └── version.cmake
├── include/cmake_project_template/
│   └── version.h                 # Auto-generated from version.txt
├── src/                          # Application sources
├── test/                         # GoogleTest unit tests
├── .github/workflows/            # CI pipeline
├── CMakeLists.txt
├── CMakePresets.json             # All presets (platform-filtered, no setup needed)
├── CMakeUserPresets.json.example # Optional: template for custom preset overrides
├── local_options.cmake.example   # Optional: template for machine-local overrides
├── project_options.cmake         # Feature toggles (shared, committed)
├── vcpkg.json                    # Package manifest
└── version.txt                   # Project version (1.0.0)
```

---

## vcpkg Setup

vcpkg is auto-detected in this order:

1. `VCPKG_ROOT_PATH` set in `local_options.cmake` or via `-D` flag
2. `VCPKG_ROOT` / `VCPKG_ROOT_PATH` environment variables
3. `vcpkg` executable found in PATH
4. Common default paths: `C:/vcpkg`, `/opt/vcpkg`, `~/vcpkg`, etc.
5. `./vcpkg` project subdirectory

For most setups nothing needs to be configured. If vcpkg is in a non-standard location, create `local_options.cmake` (see [local options](#local-options)).

---

## Local Options (`local_options.cmake`)

For machine-specific settings that should never be committed. Copy the example and uncomment what you need:

```bash
cp local_options.cmake.example local_options.cmake
```

```cmake
# local_options.cmake
set(VCPKG_ROOT_PATH "/my/custom/vcpkg")  # if not auto-detected
set(CONAN_ROOT_PATH "/path/to/conan")
set(ENABLE_CLANG_TIDY ON)
```

This file is gitignored. `local_options.cmake.example` documents all available options.

---

## CMake Presets

Presets are defined in `CMakePresets.json`. They are **automatically filtered by platform** -- only presets relevant to your OS appear in the picker.

| Preset                                  | Platform | Compiler         |
| --------------------------------------- | -------- | ---------------- |
| `msvc-debug` / `msvc-release`           | Windows  | MSVC (VS 2022)   |
| `clang-cl-debug` / `clang-cl-release`   | Windows  | Clang-CL + Ninja |
| `mingw-debug` / `mingw-release`         | Windows  | MinGW GCC        |
| `clang-linux-debug` / `clang-linux-release` | Linux | Clang            |
| `gcc-linux-debug` / `gcc-linux-release` | Linux    | GCC              |

`CMakeUserPresets.json` is optional -- only needed if you want custom preset names or overrides. Copy `CMakeUserPresets.json.example` as a starting point.

---

## Feature Toggles (`project_options.cmake`)

| Option                   | Default | Description                                             |
| ------------------------ | ------- | ------------------------------------------------------- |
| `SETUP_VCPKG`            | ON      | Validate vcpkg installation on configure                |
| `ENABLE_STRICT_COMPILER` | ON      | Warnings as errors (`/W4 /WX`, `-Wall -Wextra -Werror`) |
| `ENABLE_SANITIZERS`      | OFF     | UBSan + bounds + integer checks                         |
| `ENABLE_ASAN`            | OFF     | AddressSanitizer + LeakSanitizer                        |
| `ENABLE_TSAN_MSAN`       | OFF     | ThreadSanitizer or MemorySanitizer                      |
| `ENABLE_CLANG_TIDY`      | OFF     | Clang-Tidy static analysis                              |
| `ENABLE_CPPCHECK`        | OFF     | Cppcheck static analysis                                |
| `ENABLE_CCACHE`          | OFF     | ccache compiler launcher                                |
| `ENABLE_TRACY`           | OFF     | Tracy profiler (v0.13.1 via FetchContent)               |

Pass at configure time or set permanently in `local_options.cmake`:

```bash
cmake --preset clang-linux-debug -DENABLE_ASAN=ON -DENABLE_CLANG_TIDY=ON
```

---

## cmake/ Modules

**`config_vcpkg.cmake`** -- Locates vcpkg using the resolution order above. Validates the toolchain and reports package status. Do not edit; configure via `local_options.cmake` instead.

**`analyzers_optimizers.cmake`** -- Wires up sanitizers, Clang-Tidy, Cppcheck, ccache, and Tracy based on `project_options.cmake`. All tools are configured per-target.

**`version.cmake`** -- Reads `version.txt`, splits into major/minor/patch, and generates `include/cmake_project_template/version.h` from `version.h.in`.

---

## Sanitizers and Static Analysis

Sanitizers are Clang/GCC only. On Windows, use a `clang-*` or `mingw-*` preset.

- **`ENABLE_SANITIZERS`** -- adds `-fsanitize=undefined,bounds,integer`
- **`ENABLE_ASAN`** -- adds `-fsanitize=address` with leak detection
- **`ENABLE_TSAN_MSAN`** -- thread or memory sanitizer (mutually exclusive with ASan)

`src/main_fail_sanitizer.cpp` contains intentional violations for verifying sanitizer output.

**Clang-Tidy** rules are in `.clang-tidy` (bugprone, modernize, performance, cppcoreguidelines; warnings as errors). **Cppcheck** runs as a CMake target-level check. Code style is enforced by `.clang-format` (Microsoft base, 120-char line limit, tabs).

---

## Dependencies (`vcpkg.json`)

| Package | Use                                              |
| ------- | ------------------------------------------------ |
| `fmt`   | String formatting                                |
| `gtest` | Unit testing (fetched via FetchContent in tests) |
| `tracy` | Performance profiling (optional, FetchContent)   |

---

## CI (`.github/workflows/`)

Runs on push to `main`/`master` and pull requests. Matrix builds on `ubuntu-latest` with GCC 13 and Clang 17. Steps: checkout, install tools, bootstrap vcpkg, configure, build, run. Build artifacts are uploaded with a 7-day retention window.

---

## Adapting the Template

1. Rename the project in `CMakeLists.txt` and `vcpkg.json`.
2. Update `version.txt`.
3. Replace sources under `src/` and headers under `include/`.
4. Add vcpkg dependencies to `vcpkg.json`.
5. Adjust presets in `CMakePresets.json` as needed.
