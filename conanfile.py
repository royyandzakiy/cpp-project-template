from conan import ConanFile
from conan.tools.cmake import cmake_layout

class MyProjectConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    def requirements(self):
        self.requires("fmt/12.1.0")
        self.requires("scnlib/4.0.1")
        self.requires("tracy/0.13.1")
        self.requires("perfetto/52.0")
        self.requires("gtest/1.17.0")

    def layout(self):
        cmake_layout(self)
