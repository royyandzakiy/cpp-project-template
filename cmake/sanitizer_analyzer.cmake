# cmake/analyzers_optimizers.cmake

# ====== RUNTIME SANITIZERS ======
if(ENABLE_SANITIZERS)
  message(STATUS "Configuring Sanitizer Baseline")
  if(MSVC)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
      # ----- Runtime Sanitizer -----
      add_compile_options(/RTC1) # Run-time error checks, similar to UBSan

      if(ENABLE_ASAN)
        # ----- Address Sanitizer -----
        add_compile_options(/fsanitize=address /Zi)
        add_link_options(/fsanitize=address /incremental:no)
      endif()
    endif()
  else()
    # 1. Baseline Safety (Always ON if ENABLE_SANITIZERS is active)
    # These handle Undefined Behavior and are generally compatible with everything.
    set(SANITIZER_FLAGS
        -fsanitize=undefined
        -fsanitize=bounds
        -fsanitize=integer
        -fno-omit-frame-pointer
        -fno-optimize-sibling-calls
        -fstack-protector-strong)

    # 2. Exclusive Profile Selection
    if(ENABLE_ASAN)
      # ----- Address Sanitizer -----
      message(STATUS "Adding ASan: Address and Leak detection")
      list(
        APPEND
        SANITIZER_FLAGS
        -fsanitize=address
        -fsanitize=leak)
    elseif(ENABLE_TSAN_MSAN)
      # ----- Thread & Memory Sanitizer -----
      message(STATUS "Adding TSan: Thread/Data-race detection")
      list(APPEND SANITIZER_FLAGS -fsanitize=thread)
      message(STATUS "Adding MSan: Uninitialized memory detection")
      # track-origins provides better backtraces for where the memory was allocated
      list(
        APPEND
        SANITIZER_FLAGS
        -fsanitize=memory
        -fsanitize-memory-track-origins)
    endif()

    # 3. Apply to targets
    add_compile_options(${SANITIZER_FLAGS})
    add_link_options(${SANITIZER_FLAGS})

    # Reminder: use Debug build for symbols
    if(NOT
       CMAKE_BUILD_TYPE
       STREQUAL
       "Debug")
      message(WARNING "Sanitizers work best in 'Debug' for symbolication.")
    endif()
  endif()
endif()

# ----- MSVC: Add Asan DLL
function(add_asan_dll_to_executable TARGET_NAME)
  if(MSVC AND ENABLE_ASAN)
    set(ASAN_DLL_NAME "clang_rt.asan_dynamic-x86_64.dll")
    get_filename_component(MSVC_BIN_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)
    find_file(
      ASAN_DLL_PATH
      NAMES ${ASAN_DLL_NAME}
      PATHS ${MSVC_BIN_DIR})

    if(ASAN_DLL_PATH)
      add_custom_command(
        TARGET ${TARGET_NAME}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${ASAN_DLL_PATH}" "$<TARGET_FILE_DIR:${TARGET_NAME}>"
        COMMENT "Deploying ASan runtime to ${TARGET_NAME} output")
    endif()
  endif()
endfunction()

if(ENABLE_ASAN)
  add_asan_dll_to_executable(${PROJECT_NAME})
endif()

# ====== STATIC ANALYZERS ======
# ----- Clang-tidy -----
if(ENABLE_CLANG_TIDY)
  find_program(CLANG_TIDY_EXE NAMES "clang-tidy")
  if(CLANG_TIDY_EXE)
    set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
    message(STATUS "Clang-Tidy found: ${CLANG_TIDY_EXE}")
  else()
    message(WARNING "Clang-Tidy not found. Static analysis is disabled.")
  endif()
endif()

# ----- Cppcheck -----
if(ENABLE_CPPCHECK)
  find_program(CPPCHECK_EXE NAMES "cppcheck")
  if(CPPCHECK_EXE)
    set(CMAKE_CXX_CPPCHECK
        "${CPPCHECK_EXE}"
        "--enable=warning,performance,portability,style"
        "--inline-suppr" # Allows you to suppress warnings in code comments
        "--suppress=missingIncludeSystem"
        "--suppressions-list=${CMAKE_SOURCE_DIR}/.cppcheck_suppressions.txt"
        "--inconclusive")
    message(STATUS "Cppcheck found: ${CPPCHECK_EXE}")
  else()
    message(WARNING "Cppcheck not found. Static analysis is disabled.")
  endif()
endif()

# ----- IWYU -----
if(ENABLE_IWYU)
  find_program(IWYU_EXE NAMES "include-what-you-use" "iwyu")
  if(IWYU_EXE)
    set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE
        "${IWYU_EXE}"
        "--transitive_includes_only"
        "--no_fwd_decls")
    message(STATUS "IWYU found: ${IWYU_EXE}")
  else()
    message(WARNING "IWYU not found. Install include-what-you-use and re-run CMake.")
  endif()
endif()

# ====== COMPILATION OPTIMIZERS
# ----- ccache -----
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
