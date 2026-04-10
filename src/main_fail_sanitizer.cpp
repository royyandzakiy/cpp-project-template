#include <fmt/core.h>
#include <iostream>

auto main() -> int {
	// // 1. MSan Trigger: Uninitialized variable
	// int uninitialized_val;

	// // This will cause MSan to throw an error because 'add'
	// // will try to read a garbage value from the stack.
	// fmt::println("MSan Test (Add): {}", add(uninitialized_val, 3));

	// // 2. TSan Trigger: Data Race
	// int shared_value = 0;
	// // Two threads incrementing the same variable without a mutex/atomic
	// std::thread t1([&]() {
	// 	for (int i = 0; i < 1000; ++i)
	// 		shared_value = add(shared_value, 1);
	// });

	// std::thread t2([&]() {
	// 	for (int i = 0; i < 1000; ++i)
	// 		shared_value = add(shared_value, 1);
	// });

	// t1.join();
	// t2.join();

	// fmt::println("TSan Test (Shared Value): {}", shared_value);

	// // 3. ASan Trigger
	// int *results = new int[3];

	// for (int i = 0; i < 5; ++i) {
	// 	// When i is 3 and 4, ASan will intercept the out-of-bounds write.
	// 	results[i] = multiply(i, 10);
	// 	fmt::println("Stored result {}: {}", i, results[i]);
	// }

	// // --- ASan Trigger: Use-After-Free ---
	// delete[] results;

	// // Accessing the pointer after deletion.
	// // ASan will catch this immediately.
	// fmt::println("Post-delete access: {}", results[0]);

	return 0;
}