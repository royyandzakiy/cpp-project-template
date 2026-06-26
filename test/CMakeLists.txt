# test/CMakeLists.txt
# =============================================================================
# GTest Setup (shared by unit_tests and the sanitizer trip-wires)
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
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE) # don't let gtest's install rules pollute generated_lib/
FetchContent_MakeAvailable(googletest)

# surpress warnings from gtest libraries
foreach(t gtest gtest_main gmock gmock_main)
  if(TARGET ${t})
    target_compile_options(${t} PRIVATE -w)
  endif()
endforeach()

include(GoogleTest)
# Discover tests at ctest time, not build time: under Windows ASan the test exe needs a runtime
# DLL that's only deployed during the build, so a build-time test run can fail to start.
set(CMAKE_GTEST_DISCOVER_TESTS_DISCOVERY_MODE PRE_TEST)

# =============================================================================
# Unit tests — exercise MyLib's code (math + classify). Built only with BUILD_LIB, since that is
# what they test. The lib sources are compiled directly into the test binary (not linked against
# the DLL) so coverage is measured on them; MYLIB_STATIC_DEFINE makes MYLIB_EXPORT a no-op for
# this in-binary build (no dllimport).
# =============================================================================
if(BUILD_LIB)
  add_executable(
    unit_tests
    test_simple.cpp
    test_math.cpp
    test_classify.cpp
    ${CMAKE_SOURCE_DIR}/src/mylib/math.cpp
    ${CMAKE_SOURCE_DIR}/src/mylib/classify.cpp)
  # Pull MyLib's public + generated (build-tree mylib_export.h) include dirs without linking the DLL.
  target_include_directories(
    unit_tests PRIVATE ${CMAKE_SOURCE_DIR}/include
                       $<TARGET_PROPERTY:MyLib,INTERFACE_INCLUDE_DIRECTORIES>)
  target_compile_definitions(unit_tests PRIVATE MYLIB_STATIC_DEFINE)
  target_link_libraries(unit_tests PRIVATE GTest::gtest GTest::gmock)
  gtest_discover_tests(unit_tests)
endif()

# =============================================================================
# App module tests — exercise src/myapp/greeter with a MOCKED clock (gmock). Built only with
# BUILD_APP, since that is what they test. gmock_main provides main() + InitGoogleMock.
# =============================================================================
if(BUILD_APP)
  add_executable(app_tests test_app.cpp ${CMAKE_SOURCE_DIR}/src/myapp/greeter.cpp)
  target_include_directories(app_tests PRIVATE ${CMAKE_SOURCE_DIR}/src)
  target_link_libraries(app_tests PRIVATE GTest::gmock_main fmt::fmt)
  gtest_discover_tests(app_tests)
endif()

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
