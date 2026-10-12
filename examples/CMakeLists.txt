# MyLib consumer — links the library and calls its public API. In-tree it links the MyLib target
# directly; the same code works for an external consumer that does find_package(MyLib) against
# generated_lib/ (INSTALL_LIB=ON exports MyLib::MyLib for that case).
if(TARGET MyLib)
  add_executable(example_mylib mylib_consumer/main.cpp)
  target_link_libraries(example_mylib PRIVATE MyLib::MyLib fmt::fmt)
  # Only a SHARED MyLib produces a runtime DLL to deploy; a STATIC MyLib is linked in directly.
  if(WIN32 AND BUILD_LIB_SHARED)
    # Drop MyLib.dll (and any other runtime DLL deps) next to the exe so it runs in place.
    add_custom_command(
      TARGET example_mylib
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:example_mylib>
              $<TARGET_FILE_DIR:example_mylib>
      COMMAND_EXPAND_LISTS)
  endif()
endif()

if(TARGET project_tracy_profile) # ENABLE_TRACY and tracy found
  add_executable(example_tracy tracy/main_tracy.cpp)
  target_link_libraries(example_tracy PRIVATE fmt::fmt project_tracy_profile)
endif()

if(TARGET project_perfetto_profile) # ENABLE_PERFETTO and perfetto found
  add_executable(example_perfetto perfetto/main_perfetto.cpp)
  target_link_libraries(example_perfetto PRIVATE fmt::fmt project_perfetto_profile)
endif()

# An executable linking the instrumented (STATIC) MyLib must link the sanitizer runtime too.
foreach(_example example_mylib example_tracy example_perfetto)
  if(TARGET ${_example})
    target_enable_sanitizers(${_example}) # no-op unless ENABLE_SANITIZERS
  endif()
endforeach()
