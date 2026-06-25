# project_options.cmake

# ------ Compiler Options ------
option(ENABLE_STRICT_COMPILER "Strict compiler options, sees warnings as errors!" OFF)

# ------ Project Features ------
option(BUILD_TESTING "Build the unit tests" OFF)
option(BUILD_EXAMPLES "Build the examples/ demos" OFF)
option(GENERATE_VERSION_HEADER "Generate include/<project>/version.h from version.txt" OFF)

# ------ Package Managers ------
set(PKG_MANAGER "vcpkg" CACHE STRING "Dependency provider: vcpkg | conan | none")
set_property(CACHE PKG_MANAGER PROPERTY STRINGS vcpkg conan none)
if (PKG_MANAGER STREQUAL "vcpkg")
  option(VCPKG_MANIFEST_MODE "set VCPKG to Manifest Mode, else Global Mode" ON)
endif()

# ------ Sanitizers ------
# UBSan is the baseline; pick AT MOST ONE of ASan / TSan / MSan (they are mutually exclusive).
option(ENABLE_SANITIZERS "Enable runtime sanitizers (UBSan baseline)" OFF)
if(ENABLE_SANITIZERS)
  option(ENABLE_ASAN "AddressSanitizer + LeakSanitizer" OFF)
  option(ENABLE_TSAN "ThreadSanitizer (data races)" OFF)
  option(ENABLE_MSAN "MemorySanitizer (uninitialized reads) — Clang only" OFF)
endif()

# ------ Linters & Static Analyzers ------
option(ENABLE_CLANG_TIDY "Enable clang tidy" OFF)

# ------ Coverage ------
# Instrument the build and provide a `coverage` target (Clang: LLVM source-based; GCC: gcov/gcovr).
option(ENABLE_COVERAGE "Instrument for code coverage and add the 'coverage' target" OFF)

# ------ Compile Optimizations ------
option(ENABLE_CCACHE "Enable compiler cache (ccache) — no-op if ccache isn't installed" OFF)
option(ENABLE_FAST_LINKER "Use mold/lld if available (much faster linking) — auto-detected, no-op if absent" OFF)
option(ENABLE_PCH "Precompile common heavy headers (faster full builds; can slow incremental)" OFF)
option(ENABLE_UNITY_BUILD "Batch sources into unity translation units (faster clean/CI builds; incremental-hostile)" OFF)
option(ENABLE_CLANG_BUILD_ANALYZER "Enable Clang -ftime-trace + ClangBuildAnalyzer target (Clang only)" OFF)

# ------ Profilers ------
option(ENABLE_TRACY "Enable Tracy debug profiler" OFF)
option(ENABLE_PERFETTO "Enable Perfetto runtime tracing" OFF)
