# cmake/packaging.cmake
# CPack: archives what `cmake --install` produces. Include AFTER the targets and their install()
# rules. Packages the MyApp component (exe + the shared libs it needs, src/app/CMakeLists.txt)
# when BUILD_APP is on, and the MyLib development package (cmake/install.cmake) when INSTALL_LIB
# is on — so app projects and library projects both get a sensible archive.
#
#   cmake --build --preset clang-linux-release
#   cpack --config build/clang-linux-release/CPackConfig.cmake
#     -> build/clang-linux-release/package/<name>-<version>-<system>.tar.gz (.zip on Windows)

if(BUILD_APP)
  # MSVC runtime DLLs (vcruntime/msvcp) next to the exe, so the zip runs without the VC++
  # redistributable. No-op on other platforms; skipped for Debug (not redistributable).
  set(CMAKE_INSTALL_SYSTEM_RUNTIME_COMPONENT MyApp)
  include(InstallRequiredSystemLibraries)
endif()

set(_package_components "")
if(BUILD_APP)
  list(APPEND _package_components MyApp)
endif()
if(INSTALL_LIB)
  list(APPEND _package_components MyLib)
endif()

set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_VENDOR "${PROJECT_NAME}") # change to your name / org
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_NAME}")
if(WIN32)
  set(CPACK_GENERATOR "ZIP")
else()
  set(CPACK_GENERATOR "TGZ")
endif()
set(CPACK_PACKAGE_DIRECTORY "${CMAKE_BINARY_DIR}/package")
set(CPACK_STRIP_FILES ON)
# One archive holding just these components (not GTest or other dependencies' install rules).
set(CPACK_COMPONENTS_ALL ${_package_components})
set(CPACK_ARCHIVE_COMPONENT_INSTALL OFF)

include(CPack)
