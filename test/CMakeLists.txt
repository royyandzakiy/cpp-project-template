# test/CMakeLists.txt
# =============================================================================
# Test Configuration
# =============================================================================
find_package(GTest CONFIG REQUIRED)
# or, Fetch Google Test include(FetchContent) FetchContent_Declare( googletest
# URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip )
# FetchContent_MakeAvailable(googletest)

add_executable(unit_tests test_simple.cpp test_math.cpp ../src/math.cpp)

target_link_libraries(unit_tests PRIVATE GTest::gtest GTest::gmock)

include(GoogleTest)
gtest_discover_tests(unit_tests)
