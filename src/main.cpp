#include <print>

auto main(int argc, char *argv[]) -> int {
	(void)argc;
	(void)argv;
	std::println("Hello, World!"); // fyi, gcc mingw64 does not support std::print

	return 0;
}