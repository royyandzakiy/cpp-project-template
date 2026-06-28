# DEVELOPMENT

- add cpack

- library
  - add INSTALL to create as library, add in option
    - check windows lib template for inspo
    - install script, based on nexus
  - call cpack to create package

- set c compilers for each preset
- set vcenv (needed or not?)
  - if msvc asan, set debugger target

## Backlog

- expand tests to have unit, integ, e2e

- test on clion for all features
- test in vs for all features

- examples
  - qt qml example
  - ftxui example

- add gcovr.cfg
  
- fuzz example
- emscripten compiler for wasm (consider)

- github actions
  - build, run, test all presets (including sanitizers)
  - restructure ci scripts to be modular and expandable
  - add fuzz build matrix option (random seed)
  - add badges for all preset variant, or add into table
- bitbucket pipeline

- if user selects compiler that they dont hv, give graceful fallback

- examples of profiling using tracy, perfetto (compile build time), perf + flamegraph (https://github.com/brendangregg/FlameGraph), valgrind
  - review: hotspot, coz, heaptrack, gperftools
  - create profiling wiki
- examples of bugs captured with sanitizers

- move cecep project to use clangd instead

## Skip

- add license
- docs generator (doxygen but with most modern ui)
  - add doxyfile & doxygen
  - create wiki for this project (cleanup current readme, VERY bloated, move content to wiki)
- open for contributor: issues, discussions, contributions
  - fix readme: logo & badge, pitch (problem to solve), quick start (inline code example), live demo
  - add complete docs suite (tutorials, how-to-guides, understand, reference, release blog, release/change log)
  - add compiler explore quick test
