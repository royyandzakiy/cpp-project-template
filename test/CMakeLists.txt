# =============================================================================
# Test Configuration
# =============================================================================
add_executable(unit_tests
    test_simple.cpp
)

target_link_libraries(unit_tests
    PRIVATE 
        GTest::gtest 
        GTest::gtest
)

include(GoogleTest)
gtest_discover_tests(unit_tests)