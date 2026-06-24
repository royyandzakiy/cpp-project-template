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
# Tests & Examples
#=========================
if(BUILD_TESTING)
  enable_testing() # ctest / gtest_discover_tests register the unit tests
  add_subdirectory(test)
endif()
if(BUILD_EXAMPLES)
  add_subdirectory(examples)
endif()

#=========================
# Main Executable
#=========================
add_executable(${PROJECT_NAME} src/main.cpp src/math.cpp)
target_include_directories(${PROJECT_NAME} PRIVATE include src)

# --- Dependencies ---
target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)

# PCH, unity build, optional profiler links, Windows ASan DLL — see cmake/target_options.cmake
configure_target(${PROJECT_NAME})
