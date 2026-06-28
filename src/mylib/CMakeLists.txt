# =============================================================================
# MyLib — A Modern CMake Library
# =============================================================================
# Produces a properly-exported, installable CMake package with automatic
# artifact staging. Supports SHARED/STATIC, cross-platform symbol visibility,
# and seamless find_package() consumption.
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
)

if(GENERATE_VERSION_HEADER)
    list(APPEND _mylib_public_headers "${PROJECT_SOURCE_DIR}/include/MyLib/version.h")
endif()

target_sources(MyLib
    PUBLIC
        FILE_SET HEADERS
        TYPE HEADERS
        BASE_DIRS "${PROJECT_SOURCE_DIR}/include"
        FILES ${_mylib_public_headers}
    PRIVATE
        math.cpp
        classify.cpp
)

# ---- Generate Export Header ------------------------------------------------
# Generated into BUILD tree (not source) - platform/compiler specific
# Each build dir gets its own correct copy
include(GenerateExportHeader)
generate_export_header(
    MyLib
    BASE_NAME MYLIB
    EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/exports/MyLib/mylib_export.h"
)

target_sources(MyLib
    PUBLIC
        FILE_SET generated_headers
        TYPE HEADERS
        BASE_DIRS "${CMAKE_CURRENT_BINARY_DIR}/exports"
        FILES "${CMAKE_CURRENT_BINARY_DIR}/exports/MyLib/mylib_export.h"
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

# ---- Cross-Cutting Configuration --------------------------------------------
# PCH, unity build, profiler links, clang-tidy, ASan deployment
configure_target(MyLib)

# ---- Dependencies -----------------------------------------------------------
# Add any library dependencies here
# target_link_libraries(MyLib
#     PUBLIC
#         dep::dep
#     PRIVATE
#         internal::dep
# )

# ---- Installation -----------------------------------------------------------
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

install(
    TARGETS MyLib
    EXPORT MyLibTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT MyLib
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT MyLib
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT MyLib
    FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT MyLib
    FILE_SET generated_headers DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT MyLib
)

install(
    EXPORT MyLibTargets
    FILE MyLibTargets.cmake
    NAMESPACE MyLib::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyLib
    COMPONENT MyLib
)

# ---- Package Config ---------------------------------------------------------
configure_package_config_file(
    "${PROJECT_SOURCE_DIR}/cmake/MyLibConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyLib
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyLib
    COMPONENT MyLib
)

# ---- Artifact Staging -------------------------------------------------------
# Per-platform AND per-config: Debug/Release binaries aren't interchangeable
# Different toolchains/OSes must not overwrite each other
if(PROJECT_IS_TOP_LEVEL)
    set(_mylib_platform "${CMAKE_SYSTEM_NAME}-${CMAKE_CXX_COMPILER_ID}")
    add_custom_command(
        TARGET MyLib
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} --install "${CMAKE_BINARY_DIR}"
                --config $<CONFIG>
                --component MyLib
                --prefix "${PROJECT_SOURCE_DIR}/generated_lib/${_mylib_platform}/$<CONFIG>"
        COMMENT "Staging MyLib into generated_lib/${_mylib_platform}/$<CONFIG>"
        VERBATIM
    )
endif()

message(STATUS "MyLib configured (${_mylib_type} library)")
