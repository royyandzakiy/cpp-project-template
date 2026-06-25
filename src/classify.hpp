#pragma once
// A tiny branch-rich component used to demonstrate code coverage. The tests in
// test/test_classify.cpp intentionally exercise only SOME paths, so the coverage report
// shows the untested branches/regions as missed — proving coverage tracks more than lines.
namespace demo {

// -1 / 0 / 1 for negative / zero / positive. Three regions, two decision branches.
auto sign(int value) -> int;

// Inclusive [low, high] test. The `&&` short-circuits, so llvm-cov treats each operand as
// its own branch: a test that never falsifies the first operand leaves a branch uncovered.
auto in_range(int value, int low, int high) -> bool;

enum class Grade : char { A, B, C, F };

// Maps a 0..100 score to a letter via an if-chain — one branch per threshold.
auto grade(int score) -> Grade;

} // namespace demo
