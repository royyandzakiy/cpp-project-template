# MyLib consumer — links the shared library and calls its public API. In-tree it links the
# MyLib target directly; the same code works for an external consumer that does
# find_package(MyLib) against generated_lib/ (MyLib::MyLib is exported for that case).
if(BUILD_LIB AND TARGET MyLib)
  add_executable(example_mylib mylib_consumer/main.cpp)
  target_link_libraries(example_mylib PRIVATE MyLib::MyLib fmt::fmt)
  if(WIN32)
    # Drop MyLib.dll (and any other runtime DLL deps) next to the exe so it runs in place.
    add_custom_command(
      TARGET example_mylib
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:example_mylib>
              $<TARGET_FILE_DIR:example_mylib>
      COMMAND_EXPAND_LISTS)
  endif()
endif()

# if(ENABLE_SANITIZERS)
#   add_executable(example_sanitizer sanitizers/main_fail_sanitizer.cpp)
#   target_link_libraries(example_sanitizer PRIVATE fmt::fmt)
#   if(NOT WIN32)
#     find_package(Threads REQUIRED)
#     target_link_libraries(example_sanitizer PRIVATE Threads::Threads)
#   endif()
# endif()

if(TARGET project_tracy_profile)
  add_executable(example_tracy tracy/main_tracy.cpp)
  target_link_libraries(example_tracy PRIVATE fmt::fmt project_tracy_profile)
endif()

if(TARGET project_perfetto_profile)
  add_executable(example_perfetto perfetto/main_perfetto.cpp)
  target_link_libraries(example_perfetto PRIVATE fmt::fmt project_perfetto_profile)
endif()
