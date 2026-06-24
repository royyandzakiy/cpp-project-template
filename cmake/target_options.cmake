# cmake/target_options.cmake
# Per-target machinery for the main executable: precompiled headers, unity build, optional
# profiler links, and (Windows) ASan runtime deployment. Call configure_target(<target>) AFTER
# the target and its link libraries are defined.
#
# (deploy_asan_runtime() is defined in cmake/sanitizer_analyzer.cmake, included before this.)

function(configure_target target)
  # Precompiled headers — TUNE this list to the heavy headers you include everywhere.
  if(ENABLE_PCH)
    target_precompile_headers(
      ${target}
      PRIVATE
      <filesystem>
      <print>
      <string>
      <string_view>
      <vector>
      <memory>
      <utility>)
    message(STATUS "PCH enabled for ${target}")
  endif()

  # Unity / jumbo build — only meaningful once the target has several .cpp files.
  if(ENABLE_UNITY_BUILD)
    set_target_properties(${target} PROPERTIES UNITY_BUILD ON)
    message(STATUS "Unity build enabled for ${target}")
  endif()

  # Optional profiler interface targets (created by cmake/profiler.cmake when enabled).
  if(TARGET project_tracy_profile)
    target_link_libraries(${target} PRIVATE project_tracy_profile)
  endif()
  if(TARGET project_perfetto_profile)
    target_link_libraries(${target} PRIVATE project_perfetto_profile)
  endif()

  # Windows ASan: deploy the runtime DLL next to the executable (no-op on Linux/macOS).
  if(ENABLE_ASAN)
    deploy_asan_runtime(${target})
  endif()
endfunction()
