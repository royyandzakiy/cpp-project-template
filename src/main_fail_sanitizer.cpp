#include <fmt/core.h>
#include <iostream>

auto main() -> int {
	fmt::println("hello guys!");

	// 1. Memory Leak (Detectable by clang-tidy bugprone-* or clang-analyzer)
	int *leak = new int(42);
	// forgot to delete leak

	// 2. Potential Use-after-free/Dangling Pointer
	int *ptr = new int(100);
	delete ptr;
	return *ptr; // Clang-Tidy will scream about this

	(void)leak;

	return 0;
}