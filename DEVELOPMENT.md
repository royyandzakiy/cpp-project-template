# DEVELOPMENT

## Active

- ensure works for all presets offline
- ensure works for all ci presets (first CI run after the src/core + src/app restructure)

## Backlog

- add fuzzer for mylib
- add cpack
- add license
- expand tests to have unit, integ, e2e (pytest)
- docs
  - add doxygen with good ui
  - create github wiki, move the long README sections there
- examples
  - qt qml example
  - ftxui example
  - raylib example
  - crow example
  - emscripten example
  - cppwinrt scan
  - bluez scan
- continue create zephyr nrf
- recreate nxsdgldr

## Bugs

- clang-cl-asan is left out of CI: Visual Studio's bundled LLVM 19 ASan runtime crashes at startup on
  newer Windows (`interception_win: unhandled instruction`). Works with LLVM 20+; CI would need to
  install it.
- selecting `conan` as the CI package manager failed on some compilers — re-check after the CI
  caching / Conan fixes.

## Skip

- set vcenv (needed or not?)
  - if msvc asan, set debugger target
- test on clion for all features
- test in vs for all features
- add gcovr.cfg
- emscripten compiler for wasm (consider)
- if user selects compiler that they dont hv, give graceful fallback
- examples of bugs captured with sanitizers
- move cecep project to use clangd instead
- open for contributor: issues, discussions, contributions
  - fix readme: logo & badge, pitch (problem to solve), quick start (inline code example), live demo
  - add complete docs suite (tutorials, how-to-guides, understand, reference, release blog, release/change log)
  - add compiler explore quick test
