# cmake/sanitizer_analyzer.cmake

# ====== RUNTIME SANITIZERS ======
if(ENABLE_SANITIZERS)
  message(STATUS "Configuring Sanitizer Baseline")
  if(MSVC)
    # Windows (MSVC & clang-cl): ASan is the only real sanitizer — no TSan/MSan/LSan.
    if(ENABLE_ASAN)
      message(STATUS "Sanitizers: ASan (Windows)")
      # /RTC1 (CMake's default Debug flag) is incompatible with ASan on cl and clang-cl — strip it.
      string(REGEX REPLACE "/RTC[1csu]+" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
      string(REGEX REPLACE "/RTC[1csu]+" "" CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
      add_compile_options(/fsanitize=address) # instrumenting; embeds the ASan lib directives
      add_link_options(/INCREMENTAL:NO)        # ASan is incompatible with incremental linking
      # NOTE: do NOT pass /fsanitize=address as a *link* option — CMake links MSVC-style via
      # lld-link/link.exe directly (not the clang-cl driver), which rejects it.
      if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        # clang-cl ASan can't use the debug CRT (/MDd) — use the release DLL CRT (/MD).
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
        message(STATUS "  clang-cl: /MD (release CRT) required by ASan")
        # The auto-linked ASan import libs live in clang's runtime dir, which the direct linker
        # invocation doesn't search — add it. (cl.exe's ASan libs are already on the LIB path.)
        execute_process(
          COMMAND "${CMAKE_CXX_COMPILER}" --print-runtime-dir
          OUTPUT_VARIABLE _asan_rt OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
        if(_asan_rt)
          get_filename_component(_asan_rt_parent "${_asan_rt}" DIRECTORY)
          set(_asan_win "${_asan_rt_parent}/windows")
          # Explicitly link the dynamic ASan import lib + runtime thunk (the clang-cl driver
          # would do this; the direct linker invocation won't).
          add_link_options(
            "/LIBPATH:${_asan_win}"
            clang_rt.asan_dynamic-x86_64.lib
            -wholearchive:clang_rt.asan_dynamic_runtime_thunk-x86_64.lib)
        endif()
      endif()
    elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
      # No ASan requested -> fall back to MSVC runtime checks. /RTC1 is cheap, but is
      # INCOMPATIBLE with /fsanitize=address, so it must never be combined with ASan.
      message(STATUS "Sanitizers: MSVC /RTC1 runtime checks (set ENABLE_ASAN for AddressSanitizer)")
      add_compile_options(/RTC1)
    endif()
    if(ENABLE_TSAN OR ENABLE_MSAN)
      message(WARNING "TSan/MSan are unavailable on Windows (MSVC/clang-cl) — ignoring.")
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

# ----- Deploy the ASan runtime DLL next to a target (Windows only) -----
# On Windows, ASan links a dynamic runtime DLL (clang_rt.asan_dynamic-x86_64.dll) that must sit
# beside the .exe. MSVC keeps it next to cl.exe; clang-cl keeps it in its resource dir (found via
# --print-runtime-dir). No-op on Linux/macOS, where ASan is linked statically.
function(deploy_asan_runtime target)
  if(NOT (MSVC AND ENABLE_ASAN))
    return()
  endif()
  set(_dll "clang_rt.asan_dynamic-x86_64.dll")
  get_filename_component(_cxx_dir "${CMAKE_CXX_COMPILER}" DIRECTORY)
  set(_search "${_cxx_dir}")
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang") # clang-cl: runtime is under lib/clang/<v>/lib/windows
    execute_process(
      COMMAND "${CMAKE_CXX_COMPILER}" --print-runtime-dir
      OUTPUT_VARIABLE _rt
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET)
    if(_rt)
      list(APPEND _search "${_rt}")
      get_filename_component(_rt_parent "${_rt}" DIRECTORY) # .../lib/clang/<v>/lib
      list(APPEND _search "${_rt_parent}/windows")          # where the DLL actually lives
    endif()
  endif()
  find_file(
    ASAN_RUNTIME_DLL
    NAMES ${_dll}
    PATHS ${_search}
    NO_DEFAULT_PATH)
  if(ASAN_RUNTIME_DLL)
    add_custom_command(
      TARGET ${target}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different "${ASAN_RUNTIME_DLL}" "$<TARGET_FILE_DIR:${target}>"
      COMMENT "Deploying ASan runtime (${_dll}) next to ${target}")
  else()
    message(WARNING "deploy_asan_runtime: ${_dll} not found near ${CMAKE_CXX_COMPILER}; ${target} may fail to start.")
  endif()
endfunction()
# NOTE: call deploy_asan_runtime(<target>) AFTER the target is created (this module is included
# before the executables exist). The app calls it in CMakeLists.txt; tests in test/CMakeLists.txt.

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
