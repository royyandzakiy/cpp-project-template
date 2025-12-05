# cmake/conan-preconfigure.cmake
# Pre-configure script to run Conan before CMake configuration

message(STATUS "Running Conan pre-configure script...")

# Find Conan executable
find_program(CONAN_CMD conan)
if(NOT CONAN_CMD)
    message(FATAL_ERROR "Conan not found! Please install Conan: https://conan.io")
endif()

# Determine build type for Conan
if(NOT CMAKE_BUILD_TYPE)
    set(CONAN_BUILD_TYPE "Release")
    message(STATUS "CMAKE_BUILD_TYPE not set, defaulting to 'Release' for Conan")
else()
    set(CONAN_BUILD_TYPE ${CMAKE_BUILD_TYPE})
endif()
message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")

# Determine output directory (use CMake's binary directory)
if(NOT CONAN_OUTPUT_DIR)
    set(CONAN_OUTPUT_DIR ${CMAKE_BINARY_DIR})
    message(STATUS "Conan output directory: ${CONAN_OUTPUT_DIR}")
endif()

# Determine compiler settings based on CMake's detected compiler
if(CMAKE_CXX_COMPILER STREQUAL "clang++")
    
    message(STATUS "Detected Clang compiler")
    message(STATUS "Running: conan install . --build=missing -s compiler=clang -s compiler.version=20 -s -s compiler.runtime_type=${CONAN_BUILD_TYPE} -of ${CONAN_OUTPUT_DIR}")
    
    execute_process(
        COMMAND ${CONAN_CMD} install . --build=missing
                -s compiler=clang
                -s compiler.version=20
                -s build_type=${CONAN_BUILD_TYPE}
                -of ${CONAN_OUTPUT_DIR}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE CONAN_RESULT
        OUTPUT_VARIABLE CONAN_OUTPUT
        ERROR_VARIABLE CONAN_ERROR
        COMMAND_ECHO STDOUT
    )
    
elseif(MSVC)
    message(STATUS "Detected MSVC compiler")
    message(STATUS "Running: conan install . --build=missing -s compiler.runtime=dynamic -s build_type=${CONAN_BUILD_TYPE} -of ${CONAN_OUTPUT_DIR}")
    
    execute_process(
        COMMAND ${CONAN_CMD} install . --build=missing
                -s compiler.runtime=dynamic
                -s build_type=${CONAN_BUILD_TYPE}
                -of ${CONAN_OUTPUT_DIR}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE CONAN_RESULT
        OUTPUT_VARIABLE CONAN_OUTPUT
        ERROR_VARIABLE CONAN_ERROR
        COMMAND_ECHO STDOUT
    )
    
else()
    message(WARNING "Unknown compiler: ${CMAKE_CXX_COMPILER_ID}. Using default Conan profile.")
    
    execute_process(
        COMMAND ${CONAN_CMD} install . --build=missing
                -s build_type=${CONAN_BUILD_TYPE}
                -of ${CONAN_OUTPUT_DIR}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE CONAN_RESULT
        OUTPUT_VARIABLE CONAN_OUTPUT
        ERROR_VARIABLE CONAN_ERROR
        COMMAND_ECHO STDOUT
    )
endif()

# Check Conan result
if(NOT CONAN_RESULT EQUAL 0)
    message(FATAL_ERROR "Conan install failed with error: ${CONAN_RESULT}\nOutput: ${CONAN_OUTPUT}\nError: ${CONAN_ERROR}")
else()
    message(STATUS "Conan install completed successfully")
endif()

message(STATUS "Conan toolchain file: ${CONAN_TOOLCHAIN_FILE}")