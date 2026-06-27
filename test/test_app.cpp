#include "myapp/greeter.hpp"

#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <string>

namespace {

// gmock fake for app::IClock — lets the test drive greet() with a deterministic date and assert
// the dependency is actually invoked.
class MockClock : public app::IClock {
public:
	MOCK_METHOD(std::string, today, (), (const, override));
};

} // namespace

using ::testing::HasSubstr;
using ::testing::Return;

// EXPECT_CALL asserts greet() really consults the clock exactly once, and the returned date is
// woven into the message.
TEST(AppGreeterTest, EmbedsClockDate) {
	MockClock clock;
	EXPECT_CALL(clock, today()).WillOnce(Return("2026-06-26"));
	EXPECT_EQ(app::greet("World", clock), "Hello, World! Today is 2026-06-26.");
}

TEST(AppGreeterTest, IncludesTheName) {
	MockClock clock;
	EXPECT_CALL(clock, today()).WillRepeatedly(Return("2000-01-01"));
	EXPECT_THAT(app::greet("Ada", clock), HasSubstr("Hello, Ada!"));
}
