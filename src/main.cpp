#include "math.hpp"
#include <filesystem>
#include <print>

auto main() -> int {
	[[maybe_unused]] std::filesystem::path path{"."};

	std::println("Hello, clangd + CMake!");
	std::println("Hello, clangd + CMake! {}", mymath::add(1, 2));

	while (true)
		;
	return 0;
}
