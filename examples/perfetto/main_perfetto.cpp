#include <chrono>
#include <fmt/core.h>
#include <fstream>
#include <perfetto.h>
#include <thread>
#include <vector>

PERFETTO_DEFINE_CATEGORIES(perfetto::Category("app").SetDescription("Application events"));

PERFETTO_TRACK_EVENT_STATIC_STORAGE();

using namespace std::chrono_literals;

static void process(int n) {
	TRACE_EVENT("app", "process");
	volatile double result = 0;
	for (int i = 0; i < n * 10'000; ++i)
		result += i * 0.001;
}

int main() {
	// Initialize
	perfetto::TracingInitArgs args;
	args.backends = perfetto::kInProcessBackend;
	perfetto::Tracing::Initialize(args);
	perfetto::TrackEvent::Register();

	// Configure and start session
	perfetto::TraceConfig cfg;
	cfg.add_buffers()->set_size_kb(1024);
	auto *ds_cfg = cfg.add_data_sources()->mutable_config();
	ds_cfg->set_name("track_event");

	auto session = perfetto::Tracing::NewTrace();
	session->Setup(cfg);
	session->StartBlocking();

	// Traced work
	fmt::println("Running traced workload...");
	for (int i = 0; i < 10; ++i) {
		TRACE_EVENT("app", "Iteration");
		process(i + 1);
		std::this_thread::sleep_for(10ms);
	}

	// Flush, stop, save
	perfetto::TrackEvent::Flush();
	session->StopBlocking();

	std::vector<char> data(session->ReadTraceBlocking());
	std::ofstream out("trace.perfetto", std::ios::binary);
	out.write(data.data(), static_cast<std::streamsize>(data.size()));

	fmt::println("Trace saved to trace.perfetto");
	fmt::println("View at: https://ui.perfetto.dev  (drag and drop the file)");

	return 0;
}
