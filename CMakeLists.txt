cmake_minimum_required(VERSION 3.5..4.2)

include(cmake/local_path.cmake)
include(cmake/config_vcpkg.cmake)

#==============================================================================
# Project Configuration
#==============================================================================
project(cmake_project_template 
    LANGUAGES CXX
    VERSION 1.0.0
)

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
    add_compile_options(-Wall -Wextra -Werror -pedantic)
endif()

if(CLANGTIDY)
    set(CMAKE_CXX_CLANG_TIDY ${CLANGTIDY})
    message(STATUS "Clang-Tidy enabled: ${CLANGTIDY}")
endif()

option(ENABLE_SANITIZERS "Enable Address, Undefined, and Leak sanitizers" OFF)

if(ENABLE_SANITIZERS AND NOT MSVC)
    message(STATUS "Building with Address, Undefined, and Leak Sanitizers")
    
    set(SANITIZER_FLAGS 
        -fsanitize=address,undefined,leak 
        -fno-omit-frame-pointer
    )
    
    # Add to compiler flags
    add_compile_options(${SANITIZER_FLAGS})
    
    # Add to linker flags (CRITICAL: sanitizers need library linking)
    add_link_options(${SANITIZER_FLAGS})
endif()

#==============================================================================
# Dependencies
#==============================================================================
find_package(fmt CONFIG REQUIRED)
find_package(GTest CONFIG REQUIRED)

#==============================================================================
# Project Structure
#==============================================================================
add_subdirectory(test)

#==============================================================================
# Main Executable
#==============================================================================
add_executable(${PROJECT_NAME} 
    src/main.cpp
)

# Core dependencies (always included)
target_link_libraries(${PROJECT_NAME} 
    PRIVATE 
		fmt::fmt
)