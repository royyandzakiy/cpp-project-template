// TSan trip-wire: data race on a shared int from two threads.
// Expected: ThreadSanitizer reports "data race".
#include <thread>

auto main() -> int {
	int shared = 0;
	auto bump = [&] {
		for (int i = 0; i < 100000; ++i) {
			++shared; // unsynchronized concurrent write
		}
	};
	std::thread t1(bump);
	std::thread t2(bump);
	t1.join();
	t2.join();
	return shared & 1;
}
