# cmake/sanitizer_analyzer.cmake

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

# ====== COMPILATION OPTIMIZERS
# ----- ccache -----
if(ENABLE_CCACHE)
  find_program(CCACHE_PROGRAM ccache)
  if(CCACHE_PROGRAM)
    message(STATUS "ccache found: ${CCACHE_PROGRAM}")
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")

    # ccache can't cache MSVC/clang-cl separate-PDB debug info (/Zi, the Debug default).
    # Embed it (/Z7) on Windows so the clang-cl/msvc toolchains actually get cache hits.
    # Still fully debuggable (cppvsdbg/LLDB). Requires CMake >= 3.25 (CMP0141 NEW).
    if(WIN32)
      set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "Embedded")
      message(STATUS "ccache: using embedded debug info (/Z7) on Windows for cacheability")
    endif()
  else()
    message(STATUS "ccache not found. Rapid recompilation disabled.")
  endif()
endif()
