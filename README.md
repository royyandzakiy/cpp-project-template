# C++ Project Template

<!-- CI + coverage -->
[![CI](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml)
[![coverage](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/royyandzakiy/cpp-project-template/badges/coverage.json)](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml)
![C++23](https://img.shields.io/badge/C%2B%2B-23-00599C?logo=cplusplus&logoColor=white)

[![Ubuntu](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/royyandzakiy/cpp-project-template/badges/os-linux.json)](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml)
[![Clang](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/royyandzakiy/cpp-project-template/badges/clang.json)](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml)
[![GCC](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/royyandzakiy/cpp-project-template/badges/gcc.json)](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml)

[![Windows](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/royyandzakiy/cpp-project-template/badges/os-windows.json)](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml)
[![MSVC](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/royyandzakiy/cpp-project-template/badges/msvc.json)](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml)
[![Clang-CL](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/royyandzakiy/cpp-project-template/badges/clang-cl.json)](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml)
[![MinGW](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/royyandzakiy/cpp-project-template/badges/mingw.json)](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml)

[![macOS](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/royyandzakiy/cpp-project-template/badges/os-macos.json)](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml)
[![AppleClang](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/royyandzakiy/cpp-project-template/badges/appleclang.json)](https://github.com/royyandzakiy/cpp-project-template/actions/workflows/build-and-test.yml)

<!-- Badges:
     • All compiler, OS, and coverage badges are DYNAMIC. Each CI leg stages a shields-endpoint
       JSON from build/<preset>/toolchain.txt (compiler id + version), /etc/os-release or
       Win32_OperatingSystem or sw_vers (OS version), and llvm-cov/gcovr (coverage). The
       publish-badges job commits them to the orphan `badges` branch on push to main/master;
       badges read them via shields.io endpoint, so versions track what actually built+passed
       and never drift.
     • To add a badge: have a CI leg stage another <name>.json artifact and add a matching
       endpoint badge to this README — no other plumbing needed.
     • C++23 is intentionally STATIC: it's a project invariant (CMAKE_CXX_STANDARD), not a
       CI-detected fact. -->



A cross-platform, **IDE- and OS-agnostic** C++23 project template. Language intelligence comes
from [clangd](https://clangd.llvm.org/), the build from CMake Presets, and dependencies from
vcpkg or Conan. Ships with sanitizers, static analysis, formatting, coverage, profiling hooks,
examples, and unit tests — for a library, an app, or both.

Targets **Windows** (MSVC, Clang-CL, MinGW), **Linux** (GCC, Clang), and **macOS** (Apple Clang).
Requires CMake 3.28+.

> Setting up your editor? See **[EDITOR_SETUP.md](EDITOR_SETUP.md)** for clangd and debugging in
> VS Code, CLion, Neovim, Emacs, Zed, Helix, and more.

---

## Quick Start

```bash
# Configure (presets are filtered to your platform automatically)
cmake --preset clang-linux-debug    # Linux
cmake --preset clang-cl-debug       # Windows
cmake --preset appleclang-debug     # macOS

# Build (also mirrors compile_commands.json to the project root for clangd)
cmake --build --preset clang-linux-debug

# Run tests (configure with -D BUILD_TESTING=ON)
ctest --preset test-clang-linux-debug
```

List everything available for your OS with `cmake --list-presets`.

**Prerequisites:** CMake 3.28+ and Ninja, a C++23 compiler, vcpkg or Conan, and **LLVM 21**
(`clangd`, `clang-format`, `clang-tidy`) for editor intelligence and the format/lint targets — CI
pins 21, and so does the pre-commit clang-format.

---

## Dev Environment Setup

Pick **one**; they don't interfere (each preset builds into its own `build/<preset>/`):

| Tier | For | How |
|------|-----|-----|
| **Remote-WSL** *(recommended with WSL2)* | One shared Linux box for all your projects | `bash scripts/setup-ubuntu.sh` once, then **Reopen in WSL** in VS Code |
| **Dev Container** | No WSL/Linux box, or a reproducible env | **Reopen in Container** (`.devcontainer/`) |
| **Native Windows** | clang-cl / MSVC without WSL or Docker | `pwsh -File scripts/setup-windows.ps1` (winget) |

- The Dev Container **and CI both run `scripts/setup-ubuntu.sh`**, which pins Clang 21 from
  apt.llvm.org, so WSL, container and CI share one compiler version.
- Add `--with-vcpkg` (Linux) / `-WithVcpkg` (Windows) to also install vcpkg; otherwise only Conan
  is set up.
- Native Windows still needs the MSVC headers + Windows SDK (Visual Studio's "Desktop development
  with C++" workload), for the clang-cl presets too.

---

## Project Structure

```
.
├── CMakeLists.txt                # Top-level build
├── CMakePresets.json             # Presets, platform-filtered (no setup needed)
├── project_options.cmake         # Feature toggles (shared, committed)
├── project_options.local.cmake.example   # Machine-local overrides (copy; gitignored)
├── project_dependencies.cmake    # find_package() calls
├── vcpkg.json · conanfile.py     # Dependency manifests (pick one with PKG_MANAGER)
├── version.txt                   # Project version — single source of truth
├── include/MyLib/                # MyLib public headers
├── src/
│   ├── core/                     # MyLib — all logic, always built (math, classify, greeter)
│   └── app/                      # MyApp — thin main() over MyLib (BUILD_APP)
├── test/                         # GoogleTest unit tests on MyLib (+ sanitizer trip-wires)
├── examples/                     # MyLib consumer, Tracy / Perfetto demos (BUILD_EXAMPLES)
├── fuzz/                         # libFuzzer targets over MyLib (ENABLE_FUZZING)
├── cmake/                        # Build modules
│   ├── package_manager.cmake     #   dispatches to vcpkg / Conan / none (PKG_MANAGER)
│   ├── config_vcpkg.cmake        #   vcpkg detection + toolchain wiring (manifest mode)
│   ├── config_conan.cmake        #   Conan via the cmake-conan provider (+ conan-profiles/)
│   ├── compiler.cmake            #   warnings, strict mode, build-type guard
│   ├── build_acceleration.cmake  #   ccache, fast linker (mold/lld)
│   ├── sanitizers.cmake          #   target_enable_sanitizers(): ASan/TSan/UBSan
│   ├── analyzers.cmake           #   clang-tidy discovery
│   ├── profiler.cmake            #   Tracy, Perfetto, ClangBuildAnalyzer
│   ├── configure_target.cmake    #   configure_target(): PCH, unity, tidy, profiler links
│   ├── coverage.cmake            #   instrumentation + `coverage` target
│   ├── fuzzing.cmake             #   add_fuzz_target(): libFuzzer + smoke test
│   ├── format.cmake              #   format / format-check / tidy-all targets
│   ├── clangd.cmake              #   mirror compile_commands.json to the project root
│   ├── install.cmake             #   MyLib find_package() package + staging (INSTALL_LIB)
│   ├── packaging.cmake           #   CPack archive of the app and/or MyLib package
│   └── version.cmake             #   version.txt → project version + MyLib/version.h
├── scripts/                      # setup-ubuntu.sh · setup-windows.ps1 · coverage/badge helpers
├── .github/                      # CI: lint + build/test matrix on Linux/Windows/macOS
├── .devcontainer/                # Portable container (runs setup-ubuntu.sh)
└── .clangd · .clang-format · .clang-tidy · .cmake-format.yaml · .editorconfig · .pre-commit-config.yaml
```

Generated headers (`MyLib/mylib_export.h`, `MyLib/version.h`) are written into the build dir, never
the source tree.

---

## CMake Presets

Presets are **automatically filtered by platform** — only those for your OS appear.

| Preset                                      | Platform | Compiler         |
| ------------------------------------------- | -------- | ---------------- |
| `msvc-debug` / `msvc-release`               | Windows  | MSVC (VS 2022)   |
| `clang-cl-debug` / `clang-cl-release`       | Windows  | Clang-CL + Ninja |
| `mingw-debug` / `mingw-release`             | Windows  | MinGW GCC        |
| `clang-linux-debug` / `clang-linux-release` | Linux    | Clang            |
| `gcc-linux-debug` / `gcc-linux-release`     | Linux    | GCC              |
| `appleclang-debug` / `appleclang-release`   | macOS    | Apple Clang      |

Each has matching `build` and `test` presets. The Linux/macOS **debug** presets also enable
coverage. On top of those: **sanitizer** presets `clang-linux-asan` / `clang-linux-tsan` (Linux)
and `msvc-asan` / `clang-cl-asan` (Windows), a **`clang-linux-fuzz`** preset (see
[Fuzzing](#fuzzing)), plus a kitchen-sink **`clang-linux-full`** (ASan +
strict + clang-tidy + PCH + unity + examples). `CMakeUserPresets.json` is optional — copy
`CMakeUserPresets.json.example` for your own.

---

## Feature Toggles (`project_options.cmake`)

| Option                      | Default | Description                                                  |
| --------------------------- | ------- | ------------------------------------------------------------ |
| `PKG_MANAGER`               | `vcpkg` | Dependency provider: `vcpkg` \| `conan` \| `none`            |
| `BUILD_APP`                 | ON      | Build `MyApp` (`src/app`); `MyLib` (`src/core`) is always built |
| `BUILD_LIB_SHARED`          | OFF     | Build `MyLib` as a DLL / `.so` instead of static             |
| `INSTALL_LIB`               | OFF     | Install `MyLib` as a `find_package()` package + stage into `generated_lib/` |
| `BUILD_TESTING`             | OFF     | Build the GoogleTest unit tests                              |
| `BUILD_EXAMPLES`            | OFF     | Build the `examples/` demo targets                           |
| `GENERATE_VERSION_HEADER`   | ON      | Generate `MyLib/version.h` from `version.txt`                |
| `ENABLE_STRICT_COMPILER`    | OFF     | Warnings as errors (`/WX`; `-Werror -pedantic`)              |
| `ENABLE_SANITIZERS`         | OFF     | UBSan baseline (GCC/Clang)                                   |
| `ENABLE_ASAN`               | OFF     | AddressSanitizer + LeakSanitizer (needs `ENABLE_SANITIZERS`) |
| `ENABLE_TSAN`               | OFF     | ThreadSanitizer (needs `ENABLE_SANITIZERS`; not with ASan)   |
| `ENABLE_FUZZING`            | OFF     | libFuzzer targets in `fuzz/` (Clang; needs sanitizers)       |
| `ENABLE_CLANG_TIDY`         | OFF     | clang-tidy on first-party code during the build              |
| `ENABLE_COVERAGE`           | OFF     | Instrument + add the `coverage` target (GCC/Clang)           |
| `ENABLE_CCACHE`             | OFF     | ccache compiler launcher (no-op if absent)                   |
| `ENABLE_FAST_LINKER`        | OFF     | mold/lld if found (no-op if absent / MSVC)                   |
| `ENABLE_PCH`                | OFF     | Precompiled headers (faster full builds, slower incremental) |
| `ENABLE_UNITY_BUILD`        | OFF     | Unity TUs (faster clean/CI builds; incremental-hostile)      |
| `ENABLE_CLANG_BUILD_ANALYZER` | OFF   | `-ftime-trace` + ClangBuildAnalyzer target (Clang only)      |
| `ENABLE_TRACY`              | OFF     | Tracy profiler                                               |
| `ENABLE_PERFETTO`           | OFF     | Perfetto tracing                                             |

Sanitizer/coverage/strict toggles are usually set by the presets. Set the rest with `-D` or
permanently in `project_options.local.cmake` (copy the `.example`).

---

## Code Quality

**Formatting & lint.** `.clang-format` (Microsoft base, tabs, 120 cols), `.clang-tidy` (bugprone,
modernize, performance, cppcoreguidelines; warnings as errors), `.cmake-format.yaml`, and
`.editorconfig`. Targets from `cmake/format.cmake`:

```bash
cmake --build build/<preset> --target format        # rewrite src/ include/ test/ examples/
cmake --build build/<preset> --target format-check  # fail if anything is unformatted
cmake --build build/<preset> --target tidy-all      # clang-tidy over src/
```

CI runs `format-check` and `tidy-all` in its own **lint** job. Locally,
`pip install pre-commit && pre-commit install` runs clang-format and cmake-format on commit.

**Sanitizers.** Applied **per target** by `cmake/sanitizers.cmake`: each first-party target calls
`target_enable_sanitizers(<target>)` (a no-op unless `ENABLE_SANITIZERS`), so third-party code
(GTest, vcpkg/Conan deps) stays uninstrumented. Call it on any target you add — an executable that
links the static MyLib must be sanitized too, or the sanitizer runtime isn't linked. UBSan is the
baseline on GCC/Clang, plus ASan *or* TSan; Windows has ASan only. Use the sanitizer presets rather
than setting these by hand. **`test/sanitizers/sanitizer_tests.cpp`** holds gtest death tests that
fail if a sanitizer *doesn't* catch its bug class, so a silently-disabled sanitizer turns CI red.
Windows details (CRT, LLVM 20+ for `clang-cl-asan`) are in [EDITOR_SETUP.md](EDITOR_SETUP.md).

**Coverage.** `ENABLE_COVERAGE` (on in the Linux/macOS debug presets) adds a `coverage` target that
re-runs the tests and writes `build/<preset>/coverage-html/`:

```bash
cmake --build --preset clang-linux-debug --target coverage
```

Clang uses LLVM source-based coverage (`llvm-profdata` + `llvm-cov`); GCC uses `gcovr`. MSVC and
clang-cl aren't supported. CI renders the table into the run summary and, on `main`/`master`,
publishes the coverage badge above.

**Fuzzing.** <a id="fuzzing"></a>`fuzz/fuzz_mylib.cpp` is a [libFuzzer](https://llvm.org/docs/LibFuzzer.html)
target that feeds arbitrary input through MyLib's API under ASan + UBSan. The `clang-linux-fuzz`
preset builds it (`ENABLE_FUZZING`, Clang with a GNU-style driver), and ctest runs a short
fixed-seed smoke run in CI. Fuzz for real with a growing corpus:

```bash
cmake --preset clang-linux-fuzz && cmake --build --preset clang-linux-fuzz
./bin/clang/fuzz_mylib fuzz/corpus -max_total_time=60
```

`cmake/fuzzing.cmake` gives first-party libraries libFuzzer's coverage instrumentation through
`configure_target()`; add more targets with `add_fuzz_target(<name> <source>)` in `fuzz/CMakeLists.txt`.
It already earned its keep: it found signed-overflow UB in `mymath::add`/`multiply` on its first
inputs, which is why those now return `std::int64_t`.

**Profilers.** `cmake/profiler.cmake` wires **Tracy** (`ENABLE_TRACY`) and **Perfetto**
(`ENABLE_PERFETTO`) as interface targets that `configure_target()` links into first-party targets;
`examples/` has a runnable demo for each. **ClangBuildAnalyzer** (`ENABLE_CLANG_BUILD_ANALYZER`)
profiles compile time.

---

## Packaging

`cmake/packaging.cmake` sets up CPack over what `cmake --install` produces: a **ZIP** on Windows,
a **TGZ** elsewhere, written to `build/<preset>/package/`.

```bash
cmake --build --preset clang-linux-release
cpack --config build/clang-linux-release/CPackConfig.cmake
```

- **App** (`BUILD_APP`): `bin/MyApp` plus the shared libraries it loads from the build (e.g.
  `fmt.dll` from vcpkg, `MyLib` when `BUILD_LIB_SHARED`), the MSVC runtime DLLs on Windows, and a
  relative RPATH on Linux/macOS — so the extracted archive runs anywhere.
- **Library** (`INSTALL_LIB`): MyLib's headers, binaries and `find_package(MyLib)` config files.

CI packages every `*-release` preset and uploads the archive as a build artifact.

---

## Dependencies & Package Managers

The package manager is **orthogonal to the presets** — every preset works with either. Pick it
with `PKG_MANAGER` (`vcpkg` default · `conan` · `none`) via `-D`, the IDE's cache editor, or:

```cmake
# project_options.local.cmake (gitignored)
set(PKG_MANAGER conan)
```

| Package    | vcpkg (`vcpkg.json`) | Conan (`conanfile.py`) | Use                                       |
| ---------- | -------------------- | ---------------------- | ----------------------------------------- |
| `fmt`      | dependency           | requirement            | String formatting (MyLib, MyApp)          |
| `tracy`    | `tracy` feature      | requirement            | Profiler client (`ENABLE_TRACY`)          |
| `perfetto` | `perfetto` feature   | requirement            | Tracing (`ENABLE_PERFETTO`)               |

GoogleTest (tests) and cmake-conan (the Conan provider) come in via `FetchContent`.

- **vcpkg** runs in manifest mode; the optional features are switched on by their option. vcpkg is
  found via `VCPKG_ROOT_PATH` (`-D` / local options), the `VCPKG_ROOT` env var, `PATH`, common
  install paths (`C:/vcpkg`, `/opt/vcpkg`, `~/vcpkg`), or `./vcpkg`. A VS Developer Shell points
  `VCPKG_ROOT` at Visual Studio's bundled vcpkg — configure warns, and `VCPKG_ROOT_PATH` overrides it.
- **Conan** resolves through the cmake-conan provider, so `find_package()` is unchanged. For clang-cl
  the matching `cmake/conan-profiles/clang-cl-windows-*.ini` is picked automatically (the `asan` one
  under ASan); other compilers are auto-detected. If Conan isn't installed, configure falls back to
  vcpkg for that run.

> Switching managers needs a **fresh configure** into a new build directory (e.g.
> `cmake --preset clang-cl-debug -B build/conan`) — the toolchain/provider locks in at first configure.

---

## Codebase Memory (Knowledge Graph)

`.codebase-memory/` is a local code index for AI agents using the `codebase-memory` MCP server. It
isn't used by the build and is gitignored, so each clone builds its own (`index_repository`).

---

## Adapting the Template

1. Rename the project in `CMakeLists.txt` and `vcpkg.json`, and `MyLib` / `MyApp` to your names.
2. Update `version.txt`.
3. Replace sources under `src/core/` (logic) and `src/app/` (`main()`), and headers under
   `include/`.
4. Add dependencies to `vcpkg.json` and/or `conanfile.py` (whichever `PKG_MANAGER` you use).
   Set `CPACK_PACKAGE_VENDOR` in `cmake/packaging.cmake` to your name / org.
5. Adjust presets in `CMakePresets.json` as needed.
6. Replace this README using `README.md.template` as a starting point.

### Library or app

Both use the same shape: the logic lives in `MyLib` (`src/core`), which the tests link, and an
executable is a thin `main()` on top. Pick one and trim:

**Library project** — `MyLib` is what you ship.

1. Delete `src/app/` and its `add_subdirectory` / `BUILD_APP` lines (or keep the example in
   `examples/mylib_consumer/` as the demo).
2. Set `INSTALL_LIB=ON` (and `BUILD_LIB_SHARED=ON` for a DLL / `.so`).

**App project** — `MyLib` is just your internal, testable core.

1. Delete `cmake/install.cmake`, `cmake/MyLibConfig.cmake.in`, the `INSTALL_LIB` block in
   `src/core/CMakeLists.txt`, and `examples/mylib_consumer/`.
2. Optionally move `include/MyLib/*.hpp` next to the sources in `src/core/`, since nothing outside
   the project consumes them (point `BASE_DIRS` / `target_include_directories` there).
