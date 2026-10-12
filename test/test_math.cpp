#include "MyLib/math.hpp"
#include <gtest/gtest.h>

#include <cstdint>
#include <limits>

using namespace mymath; // functions are declared in namespace mymath

TEST(MathTest, Add) {
	EXPECT_EQ(add(2, 3), 5);
	EXPECT_EQ(add(-1, 1), 0);
	EXPECT_EQ(add(0, 0), 0);
}

TEST(MathTest, Subtract) {
	EXPECT_EQ(subtract(10, 4), 6);
	EXPECT_EQ(subtract(0, 5), -5);
}

TEST(MathTest, Multiply) {
	EXPECT_EQ(multiply(4, 5), 20);
	EXPECT_EQ(multiply(0, 10), 0);
	EXPECT_EQ(multiply(-3, 4), -12);
}

// The int extremes the fuzzer (fuzz/fuzz_mylib.cpp) reached: 64-bit results mean no overflow.
TEST(MathTest, NoOverflowAtIntLimits) {
	constexpr int min = std::numeric_limits<int>::min();
	constexpr int max = std::numeric_limits<int>::max();
	EXPECT_EQ(add(min, min), std::int64_t{min} * 2);
	EXPECT_EQ(subtract(min, max), std::int64_t{min} - max);
	EXPECT_EQ(multiply(max, max), std::int64_t{max} * max);
}

TEST(MathTest, Divide) {
	EXPECT_DOUBLE_EQ(divide(10, 2), 5.0);
	EXPECT_DOUBLE_EQ(divide(5, 0), 0.0);
	EXPECT_DOUBLE_EQ(divide(7, 2), 3.5);
}
