find_package(fmt CONFIG REQUIRED)
find_package(scn CONFIG REQUIRED)
include(FetchContent)
FetchContent_Declare(
  sml
  GIT_REPOSITORY https://github.com/boost-ext/sml.git
  GIT_TAG v1.1.13)
FetchContent_MakeAvailable(sml)
