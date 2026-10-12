# =============================================================================
# MyLib — the project's core library (src/core)
# =============================================================================
# All logic lives here so it can be unit-tested; the app (src/app) and examples are thin
# consumers. Always built. STATIC by default; BUILD_LIB_SHARED=ON makes it a DLL / .so.
# Installing it as a find_package() package is optional (INSTALL_LIB, cmake/install.cmake).
# =============================================================================

# ---- Library Type -----------------------------------------------------------
if(BUILD_LIB_SHARED)
    set(_mylib_type SHARED)
else()
    set(_mylib_type STATIC)
endif()

# ---- Library Definition -----------------------------------------------------
add_library(MyLib ${_mylib_type})
add_library(MyLib::MyLib ALIAS MyLib)  # In-tree consumers use same name as installed

message(STATUS "MyLib: building ${_mylib_type} library")

# ---- Sources + Headers ------------------------------------------------------
# Hand-written public headers
set(_mylib_public_headers
    "${PROJECT_SOURCE_DIR}/include/MyLib/math.hpp"
    "${PROJECT_SOURCE_DIR}/include/MyLib/classify.hpp"
    "${PROJECT_SOURCE_DIR}/include/MyLib/greeter.hpp"
)

target_sources(MyLib
    PUBLIC
        FILE_SET HEADERS
        TYPE HEADERS
        BASE_DIRS "${PROJECT_SOURCE_DIR}/include"
        FILES ${_mylib_public_headers}
    PRIVATE
        math.cpp
        classify.cpp
        greeter.cpp
)

# ---- Generated Headers ------------------------------------------------------
# Generated into the BUILD tree (not source): mylib_export.h is platform/compiler specific, and
# each build dir gets its own copy. Both install next to the hand-written headers.
include(GenerateExportHeader)
generate_export_header(
    MyLib
    BASE_NAME MYLIB
    EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/exports/MyLib/mylib_export.h"
)
set(_mylib_generated_headers "${CMAKE_CURRENT_BINARY_DIR}/exports/MyLib/mylib_export.h")

if(GENERATE_VERSION_HEADER)
    generate_version_header("${CMAKE_CURRENT_BINARY_DIR}/exports/MyLib/version.h")
    list(APPEND _mylib_generated_headers "${CMAKE_CURRENT_BINARY_DIR}/exports/MyLib/version.h")
endif()

target_sources(MyLib
    PUBLIC
        FILE_SET generated_headers
        TYPE HEADERS
        BASE_DIRS "${CMAKE_CURRENT_BINARY_DIR}/exports"
        FILES ${_mylib_generated_headers}
)

# ---- Include Paths ----------------------------------------------------------
target_include_directories(MyLib
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/exports>
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

# ---- Compile Definitions ----------------------------------------------------
# STATIC: neutralize export macro for lib AND consumers
if(NOT BUILD_LIB_SHARED)
    target_compile_definitions(MyLib
        PUBLIC
            MYLIB_STATIC_DEFINE
    )
endif()

# ---- Properties -------------------------------------------------------------
set_target_properties(MyLib PROPERTIES
    CXX_VISIBILITY_PRESET hidden      # Only MYLIB_EXPORT symbols exported
    VISIBILITY_INLINES_HIDDEN ON
    DEBUG_POSTFIX d                   # MyLibd.{dll,lib,a} in Debug
    CXX_EXTENSIONS OFF
)

# ---- Compile Features -------------------------------------------------------
target_compile_features(MyLib
    PUBLIC
        cxx_std_23
)

# ---- Dependencies -----------------------------------------------------------
# PRIVATE deps of a STATIC lib still reach consumers' link line — declare them in
# cmake/MyLibConfig.cmake.in too (find_dependency) so installed consumers resolve them.
target_link_libraries(MyLib
    PRIVATE
        fmt::fmt
)

# ---- Cross-Cutting Configuration --------------------------------------------
# PCH, unity build, profiler links, clang-tidy
configure_target(MyLib)

target_enable_sanitizers(MyLib) # no-op unless ENABLE_SANITIZERS

# ---- Installation (optional) ------------------------------------------------
# find_package()-able package + staging into generated_lib/. App-only projects can delete
# cmake/install.cmake and these lines.
if(INSTALL_LIB)
    include(${PROJECT_SOURCE_DIR}/cmake/install.cmake)
endif()

message(STATUS "MyLib configured (${_mylib_type} library)")
