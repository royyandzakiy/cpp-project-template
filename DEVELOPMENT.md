# DEVELOPMENT

## Backlog

- make all sanitizers work
  - have them in proper presets to easily select between them

- github actions
  - check if coverage works fine
  - build, run, test all presets (including sanitizers)

- bitbucket pipeline

- examples of profiling using tracy, perfetto, flanegraph
- examples of bugs captured with sanitizers

- create template min using this as base
- move cecep project to use clangd instead

- add INSTALL to create as library, add in option
  - merge with win lib

- CI github actions:
  - os: add windows & linux
  - compilers: gcc16, clang, apple clang, msvc
  - fuzz build matrix (random seed)

## Skip

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
