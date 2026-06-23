# cmake/config_conan.cmake
# Optional Conan 2 dependency provider integration.
# Activated when USE_CONAN=ON is set (via preset or -D flag).
# Conan packages are resolved through the cmake-conan dependency provider,
# so find_package() calls in CMakeLists.txt work unchanged.

option(USE_CONAN "Use Conan as the package manager instead of vcpkg" OFF)

if(USE_CONAN)
    message(STATUS "[config_conan] Conan dependency provider enabled")

    # Verify conan_provider.cmake is present (added via git submodule)
    set(CONAN_PROVIDER "${CMAKE_SOURCE_DIR}/cmake-conan/conan_provider.cmake")
    if(NOT EXISTS "${CONAN_PROVIDER}")
        message(FATAL_ERROR
            "[config_conan] cmake-conan submodule not found at ${CONAN_PROVIDER}.\n"
            "Run: git submodule update --init --recursive"
        )
    endif()

    # Disable vcpkg when Conan is active to avoid toolchain conflicts
    set(SETUP_VCPKG OFF CACHE BOOL "Disabled because USE_CONAN=ON" FORCE)

    message(STATUS "[config_conan] Using conan_provider.cmake: ${CONAN_PROVIDER}")
    message(STATUS "[config_conan] Pass -DCMAKE_PROJECT_TOP_LEVEL_INCLUDES=${CONAN_PROVIDER} at configure time")
endif()
