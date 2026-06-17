#include <fmt/core.h>
#include <thread>

// Uncomment ONE scenario at a time, then rebuild with the matching sanitizer option.
// ASan:          -DENABLE_SANITIZERS=ON -DENABLE_ASAN=ON          (Windows + Linux)
// TSan / MSan:   -DENABLE_SANITIZERS=ON -DENABLE_TSAN_MSAN=ON     (Linux only)

static int add(int a, int b) {
	return a + b;
}
static int multiply(int a, int b) {
	return a * b;
}

int main() {
	fmt::println("=== Sanitizer demo ===");

	// =========================================================
	// SCENARIO 1 — ASan: out-of-bounds write  (Windows + Linux)
	// =========================================================
	{
		int *arr = new int[3];
		for (int i = 0; i < 5; ++i) { // i = 3, 4 → out of bounds
			arr[i] = multiply(i, 10);
			fmt::println("  arr[{}] = {}", i, arr[i]);
		}
		delete[] arr;
	}

	// =========================================================
	// SCENARIO 2 — ASan: use-after-free  (Windows + Linux)
	// =========================================================
	// {
	// 	int* p = new int(42);
	// 	delete p;
	// 	fmt::println("  use-after-free: {}", *p);
	// }

#ifndef _WIN32
	// =========================================================
	// SCENARIO 3 — TSan: data race  (Linux / macOS)
	// =========================================================
	// {
	// 	int shared = 0;
	// 	std::thread t1([&]() { for (int i = 0; i < 10000; ++i) shared = add(shared, 1); });
	// 	std::thread t2([&]() { for (int i = 0; i < 10000; ++i) shared = add(shared, 1); });
	// 	t1.join();
	// 	t2.join();
	// 	fmt::println("  shared (racy): {}", shared);
	// }

	// =========================================================
	// SCENARIO 4 — MSan: uninitialized read  (Linux / Clang only)
	// =========================================================
	// {
	// 	int uninit;
	// 	fmt::println("  uninitialized: {}", add(uninit, 3));
	// }
#endif

	return 0;
}
