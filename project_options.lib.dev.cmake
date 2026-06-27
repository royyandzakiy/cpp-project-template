# project_options.lib.dev.cmake — STANDARDIZED option profile (committed, shared by the team).
#
# Library ONLY (no app), tuned for developing MyLib: unit tests on, examples on so the
# example_mylib consumer exercises the exported package, strict warnings + clang-tidy on, fast
# rebuilds. PCH/unity off for a snappy inner loop.
#
# Use either:
#   * -DPROJECT_OPTIONS_PROFILE=lib.dev      (if the selector is wired in CMakeLists.txt), or
#   * include(project_options.lib.dev.cmake) from your gitignored project_options.local.cmake.
# Must be processed BEFORE project_options.cmake (policy CMP0077).

# ------ Package manager (vcpkg | conan | none) ------
set(PKG_MANAGER conan)

# ------ Targets: library only ------
set(BUILD_APP OFF)
set(BUILD_LIB ON)
set(BUILD_LIB_SHARED ON) # OFF -> static MyLib

# ------ Validate the library + its packaging ------
set(BUILD_TESTING ON)
set(BUILD_EXAMPLES ON) # builds example_mylib -> exercises find_package/consumption of MyLib
set(GENERATE_VERSION_HEADER ON)

# ------ Code quality ------
set(ENABLE_STRICT_COMPILER ON)
set(ENABLE_CLANG_TIDY ON)

# ------ Build speed ------
set(ENABLE_CCACHE ON)
set(ENABLE_FAST_LINKER ON)
