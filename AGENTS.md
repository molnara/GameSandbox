# Repository Guidelines

## Project Structure & Module Organization

GameSandbox is a Godot project using GDScript; `project.godot` declares Godot 4.7 and Forward Plus rendering.

- `core/logging/log.gd` implements the global `Log` autoload, including severity filtering and the `message_logged` signal.
- `tests/framework/` contains the custom assertion helpers, suite lifecycle, and headless test runner.
- `tests/unit/test_logger.gd` covers logging behavior and edge cases.
- `icon.svg` is the current project image asset. No gameplay scenes or dedicated asset directory exist yet.

Keep reusable services under `core/` and corresponding unit suites under `tests/unit/`. Preserve script `.gd.uid` files; `.godot/` is generated cache data.

## Build, Test, and Development Commands

Run commands from the repository root in PowerShell. Both local executables are verified accessible and report `4.7.2.stable.official.ed1daf0bf`:

- Editor: `C:\Tools\Godot\Godot_v4.7.2-stable_win64.exe`
- Console (preferred for tests): `C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`

Open the editor for development and asset import:

```powershell
& 'C:\Tools\Godot\Godot_v4.7.2-stable_win64.exe' --editor --path .
```

Run all registered unit suites; exit code `1` indicates assertion failures:

```powershell
& 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/framework/test_runner.gd
```

The sandbox may prevent Godot from writing to its `user://` directory, causing file logging tests and Godot's own log initialization to fail. If this occurs, rerun the test command with sandbox escalation so Godot can write its temporary test files.

No export presets or build scripts are checked in. No main scene is configured; create and select a scene in the editor before running gameplay. Prefer the editor UI when changing project settings.

## Coding Style & Naming Conventions

Use UTF-8, as required by `.editorconfig`. Follow the existing GDScript style: tabs for indentation, explicit parameter and return types, and typed variables where practical. Use `snake_case` for files, functions, and variables, `UPPER_SNAKE_CASE` for constants and enum values, and a leading underscore for internal helpers. Separate functions with blank lines. No formatter or linter is configured.

## Testing Guidelines

Extend `tests/framework/test_suite.gd`, name files `test_<module>.gd`, and name cases `test_<behavior>`. Register cases with `register_test()` in `_init()`. Explicitly preload and append new suites in `test_runner.gd`; discovery is manual. Use setup/teardown hooks to reset state and free allocated nodes. Cover changed behavior and relevant boundaries. No numeric coverage threshold is configured.

## Commit & Pull Request Guidelines

History follows Conventional Commits, including `test(logging): cover logger edge cases` and `refactor(testing): introduce reusable unit test framework`. Use an imperative summary and a scope when helpful. PRs should describe the behavior changed, link relevant issues, and report the test command and result. Include screenshots for visual changes. Keep generated caches, exported builds, and local secrets out of commits.

## Local validation

Run `./tools/validate.ps1` in PowerShell 7 to import the project and run all registered tests. The default executable is the console Godot 4.7.2 path above; pass `-Godot <path>` to override it. `-VersionTimeoutSeconds`, `-ImportTimeoutSeconds`, and `-TestTimeoutSeconds` set stage timeouts (defaults: 30, 120, and 120 seconds). Timed-out process trees are terminated.

Each invocation retains a unique directory under ignored `.validation/`. `validation.json` records stage durations, exit codes, timeout status, and the engine version; each stage has stdout and stderr files, and import and test have Godot logs. `report.json` is version 1 and records the user data directory, total duration and assertion counts, and each case's suite, name, duration, assertion counts, and failure descriptions. A missing, invalid, inconsistent, or zero-case report fails validation. User data is isolated under the artifact directory and retained for inspection. Artifacts can be removed manually.

If validation fails, inspect the named stage's stderr, stdout, and Godot log along with `validation.json`. Setup failures include an inaccessible executable or user data directory. Sandboxed Godot may fail to read the Windows certificate store; run validation with appropriate permissions if the diagnostics show that error. Direct runner invocation remains supported without a report; set `GAMESANDBOX_TEST_REPORT` to an absolute writable path to request one.
