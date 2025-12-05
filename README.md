```bash
# called once
conan profile list
conan profile detect

# called every pristine build
conan install . --build=missing
 && cmake -B build --preset default
 && cmake --build build --config Release
 && cmake --build build --config Debug
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
conan install . -of build-msvc --build=missing -s compiler=msvc -s compiler.version=193 -s compiler.runtime=dynamic
conan install . -of build-clang --build=missing -s compiler=clang -s compiler.version=20 -s build_type=Release

# still fails to build
conan install . -of build-gcc --build=missing -s compiler=gcc -s compiler.version=15 -s compiler.libcxx=libstdc++
```