#include "math.hpp"
#include <fmt/core.h>

auto main() -> int {
	fmt::println("Add: {}", add(5, 3));
	fmt::println("Subtract: {}", subtract(10, 4));
	fmt::println("Multiply: {}", multiply(6, 7));
	fmt::println("Divide: {}", divide(15, 3));
	fmt::println("Divide by zero: {}", divide(10, 0));

	return 0;
}