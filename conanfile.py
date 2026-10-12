from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, cmake_layout

class MyProjectConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps"

    def requirements(self):
        self.requires("fmt/12.1.0")
        self.requires("scnlib/4.0.1")
        self.requires("tracy/0.13.1")
        self.requires("perfetto/52.0")
        self.requires("gtest/1.17.0")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)
        # cmake-conan drives the build from our own presets, so don't add Conan's per-build-dir
        # presets to CMakeUserPresets.json (two Debug build dirs collide on "conan-debug").
        tc.user_presets_path = False
        tc.generate()
