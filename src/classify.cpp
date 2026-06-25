#include "classify.hpp"

namespace demo {

auto sign(int value) -> int {
	if (value > 0) {
		return 1;
	}
	if (value < 0) {
		return -1;
	}
	return 0;
}

auto in_range(int value, int low, int high) -> bool {
	return value >= low && value <= high;
}

auto grade(int score) -> Grade {
	constexpr int a_min = 90;
	constexpr int b_min = 80;
	constexpr int c_min = 70;
	if (score >= a_min) {
		return Grade::A;
	}
	if (score >= b_min) {
		return Grade::B;
	}
	if (score >= c_min) {
		return Grade::C;
	}
	return Grade::F;
}

} // namespace demo
