// UBSan trip-wire: signed integer overflow (true undefined behavior).
// Expected: UBSan reports "runtime error: signed integer overflow".
#include <climits>

auto main(int argc, char ** /*argv*/) -> int {
	int x = INT_MAX;
	x += argc; // argc >= 1 at runtime -> overflow (argc keeps it non-constant-folded)
	return x;
}
