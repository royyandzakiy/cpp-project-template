#include <filesystem>
#include <print>

auto main() -> int {
	[[maybe_unused]] std::filesystem::path path{"."};

	std::println("Hello, clangd + CMake!");
	return 0;
}
