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
# Discover tests at ctest time, not build time: under Windows ASan the test exe needs a runtime
# DLL that's only deployed during the build, so a build-time test run can fail to start.
set(CMAKE_GTEST_DISCOVER_TESTS_DISCOVERY_MODE PRE_TEST)
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
  # Compile in only the death tests whose sanitizer is actually active in this build.
  if(MSVC)
    # Windows (MSVC/clang-cl): only ASan exists — no UBSan baseline, no LSan.
    if(ENABLE_ASAN)
      target_compile_definitions(sanitizer_tests PRIVATE SANITIZER_ASAN)
    endif()
  else()
    # GCC/Clang: UBSan is always the baseline, plus one of ASan(+LSan)/TSan/MSan.
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
  endif()
  # TSan/MSan default to report-and-continue; force termination on the first finding so the
  # EXPECT_DEATH tests observe a death. (ASan/UBSan already halt.)
  gtest_discover_tests(sanitizer_tests PROPERTIES
    ENVIRONMENT "TSAN_OPTIONS=halt_on_error=1;MSAN_OPTIONS=halt_on_error=1")
  # Windows ASan: the runtime DLL must sit next to the test exe (shared bin/ dir covers all exes).
  if(ENABLE_ASAN)
    deploy_asan_runtime(sanitizer_tests)
  endif()
endif()
