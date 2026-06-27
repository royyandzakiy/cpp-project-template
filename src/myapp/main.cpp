#include "myapp/greeter.hpp"

#include <fmt/base.h>

// MyApp is a standalone binary — it deliberately does NOT depend on MyLib, so BUILD_APP and
// BUILD_LIB are fully independent. Its greet() module (greeter.*) is unit-tested with a mock
// clock in test/test_app.cpp.
auto main() -> int {
	const app::SystemClock clock;
	fmt::println("{}", app::greet("World", clock));
	return 0;
}
