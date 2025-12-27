# Repository Guidelines

## Project Structure & Module Organization
- `src/main.cpp` contains the Qt Quick application entry point.
- `qml/Main.qml` provides the MVP window, toolbar, and canvas.
- `qml/CanvasItem.qml` defines draggable image/note items.
- `CMakeLists.txt` defines the CMake build, C++20 standard, and Qt6 dependencies.
- `cmake-build-debug/` is an IDE-generated build output; treat it as local-only.

Keep source under `src/`, headers in `include/`, and QML in `qml/` to keep CMake targets clean and discoverable.

## Build, Test, and Development Commands
- Configure: `cmake -S . -B build` creates a fresh build directory.
- Build: `cmake --build build` compiles the `RefNexus` executable.
- Run: `./build/RefNexus` launches the Qt application.

Qt6 is required (`Core`, `Gui`, `Qml`, `Quick`, `QuickControls2`). Ensure your Qt installation is discoverable by CMake (e.g., `CMAKE_PREFIX_PATH`).

## Coding Style & Naming Conventions
- Use 4-space indentation and braces on the next line (as in `main.cpp`).
- Keep includes ordered from Qt headers to project headers.
- Prefer `UpperCamelCase` for types and `lowerCamelCase` for variables/functions.
- Limit file names to `*.cpp` and `*.h` with matching base names.

No formatter is configured yet. If you add one (e.g., `clang-format`), document it here and align existing files.

## Testing Guidelines
- There is no test suite yet. If you introduce tests, place them under `tests/` and keep executable names in the pattern `test_<module>`.
- Recommended frameworks for Qt/C++ include Qt Test or Catch2; document chosen tooling in this file.

## Commit & Pull Request Guidelines
- This repository does not include Git history in the workspace, so no commit convention is enforced.
- Use concise, imperative commit messages (e.g., “Add window layout”).
- PRs should describe the change, list any new dependencies, and include a screenshot for UI-visible updates.
