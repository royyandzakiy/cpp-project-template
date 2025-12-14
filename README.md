# C++ Project Template

This repository is a reusable C++ project template intended to serve as a consistent starting point for modern C++ development across platforms and toolchains.

It standardizes **CMake**, **Conan**, and **CMake Presets** usage, targets **C++23**, and supports **Clang**, **GCC (MinGW)**, and **MSVC** out of the box.

The template is designed to work best with IDEs and editors that support the **CMake Tools / CMake extension** workflow (Visual Studio, VS Code, CLion).

---

## Key Features

* **Modern CMake (3.28+)**

  * Clean, target-based configuration
  * `CMAKE_CXX_STANDARD=23`, no compiler extensions
  * `compile_commands.json` enabled by default

* **CMake Presets–First Workflow**

  * Predefined configure, build, and test presets
  * One-command configuration and builds
  * No manual generator or compiler switching

* **Conan 2 Integration**

  * Dependencies managed via Conan
  * Automatic dependency installation via `conan-preconfigure.cmake`
  * Toolchain generation handled transparently

* **Multi-Compiler Support**

  * **Clang** (Ninja)
  * **MSVC** (Visual Studio 2022)
  * **GCC (MinGW)**

* **Cross-Platform Friendly**

  * Works on Windows and Unix-like environments
  * Consistent build directory layout per compiler

---

## Project Structure (High Level)

```
.
├── CMakeLists.txt
├── CMakePresets.json
├── conanfile.py
├── cmake/
│   └── conan-preconfigure.cmake
├── src/
│   └── main.cpp
└── build-*        # Generated build directories
```

---

## Conan Pre-Configuration

The file `cmake/conan-preconfigure.cmake` is included **before** the project definition. Its responsibilities are:

* Validating the selected compiler profile (`clang`, `gcc`, or `msvc`)
* Determining the build type
* Running `conan install` automatically if needed
* Generating and loading the Conan CMake toolchain

As a result, **you normally do not need to invoke Conan manually**. Using CMake presets is sufficient.

---

## Supported Toolchains

You choose the toolchain via **CMake configure presets**:

| Toolchain   | Notes                              |
| ----------- | ---------------------------------- |
| Clang       | Uses Ninja generator               |
| MSVC        | Visual Studio 2022, static runtime |
| GCC (MinGW) | Uses MinGW Makefiles               |

### Important Notes

* `std::print` / `std::println`

  * Supported by **Clang** and **MSVC**
  * **Not supported** by GCC MinGW at the time of writing

* C++20/23 **Modules**

  * Supported **only with MSVC** in this template

---

## Recommended Workflow

### 1. Use a CMake-Aware IDE or Editor

This template is intended to be used with:

* **Visual Studio** (CMake project support)
* **VS Code** with the **CMake Tools extension**
* **CLion**

Avoid invoking raw `cmake` commands manually unless you know exactly what you are doing.

---

### 2. Configure Using Presets

List available presets:

```bash
cmake --list-presets
```

Configure (example: Clang Debug):

```bash
cmake --preset clang-debug
```

This will:

* Select the compiler
* Run Conan automatically
* Generate the build system

---

### 3. Build Using Presets

```bash
cmake --build --preset build-clang-debug
```

Equivalent presets exist for:

* Clang Debug / Release
* MSVC Debug / Release
* GCC Debug / Release

---

### 4. Run

The executable is produced in the corresponding build directory:

```bash
./build-clang/<project_name>
```

---

## Example Entry Point

The default `main.cpp` demonstrates a minimal C++23 program:

* Uses `<print>` for output
* Compiles cleanly across supported compilers (with the GCC caveat noted above)

---

## Dependency Management

Dependencies are declared in `conanfile.py` using Conan 2.

* CMake dependencies are generated via `CMakeDeps`
* Toolchains via `CMakeToolchain`

Adding a dependency typically requires:

1. Adding it to `conanfile.py`
2. Calling `find_package()` and linking the target in `CMakeLists.txt`

---

## Intended Usage

This repository is meant to be **copied or forked** as the starting point for new projects. Rename the project, adjust dependencies, and extend as needed while keeping the overall structure intact.

---

## Summary

This template provides:

* A clean, repeatable C++23 setup
* Zero-friction compiler switching
* Automatic dependency management
* A presets-driven workflow aligned with modern CMake best practices

Use the CMake extension, rely on presets, and let Conan handle the rest.
