#include <filesystem>
#include <iostream>

auto main() -> int {
	[[maybe_unused]] std::filesystem::path path;

	std::cout << "Hello, clangd + CMake!\n";
	return 0;
}
