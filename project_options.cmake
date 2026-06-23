# project_options.cmake

# ------ Compiler Options ------
option(ENABLE_STRICT_COMPILER "Strict compiler options, sees warnings as errors!" OFF)

# ------ Package Managers ------
# Single knob. Swap with -DPKG_MANAGER=conan, set(PKG_MANAGER ...) in local_options.cmake,
# the IDE's CMake cache UI (dropdown), or a *-conan preset.
# NOTE: switching needs a fresh configure (toolchain/provider lock in at first configure) —
# use a separate build dir or the matching preset.
set(PKG_MANAGER "vcpkg" CACHE STRING "Dependency provider: vcpkg | conan | none")
set_property(CACHE PKG_MANAGER PROPERTY STRINGS vcpkg conan none)
option(VCPKG_MANIFEST_MODE "VCPKG in Manifest Mode, else Global Mode" ON)

# ------ Sanitizers ------
option(ENABLE_SANITIZERS "Enable static & runtime sanitizers" OFF)
if(ENABLE_SANITIZERS)
  option(ENABLE_ASAN "Enable Address, Leak, and Undefined sanitizers" OFF)
  option(ENABLE_TSAN_MSAN "Enable Thread sanitizer (Data races) & Memory sanitizer (Uninitialized reads)" OFF)
endif()

# ------ Linters & Static Analyzers ------
option(ENABLE_CLANG_TIDY "Enable clang tidy" OFF)

# ------ Compile Optimizations ------
option(ENABLE_CCACHE "Enable compiler cache (ccache) — no-op if ccache isn't installed" ON)
option(ENABLE_FAST_LINKER "Use mold/lld if available (much faster linking) — auto-detected, no-op if absent" ON)
option(ENABLE_PCH "Precompile common heavy headers (faster full builds; can slow incremental)" OFF)
option(ENABLE_UNITY_BUILD "Batch sources into unity translation units (faster clean/CI builds; incremental-hostile)" OFF)
option(ENABLE_CLANG_BUILD_ANALYZER "Enable Clang -ftime-trace + ClangBuildAnalyzer target (Clang only)" OFF)

# ------ Profilers ------
option(ENABLE_TRACY "Enable Tracy debug profiler" OFF)
option(ENABLE_PERFETTO "Enable Perfetto runtime tracing" OFF)
