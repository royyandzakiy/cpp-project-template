#include "MyLib/greeter.hpp"

#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <string>

namespace {

// gmock fake for demo::IClock — lets the test drive greet() with a deterministic date and assert
// the dependency is actually invoked.
class MockClock : public demo::IClock {
public:
	MOCK_METHOD(std::string, today, (), (const, override));
};

} // namespace

using ::testing::HasSubstr;
using ::testing::Return;

// EXPECT_CALL asserts greet() really consults the clock exactly once, and the returned date is
// woven into the message.
TEST(GreeterTest, EmbedsClockDate) {
	MockClock clock;
	EXPECT_CALL(clock, today()).WillOnce(Return("2026-06-26"));
	EXPECT_EQ(demo::greet("World", clock), "Hello, World! Today is 2026-06-26.");
}

TEST(GreeterTest, IncludesTheName) {
	MockClock clock;
	EXPECT_CALL(clock, today()).WillRepeatedly(Return("2000-01-01"));
	EXPECT_THAT(demo::greet("Ada", clock), HasSubstr("Hello, Ada!"));
}
