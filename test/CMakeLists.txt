# test/CMakeLists.txt
# =============================================================================
# Test Configuration
# =============================================================================
find_package(GTest CONFIG REQUIRED)
# or, Fetch Google Test include(FetchContent) FetchContent_Declare( googletest
# URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip )
# FetchContent_MakeAvailable(googletest)

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
target_link_libraries(unit_tests PRIVATE GTest::gtest GTest::gtest)

include(GoogleTest)
gtest_discover_tests(unit_tests)
