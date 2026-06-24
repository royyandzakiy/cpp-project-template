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
  add_executable(sanitizer_tests sanitizers/sanitizer_tests.cpp)
  target_link_libraries(sanitizer_tests PRIVATE GTest::gtest GTest::gtest_main)
  # Tell the source which death tests to compile in. UBSan is always the baseline.
  target_compile_definitions(sanitizer_tests PRIVATE SANITIZER_UBSAN)
  if(ENABLE_ASAN)
    target_compile_definitions(sanitizer_tests PRIVATE SANITIZER_ASAN SANITIZER_LSAN)
  elseif(ENABLE_TSAN)
    find_package(Threads REQUIRED)
    target_link_libraries(sanitizer_tests PRIVATE Threads::Threads)
    target_compile_definitions(sanitizer_tests PRIVATE SANITIZER_TSAN)
  elseif(ENABLE_MSAN)
    target_compile_definitions(sanitizer_tests PRIVATE SANITIZER_MSAN)
  endif()
  # TSan and MSan default to report-and-continue; force them to terminate on the first
  # finding so the EXPECT_DEATH death tests actually observe a death. (ASan/UBSan already halt.)
  gtest_discover_tests(sanitizer_tests PROPERTIES
    ENVIRONMENT "TSAN_OPTIONS=halt_on_error=1;MSAN_OPTIONS=halt_on_error=1")
endif()
