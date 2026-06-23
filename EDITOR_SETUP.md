# Editor Setup

This project is **IDE- and OS-agnostic by design**. All language intelligence comes from
[clangd](https://clangd.llvm.org/), an LSP server that every major editor can drive. The
build is configured with CMake Presets, so the same commands work on Windows, Linux, and macOS.

## How the configuration is split

There are two layers. Understanding the split is the key to setting up any editor:

| Layer | Files | Who reads it |
|-------|-------|--------------|
| **Shared / portable** | `.clangd`, `.clang-tidy`, `.clang-format`, `compile_commands.json` | Every clangd-based editor, identically. Commit these. |
| **Per-editor launcher** | `.vscode/settings.json` (`clangd.arguments`), Neovim `cmd`, CLion settings, … | Each editor separately. These flags **cannot** live in `.clangd`. |

`.clangd` holds all the *semantic* behavior (background index, IncludeCleaner, inlay hints,
clang-tidy integration). The launcher flags below are the bits clangd only accepts on its
command line — most importantly `--query-driver`, which clangd refuses to read from a project
`.clangd` for security reasons.

## Prerequisites

- **LLVM/clangd** (this template targets LLVM 20.x) — `clangd`, `clang-format`, `clang-tidy`
- **CMake ≥ 3.28** and **Ninja**
- **vcpkg** (auto-detected; see `cmake/config_vcpkg.cmake`)

## Step 1 — generate `compile_commands.json` (all editors)

clangd needs a compilation database. Configure any preset; CMake exports it and the
`mirror_compile_commands` target copies it to the project root (where `.clangd` points):

```sh
# pick the preset for your platform/toolchain
cmake --preset clang-linux-debug      # Linux
cmake --preset clang-cl-debug         # Windows
cmake --preset appleclang-debug       # macOS

cmake --build --preset clang-linux-debug   # generates + mirrors compile_commands.json
```

List everything available with `cmake --list-presets`.

## Step 2 — the canonical clangd launch flags

These mirror `.vscode/settings.json`. Replicate them in whatever editor you use:

```
--query-driver=**/clang*,**/clang-cl*,**/clang++*,**/g++*,**/gcc*,**/c++*
--header-insertion=iwyu
--header-insertion-decorators
--completion-style=detailed
--function-arg-placeholders=true
--pch-storage=memory
-j=4
```

`--query-driver` lets clangd interrogate your compiler (gcc / clang-cl / mingw) for its system
include paths — essential on Windows and for any non-default-named driver.

---

## VS Code

Already configured. Install the recommended extensions (`.vscode/extensions.json`):
**clangd** (`llvm-vs-code-extensions.vscode-clangd`) and **CMake Tools**. The MS C/C++
extension (`cpptools`) is deliberately marked *unwanted* — its IntelliSense engine conflicts
with clangd and is disabled in settings. Nothing else to do.

## CLion

CLion has first-class native support for everything in this template — **no plugins needed**.

1. **Open the project folder.** CLion detects `CMakePresets.json` and lists the presets under
   *Settings → Build, Execution, Deployment → CMake*. Enable the preset(s) for your platform
   (e.g. `appleclang-debug`, `clang-linux-debug`, `clang-cl-debug`). The vcpkg toolchain file is
   wired in by the preset, so no manual toolchain setup is required.
2. **clang-format** — CLion auto-detects `.clang-format`. Confirm
   *Settings → Editor → Code Style* shows **“Enable ClangFormat”** (it prompts on first open).
   Now *Reformat Code* uses your project style.
3. **clang-tidy** — CLion reads project `.clang-tidy` automatically. Keep
   *Settings → Editor → Inspections → C/C++ → General → Clang-Tidy →* **“Prefer .clang-tidy
   files over IDE settings”** checked (default).
4. **Run/Debug** — CLion creates run configurations from CMake targets automatically; LLDB/GDB
   debugging works out of the box per preset.

> **Important nuance:** CLion does **not** read the project `.clangd` file or
> `compile_commands.json` — it builds its own code model directly from CMake and runs its
> *bundled* clangd configured through IDE settings. So the semantic options in `.clangd`
> (inlay hints, IncludeCleaner, etc.) are controlled in CLion via
> *Settings → Editor → Inlay Hints* and *Languages & Frameworks → C/C++ → Clangd*, not the file.
> `.clang-format` and `.clang-tidy`, by contrast, **are** honored natively. Practically: presets,
> formatting, and linting "just work"; only the clangd *semantic toggles* are set in the GUI.

CLion writes its project metadata to `.idea/` and builds into `cmake-build-*/` — both are
gitignored.

## Neovim (nvim-lspconfig)

```lua
require('lspconfig').clangd.setup({
  cmd = {
    'clangd',
    '--query-driver=**/clang*,**/clang-cl*,**/clang++*,**/g++*,**/gcc*,**/c++*',
    '--header-insertion=iwyu',
    '--header-insertion-decorators',
    '--completion-style=detailed',
    '--function-arg-placeholders=true',
    '--pch-storage=memory',
    '-j=4',
  },
})
```

(Semantic behavior still comes from the project `.clangd`.)

## Emacs

**eglot** (built-in, Emacs 29+):

```elisp
(add-to-list 'eglot-server-programs
             '((c++-mode c-mode)
               . ("clangd"
                  "--query-driver=**/clang*,**/clang-cl*,**/clang++*,**/g++*,**/gcc*,**/c++*"
                  "--header-insertion=iwyu" "--completion-style=detailed"
                  "--function-arg-placeholders=true" "--pch-storage=memory" "-j=4")))
```

**lsp-mode**: set `(setq lsp-clients-clangd-args '("--query-driver=..." ...))`.

## Zed

In `.zed/settings.json` (project) or your user settings:

```json
{
  "lsp": {
    "clangd": {
      "arguments": [
        "--query-driver=**/clang*,**/clang-cl*,**/clang++*,**/g++*,**/gcc*,**/c++*",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders=true",
        "--pch-storage=memory"
      ]
    }
  }
}
```

## Helix

`.helix/languages.toml`:

```toml
[language-server.clangd]
command = "clangd"
args = ["--query-driver=**/clang*,**/clang-cl*,**/clang++*,**/g++*,**/gcc*,**/c++*",
        "--header-insertion=iwyu", "--completion-style=detailed",
        "--function-arg-placeholders=true", "--pch-storage=memory", "-j=4"]
```

## Vim (coc.nvim) / Sublime Text (LSP)

Both install a clangd wrapper (`coc-clangd`, `LSP-clangd`) that auto-finds clangd. Add the same
flag list to the package's `initializationOptions`/`args` setting.

---

## Alternative: machine-wide clangd flags

If you'd rather not repeat the flags per editor, put them in your **user** clangd config — it
applies to every project and is allowed to set `--query-driver` equivalents:

- Linux/macOS: `~/.config/clangd/config.yaml`
- Windows: `%LocalAppData%\clangd\config.yaml`

```yaml
CompileFlags:
  CompilationDatabase: build
# Note: --query-driver, --header-insertion etc. are command-line only; for those,
# set them in your editor's clangd launch args (above). The user config.yaml covers
# the same keys as the project .clangd.
```

The project `.clangd` already covers the index/diagnostics/inlay-hint behavior, so most editors
only need the launch flags from Step 2.
