#include "MyLib/greeter.hpp"

#include <fmt/base.h>

// Keep main() thin: wire up the real dependencies and hand off to MyLib, where the logic lives
// and is unit-tested (test/test_greeter.cpp drives greet() with a mock clock).
auto main() -> int {
	const demo::SystemClock clock;
	fmt::println("{}", demo::greet("World", clock));
	return 0;
}
