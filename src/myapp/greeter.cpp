#include "greeter.hpp"

#include <chrono>
#include <fmt/format.h>
#include <string>
#include <string_view>

namespace app {

auto SystemClock::today() const -> std::string {
	// Format from the y/m/d integer fields (std::chrono calendar).
	const auto days = std::chrono::floor<std::chrono::days>(std::chrono::system_clock::now());
	const std::chrono::year_month_day date{days};
	return fmt::format("{:04}-{:02}-{:02}", static_cast<int>(date.year()), static_cast<unsigned>(date.month()),
					   static_cast<unsigned>(date.day()));
}

auto greet(std::string_view name, const IClock &clock) -> std::string {
	return fmt::format("Hello, {}! Today is {}.", name, clock.today());
}

} // namespace app
