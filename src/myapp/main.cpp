#include <fmt/base.h>

// MyApp is a standalone hello-world binary — it deliberately does NOT depend on MyLib, so
// BUILD_APP and BUILD_LIB are fully independent. See examples/mylib_consumer for linking MyLib.
auto main() -> int {
	fmt::println("Hello from MyApp!");
	return 0;
}
