#include "MyLib/math.hpp"

#include <cstdint>

namespace mymath {

auto add(int a, int b) -> std::int64_t {
	return std::int64_t{a} + b;
}

auto subtract(int a, int b) -> std::int64_t {
	return std::int64_t{a} - b;
}

auto multiply(int a, int b) -> std::int64_t {
	return std::int64_t{a} * b;
}

auto divide(double a, double b) -> double {
	if (b == 0) {
		return 0; // Error case
	}
	return a / b;
}

} // namespace mymath
