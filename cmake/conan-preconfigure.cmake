# ==============================================================================
# conan-preconfigure.cmake
# ==============================================================================
# Pre-configure script to run Conan before CMake configuration
# This script automatically installs dependencies using Conan
# ==============================================================================

cmake_minimum_required(VERSION 3.20)

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------
message(STATUS "Running Conan pre-configure script...")

# ------------------------------------------------------------------------------
# Conan executable discovery
# ------------------------------------------------------------------------------
find_program(CONAN_CMD conan
    HINTS
        "$ENV{HOME}/.local/bin"
        "/usr/local/bin"
        "/usr/bin"
        "C:/Python*/Scripts"
    DOC "Path to Conan executable"
)

if(NOT CONAN_CMD)
    message(FATAL_ERROR 
        "Conan not found! Please install Conan from: https://conan.io\n"
        "Installation command: pip install conan"
    )
endif()

message(STATUS "Found Conan: ${CONAN_CMD}")

# ------------------------------------------------------------------------------
# Build configuration determination
# ------------------------------------------------------------------------------
if(NOT CMAKE_BUILD_TYPE)
    set(CONAN_BUILD_TYPE "Release")
    message(STATUS "CMAKE_BUILD_TYPE not set, defaulting to 'Release' for Conan")
else()
    set(CONAN_BUILD_TYPE "${CMAKE_BUILD_TYPE}")
endif()

message(STATUS "Build type for Conan: ${CONAN_BUILD_TYPE}")

# ------------------------------------------------------------------------------
# Output directory configuration
# ------------------------------------------------------------------------------
if(NOT CONAN_OUTPUT_DIR)
    set(CONAN_OUTPUT_DIR "${CMAKE_BINARY_DIR}")
endif()

message(STATUS "Conan output directory: ${CONAN_OUTPUT_DIR}")

# Ensure output directory exists
file(MAKE_DIRECTORY "${CONAN_OUTPUT_DIR}")

# ------------------------------------------------------------------------------
# Compiler-specific Conan command construction
# ------------------------------------------------------------------------------
set(CONAN_BASE_COMMAND
    "${CONAN_CMD}" install .
    "--build=missing"
    "-s" "build_type=${CONAN_BUILD_TYPE}"
    "-of" "${CONAN_OUTPUT_DIR}"
)

if(CMAKE_CXX_COMPILER STREQUAL "clang++")
    # --------------------------------------------------------------------------
    # Clang compiler configuration
    # --------------------------------------------------------------------------
    message(STATUS "Detected Clang compiler")
    
    # Extract Clang version
    execute_process(
        COMMAND "${CMAKE_CXX_COMPILER}" --version
        OUTPUT_VARIABLE CLANG_VERSION_OUTPUT
        ERROR_VARIABLE CLANG_VERSION_ERROR
    )
    
    # Parse version - try to extract major version number
    string(REGEX MATCH "clang version ([0-9]+)\\.[0-9]+\\.[0-9]+" 
           CLANG_VERSION_MATCH "${CLANG_VERSION_OUTPUT}")
    
    if(CLANG_VERSION_MATCH)
        set(CONAN_COMPILER_VERSION "${CMAKE_MATCH_1}")
    else()
        # Fallback to a reasonable default
        set(CONAN_COMPILER_VERSION "17")
        message(WARNING 
            "Could not determine Clang version, using default: ${CONAN_COMPILER_VERSION}"
        )
    endif()
    
    set(CONAN_FULL_COMMAND
        ${CONAN_BASE_COMMAND}
        "-s" "compiler=clang"
        "-s" "compiler.version=${CONAN_COMPILER_VERSION}"
    )
    
elseif(MSVC)
    # --------------------------------------------------------------------------
    # MSVC compiler configuration
    # --------------------------------------------------------------------------
    message(STATUS "Detected MSVC compiler")
    
    set(CONAN_FULL_COMMAND
        ${CONAN_BASE_COMMAND}
        "-s" "compiler.runtime=dynamic"
    )
    
    # Add architecture if specified
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        list(APPEND CONAN_FULL_COMMAND "-s" "arch=x86_64")
    else()
        list(APPEND CONAN_FULL_COMMAND "-s" "arch=x86")
    endif()
    
else()
    # --------------------------------------------------------------------------
    # Generic compiler configuration
    # --------------------------------------------------------------------------
    message(WARNING 
        "Unknown compiler: ${CMAKE_CXX_COMPILER_ID}. Using default Conan profile."
    )
    
    set(CONAN_FULL_COMMAND ${CONAN_BASE_COMMAND})
endif()

# ------------------------------------------------------------------------------
# Conan execution
# ------------------------------------------------------------------------------
message(STATUS "Executing Conan command:")
foreach(ARG IN LISTS CONAN_FULL_COMMAND)
    if(ARG STREQUAL "${CONAN_CMD}")
        message(STATUS "  ${ARG}")
    else()
        message(STATUS "    ${ARG}")
    endif()
endforeach()

execute_process(
    COMMAND ${CONAN_FULL_COMMAND}
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    RESULT_VARIABLE CONAN_RESULT
    OUTPUT_VARIABLE CONAN_OUTPUT
    ERROR_VARIABLE CONAN_ERROR
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
)

# ------------------------------------------------------------------------------
# Result verification
# ------------------------------------------------------------------------------
if(NOT CONAN_RESULT EQUAL 0)
    message(FATAL_ERROR 
        "Conan installation failed with exit code: ${CONAN_RESULT}\n"
        "Output:\n${CONAN_OUTPUT}\n"
        "Errors:\n${CONAN_ERROR}"
    )
endif()

message(STATUS "Conan installation completed successfully")

# ------------------------------------------------------------------------------
# Toolchain file detection
# ------------------------------------------------------------------------------
set(CONAN_TOOLCHAIN_FILE 
    "${CONAN_OUTPUT_DIR}/generators/conan_toolchain.cmake"
)

if(EXISTS "${CONAN_TOOLCHAIN_FILE}")
    message(STATUS "Conan toolchain file: ${CONAN_TOOLCHAIN_FILE}")
    
    # Set global variable for parent CMakeLists.txt
    set(CONAN_TOOLCHAIN_FILE "${CONAN_TOOLCHAIN_FILE}" CACHE FILEPATH 
        "Path to Conan-generated toolchain file" FORCE
    )
else()
    # Fallback search for toolchain file
    file(GLOB_RECURSE CONAN_TOOLCHAIN_CANDIDATES 
        "${CONAN_OUTPUT_DIR}/*conan_toolchain.cmake"
    )
    
    if(CONAN_TOOLCHAIN_CANDIDATES)
        list(GET CONAN_TOOLCHAIN_CANDIDATES 0 DETECTED_TOOLCHAIN)
        message(STATUS "Found toolchain file: ${DETECTED_TOOLCHAIN}")
        set(CONAN_TOOLCHAIN_FILE "${DETECTED_TOOLCHAIN}" CACHE FILEPATH 
            "Path to Conan-generated toolchain file" FORCE
        )
    else()
        message(WARNING 
            "Conan toolchain file not found at expected location:\n"
            "  ${CONAN_TOOLCHAIN_FILE}\n"
            "You may need to specify the toolchain file manually."
        )
    endif()
endif()

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
message(STATUS "Conan pre-configure completed successfully")