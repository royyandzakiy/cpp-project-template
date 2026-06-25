# src/mylib/CMakeLists.txt
# MyLib — a SHARED library (DLL on Windows). Produces a properly-exported, installable CMake
# package and auto-stages it into <repo>/generated_lib/ after every build.
# =============================================================================

# ----- The shared library -----
add_library(MyLib SHARED math.cpp classify.cpp)
add_library(MyLib::MyLib ALIAS MyLib) # so in-tree consumers can use the same name as installed ones

set_target_properties(
  MyLib PROPERTIES
  CXX_VISIBILITY_PRESET hidden # only MYLIB_EXPORT-annotated symbols are exported (matches Windows)
  VISIBILITY_INLINES_HIDDEN ON
  DEBUG_POSTFIX d) # MyLibd.dll in Debug, so debug/release artifacts can coexist

# ----- Export macro header (cross-platform: __declspec on Windows, visibility on GCC/Clang) -----
# Generated into the BUILD tree (not the source tree): the content is compiler/platform specific,
# so a shared source-tree copy would be stale when the same checkout is built on two toolchains
# (e.g. Windows + WSL on the same path). Each build dir gets its own correct copy.
include(GenerateExportHeader)
generate_export_header(
  MyLib
  BASE_NAME MYLIB
  EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/exports/MyLib/mylib_export.h")

# ----- Public headers / include interface -----
target_include_directories(
  MyLib
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/exports> # generated mylib_export.h
         $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>         # hand-written public headers
         $<INSTALL_INTERFACE:include>)

# Two header file sets so install() lays both source and generated headers under include/MyLib/.
set(_mylib_public_headers
    "${CMAKE_SOURCE_DIR}/include/MyLib/math.hpp"
    "${CMAKE_SOURCE_DIR}/include/MyLib/classify.hpp")
if(GENERATE_VERSION_HEADER) # version.h is platform-independent, lives in the source tree
  list(APPEND _mylib_public_headers "${CMAKE_SOURCE_DIR}/include/MyLib/version.h")
endif()
target_sources(
  MyLib
  PUBLIC FILE_SET HEADERS BASE_DIRS "${CMAKE_SOURCE_DIR}/include" FILES ${_mylib_public_headers}
         FILE_SET generated_headers TYPE HEADERS BASE_DIRS "${CMAKE_CURRENT_BINARY_DIR}/exports"
         FILES "${CMAKE_CURRENT_BINARY_DIR}/exports/MyLib/mylib_export.h")

# Shared tidy/PCH/profiler/ASan machinery (same helper the app uses).
configure_target(MyLib)

# =============================================================================
# Install + CMake package — lets external projects `find_package(MyLib)`.
# Everything is tagged COMPONENT MyLib so the staging step can install ONLY MyLib — without it,
# `cmake --install` would also drag in install rules from FetchContent deps (gtest/sml).
# =============================================================================
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

install(
  TARGETS MyLib
  EXPORT MyLibTargets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT MyLib
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT MyLib
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT MyLib
  FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT MyLib
  FILE_SET generated_headers DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT MyLib)

install(
  EXPORT MyLibTargets
  FILE MyLibTargets.cmake
  NAMESPACE MyLib::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyLib
  COMPONENT MyLib)

configure_package_config_file(
  "${CMAKE_SOURCE_DIR}/cmake/MyLibConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake"
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyLib)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake"
              "${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyLib
        COMPONENT MyLib)

# ----- Seamless artifact staging: auto-install into <repo>/generated_lib/ after each build -----
add_custom_command(
  TARGET MyLib
  POST_BUILD
  COMMAND ${CMAKE_COMMAND} --install "${CMAKE_BINARY_DIR}" --config $<CONFIG> --component MyLib
          --prefix "${CMAKE_SOURCE_DIR}/generated_lib"
  COMMENT "Staging MyLib into generated_lib/ (bin, lib, include, lib/cmake/MyLib)"
  VERBATIM)
