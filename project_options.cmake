# project_options.cmake

# ------ Compiler Options ------
option(ENABLE_STRICT_COMPILER "Strict compiler options, sees warnings as errors!" OFF)

# ------ Package Managers ------
option(SETUP_VCPKG "Check & setup vcpkg installation" ON)
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
option(ENABLE_CLANG_BUILD_ANALYZER "Enable Clang -ftime-trace + ClangBuildAnalyzer target (Clang only)" OFF)

# ------ Profilers ------
option(ENABLE_TRACY "Enable Tracy debug profiler" OFF)
option(ENABLE_PERFETTO "Enable Perfetto runtime tracing" OFF)
