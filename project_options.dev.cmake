# project_options.dev.cmake — STANDARDIZED option profile (committed, shared by the team).
#
# Full app + library, tuned for the development inner loop: tests/examples on, strict warnings and
# clang-tidy on, fast rebuilds (ccache + fast linker). Sanitizers come from presets; throughput
# knobs (PCH/unity) stay OFF to keep incremental builds snappy.
#
# Use either:
#   * -DPROJECT_OPTIONS_PROFILE=dev      (if the selector is wired in CMakeLists.txt), or
#   * include(project_options.dev.cmake) from your gitignored project_options.local.cmake.
# Must be processed BEFORE project_options.cmake so these set()s win over the option() defaults
# (policy CMP0077, NEW at cmake_minimum_required 3.28).

# ------ Package manager (vcpkg | conan | none) ------
set(PKG_MANAGER conan)

# ------ Targets ------
set(BUILD_APP ON)
set(BUILD_LIB ON)
set(BUILD_LIB_SHARED ON) # OFF -> static MyLib

# ------ Build everything you iterate on ------
set(BUILD_TESTING ON)
set(BUILD_EXAMPLES ON)
set(GENERATE_VERSION_HEADER ON)

# ------ Code quality (catch problems early) ------
set(ENABLE_STRICT_COMPILER ON)
set(ENABLE_CLANG_TIDY ON)

# ------ Build speed (pure wins; no-op if the tool is missing) ------
set(ENABLE_CCACHE ON)
set(ENABLE_FAST_LINKER ON)

# PCH/unity left OFF (incremental-hostile); sanitizers/coverage come from presets.
