// Demonstrates consuming MyLib: include its public headers and call its API (across the DLL
// boundary when BUILD_LIB_SHARED=ON). Built as `example_mylib` when BUILD_EXAMPLES.
#include "MyLib/classify.hpp"
#include "MyLib/math.hpp"

#include <fmt/base.h>

auto main() -> int {
	fmt::println("MyLib consumer:");
	fmt::println("  mymath::add(2, 3)   = {}", mymath::add(2, 3));
	fmt::println("  mymath::divide(7,2) = {}", mymath::divide(7, 2));
	fmt::println("  demo::sign(-5)      = {}", demo::sign(-5));
	fmt::println("  demo::grade(85)     = {}", static_cast<int>(demo::grade(85)));
	return 0;
}
