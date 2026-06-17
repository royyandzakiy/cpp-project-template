#include <atomic>
#include <chrono>
#include <cmath>
#include <fmt/core.h>
#include <thread>
#include <tracy/Tracy.hpp>

using namespace std::chrono_literals;

static void background_worker(std::atomic<bool>& running)
{
	tracy::SetThreadName("BackgroundWorker");
	int iteration = 0;

	while (running) {
		ZoneScopedN("WorkerTick");

		{
			ZoneScopedN("Compute");
			volatile double result = 0;
			for (int i = 0; i < 50'000; ++i)
				result += std::sin(i * 0.001);
		}

		double val = std::sin(iteration * 0.1);
		TracyPlot("SineValue", val);

		if (iteration % 10 == 0)
			TracyMessageL("Every 10th tick");

		++iteration;
		std::this_thread::sleep_for(30ms);
	}
}

int main()
{
	fmt::println("Tracy example — connect tracy-profiler.exe to observe.");

	std::atomic<bool> running{true};
	std::thread worker(background_worker, std::ref(running));

	for (int frame = 0; frame < 200; ++frame) {
		ZoneScopedN("MainFrame");

		{
			ZoneScopedN("Update");
			volatile int x = 0;
			for (int i = 0; i < 10'000; ++i)
				x += i;
		}

		fmt::println("Frame {}", frame);
		FrameMark;
		std::this_thread::sleep_for(16ms);
	}

	running = false;
	worker.join();

	fmt::println("Done.");
	return 0;
}
