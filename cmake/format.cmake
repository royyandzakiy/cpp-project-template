# cmake/format.cmake
# =============================================================================
# Formatting & static-analysis convenience targets
# =============================================================================
#   cmake --build <dir> --target format        # rewrite sources in place
#   cmake --build <dir> --target format-check   # fail if anything is unformatted (CI)
#   cmake --build <dir> --target tidy-all        # run clang-tidy over all TUs
#
# Style/checks themselves live in .clang-format / .clang-tidy — these targets
# only drive the tools.

# Project-owned sources — the same set the clang-format pre-commit hook covers.
# CONFIGURE_DEPENDS re-globs when files are added.
file(
  GLOB_RECURSE FORMAT_SOURCES
  CONFIGURE_DEPENDS
  "${CMAKE_SOURCE_DIR}/src/*.cpp"
  "${CMAKE_SOURCE_DIR}/src/*.hpp"
  "${CMAKE_SOURCE_DIR}/src/*.h"
  "${CMAKE_SOURCE_DIR}/include/*.hpp"
  "${CMAKE_SOURCE_DIR}/include/*.h"
  "${CMAKE_SOURCE_DIR}/test/*.cpp"
  "${CMAKE_SOURCE_DIR}/test/*.hpp"
  "${CMAKE_SOURCE_DIR}/examples/*.cpp"
  "${CMAKE_SOURCE_DIR}/examples/*.hpp"
  "${CMAKE_SOURCE_DIR}/fuzz/*.cpp")

# clang-tidy analyzes production translation units only: test code breaks many rules on purpose,
# and examples are only in the compile DB when their option is on.
set(TIDY_SOURCES ${FORMAT_SOURCES})
list(FILTER TIDY_SOURCES INCLUDE REGEX "\\.cpp$")
list(FILTER TIDY_SOURCES INCLUDE REGEX "/src/")

# ----- clang-format targets -----
find_program(CLANG_FORMAT_EXE NAMES clang-format)
if(CLANG_FORMAT_EXE AND FORMAT_SOURCES)
  add_custom_target(
    format
    COMMAND ${CLANG_FORMAT_EXE} -i --style=file ${FORMAT_SOURCES}
    COMMENT "clang-format: rewriting ${PROJECT_NAME} sources in place"
    VERBATIM)
  add_custom_target(
    format-check
    COMMAND ${CLANG_FORMAT_EXE} --dry-run --Werror --style=file ${FORMAT_SOURCES}
    COMMENT "clang-format: checking ${PROJECT_NAME} sources (no changes written)"
    VERBATIM)
else()
  message(STATUS "clang-format not found; 'format' / 'format-check' targets unavailable.")
endif()

# ----- clang-tidy target (uses the compile DB in the build dir) -----
find_program(CLANG_TIDY_EXE NAMES clang-tidy)
if(CLANG_TIDY_EXE AND TIDY_SOURCES)
  add_custom_target(
    tidy-all
    COMMAND ${CLANG_TIDY_EXE} -p "${CMAKE_BINARY_DIR}" ${TIDY_SOURCES}
    COMMENT "clang-tidy: analyzing ${PROJECT_NAME} translation units"
    VERBATIM)
else()
  message(STATUS "clang-tidy not found; 'tidy-all' target unavailable.")
endif()
