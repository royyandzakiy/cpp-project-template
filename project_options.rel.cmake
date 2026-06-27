# project_options.rel.cmake — STANDARDIZED option profile (committed, shared by the team).
#
# Full app + library, tuned for producing shippable artifacts: no tests/examples, no -Werror or
# clang-tidy (a release build shouldn't fail on a new compiler's warnings), and the throughput
# knobs (PCH + unity) ON for faster clean builds. Pair with a Release preset (CMAKE_BUILD_TYPE).
#
# Use either:
#   * -DPROJECT_OPTIONS_PROFILE=rel      (if the selector is wired in CMakeLists.txt), or
#   * include(project_options.rel.cmake) from your gitignored project_options.local.cmake.
# Must be processed BEFORE project_options.cmake (policy CMP0077).
#
# Note: run the test suite with the dev profile in CI; this profile is for the artifact build.

# ------ Package manager (vcpkg | conan | none) ------
set(PKG_MANAGER conan)

# ------ Targets ------
set(BUILD_APP ON)
set(BUILD_LIB ON)
set(BUILD_LIB_SHARED ON) # OFF -> static MyLib

# ------ Lean artifact build ------
set(BUILD_TESTING OFF)
set(BUILD_EXAMPLES OFF)
set(GENERATE_VERSION_HEADER ON)

# ------ Don't fail / slow the release build on analysis ------
set(ENABLE_STRICT_COMPILER OFF)
set(ENABLE_CLANG_TIDY OFF)

# ------ Build speed ------
set(ENABLE_CCACHE ON)
set(ENABLE_FAST_LINKER ON)
set(ENABLE_PCH ON)         # faster clean builds (this is a clean/CI build, not an edit loop)
set(ENABLE_UNITY_BUILD ON) # batch TUs; incremental-hostile but irrelevant for a clean build
