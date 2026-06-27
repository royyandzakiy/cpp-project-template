cmake_minimum_required(VERSION 3.28)

#=========================
# Project Options & Package Manager
#=========================
include(project_options.local.cmake OPTIONAL) # create & modify to change locally (only for you)
include(project_options.cmake) # modify to change for all developers

# If this project is consumed via add_subdirectory(), the parent owns the provider/toolchain, hence
# omit this setup_package_maanager(). But because before project(), PROJECT_IS_TOP_LEVEL isn't set yet
# hence use the source-dir check
include(cmake/package_manager.cmake)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  setup_package_manager() # dispatches to vcpkg / conan / none per PKG_MANAGER
endif()

#=========================
# Project Configuration
#=========================
include(cmake/version.cmake) # reads version.txt -> PROJECT_VERSION_STRING (before project())
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
include(cmake/target_options.cmake) # defines configure_target()
if(PROJECT_IS_TOP_LEVEL)
  include(cmake/format.cmake) # format / format-check / tidy-all targets
  include(cmake/clangd.cmake) # mirror compile_commands.json for clangd
endif()

#=========================
# Version Header
#=========================
if(GENERATE_VERSION_HEADER)
  generate_version_header()
endif()

#=========================
# Dependencies
#=========================
# Lets a lib-only (or add_subdirectory) build configure with no third-party deps.
if(BUILD_APP OR BUILD_EXAMPLES)
  find_package(fmt CONFIG REQUIRED)
  find_package(scn CONFIG REQUIRED)
  include(FetchContent)
  FetchContent_Declare(
    sml
    GIT_REPOSITORY https://github.com/boost-ext/sml.git
    GIT_TAG v1.1.13)
  FetchContent_MakeAvailable(sml)
endif()

#=========================
# Targets
#=========================
# Add or remove targets as needed
if(BUILD_APP)
  add_subdirectory(src/myapp) # standalone hello-world binary
endif()
if(BUILD_LIB)
  add_subdirectory(src/mylib) # library + installable MyLib package (handles its own staging)
endif()
if(BUILD_EXAMPLES)
  add_subdirectory(examples) # AFTER src/mylib so the example can link the MyLib target
endif()

#=========================
# Tests & Coverage
#=========================
if(BUILD_TESTING)
  enable_testing() # ctest / gtest_discover_tests register the unit tests
  add_subdirectory(test)
  if(ENABLE_COVERAGE AND TARGET unit_tests)
    setup_coverage_target(unit_tests) # adds the `coverage` target (runs tests + reports)
  endif()
endif()
