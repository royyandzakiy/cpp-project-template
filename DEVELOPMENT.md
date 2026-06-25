7# DEVELOPMENT

- find pkg with pkg mgr guards
- project opts does not req additional installs - fast linker off
- if user selects compiler that they dont hv, give graceful fallback
- generate version to give good msg if version.txt missing
- gen version off by def (keep the file)

## Backlog

- cleanup current cmakelists

- add INSTALL to create as library, add in option
  - check windows lib template for inspo

- github actions
  - check if coverage works fine
  - build, run, test all presets (including sanitizers)
  - add fuzz build matrix option (random seed)
  - add badges to readme after successful testing
- bitbucket pipeline

- examples of profiling using tracy, perfetto (compile build time), perf + flamegraph (https://github.com/brendangregg/FlameGraph)
- examples of bugs captured with sanitizers

- create template min using this as base
- move cecep project to use clangd instead

## Skip

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
