cmake_minimum_required(VERSION 3.5)

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

if(MSVC)
  add_compile_options(/W4 /permissive- /WX)
else()
  # Clang/GCC
  add_compile_options(
    -Wall
    -Wextra
    -Werror
    -pedantic)
endif()

# Compiler sanitizers
option(ENABLE_SANITIZERS "Enable comprehensive runtime sanitizers" OFF)

if(ENABLE_SANITIZERS AND NOT MSVC)
  message(STATUS "Configuring Hardened Sanitizer Profile")

  # 1. Address & Undefined (The standard combo)
  # 2. Add 'bounds' and 'integer' for extra UBSan checks
  set(SANITIZER_FLAGS
      -fsanitize=address
      -fsanitize=undefined
      -fsanitize=leak
      -fsanitize=bounds
      -fsanitize=integer
      -fno-omit-frame-pointer
      -fno-optimize-sibling-calls)

  # Note: ThreadSanitizer (-fsanitize=thread) and MemorySanitizer (-fsanitize=memory)
  # usually cannot be combined with AddressSanitizer.

  # Extra UBSan hardening
  add_compile_options(-fstack-protector-strong)

  # Add to compiler and linker
  add_compile_options(${SANITIZER_FLAGS})
  add_link_options(${SANITIZER_FLAGS})

  # Optimization: Symbols are required for readable stack traces
  if(NOT
     CMAKE_BUILD_TYPE
     STREQUAL
     "Debug")
    message(WARNING "Sanitizers are most effective in Debug builds (-g).")
  endif()
endif()

# Static Analysis: Clang-tidy
# find_program(CLANG_TIDY_EXE NAMES "clang-tidy")
if(CLANG_TIDY_EXE)
  set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
  message(STATUS "Clang-Tidy found: ${CLANG_TIDY_EXE}")
else()
  message(WARNING "Clang-Tidy not found. Static analysis is disabled.")
endif()

# Static Analysis: Cppcheck
# find_program(CPPCHECK_EXE NAMES "cppcheck")
if(CPPCHECK_EXE)
  set(CMAKE_CXX_CPPCHECK
      "${CPPCHECK_EXE}"
      "--enable=warning,performance,portability,style"
      "--inline-suppr" # Allows you to suppress warnings in code comments
      "--suppress=missingIncludeSystem"
      "--inconclusive")
  message(STATUS "Cppcheck found: ${CPPCHECK_EXE}")
else()
  message(WARNING "Cppcheck not found. Static analysis is disabled.")
endif()

#==============================================================================
# Dependencies
#==============================================================================
find_package(fmt CONFIG REQUIRED)

#==============================================================================
# Project Structure
#==============================================================================
add_subdirectory(test)

#==============================================================================
# Main Executable
#==============================================================================
add_executable(${PROJECT_NAME} src/main.cpp src/math.cpp)

# Core dependencies (always included)
target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)
