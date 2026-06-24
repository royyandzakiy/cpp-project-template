cmake_minimum_required(VERSION 3.28)

include(local_options.cmake OPTIONAL)
include(project_options.cmake)
include(cmake/package_manager.cmake)
setup_package_manager()            # dispatches to vcpkg / conan / none per PKG_MANAGER

#=========================
# Project Configuration
#=========================
project(
  cpp_project_template
  LANGUAGES CXX
  VERSION 1.0.0)

#=========================
# Version Management
#=========================
include(cmake/version.cmake)
generate_version_header()
source_group("Generated" FILES "${CMAKE_CURRENT_SOURCE_DIR}/include/version.h")
message(STATUS "Building ${PROJECT_NAME} version ${PROJECT_VERSION}")

#=========================
# Compiler Configuration
#=========================
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(WIN32)
  set(CMAKE_DEBUG_POSTFIX d)
endif()

if(MSVC)
  add_compile_options(/W4 /permissive- /utf-8)
  if(ENABLE_STRICT_COMPILER)
    add_compile_options(/WX /GS) # warnings as errors, stack guards
    # /Zc: conformance flags are cl.exe-specific. clang-cl already conforms and reports them as
    # "unused argument", which /WX turns into an error — so only pass them to real MSVC.
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
      add_compile_options(
        /Zc:preprocessor # Critical for modern C++ macro-heavy libs
        /Zc:__cplusplus # Ensures __cplusplus macro reports correctly
      )
    endif()
  endif()

else()
  # Clang/GCC
  add_compile_options(-Wall -Wextra)
  if(ENABLE_STRICT_COMPILER)
    add_compile_options(-Werror -pedantic) # more strict
  endif()
endif()

include(cmake/sanitizer_analyzer.cmake)
include(cmake/profiler.cmake)
include(cmake/format.cmake)

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
# Subdirectories
#=========================
if(BUILD_TESTING)
  enable_testing() # ctest / gtest_discover_tests register the unit tests
  add_subdirectory(test)
endif()
add_subdirectory(examples)

#=========================
# Main Executable
#=========================
add_executable(${PROJECT_NAME} src/main.cpp src/math.cpp)

# --- Include directories ---
# Public headers (incl. the generated include/${PROJECT_NAME}/version.h) live here.
target_include_directories(${PROJECT_NAME} PRIVATE include src)
# target_include_directories(${PROJECT_NAME} PRIVATE path/to/folder)

# --- Build-time optimizations (per target) ---
# Precompiled headers: tune this list to the heavy headers you use everywhere.
if(ENABLE_PCH)
  target_precompile_headers(
    ${PROJECT_NAME}
    PRIVATE
    <filesystem>
    <print>
    <string>
    <string_view>
    <vector>
    <memory>
    <utility>)
  message(STATUS "PCH enabled for ${PROJECT_NAME}")
endif()
# Unity build: only meaningful once the target has several .cpp files.
if(ENABLE_UNITY_BUILD)
  set_target_properties(${PROJECT_NAME} PROPERTIES UNITY_BUILD ON)
  message(STATUS "Unity build enabled for ${PROJECT_NAME}")
endif()

# --- Compile definitions ---
# target_compile_definitions(${PROJECT_NAME} PRIVATE ANY_MACRO_HERE)

# --- Core Dependencies ---
target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)

# --- Optional Dependencies ---
if(TARGET project_tracy_profile)
  target_link_libraries(${PROJECT_NAME} PRIVATE project_tracy_profile)
endif()
if(TARGET project_perfetto_profile)
  target_link_libraries(${PROJECT_NAME} PRIVATE project_perfetto_profile)
endif()

# --- ASan runtime DLL (Windows) --- must come after the target exists
if(ENABLE_ASAN)
  deploy_asan_runtime(${PROJECT_NAME})
endif()

#=========================
# clangd Integration
#=========================
# Presets build into build/<preset>/, a layout clangd cannot auto-discover
# (it only searches the file's dir, ./build, and ancestors). Mirror the active
# preset's compile_commands.json to the project root so the checked-in .clangd
# (CompilationDatabase: .) always reflects the build you last configured.
# The Visual Studio and Xcode generators don't emit compile_commands.json (only Ninja/Makefiles
# do), so only mirror it for generators that actually produce it.
if(CMAKE_EXPORT_COMPILE_COMMANDS AND NOT CMAKE_GENERATOR MATCHES "Visual Studio|Xcode")
  add_custom_target(
    mirror_compile_commands ALL
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_BINARY_DIR}/compile_commands.json"
            "${CMAKE_SOURCE_DIR}/compile_commands.json"
    BYPRODUCTS "${CMAKE_SOURCE_DIR}/compile_commands.json"
    COMMENT "Mirroring compile_commands.json to project root for clangd"
    VERBATIM)
endif()
