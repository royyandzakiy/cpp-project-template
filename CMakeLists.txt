cmake_minimum_required(VERSION 3.28)

include(local_options.cmake OPTIONAL)
include(project_options.cmake)
include(cmake/config_vcpkg.cmake)

#==============================================================================
# Project Configuration
#==============================================================================
project(
  cmake_project_template
  LANGUAGES CXX
  VERSION 1.0.0)

#==============================================================================
# Version Management
#==============================================================================
include(cmake/version.cmake)
generate_version_header()
source_group("Generated" FILES "${CMAKE_CURRENT_SOURCE_DIR}/include/version.h")
message(STATUS "Building ${PROJECT_NAME} version ${PROJECT_VERSION}")

#==============================================================================
# Compiler Configuration
#==============================================================================
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(WIN32)
  set(CMAKE_DEBUG_POSTFIX d)
endif()

if(MSVC)
  add_compile_options(/W4 /permissive- /utf-8)
  if(ENABLE_STRICT_COMPILER)
    add_compile_options(/WX /GS) # warning as errors. Stack guards
    add_compile_options(
      /Zc:preprocessor # Critical for modern C++ macro-heavy libs
      /Zc:__cplusplus # Ensures __cplusplus macro reports correctly
    )
  endif()

else()
  # Clang/GCC
  add_compile_options(-Wall -Wextra)
  if(ENABLE_STRICT_COMPILER)

    add_compile_options(-Werror -pedantic) # more strict
  endif()
endif()

include(cmake/sanitizer_analyzer.cmake)

#==============================================================================
# Dependencies
#==============================================================================
find_package(fmt CONFIG REQUIRED)
find_package(scn CONFIG REQUIRED)
include(FetchContent)
FetchContent_Declare(
  sml
  GIT_REPOSITORY https://github.com/boost-ext/sml.git
  GIT_TAG v1.1.13)
FetchContent_MakeAvailable(sml)

#==============================================================================
# Project Structure
#==============================================================================
add_subdirectory(test)

#==============================================================================
# Main Executable
#==============================================================================
add_executable(${PROJECT_NAME} src/main.cpp src/math.cpp)
# add_executable(${PROJECT_NAME} src/main_fail_sanitizer.cpp)
# target_include_directories(${PROJECT_NAME} PRIVATE path/to/folder)

# Core dependencies (always included)
target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)
# target_compile_definitions(${PROJECT_NAME} PRIVATE ANY_MACRO_HERE)

if(TARGET project_tracy_profile)
  target_link_libraries(${PROJECT_NAME} PRIVATE project_tracy_profile)
endif()
