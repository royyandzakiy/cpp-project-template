# ===== Compiletime Profiling: ClangBuildAnalyzer =====

# ===== Runtime Profiling: Perfetto =====

# ===== Debug Profiling: Tracy =====
if(ENABLE_TRACY)
  # call tracy via cmake fetch
  include(FetchContent)
  FetchContent_Declare(
    tracy
    GIT_REPOSITORY https://github.com/wolfpld/tracy.git
    GIT_TAG v0.13.1 # NEED TO MATCH THE tracy-profiler.exe VERSION! or else will not be able to monitor
  )
  FetchContent_GetProperties(tracy)
  FetchContent_Populate(tracy)
  add_library(project_tracy_profile INTERFACE)

  target_sources(project_tracy_profile INTERFACE "${tracy_SOURCE_DIR}/public/TracyClient.cpp")
  target_include_directories(project_tracy_profile INTERFACE "${tracy_SOURCE_DIR}/public")
  target_compile_definitions(project_tracy_profile INTERFACE TRACY_ENABLE)

  if(MSVC OR (WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
    set_source_files_properties(
      "${tracy_SOURCE_DIR}/public/TracyClient.cpp" PROPERTIES COMPILE_FLAGS
                                                              "/W0" # Set warning level to 0 for this file
    )
  else()
    set_source_files_properties(
      "${tracy_SOURCE_DIR}/public/TracyClient.cpp" PROPERTIES COMPILE_FLAGS "-w" # Suppress all warnings on GCC/Clang
    )
  endif()

  if(WIN32)
    target_link_libraries(project_tracy_profile INTERFACE ws2_32 dbghelp)
    target_compile_definitions(project_tracy_profile INTERFACE _CRT_SECURE_NO_WARNINGS)
  endif()

  # call tracy via find_package of vcpkg
  # find_package(tracy CONFIG REQUIRED)
  # # Create an internal interface target to hold Tracy settings
  # # to avoid needing to know the name of the executable here.
  # add_library(project_tracy_profile INTERFACE)

  # # Link the vcpkg tracy target
  # target_link_libraries(project_tracy_profile INTERFACE Tracy::TracyClient)

  # # Enable tracy macros globally for anyone using this profile
  # target_compile_definitions(project_tracy_profile INTERFACE TRACY_ENABLE)

  message(STATUS "Tracy profiler enabled via project_tracy_profile")
endif()
