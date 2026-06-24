// LSan trip-wire: a leaked allocation that is UNREACHABLE at exit.
// Expected: LeakSanitizer reports "detected memory leaks".
//
// The allocation must be unreachable when LSan scans at exit — otherwise it's treated as
// "still reachable" and not reported. Leaking inside a noinline helper drops the only
// pointer once the helper returns.
#include <cstdio>

#if defined(__GNUC__) || defined(__clang__)
__attribute__((noinline))
#endif
static void
leak_now() {
	int *p = new int[64];
	p[0] = 1;
	std::printf("allocated %d\n", p[0]); // use it so the allocation isn't optimized away
}                                        // p goes out of scope here, never freed -> unreachable

auto main() -> int {
	leak_now();
	return 0;
}
