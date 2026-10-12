# cmake/install.cmake
# Installs MyLib as a find_package(MyLib)-able CMake package and, when top-level, stages it into
# generated_lib/<platform>/<config>/ after every build. Included from src/core/CMakeLists.txt when
# INSTALL_LIB is ON (it must be included from there: the POST_BUILD step needs MyLib's directory).
#
# Only needed when MyLib is shipped to other projects. App-only projects can delete this file,
# cmake/MyLibConfig.cmake.in and the include() in src/core/CMakeLists.txt.

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
