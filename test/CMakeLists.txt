# test/CMakeLists.txt
# =============================================================================
# Test Configuration
# =============================================================================
# Compile the real implementation (src/math.cpp) into the test binary so the math tests link.
add_executable(unit_tests test_simple.cpp test_math.cpp ${CMAKE_SOURCE_DIR}/src/math.cpp)
target_include_directories(unit_tests PRIVATE ${CMAKE_SOURCE_DIR}/src)

# =============================================================================
# GTest Setup
# =============================================================================
# find_package(GTest CONFIG REQUIRED) # need to add `gtest` in vcpkg.json
include(FetchContent)
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG v1.17.0
  SYSTEM)
set(gtest_force_shared_crt
    ON
    CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# surpress warnings from gtest libraries
foreach(t gtest gtest_main gmock gmock_main)
  if(TARGET ${t})
    target_compile_options(${t} PRIVATE -w)
  endif()
endforeach()

target_link_libraries(unit_tests PRIVATE GTest::gtest GTest::gmock)

include(GoogleTest)
gtest_discover_tests(unit_tests)

# =============================================================================
# Sanitizer trip-wires — verify each sanitizer actually CATCHES its bug class.
# Built only when ENABLE_SANITIZERS (so they inherit the sanitizer flags from
# cmake/sanitizer_analyzer.cmake). Each is a ctest test that PASSES when the
# sanitizer's diagnostic appears in the output — if a trip-wire runs clean, the
# sanitizer silently isn't working and the test goes red.
# =============================================================================
if(ENABLE_SANITIZERS)
  # UBSan is always part of the baseline.
  add_executable(trip_ubsan sanitizers/trip_ubsan.cpp)
  add_test(NAME sanitizer_ubsan COMMAND trip_ubsan)
  set_tests_properties(sanitizer_ubsan PROPERTIES PASS_REGULAR_EXPRESSION "runtime error|undefined")

  if(ENABLE_ASAN)
    add_executable(trip_asan sanitizers/trip_asan.cpp)
    add_test(NAME sanitizer_asan COMMAND trip_asan)
    set_tests_properties(sanitizer_asan PROPERTIES PASS_REGULAR_EXPRESSION "AddressSanitizer|heap-buffer-overflow")

    add_executable(trip_lsan sanitizers/trip_lsan.cpp)
    add_test(NAME sanitizer_lsan COMMAND trip_lsan)
    set_tests_properties(sanitizer_lsan PROPERTIES PASS_REGULAR_EXPRESSION "LeakSanitizer|detected memory leaks")
  elseif(ENABLE_TSAN)
    find_package(Threads REQUIRED)
    add_executable(trip_tsan sanitizers/trip_tsan.cpp)
    target_link_libraries(trip_tsan PRIVATE Threads::Threads)
    add_test(NAME sanitizer_tsan COMMAND trip_tsan)
    set_tests_properties(sanitizer_tsan PROPERTIES PASS_REGULAR_EXPRESSION "ThreadSanitizer|data race")
  elseif(ENABLE_MSAN)
    add_executable(trip_msan sanitizers/trip_msan.cpp)
    add_test(NAME sanitizer_msan COMMAND trip_msan)
    set_tests_properties(sanitizer_msan PROPERTIES PASS_REGULAR_EXPRESSION "MemorySanitizer|use-of-uninitialized")
  endif()
endif()
