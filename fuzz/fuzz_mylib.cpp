// libFuzzer entry point for MyLib: libFuzzer feeds arbitrary bytes, FuzzedDataProvider turns them
// into typed arguments, and ASan/UBSan turn any memory error or undefined behavior into a crash.
#include "MyLib/classify.hpp"
#include "MyLib/greeter.hpp"
#include "MyLib/math.hpp"

#include <fuzzer/FuzzedDataProvider.h>

#include <cstddef>
#include <cstdint>
#include <string>

namespace {

// Deterministic clock, so a crash reproduces from its input file alone.
class FixedClock final : public demo::IClock {
  public:
	[[nodiscard]] auto today() const -> std::string override {
		return "2000-01-01";
	}
};

} // namespace

extern "C" auto LLVMFuzzerTestOneInput(const std::uint8_t *data, std::size_t size) -> int {
	FuzzedDataProvider input(data, size);
	const int a = input.ConsumeIntegral<int>();
	const int b = input.ConsumeIntegral<int>();
	const int c = input.ConsumeIntegral<int>();

	(void)demo::sign(a);
	(void)demo::in_range(a, b, c);
	(void)demo::grade(a);

	(void)mymath::add(a, b);
	(void)mymath::subtract(a, b);
	(void)mymath::multiply(a, b);
	(void)mymath::divide(input.ConsumeFloatingPoint<double>(), input.ConsumeFloatingPoint<double>());

	const FixedClock clock;
	(void)demo::greet(input.ConsumeRemainingBytesAsString(), clock);
	return 0;
}
