# Developer infrastructure research

Research date: 2026-10-29. Goal: let an AI coding agent implement and verify prototype changes with little routine human intervention, while leaving design judgment to a person.

## Current starting point

GameSandbox targets Godot 4.7 and Forward Plus, with Jolt 3D physics and D3D12 on Windows. It has a logger and a small custom unit framework. The runner explicitly registers suites, calls tests synchronously, counts assertions and exits nonzero for assertion failures. There is no main scene, gameplay, export preset, CI configuration, or existing visual baseline. Consequently, gameplay and visual examples below are proposed acceptance tests, not claims about existing behavior.

## Recommendations, in order

| Priority | Investment | Outcome and acceptance criteria |
| --- | --- | --- |
| 1 | One validation entry point | A PowerShell command imports the project with the pinned Godot editor, runs unit tests, enforces timeouts, propagates failures and writes a concise report. A clean checkout and an intentionally failing test must both produce the expected exit status. Allow an executable path override; record the engine version. |
| 2 | Reliable test reporting | Extend the current runner with case names, durations, failure details, zero-test detection and machine-readable JSON or JUnit. Check that parse errors, crashes and timeouts fail the outer command, even if no assertion is recorded. Add asynchronous lifecycle support only when scene tests need it. |
| 3 | CI and isolated runs | Run the same command on every change and a clean checkout; pin Godot and dependencies, import before tests, provide writable isolated user data and retain logs and reports on failure. Avoid shared mutable test files and generated cache in version control. Start with Windows to match the local engine; add Linux only when portability matters. |
| 4 | Scene and gameplay harness | Once a playable scene exists, instantiate it in an isolated fixture, advance physics frames, inject named actions, assert observable state and clean up nodes and input. Bound every wait and print the scene, step and observed state on failure. Cover a short critical path and a regression for each discovered defect. |
| 5 | Reproducible exploration | Drive bounded scripted or seeded bot scenarios, check invariants every tick, and save seed, inputs, configuration and first failure. Replay failures as deterministic regression cases. Pin timestep, seed and environment, but verify replay stability: physics, ordering and platform differences can still prevent exact determinism. |
| 6 | Rendered verification | Add a separate rendered lane when UI or visuals exist. Capture fixed-resolution, fixed-camera checkpoints after assets and frames settle; preserve baseline, actual and diff. Pin renderer, fonts and environment, calibrate thresholds and require review of baseline updates. Headless logic success does not establish visual correctness. |
| 7 | Performance and export smoke | When a representative scene and target budget exist, record frame-time percentiles, memory and entity counts on a stable runner, with warmup and repeated runs. Initially report trends rather than gating noisy shared CI. Add a clean export and bounded launch smoke test once a target and preset are chosen. |

Godot documents headless operation and command-line export; exports require an editor binary, export templates and a matching preset. Headless mode uses a headless display and dummy audio, so rendered and audio behavior need separate coverage. [Godot command-line documentation](https://docs.godotengine.org/en/latest/tutorials/editor/command_line_tutorial.html)

## Agent-facing workflow

Give agents a short, versioned instruction file describing the validation command, scene conventions, expected artifacts and how to reproduce a failure. A single run should return an unambiguous status and paths to diagnostics. Suggested artifacts under an ignored per-run directory: `summary.json` (engine version, revision, suite, seed, result, duration), full engine log, case failures, input trace and, for rendered failures, screenshots and diffs. Limit artifact size and retention; do not put secrets or private player data into logs. CI should upload artifacts even on failure.

Separate fast checks run on every edit from longer scenario, rendered and performance lanes run on demand or on a schedule. A failing test must identify what was expected, what actually happened and how to replay it. Run each scenario with a wall-clock timeout and ensure subprocesses are terminated. Test the harness itself with deliberate assertion failure, malformed script, timeout and empty selection so false green results are caught.

AI can propose scenarios, inspect structured failures and iterate locally; assertions should encode explicit game rules rather than simply accepting the AI's description of the result. Use AI visual assessment as supplementary triage, not the sole pass criterion. Human review remains useful for feel, readability, balance and intentional visual changes; automated bots can detect regressions but cannot establish that play is fun.

## Tool choices and tradeoffs

- **Keep the existing framework initially.** It is small and already integrated. Add reporting, isolation and async support as actual needs arise; manual suite registration must fail clearly if nothing runs. Avoid building a general test framework before gameplay exists.
- **Evaluate GdUnit4 if maintenance becomes costly.** Its documented CI tooling and editor integration may replace custom plumbing, but introduce an addon, version compatibility and migration costs. Trial it on one real asynchronous scene test, compare diagnostics and runtime, and pin a version compatible with the installed engine before adoption. [GdUnit4 CI documentation](https://godot-gdunit-labs.github.io/gdUnit4/latest/faq/ci/)
- **Evaluate a scenario runner, not an agent-only interface.** [godot-qa](https://github.com/youichi-uda/godot-qa) describes input replay, assertions and screenshot comparisons. Its suitability, maintenance, license and Godot 4.7 compatibility need a small local proof of concept before dependency adoption. A simple project-owned scenario format may suffice for early prototypes.
- **Visual baselines need a controlled renderer.** Differences across drivers and antialiasing can make pixel comparisons noisy. Establish thresholds empirically on the chosen CI environment and inspect diffs; an open GdUnit4 discussion describes these difficulties, not a guaranteed portable solution. [Visual regression discussion](https://github.com/godot-gdunit-labs/gdUnit4/issues/655)
- **Measure before enforcing budgets.** Godot exposes engine and custom performance monitors; use representative gameplay and a stable environment, and investigate regressions with profiling rather than assuming a headless timing represents a player's experience. [Custom performance monitors](https://docs.godotengine.org/en/latest/tutorials/scripting/debug/custom_performance_monitors.html)

## First implementation milestone

1. Create `tools/validate.ps1` with configurable Godot path, import and unit stages, bounded execution, per-run artifacts and reliable exit propagation. Preserve the existing direct test command.
2. Enhance the runner's per-case output and machine-readable summary; add focused framework checks for failure reporting and empty runs.
3. Run locally from a clean checkout, including deliberate failure and timeout probes, then configure CI to invoke the identical entry point and upload diagnostics.
4. With the first gameplay scene, add one headless interaction scenario and one rendered screenshot checkpoint; prove each catches an intentional regression before expanding coverage.

The repository notes that sandboxed Godot may be unable to write `user://`; CI and local validation must provide a writable location, and sandbox failures should be distinguished from game failures. Exact import flags, renderer setup, CI provider and addon compatibility should be verified against the installed 4.7.2 binary during implementation; no external tool was installed or benchmarked for this research.
