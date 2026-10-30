# Implementation plans

These plans are proposed follow-up work; none has been implemented yet. Keep each milestone small and validate its failure modes before building on it.

## Plan 1: Local validation and reporting

1. Add `tools/validate.ps1`, accepting a Godot executable override and using the documented local console executable by default. Check the executable and report its version. Import the project before executing the existing unit runner; verify the appropriate flags against the installed binary.
2. Run stages as bounded subprocesses. Capture stdout, stderr, duration and exit status in an ignored, unique run directory. Return nonzero for import errors, assertion failures, crashes, timeouts, missing reports or zero tests. Clean up timed-out processes.
3. Extend the test framework to identify cases, report failures and durations, and emit a machine-readable summary with a versioned schema. Preserve direct runner use and manual registration. Add async support when scene tests require it, rather than speculating about its interface now.
4. Make test data isolated and writable, including Godot's user data. Distinguish an environment or permissions failure from a test failure. Avoid changing a developer's existing user data.
5. Verify a clean run and deliberate assertion failure, malformed script, timeout and empty selection. Confirm each produces the expected exit code and useful diagnostics; restore the probes after verification.

**Deliverables:** validation command, case-level output, structured results and focused tests of runner behavior. Document invocation and artifact paths in repository guidance.

## Plan 2: CI

1. Select a CI provider and Windows runner with access to a pinned Godot 4.7.2 binary. Verify download integrity and cache only where useful; do not commit generated `.godot` data.
2. On a clean checkout, invoke the same validation command used locally. Set writable isolated data and a job timeout. Upload reports and logs on both success and failure, with bounded retention.
3. Exercise a deliberate failure in a temporary branch or equivalent safe test, and confirm the job fails and artifacts remain available.

**Deliverables:** CI configuration and a short reproduction guide. Linux and export lanes can be added when they serve a target platform.

## Plan 3: Gameplay scenarios

**Prerequisite:** a playable scene and explicit expected behavior.

1. Provide fixtures for scene creation, bounded frame waits, input injection and cleanup. Reset input, random state and test-created nodes between cases. Capture errors and state at the first failure.
2. Implement one short scenario against a meaningful player journey, asserting independently observable outcomes at key steps. Introduce an intentional defect to prove the test catches it.
3. Add bounded seeded exploration after the basic scenario is stable. Save the engine version, seed, initial configuration, tick-indexed inputs and failure details. Provide a replay command; verify repeatability on the same runner and preserve a minimal regression case when a bug is found.

**Deliverables:** a reproducible scenario command, actionable failure artifacts and a small set of tests anchored in game rules. Add asynchronous test support or evaluate GdUnit4 if existing framework changes become disproportionate.

## Plan 4: Visual test room

**Prerequisite:** representative game content and a Windows environment capable of rendering Forward Plus with D3D12.

1. Create a small scene using actual prototype content: player, floor and wall, representative objects, lighting and a HUD. Fix camera, viewport at 1280×720, seed, object positions and animation time. Avoid uncontrolled timers and effects.
2. Run a rendered capture separately from headless tests. Wait for assets and scene state to settle, then wait for Godot's post-draw signal before saving the viewport. Bound waits and fail clearly on an empty or missing image.
3. Record engine version, renderer, GPU and driver. Capture repeatedly on the designated runner and establish a comparison tolerance from observed variation. Have a person review and approve the initial PNG before committing it with its scenario.
4. On comparison failure, retain baseline, actual, diff and environment details. Test the workflow with an intentional visible defect. Require review when an intended change updates a baseline; never automatically accept new images.
5. Add a second aspect-ratio UI checkpoint when the UI exists. Consider a separate pinned software-rendered environment only after proving it works for the selected rendering configuration; do not assume it matches the production renderer.

**Deliverables:** reviewed baseline, reproducible capture command, comparison report and documented update procedure. Screenshots complement state assertions and human assessment of feel.

## Plan 5: Performance and export

**Prerequisite:** a representative workload and chosen target platform.

1. Define the scenario and target metrics, warmup period, sampling duration and runner configuration. Collect frame-time percentiles, memory and relevant entity counts across repeated runs; retain metadata and results.
2. Establish normal variation before proposing thresholds. Investigate anomalies with profiling, and avoid making noisy shared CI timings a hard gate prematurely.
3. Create a target export preset and provision matching templates. Export from a clean checkout, launch the result with a bounded smoke scenario and retain logs. Verify a broken export or launch produces a failure.

**Deliverables:** trend reports, documented budgets when agreed, and an automated export smoke lane.
