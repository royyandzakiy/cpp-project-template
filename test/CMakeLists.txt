# test/CMakeLists.txt
# =============================================================================
# Test Configuration
# =============================================================================
add_executable(unit_tests test_simple.cpp)

# find_package(GTest CONFIG REQUIRED)
include(FetchContent)
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG v1.17.0)
set(gtest_force_shared_crt
    ON
    CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)
target_link_libraries(unit_tests PRIVATE GTest::gtest GTest::gmock)

include(GoogleTest)
gtest_discover_tests(unit_tests)
