# DEVELOPMENT

## Easy

- add INSTALL to create as library, add in option
  - merge with win lib

## Prio

- add dev-container: use clang-cl, clang, gcc16
  - add windows-setup.ps1 with winget + microsoft.visualstudio
- add conan
  - add option to choose vcpkg vs conan

## Backlog

- using clang, add option to choose asan vs tsan/msan (fix current bugs)
  - add all static analyzers (gcc, then clang-cl, msvc)
  - add .clangd
  - ensure all project_options.cmake works fine
- CI github actions:
  - os: add windows & linux
  - compilers: gcc16, clang, apple clang, msvc
  - fuzz build matrix (random seed)

## Skip

- contribution goodies
- open for contributor: issues, discussions, contributions
  - fix readme: logo & badge, pitch (problem to solve), quick start (inline code example), live demo
  - add complete docs suite (tutorials, how-to-guides, understand, reference, release blog, release/change log)
  - add compiler explore quick test
- profiling
  - use perf + [flamegraph](https://github.com/brendangregg/FlameGraph)
  - add tracey
- add more hardenning
  - use sourcetrail app
  - code coverage: find out whats best practice todo in CI after generate coverage report XML (other than via codecov)
- add doxyfile & doxygen
