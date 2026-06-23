# C++ Project Template (clangd)

A cross-platform, **IDE- and OS-agnostic** C++23 project template. Language intelligence comes
from [clangd](https://clangd.llvm.org/), the build from CMake Presets, and dependencies from
vcpkg. Ships with sanitizers, static analysis, formatting, profiling hooks, example targets, and
unit tests.

Targets **Windows** (MSVC, Clang-CL, MinGW), **Linux** (GCC, Clang), and **macOS** (Apple Clang).
Requires CMake 3.28+.

> New to the project in your editor? See **[EDITOR_SETUP.md](EDITOR_SETUP.md)** for clangd setup
> and debugging in VS Code, CLion, Neovim, Emacs, Zed, Helix, and more.

---

## Prerequisites

- **CMake 3.28+** and **Ninja**
- A **C++23** compiler (one of the toolchains above)
- **vcpkg** — auto-detected from PATH and common install locations (see [vcpkg setup](#vcpkg-setup))
- **LLVM 20.x** (`clangd`, `clang-format`, `clang-tidy`) for editor intelligence and the
  format/lint targets

---

## Quick Start

```bash
# Configure (presets are filtered to your platform automatically)
cmake --preset clang-linux-debug    # Linux
cmake --preset clang-cl-debug       # Windows
cmake --preset appleclang-debug     # macOS

# Build (also mirrors compile_commands.json to the project root for clangd)
cmake --build --preset clang-linux-debug

# Run tests
ctest --preset test-clang-linux-debug
```

List everything available for your OS with `cmake --list-presets`.

---

## Project Structure

```
.
├── .clangd                       # clangd behavior (index, IncludeCleaner, inlay hints)
├── .clang-format                 # Formatting style (Microsoft base, tabs, 120 cols)
├── .clang-tidy                   # Static-analysis checks (warnings as errors)
├── .cmake-format.yaml            # CMake formatting style
├── .editorconfig                 # Cross-editor defaults (indent, EOL, charset)
├── .pre-commit-config.yaml       # Git pre-commit hooks (format + lint)
├── CMakeLists.txt                # Top-level build
├── CMakePresets.json             # Presets, platform-filtered (no setup needed)
├── CMakeUserPresets.json.example # Optional: custom preset overrides
├── local_options.cmake.example   # Optional: machine-local overrides (gitignored)
├── project_options.cmake         # Feature toggles (shared, committed)
├── vcpkg.json                    # Package manifest
├── version.txt                   # Project version (1.0.0)
├── EDITOR_SETUP.md               # Per-editor clangd setup
├── cmake/                        # CMake utility modules (internal)
│   ├── config_vcpkg.cmake        #   vcpkg detection + toolchain wiring
│   ├── config_conan.cmake        #   optional Conan alternative
│   ├── sanitizer_analyzer.cmake  #   sanitizers, clang-tidy, ccache
│   ├── profiler.cmake            #   Tracy, Perfetto, ClangBuildAnalyzer
│   ├── format.cmake              #   format / format-check / tidy-all targets
│   └── version.cmake             #   generates the version header
├── include/cpp_project_template/
│   └── version.h                 # Auto-generated from version.txt (gitignored)
├── src/                          # Application sources
├── test/                         # GoogleTest unit tests
└── examples/                     # Sanitizer / Tracy / Perfetto demo targets
```

---

## Editor & clangd Setup

Language intelligence is editor-agnostic — the same four files drive every clangd-based editor:

| File | Purpose |
|------|---------|
| `.clangd` | Semantic behavior: background index, IncludeCleaner, inlay hints, clang-tidy integration |
| `.clang-tidy` | Which static-analysis checks run |
| `.clang-format` | Formatting style |
| `compile_commands.json` | Compilation database — mirrored to the project root on each build |

CMake exports `compile_commands.json` and the `mirror_compile_commands` target copies the active
preset's database to the project root, where `.clangd` (`CompilationDatabase: .`) picks it up.
Editor-specific launch flags (e.g. `--query-driver`) live per-editor — see
**[EDITOR_SETUP.md](EDITOR_SETUP.md)**.

---

## CMake Presets

Presets are defined in `CMakePresets.json` and **automatically filtered by platform** — only
presets relevant to your OS appear.

| Preset                                      | Platform | Compiler         |
| ------------------------------------------- | -------- | ---------------- |
| `msvc-debug` / `msvc-release`               | Windows  | MSVC (VS 2022)   |
| `clang-cl-debug` / `clang-cl-release`       | Windows  | Clang-CL + Ninja |
| `mingw-debug` / `mingw-release`             | Windows  | MinGW GCC        |
| `clang-linux-debug` / `clang-linux-release` | Linux    | Clang            |
| `gcc-linux-debug` / `gcc-linux-release`     | Linux    | GCC              |
| `appleclang-debug` / `appleclang-release`   | macOS    | Apple Clang      |

Each has matching `build` and `test` presets. `CMakeUserPresets.json` is optional — copy
`CMakeUserPresets.json.example` if you want custom names or overrides.

---

## Feature Toggles (`project_options.cmake`)

| Option                      | Default | Description                                                  |
| --------------------------- | ------- | ------------------------------------------------------------ |
| `PKG_MANAGER`               | `vcpkg` | Dependency provider: `vcpkg` \| `conan` \| `none`            |
| `VCPKG_MANIFEST_MODE`       | ON      | Use `vcpkg.json` (manifest) vs. a global install             |
| `ENABLE_STRICT_COMPILER`    | OFF     | Warnings as errors + hardening (`/WX /GS`, `-Werror -pedantic`) |
| `ENABLE_SANITIZERS`         | OFF     | UBSan + bounds + integer checks                              |
| `ENABLE_ASAN`               | OFF     | AddressSanitizer + LeakSanitizer                             |
| `ENABLE_TSAN_MSAN`          | OFF     | ThreadSanitizer or MemorySanitizer                           |
| `ENABLE_CLANG_TIDY`         | OFF     | clang-tidy during the build (also runs live in clangd)       |
| `ENABLE_CCACHE`             | **ON**  | ccache compiler launcher (no-op if ccache absent)            |
| `ENABLE_FAST_LINKER`        | **ON**  | Use mold/lld if found (faster linking); no-op if absent / MSVC |
| `ENABLE_PCH`                | OFF     | Precompiled headers (faster full builds, slower incremental) |
| `ENABLE_UNITY_BUILD`        | OFF     | Unity/jumbo TUs (faster clean/CI builds; incremental-hostile) |
| `ENABLE_CLANG_BUILD_ANALYZER` | OFF   | `-ftime-trace` + ClangBuildAnalyzer target (Clang only)      |
| `ENABLE_TRACY`              | OFF     | Tracy debug profiler (FetchContent)                          |
| `ENABLE_PERFETTO`           | OFF     | Perfetto runtime tracing (FetchContent)                      |

Pass at configure time or set permanently in `local_options.cmake`:

```bash
cmake --preset clang-linux-debug -DENABLE_ASAN=ON -DENABLE_CLANG_TIDY=ON
```

---

## Formatting, Linting & Static Analysis

Styles and checks are split by tool so each is shared and editor-agnostic:

- **`.clang-format`** — Microsoft base, tabs, 120-column limit, C++23.
- **`.clang-tidy`** — bugprone, modernize, performance, cppcoreguidelines; warnings as errors.
- **`.cmake-format.yaml`** — CMake formatting.
- **`.editorconfig`** — cross-editor indent/EOL/charset defaults (honored by VS Code, CLion, Visual Studio); matches the rules above.

Convenience build targets (from `cmake/format.cmake`):

```bash
cmake --build build/<preset> --target format        # rewrite sources in place
cmake --build build/<preset> --target format-check   # fail if unformatted (CI)
cmake --build build/<preset> --target tidy-all       # run clang-tidy over all TUs
```

Git hooks via [pre-commit](https://pre-commit.com/) (`.pre-commit-config.yaml`) run clang-format
and cmake-format on commit:

```bash
pip install pre-commit && pre-commit install
```

---

## Sanitizers & Profilers

Sanitizers are Clang/GCC oriented; on Windows use a `clang-*` or `mingw-*` preset
(MSVC supports ASan only). Wired by `cmake/sanitizer_analyzer.cmake`:

- **`ENABLE_SANITIZERS`** — `-fsanitize=undefined,bounds,integer`
- **`ENABLE_ASAN`** — AddressSanitizer + leak detection
- **`ENABLE_TSAN_MSAN`** — Thread or Memory sanitizer (mutually exclusive with ASan)

Profilers are wired by `cmake/profiler.cmake`: **Tracy** (`ENABLE_TRACY`) and **Perfetto**
(`ENABLE_PERFETTO`), each exposed as an interface target the main executable links when enabled.

The **`examples/`** directory has runnable demos — `examples/sanitizers/main_fail_sanitizer.cpp`
(intentional violations to verify sanitizer output), plus Tracy and Perfetto examples that build
only when their option is enabled.

---

## Dependencies

**vcpkg manifest (`vcpkg.json`):**

| Package  | Use                          |
| -------- | ---------------------------- |
| `fmt`    | String formatting            |
| `scnlib` | Type-safe input parsing      |
| `tracy`  | Performance profiling        |

**Fetched via `FetchContent`:**

| Package      | Use                                                        |
| ------------ | ---------------------------------------------------------- |
| `sml`        | `boost-ext/sml` state machine (header-only)                |
| `googletest` | Unit testing (in `test/`)                                  |
| `perfetto`   | Runtime tracing (when `ENABLE_PERFETTO`)                   |

---

## vcpkg Setup

vcpkg is auto-detected in this order:

1. `VCPKG_ROOT_PATH` set in `local_options.cmake` or via `-D`
2. `VCPKG_ROOT` / `VCPKG_ROOT_PATH` environment variables
3. `vcpkg` executable found in PATH
4. Common default paths: `C:/vcpkg`, `/opt/vcpkg`, `~/vcpkg`, etc.
5. `./vcpkg` project subdirectory

For most setups nothing needs configuring. For a non-standard location, set `VCPKG_ROOT_PATH` in
`local_options.cmake` (copy `local_options.cmake.example`). Conan is available as an alternative
via `cmake/config_conan.cmake`.

---

## cmake/ Modules

- **`config_vcpkg.cmake`** — locates vcpkg, validates the toolchain, reports package status. Don't
  edit; configure via `local_options.cmake`.
- **`config_conan.cmake`** — optional Conan-based dependency flow (alternative to vcpkg).
- **`sanitizer_analyzer.cmake`** — sanitizers, clang-tidy, ccache, per
  `project_options.cmake`.
- **`profiler.cmake`** — Tracy, Perfetto, and ClangBuildAnalyzer integration.
- **`format.cmake`** — `format` / `format-check` / `tidy-all` targets.
- **`version.cmake`** — reads `version.txt` and generates
  `include/cpp_project_template/version.h` from `version.h.in`.

---

## Codebase Memory (Knowledge Graph)

**What it is:** a queryable knowledge graph of the codebase (symbols, calls, imports, structure)
stored in `.codebase-memory/`. It's **not used by the build** — it's developer/AI tooling.

**Workflow:** consumed by AI coding agents (e.g. Claude Code) over **MCP**
(Model Context Protocol). Instead of blindly grepping, the agent queries the graph — "who calls
this?", "where is X defined?", "show the architecture" — for faster, more accurate code
navigation and edits. The index is generated once and shared via git.

**To use it:** add the `codebase-memory` MCP server to your AI client (e.g. in Claude Code,
register it in your MCP config), then ask the agent to `index_repository` (or it bootstraps from
the committed `graph.db.zst`). No MCP client → these files are simply inert.

| File             | Purpose                                                                  |
| ---------------- | ------------------------------------------------------------------------ |
| `graph.db.zst`   | Compressed index snapshot — teammates bootstrap from it instead of re-indexing |
| `artifact.json`  | Index metadata (node/edge counts, timestamp, schema version)             |
| `.gitattributes` | Marks the artifact binary + `merge=ours` so it never conflicts           |

It is intentionally **committed** (the `.gitattributes` is auto-generated for exactly that). The
artifact is a point-in-time snapshot, so re-index before a release if you want it current — or
delete the directory and let each clone build its own index.

---

## Adapting the Template

1. Rename the project in `CMakeLists.txt` and `vcpkg.json` (the generated header path follows the
   project name).
2. Update `version.txt`.
3. Replace sources under `src/` and headers under `include/`.
4. Add vcpkg dependencies to `vcpkg.json`.
5. Adjust presets in `CMakePresets.json` as needed.
6. Replace this README using `README.md.template` as a starting point.
