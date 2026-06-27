# project_options.lib.rel.cmake — STANDARDIZED option profile (committed, shared by the team).
#
# Library ONLY (no app), tuned for producing the distributable MyLib artifact: no tests/examples,
# no -Werror or clang-tidy, throughput knobs (PCH + unity) ON. Pair with a Release preset; the
# result is auto-staged to generated_lib/<platform>/<config>/ for find_package(MyLib) consumers.
#
# Use either:
#   * -DPROJECT_OPTIONS_PROFILE=lib.rel      (if the selector is wired in CMakeLists.txt), or
#   * include(project_options.lib.rel.cmake) from your gitignored project_options.local.cmake.
# Must be processed BEFORE project_options.cmake (policy CMP0077).

# ------ Package manager (vcpkg | conan | none) ------
set(PKG_MANAGER conan)

# ------ Targets: library only ------
set(BUILD_APP OFF)
set(BUILD_LIB ON)
set(BUILD_LIB_SHARED ON) # OFF -> static MyLib (.lib / .a)

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
set(ENABLE_PCH ON)
set(ENABLE_UNITY_BUILD ON)
