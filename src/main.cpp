#include <fmt/core.h>
#include <iostream>

auto main() -> int {
	fmt::println("hello guys!");
	std::cout << "test";

	int *ptr = nullptr;
	*ptr = 42;
	std::cout << "Value: " << *ptr << std::endl;

	return 0;
}