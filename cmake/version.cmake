# cmake/version.cmake
# Single source of truth for the project version: version.txt.
#
#   - This file is included BEFORE project(): it reads version.txt into PROJECT_VERSION_STRING so
#     project(... VERSION ${PROJECT_VERSION_STRING}) uses it — no duplicated version literal.
#   - generate_version_header(<output>) is called AFTER project() (from src/core/CMakeLists.txt,
#     gated by GENERATE_VERSION_HEADER) to write MyLib/version.h into the build tree. It relies on
#     the PROJECT_VERSION_* variables that project() parsed, so there's no manual version splitting.

if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../version.txt")
  file(READ "${CMAKE_CURRENT_LIST_DIR}/../version.txt" _version_raw)
  string(STRIP "${_version_raw}" PROJECT_VERSION_STRING)
  unset(_version_raw)
else()
  set(PROJECT_VERSION_STRING "0.1.0")
  message(WARNING "version.txt not found; defaulting to ${PROJECT_VERSION_STRING}. else, create version.txt with values X.Y.Z (can have more than 1 digit for each)")
endif()

function(generate_version_header output)
  # NB: CMAKE_CURRENT_LIST_DIR inside a function is the CALLER's dir, so use an explicit path.
  configure_file("${PROJECT_SOURCE_DIR}/cmake/version.h.in" "${output}" @ONLY)
  source_group("Generated" FILES "${output}")
  message(STATUS "Version header: ${PROJECT_NAME} v${PROJECT_VERSION} -> ${output}")
endfunction()
