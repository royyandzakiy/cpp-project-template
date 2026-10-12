# cmake/profiler.cmake
# Compile-time profiling (ClangBuildAnalyzer) and runtime profilers (Tracy, Perfetto).
#
# ENABLE_TRACY / ENABLE_PERFETTO pull the library (the vcpkg manifest feature, see
# cmake/config_vcpkg.cmake, or conanfile.py) and create project_tracy_profile /
# project_perfetto_profile, which configure_target() links into first-party targets.

# ===== Compiletime Profiling: ClangBuildAnalyzer =====
if(ENABLE_CLANG_BUILD_ANALYZER)
  if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    message(WARNING "ENABLE_CLANG_BUILD_ANALYZER requires Clang (current: ${CMAKE_CXX_COMPILER_ID}). Skipping.")
  else()
    add_compile_options(-ftime-trace)
    message(STATUS "Clang -ftime-trace enabled for ClangBuildAnalyzer")

    find_program(CLANG_BUILD_ANALYZER_EXE NAMES "ClangBuildAnalyzer")
    if(CLANG_BUILD_ANALYZER_EXE)
      message(STATUS "ClangBuildAnalyzer found: ${CLANG_BUILD_ANALYZER_EXE}")
      # Run manually after a full build: cmake --build . --target clang-build-analyze
      add_custom_target(
        clang-build-analyze
        COMMAND ${CLANG_BUILD_ANALYZER_EXE} --all "${CMAKE_BINARY_DIR}" "${CMAKE_BINARY_DIR}/cba.bin"
        COMMAND ${CLANG_BUILD_ANALYZER_EXE} --analyze "${CMAKE_BINARY_DIR}/cba.bin"
        COMMENT "Collecting and analyzing Clang build traces"
        VERBATIM)
    else()
      message(WARNING "ClangBuildAnalyzer not found — -ftime-trace is active but analysis target unavailable.")
      message(STATUS "  Download: https://github.com/aras-p/ClangBuildAnalyzer/releases")
      message(STATUS "  Extract the exe and add it to PATH, then re-run CMake.")
    endif()
  endif()
endif()

# ===== Runtime Profiling: Perfetto =====
if(ENABLE_PERFETTO)
  find_package(perfetto CONFIG QUIET)
  if(perfetto_FOUND)
    if(NOT TARGET project_perfetto_profile)
      add_library(project_perfetto_profile INTERFACE)
      target_link_libraries(project_perfetto_profile INTERFACE perfetto::perfetto)
      target_compile_definitions(project_perfetto_profile INTERFACE PERFETTO_ENABLE_TRACING)
    endif()
    message(STATUS "Perfetto tracing ENABLED via project_perfetto_profile")
  else()
    message(WARNING "ENABLE_PERFETTO is ON but perfetto wasn't found (vcpkg 'perfetto' feature / conanfile.py) — tracing disabled.")
  endif()
endif()

# ===== Runtime Profiling: Tracy =====
if(ENABLE_TRACY)
  find_package(tracy CONFIG QUIET)
  if(tracy_FOUND)
    if(NOT TARGET project_tracy_profile)
      add_library(project_tracy_profile INTERFACE)
      target_link_libraries(project_tracy_profile INTERFACE Tracy::TracyClient)
      target_compile_definitions(project_tracy_profile INTERFACE TRACY_ENABLE)
    endif()
    message(STATUS "Tracy runtime profiling ENABLED via project_tracy_profile")
  else()
    message(WARNING "ENABLE_TRACY is ON but tracy wasn't found (vcpkg 'tracy' feature / conanfile.py) — profiling disabled.")
  endif()
endif()
