# Developer infrastructure roadmap

This roadmap supports rapid Godot prototyping with automated feedback that an AI agent can use independently. Human review remains valuable for game feel, design decisions and intentional visual changes. Priorities and estimates are proposals, not commitments.

## Development environment

The current development environment is Windows with PowerShell, using the local Godot 4.7.2 stable editor and console executables documented in `AGENTS.md`. The project configures Forward Plus, D3D12 on Windows, and Jolt for 3D physics. These are project settings; an actual run may use a fallback graphics driver.

GPU model, graphics driver version, Windows version, display scaling and the active rendering driver have not yet been recorded. Capture these from the designated visual-test runner when the baseline is established, alongside the exact engine version and viewport settings. Keep machine-specific details with the baseline metadata rather than assuming every developer has the same setup. Use separate baselines for materially different rendering environments if needed.

## 1. Trustworthy local validation

Create a single PowerShell entry point that imports the project, runs the existing tests, applies timeouts, produces useful artifacts and returns a reliable exit code. Improve case-level reporting and detect empty runs. Prove failures are reported correctly before relying on green results. See Plan 1 in [PLANS.md](PLANS.md).

**Done when:** a clean checkout passes with Godot 4.7.2, and intentional assertion, parse and timeout failures each return nonzero with actionable diagnostics.

## 2. Repeatable CI

Run the same validation entry point on changes in a clean, pinned environment. Retain reports and logs on failure; isolate writable test data. Start with Windows to match the local setup, and add platforms when they become targets.

**Done when:** a clean CI run passes, a deliberately failing change fails, and its artifacts explain how to reproduce it. CI provider and hosting remain implementation choices.

## 3. Gameplay scenarios

After the first playable scene exists, build fixtures that load scenes, advance frames, inject actions and check observable game state. Add a short critical-path scenario and regressions for discovered bugs. Record seeds and input traces for bounded bot exploration.

**Done when:** a scenario runs unattended, cleans up reliably, detects an intentional gameplay regression and can replay a reported failure. Determinism must be demonstrated on the chosen environment, not assumed.

## 4. Visual verification

After real visual content exists, establish a reviewed screenshot of a deterministic visual test room at 1280×720. Fix the camera, state, lighting and animation timing; capture using the project's Forward Plus/D3D12 configuration on a designated Windows runner. Add a UI baseline at a second aspect ratio when useful.

**Done when:** repeated captures on the designated runner are stable, an intentional visual regression produces a useful diff, and baseline updates are reviewed. Rendered checks run separately from headless logic tests.

## 5. Performance and delivery

Once representative gameplay, a target platform and budgets exist, collect performance trends on a stable runner. Add export and bounded launch smoke tests after choosing an export preset. Start with reporting; introduce gates only after measuring noise.

**Done when:** a representative workload produces comparable metrics, and an exported build can be launched and checked automatically on the selected target.

Revisit framework and third-party tool choices at each milestone. [RESEARCH.md](RESEARCH.md) contains sources and tradeoffs.
