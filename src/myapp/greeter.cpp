#include "myapp/greeter.hpp"

#include <chrono>
#include <fmt/chrono.h>
#include <fmt/format.h>

namespace app {

auto SystemClock::today() const -> std::string {
	return fmt::format("{:%Y-%m-%d}", std::chrono::system_clock::now());
}

auto greet(std::string_view name, const IClock& clock) -> std::string {
	return fmt::format("Hello, {}! Today is {}.", name, clock.today());
}

} // namespace app
