#pragma once
#include <string>
#include <string_view>

namespace app {

// Abstract clock so callers can inject a fake/mock in tests (see test/test_app.cpp). The full set
// of special members is defaulted to satisfy the rule of five for a polymorphic base.
class IClock {
public:
	IClock() = default;
	IClock(const IClock&) = default;
	IClock(IClock&&) = default;
	auto operator=(const IClock&) -> IClock& = default;
	auto operator=(IClock&&) -> IClock& = default;
	virtual ~IClock() = default;

	[[nodiscard]] virtual auto today() const -> std::string = 0;
};

// The real clock used by the application.
class SystemClock final : public IClock {
public:
	[[nodiscard]] auto today() const -> std::string override;
};

// The unit under test: formats a greeting using the injected clock's date.
[[nodiscard]] auto greet(std::string_view name, const IClock& clock) -> std::string;

} // namespace app
