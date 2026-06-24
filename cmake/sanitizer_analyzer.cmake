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
    # Baseline: UBSan (composes with one of ASan/TSan/MSan).
    # -fno-sanitize-recover=all makes UBSan findings fatal (non-zero exit) instead of just
    # printing and continuing — important so they actually fail a build/test.
    set(SANITIZER_FLAGS
        -fsanitize=undefined
        -fsanitize=bounds
        -fno-sanitize-recover=all
        -fno-omit-frame-pointer
        -fno-optimize-sibling-calls
        -fstack-protector-strong)

    # ASan / TSan / MSan are mutually exclusive — allow at most one.
    set(_san_choice 0)
    foreach(_s ENABLE_ASAN ENABLE_TSAN ENABLE_MSAN)
      if(${_s})
        math(EXPR _san_choice "${_san_choice} + 1")
      endif()
    endforeach()
    if(_san_choice GREATER 1)
      message(FATAL_ERROR "ENABLE_ASAN / ENABLE_TSAN / ENABLE_MSAN are mutually exclusive — enable only one.")
    endif()

    if(ENABLE_ASAN)
      message(STATUS "Sanitizers: UBSan + ASan + LSan")
      list(APPEND SANITIZER_FLAGS -fsanitize=address -fsanitize=leak)
    elseif(ENABLE_TSAN)
      message(STATUS "Sanitizers: UBSan + TSan")
      list(APPEND SANITIZER_FLAGS -fsanitize=thread)
    elseif(ENABLE_MSAN)
      if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        message(FATAL_ERROR "ENABLE_MSAN requires Clang — MemorySanitizer is Clang-only (compiler: ${CMAKE_CXX_COMPILER_ID}).")
      endif()
      message(STATUS "Sanitizers: UBSan + MSan (needs an instrumented libc++ to avoid false positives)")
      list(APPEND SANITIZER_FLAGS -fsanitize=memory -fsanitize-memory-track-origins)
    else()
      message(STATUS "Sanitizers: UBSan baseline only (set ENABLE_ASAN / ENABLE_TSAN / ENABLE_MSAN for more)")
    endif()

    add_compile_options(${SANITIZER_FLAGS})
    add_link_options(${SANITIZER_FLAGS})

    if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
      message(WARNING "Sanitizers work best in a Debug build for readable symbols.")
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
# ----- Fast linker (mold / lld) -----
# Linking is often the dominant cost; swapping the linker is a one-flag win. Applies only to
# GNU-like drivers (Clang/GCC/AppleClang/MinGW); MSVC & clang-cl use their own fast linkers.
if(ENABLE_FAST_LINKER AND NOT MSVC)
  find_program(MOLD_LINKER mold)
  find_program(LLD_LINKER NAMES ld.lld lld)
  if(MOLD_LINKER)
    add_link_options(-fuse-ld=mold)
    message(STATUS "Fast linker: mold (${MOLD_LINKER})")
  elseif(LLD_LINKER)
    add_link_options(-fuse-ld=lld)
    message(STATUS "Fast linker: lld (${LLD_LINKER})")
  else()
    message(STATUS "Fast linker: mold/lld not found; using the default linker")
  endif()
endif()

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
