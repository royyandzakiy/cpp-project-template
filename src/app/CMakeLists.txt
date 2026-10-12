# =============================================================================
# MyApp — thin executable over MyLib (src/app)
# =============================================================================
# Only main() and wiring live here; the logic is in MyLib (src/core) so tests can link it.
# Library-only projects can delete this directory (or move main.cpp to examples/).
# =============================================================================

# ---- Executable -------------------------------------------------------------
add_executable(MyApp)

# ---- Sources ----------------------------------------------------------------
target_sources(MyApp
    PRIVATE
        main.cpp
)

# ---- Properties -------------------------------------------------------------
set_target_properties(MyApp PROPERTIES
    CXX_EXTENSIONS OFF           # Matches root setting (good practice)
    # OUTPUT_NAME myapp          # Optional: lower-case output name
    # VERSION ${PROJECT_VERSION} # Optional: version info
)

# ---- Compile Features -------------------------------------------------------
# Even though root sets it globally, this makes it explicit
target_compile_features(MyApp
    PRIVATE
        cxx_std_23
)

# ---- Compile Options --------------------------------------------------------
# target_compile_options(MyApp
#     PRIVATE
#         $<$<CXX_COMPILER_ID:MSVC>:/bigobj>
#         $<$<CXX_COMPILER_ID:GCC>:-Wno-sign-compare>
# )

# ---- Dependencies -----------------------------------------------------------
target_link_libraries(MyApp
    PRIVATE
        MyLib::MyLib
        fmt::fmt
)

# ---- Cross-Cutting Configuration --------------------------------------------
# Applies PCH, unity build, profiler links (Tracy/Perfetto), clang-tidy via configure_target().
# See cmake/configure_target.cmake for implementation details.
configure_target(MyApp)

target_enable_sanitizers(MyApp) # no-op unless ENABLE_SANITIZERS

message(STATUS "MyApp configured (executable over MyLib)")
