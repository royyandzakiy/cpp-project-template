# cmake/config_conan.cmake
# Conan 2 integration via the cmake-conan dependency provider. Included by
# setup_package_manager() when PKG_MANAGER=conan, so find_package() in CMakeLists
# resolves through Conan with no other changes. (vcpkg isn't included in this mode,
# so the two never run together.)

set(CONAN_PROVIDER "${CMAKE_SOURCE_DIR}/cmake/cmake-conan/conan_provider.cmake")
if(NOT EXISTS "${CONAN_PROVIDER}")
  message(FATAL_ERROR
    "[conan] cmake-conan submodule not found at ${CONAN_PROVIDER}.\n"
    "Run: git submodule update --init --recursive")
endif()

# Register the provider (consumed at the next project() call). Honor an explicit
# -D / preset override if one was already supplied.
if(NOT DEFINED CMAKE_PROJECT_TOP_LEVEL_INCLUDES)
  set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES "${CONAN_PROVIDER}")
endif()

# Optional host profile. A preset / local_options may set CONAN_HOST_PROFILE (e.g. the
# clang-cl profile that maps clang-cl -> compiler=msvc). If unset, the cmake-conan
# provider auto-detects settings from the CMake configuration.
if(CONAN_HOST_PROFILE)
  message(STATUS "[conan] host profile: ${CONAN_HOST_PROFILE}")
else()
  message(STATUS "[conan] no explicit profile — provider auto-detects from CMake")
endif()

message(STATUS "[conan] provider: ${CONAN_PROVIDER}")
