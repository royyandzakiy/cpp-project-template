# DEVELOPMENT

- fix badge issues
- test on clion for all features
- test in vs for all features
- move examples above

- library
  - consider, create myapp and mylib. both are generated as seperate things, myapp does not use mylib. examples do use mylib
  - create install script, based on nexus
    - keep cmakelists clean, when switching between mylib and myapp. hide grim install & lib export details
  - for lib, change cpp_project_template to mylib
    - modify version creation script to only generate header for mylib
    - use generated_lib folder

- add license
- move dependencies to single cmake
- set c compilers for each preset
- if msvc asan, set debugger target
- add gcovr.cfg
- set vcenv

- examples
  - qt qml example
  - ftxui example
  
- fuzz example
- emscripten compiler for wasm (consider)

## Backlog

- create local_options.debug/release/lib-debug/lib-release.cmake

- github actions
  - build, run, test all presets (including sanitizers)
  - restructure ci scripts to be modular and expandable
  - add fuzz build matrix option (random seed)
  - add badges for all preset variant, or add into table
- bitbucket pipeline

- add INSTALL to create as library, add in option
  - check windows lib template for inspo

- examples of profiling using tracy, perfetto (compile build time), perf + flamegraph (https://github.com/brendangregg/FlameGraph), valgrind
  - review: hotspot, coz, heaptrack, gperftools
  - create profiling wiki
- examples of bugs captured with sanitizers

- create template min using this as base
- move cecep project to use clangd instead

## Skip

- if user selects compiler that they dont hv, give graceful fallback
- docs generator (doxygen but with most modern ui)
  - create wiki for this project (cleanup current readme, VERY bloated, move content to wiki)
- open for contributor: issues, discussions, contributions
  - fix readme: logo & badge, pitch (problem to solve), quick start (inline code example), live demo
  - add complete docs suite (tutorials, how-to-guides, understand, reference, release blog, release/change log)
  - add compiler explore quick test
- add more hardenning
  - use sourcetrail app
  - code coverage: find out whats best practice todo in CI after generate coverage report XML (other than via codecov)
- add doxyfile & doxygen
