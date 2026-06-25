cmake_minimum_required(VERSION 3.28)

include(local_options.cmake OPTIONAL)
include(project_options.cmake)
include(cmake/package_manager.cmake)
setup_package_manager() # dispatches to vcpkg / conan / none per PKG_MANAGER

include(cmake/version.cmake) # reads version.txt -> PROJECT_VERSION_STRING (before project())

#=========================
# Project Configuration
#=========================
project(
  cpp_project_template
  LANGUAGES CXX
  VERSION ${PROJECT_VERSION_STRING})

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#=========================
# Modules
#=========================
include(cmake/compiler.cmake) # warnings, strict, build-type guard, debug postfix
include(cmake/sanitizer_analyzer.cmake) # sanitizers, clang-tidy, ccache, fast-linker, deploy_asan_runtime()
include(cmake/coverage.cmake) # coverage instrumentation + setup_coverage_target() (when ENABLE_COVERAGE)
include(cmake/profiler.cmake) # Tracy / Perfetto / ClangBuildAnalyzer (when enabled)
include(cmake/format.cmake) # format / format-check / tidy-all targets
include(cmake/clangd.cmake) # mirror compile_commands.json for clangd
include(cmake/target_options.cmake) # defines configure_target()

#=========================
# Version Header
#=========================
if(GENERATE_VERSION_HEADER)
  generate_version_header()
endif()

#=========================
# Dependencies
#=========================
find_package(fmt CONFIG REQUIRED)
# find_package(scn CONFIG REQUIRED)
include(FetchContent)
FetchContent_Declare(
  sml
  GIT_REPOSITORY https://github.com/boost-ext/sml.git
  GIT_TAG v1.1.13)
FetchContent_MakeAvailable(sml)

#=========================
# Targets
#=========================
# Default the install tree to <repo>/generated_lib/ — MyLib auto-stages there after each build.
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/generated_lib" CACHE PATH "Install prefix" FORCE)
endif()

if(BUILD_LIB)
  add_subdirectory(src/mylib) # shared library + installable MyLib package
endif()
if(BUILD_APP)
  add_subdirectory(src/myapp) # standalone hello-world binary
endif()

#=========================
# Tests & Examples
#=========================
if(BUILD_TESTING)
  enable_testing() # ctest / gtest_discover_tests register the unit tests
  add_subdirectory(test)
  if(ENABLE_COVERAGE AND TARGET unit_tests)
    setup_coverage_target(unit_tests) # adds the `coverage` target (runs tests + reports)
  endif()
endif()
if(BUILD_EXAMPLES)
  add_subdirectory(examples) # AFTER src/mylib so the example can link the MyLib target
endif()
