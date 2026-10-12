# fuzz/CMakeLists.txt
# libFuzzer targets over MyLib — built when ENABLE_FUZZING (see cmake/fuzzing.cmake).
add_fuzz_target(fuzz_mylib fuzz_mylib.cpp)
