#include "math.hpp"
#include <filesystem>
#include <fmt/base.h>

auto main() -> int {
	[[maybe_unused]] std::filesystem::path path{"."};

	fmt::println("Hello, clangd + CMake!");
	fmt::println("Hello, clangd + CMake! {}", mymath::add(1, 2));

	return 0;
}
