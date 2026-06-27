# =============================================================================
# MyApp — Standalone Hello-World Binary
# =============================================================================
# Intentionally independent of MyLib so BUILD_APP and BUILD_LIB can be toggled
# separately in multi-config workflows (e.g. CI matrix, feature toggles).
# =============================================================================

# ---- Executable -------------------------------------------------------------
add_executable(MyApp)

# ---- Sources ----------------------------------------------------------------
target_sources(MyApp
    PRIVATE
        main.cpp
        greeter.cpp
        # Headers are NOT listed here - they're found via include paths
        # greeter.hpp  # ← Optional: add for IDE visibility
)

# ---- Include Paths ----------------------------------------------------------
target_include_directories(MyApp
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

# ---- Dependencies -----------------------------------------------------------
target_link_libraries(MyApp
    PRIVATE
        fmt::fmt
        sml::sml
)

# ---- Cross-Cutting Configuration --------------------------------------------
# Applies PCH, unity build, profiler links (Tracy/Perfetto), clang-tidy,
# Windows ASan DLL deployment — all via configure_target().
# See cmake/configure_target.cmake for implementation details.
configure_target(MyApp)

message(STATUS "MyApp configured (standalone executable)")
