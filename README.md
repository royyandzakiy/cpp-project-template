```bash
conan profile list
conan profile detect

conan install . --build=missing

cmake -B build --preset conan-default
cmake --build build --config Release
cmake --build build --config Debug
```

create custom profile
```bash
# notepad %USERPROFILE%\.conan2\profiles\default

[settings]
os=Windows
arch=x86_64
compiler=msvc
compiler.version=193
compiler.runtime=dynamic
build_type=Release

[conf]
tools.microsoft.msbuild:vs_version=17
```

specify via command

```bash
conan install . --build=missing -s compiler=msvc -s compiler.version=193 -s compiler.runtime=dynamic

# These 2 are still problematic
conan install . --build=missing -s compiler=gcc -s compiler.version=12 -s compiler.libcxx=libstdc++11
conan install . --build=missing -s compiler=clang -s compiler.version=17 -s compiler.runtime=dynamic -s compiler.runtime_type=Release -s compiler.cppstd=20 -s build_type=Release -c tools.cmake.cmaketoolchain:generator=Ninja
```