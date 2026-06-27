# src/myapp/CMakeLists.txt
# MyApp — a standalone hello-world binary. Intentionally independent of MyLib so BUILD_APP and
# BUILD_LIB can be toggled separately.
# =============================================================================
add_executable(MyApp main.cpp greeter.cpp)
target_include_directories(MyApp PRIVATE ${PROJECT_SOURCE_DIR}/src) # so "myapp/greeter.hpp" resolves
target_link_libraries(MyApp PRIVATE fmt::fmt sml::sml)

# PCH, unity build, optional profiler links, clang-tidy, Windows ASan DLL — see cmake/target_options.cmake
configure_target(MyApp)
