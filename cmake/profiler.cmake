# cmake/profiler.cmake

# ===== Compiletime Profiling: ClangBuildAnalyzer =====
if(ENABLE_CLANG_BUILD_ANALYZER)
  if(NOT
     CMAKE_CXX_COMPILER_ID
     MATCHES
     "Clang")
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
  include(FetchContent)
  FetchContent_Declare(
    perfetto
    GIT_REPOSITORY https://github.com/google/perfetto.git
    GIT_TAG v47.0 # check https://github.com/google/perfetto/releases for latest
    GIT_SHALLOW TRUE)
  FetchContent_GetProperties(perfetto)
  FetchContent_Populate(perfetto)

  add_library(project_perfetto_profile INTERFACE)
  target_sources(project_perfetto_profile INTERFACE "${perfetto_SOURCE_DIR}/sdk/perfetto.cc")
  target_include_directories(project_perfetto_profile INTERFACE "${perfetto_SOURCE_DIR}/sdk")
  target_compile_definitions(project_perfetto_profile INTERFACE PERFETTO_ENABLE_TRACING)

  if(MSVC OR (WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
    set_source_files_properties("${perfetto_SOURCE_DIR}/sdk/perfetto.cc" PROPERTIES COMPILE_FLAGS "/W0")
  else()
    set_source_files_properties("${perfetto_SOURCE_DIR}/sdk/perfetto.cc" PROPERTIES COMPILE_FLAGS "-w")
  endif()

  if(WIN32)
    target_link_libraries(project_perfetto_profile INTERFACE ws2_32)
  else()
    target_link_libraries(project_perfetto_profile INTERFACE pthread)
  endif()

  message(STATUS "Perfetto runtime profiling enabled via project_perfetto_profile")
endif()

# ===== Debug Profiling: Tracy =====
if(ENABLE_TRACY)
  include(FetchContent)
  FetchContent_Declare(
    tracy
    GIT_REPOSITORY https://github.com/wolfpld/tracy.git
    GIT_TAG v0.13.1 # NEED TO MATCH the tracy-profiler.exe VERSION or monitoring won't connect
  )
  FetchContent_GetProperties(tracy)
  FetchContent_Populate(tracy)

  add_library(project_tracy_profile INTERFACE)
  target_sources(project_tracy_profile INTERFACE "${tracy_SOURCE_DIR}/public/TracyClient.cpp")
  target_include_directories(project_tracy_profile INTERFACE "${tracy_SOURCE_DIR}/public")
  target_compile_definitions(project_tracy_profile INTERFACE TRACY_ENABLE)

  if(MSVC OR (WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
    set_source_files_properties("${tracy_SOURCE_DIR}/public/TracyClient.cpp" PROPERTIES COMPILE_FLAGS "/W0")
  else()
    set_source_files_properties("${tracy_SOURCE_DIR}/public/TracyClient.cpp" PROPERTIES COMPILE_FLAGS "-w")
  endif()

  if(WIN32)
    target_link_libraries(project_tracy_profile INTERFACE ws2_32 dbghelp)
    target_compile_definitions(project_tracy_profile INTERFACE _CRT_SECURE_NO_WARNINGS)
  else()
    target_link_libraries(project_tracy_profile INTERFACE pthread dl)
  endif()

  message(STATUS "Tracy debug profiling enabled via project_tracy_profile")

  message(
    STATUS "--------------------------------------------------------\n"
           "Tracy Profiler Configuration:\n"
           "  * call tracy via find_package of vcpkg\n"
           "    find_package(tracy CONFIG REQUIRED)\n"
           "  * Create an internal interface target to hold Tracy settings\n"
           "    add_library(project_tracy_profile INTERFACE)\n"
           "  * Link the vcpkg tracy target\n"
           "    target_link_libraries(project_tracy_profile INTERFACE Tracy::TracyClient)\n"
           "  * Enable tracy macros globally for anyone using this profile\n"
           "    target_compile_definitions(project_tracy_profile INTERFACE TRACY_ENABLE)\n"
           "--------------------------------------------------------")
endif()
