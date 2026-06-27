#include "MyLib/classify.hpp"
#include <gtest/gtest.h>

using namespace demo; // declared in namespace demo

// sign(): all three paths exercised → expect 100% region AND branch coverage for this function.
TEST(ClassifyTest, SignFullyCovered) {
	EXPECT_EQ(sign(5), 1);
	EXPECT_EQ(sign(-3), -1);
	EXPECT_EQ(sign(0), 0);
}

// in_range(): the `&&` is two branches. We make the SECOND operand both true and false, but
// never falsify the FIRST (value >= low) — so coverage flags that branch as partially taken.
TEST(ClassifyTest, InRangePartialBranch) {
	EXPECT_TRUE(in_range(5, 1, 10));   // value >= low TRUE, value <= high TRUE
	EXPECT_FALSE(in_range(11, 1, 10)); // value >= low TRUE, value <= high FALSE
	// Deliberately omitted: in_range(0, 1, 10) — would make `value >= low` FALSE.
}

// grade(): we cover A/B/C but NOT the final `return Grade::F`, so the coverage report shows
// that region/branch as missed. This is the headline demonstration — remove the comment line
// below (add EXPECT_EQ(grade(50), Grade::F)) and re-run `coverage` to watch it turn green.
TEST(ClassifyTest, GradeMissesFailingPath) {
	EXPECT_EQ(grade(95), Grade::A);
	EXPECT_EQ(grade(85), Grade::B);
	EXPECT_EQ(grade(75), Grade::C);
	// Deliberately omitted: EXPECT_EQ(grade(50), Grade::F);
}
