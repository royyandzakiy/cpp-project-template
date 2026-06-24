// MSan trip-wire: use of an uninitialized value (Clang only).
// Expected: MemorySanitizer reports "use-of-uninitialized-value".
#include <cstdio>

auto main(int argc, char ** /*argv*/) -> int {
	int x;            // deliberately uninitialized
	int y = x + argc; // use of uninitialized value
	std::printf("%d\n", y);
	return y & 1;
}
