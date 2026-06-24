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
