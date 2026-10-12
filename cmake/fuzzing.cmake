# cmake/fuzzing.cmake
# libFuzzer fuzz targets over MyLib (ENABLE_FUZZING). Needs Clang with a GNU-style driver (Linux,
# or clang on Windows/MinGW) — not GCC, clang-cl or AppleClang, which don't ship libFuzzer — and
# the sanitizers on, so fuzz findings are real memory/UB errors. The clang-linux-fuzz preset sets
# all of it.
#
#   - configure_target() adds -fsanitize=fuzzer-no-link to first-party LIBRARIES, so the fuzzer
#     gets coverage feedback from inside MyLib.
#   - add_fuzz_target(<name> <source>) builds a fuzzer exe linked to MyLib and, with BUILD_TESTING,
#     registers a short fixed-seed run as a ctest smoke test.
#
# Run a fuzzer for real (corpus dir is created/grown in place):
#   ./bin/clang/fuzz_mylib fuzz/corpus -max_total_time=60

if(NOT ENABLE_FUZZING)
  return()
endif()

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR MSVC)
  message(WARNING "Fuzzing: libFuzzer needs Clang with a GNU-style driver (compiler: "
                  "${CMAKE_CXX_COMPILER_ID}); ignoring ENABLE_FUZZING. Use the clang-linux-fuzz preset.")
  set(ENABLE_FUZZING OFF)
  return()
endif()
if(NOT ENABLE_SANITIZERS)
  # The fuzzer-no-link instrumentation in MyLib needs a sanitizer runtime in every exe that links it.
  message(FATAL_ERROR "ENABLE_FUZZING needs ENABLE_SANITIZERS (use the clang-linux-fuzz preset).")
endif()
message(STATUS "Fuzzing: libFuzzer targets enabled (fuzz/)")

function(add_fuzz_target name source)
  add_executable(${name} ${source})
  target_link_libraries(${name} PRIVATE MyLib::MyLib)
  target_compile_options(${name} PRIVATE -fsanitize=fuzzer)
  target_link_options(${name} PRIVATE -fsanitize=fuzzer)
  target_enable_sanitizers(${name})
  if(BUILD_TESTING)
    # Smoke run: fixed seed and run count, so CI is deterministic and quick.
    add_test(NAME ${name}_smoke COMMAND ${name} -runs=50000 -seed=1)
  endif()
endfunction()
