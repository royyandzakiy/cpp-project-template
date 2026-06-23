# cmake/config_conan.cmake
# Conan 2 integration via the cmake-conan dependency provider. Included by
# setup_package_manager() when PKG_MANAGER=conan, so find_package() resolves through Conan
# with no other changes. Works with ANY preset — the package manager is chosen orthogonally
# (PKG_MANAGER in local_options / -D / IDE), never baked into a preset.

set(CONAN_PROVIDER "${CMAKE_SOURCE_DIR}/cmake/cmake-conan/conan_provider.cmake")
if(NOT EXISTS "${CONAN_PROVIDER}")
  message(FATAL_ERROR
    "[conan] cmake-conan submodule not found at ${CONAN_PROVIDER}.\n"
    "Run: git submodule update --init --recursive")
endif()

# Register the provider (consumed at the next project() call). Honor an explicit override.
if(NOT DEFINED CMAKE_PROJECT_TOP_LEVEL_INCLUDES)
  set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES "${CONAN_PROVIDER}")
endif()

# Host profile selection:
#   - clang-cl needs an explicit profile (maps clang-cl -> compiler=msvc + executables); auto-pick
#     cmake/conan-profiles/clang-cl-windows-<buildtype>.ini based on the active preset.
#   - every other compiler: leave unset so cmake-conan auto-detects from the CMake configuration.
# An explicit -DCONAN_HOST_PROFILE=... always wins.
if(NOT CONAN_HOST_PROFILE AND CMAKE_CXX_COMPILER MATCHES "clang-cl")
  string(TOLOWER "${CMAKE_BUILD_TYPE}" _conan_bt)
  set(_conan_prof "${CMAKE_SOURCE_DIR}/cmake/conan-profiles/clang-cl-windows-${_conan_bt}.ini")
  if(EXISTS "${_conan_prof}")
    set(CONAN_HOST_PROFILE "${_conan_prof}" CACHE FILEPATH "Conan host profile (auto-selected for clang-cl)")
  else()
    message(WARNING "[conan] clang-cl detected but no profile at ${_conan_prof}; "
                    "the provider will auto-detect (may mis-map clang-cl to compiler=clang).")
  endif()
endif()

if(CONAN_HOST_PROFILE)
  message(STATUS "[conan] host profile: ${CONAN_HOST_PROFILE}")
else()
  message(STATUS "[conan] no explicit profile — cmake-conan auto-detects from CMake")
endif()
message(STATUS "[conan] provider: ${CONAN_PROVIDER}")
