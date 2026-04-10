# cmake/analyzers_optimizers.cmake
if(ENABLE_SANITIZERS AND NOT MSVC)
  message(STATUS "Configuring Hardened Sanitizer Profile")

  # 1. Address & Undefined (The standard combo)
  # 2. Add 'bounds' and 'integer' for extra UBSan checks
  set(SANITIZER_FLAGS
      -fsanitize=address
      -fsanitize=undefined
      -fsanitize=leak
      -fsanitize=bounds
      -fsanitize=integer
      -fno-omit-frame-pointer
      -fno-optimize-sibling-calls)

  # Note: ThreadSanitizer (-fsanitize=thread) and MemorySanitizer (-fsanitize=memory)
  # usually cannot be combined with AddressSanitizer.

  # Extra UBSan hardening
  add_compile_options(-fstack-protector-strong)

  # Add to compiler and linker
  add_compile_options(${SANITIZER_FLAGS})
  add_link_options(${SANITIZER_FLAGS})

  # Optimization: Symbols are required for readable stack traces
  if(NOT
     CMAKE_BUILD_TYPE
     STREQUAL
     "Debug")
    message(WARNING "Sanitizers are most effective in Debug builds (-g).")
  endif()
endif()

# Static Analysis: Clang-tidy
if(ENABLE_CLANG_TIDY)
  find_program(CLANG_TIDY_EXE NAMES "clang-tidy")
  if(CLANG_TIDY_EXE)
    set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
    message(STATUS "Clang-Tidy found: ${CLANG_TIDY_EXE}")
  else()
    message(WARNING "Clang-Tidy not found. Static analysis is disabled.")
  endif()
endif()

# Static Analysis: Cppcheck
if(ENABLE_CPPCHECK)
  find_program(CPPCHECK_EXE NAMES "cppcheck")
  if(CPPCHECK_EXE)
    set(CMAKE_CXX_CPPCHECK
        "${CPPCHECK_EXE}"
        "--enable=warning,performance,portability,style"
        "--inline-suppr" # Allows you to suppress warnings in code comments
        "--suppress=missingIncludeSystem"
        "--inconclusive")
    message(STATUS "Cppcheck found: ${CPPCHECK_EXE}")
  else()
    message(WARNING "Cppcheck not found. Static analysis is disabled.")
  endif()
endif()

# Cache compilation: ccache
if(ENABLE_CCACHE)
  find_program(CCACHE_PROGRAM ccache)
  if(CCACHE_PROGRAM)
    message(STATUS "ccache found: ${CCACHE_PROGRAM}")
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
  else()
    message(STATUS "ccache not found. Rapid recompilation disabled.")
  endif()
endif()

# Tracy Configuration
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
