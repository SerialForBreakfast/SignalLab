# Agent notes (SignalLab)

This file captures **project-specific preferences** so assistants use the same defaults for builds, paths, and tooling. It does not replace product specs in [SignalLab/ReadMe.md](SignalLab/ReadMe.md) or the task breakdown in [SignalLab/Tasks.md](SignalLab/Tasks.md).

## Repository layout

- **Xcode project:** [SignalLab/SignalLab.xcodeproj](SignalLab/SignalLab.xcodeproj) — run `xcodebuild` from the `**SignalLab`** directory that contains this `.xcodeproj` (not the parent repo folder unless that is where the project lives in your clone).
- **App sources (synchronized group):** `SignalLab/SignalLab/` — `App/`, `Shared/`, `Labs/`.
- **Unit tests:** `SignalLab/SignalLabTests/`.
- **Contributor / curriculum docs:** `SignalLab/Docs/` (kept outside the synced app sources so markdown is not bundled as app resources by default).

## Builds and tests (command line only)

Prefer **CLI** for builds and tests. Do not rely on opening the Xcode GUI.

**Scheme:** `SignalLab`

**Preferred simulator (maintainer default):**

- **Device type:** iPhone17,1 (simulator hardware class as shown in Xcode / device info).
- **OS:** iOS **26.4**.

**Example `xcodebuild` destination** (adjust the **name** if your install labels the runtime differently; use `xcrun simctl list devices available` to confirm):

```bash
cd SignalLab   # directory containing SignalLab.xcodeproj
xcodebuild -scheme SignalLab \
  -destination 'platform=iOS Simulator,OS=26.4,name=iPhone 17' \
  build

xcodebuild -scheme SignalLab \
  -destination 'platform=iOS Simulator,OS=26.4,name=iPhone 17' \
  test
```

If multiple runtimes or devices match, prefer the pairing above, or pass an explicit simulator **UDID**:

```bash
-destination 'platform=iOS Simulator,id=<UDID>'
```

Resolve `<UDID>` with `xcrun simctl list devices available` for an **iPhone 17** (or equivalent iPhone17,1) simulator on **iOS 26.4**.

## Swift and project conventions (summary)

- **UI / target-specific Swift** in this repo uses an `**iOS` filename prefix** (e.g. `iOSLabCatalogView.swift`) for clarity if additional Apple platforms are added later.
- Prefer **Swift concurrency** (`async`/`await`, structured tasks); keep UI work on the **main actor**; document non-obvious isolation on public APIs.
- **Dependencies:** Swift Package Manager only (exact versions when adding packages); no CocoaPods or Carthage.
- **Tests:** Swift Testing; focus on **business logic** and state, not trivial framework smoke tests. Do not skip or disable tests to force green CI.

## Where to look first


| Topic                                   | Location                                                                                                                               |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Vision, roadmap, lab curriculum         | [SignalLab/ReadMe.md](SignalLab/ReadMe.md)                                                                                             |
| Milestones, tasks, acceptance criteria  | [SignalLab/Tasks.md](SignalLab/Tasks.md)                                                                                               |
| Phases / principles (short)             | [SignalLab/Docs/Roadmap.md](SignalLab/Docs/Roadmap.md), [SignalLab/Docs/LabDesignPrinciples.md](SignalLab/Docs/LabDesignPrinciples.md) |
| Crash Lab investigation write-up        | [SignalLab/Docs/CrashLabInvestigationGuide.md](SignalLab/Docs/CrashLabInvestigationGuide.md)                                           |
| Breakpoint Lab investigation write-up   | [SignalLab/Docs/BreakpointLabInvestigationGuide.md](SignalLab/Docs/BreakpointLabInvestigationGuide.md)                                 |
| Retain Cycle Lab investigation write-up | [SignalLab/Docs/RetainCycleLabInvestigationGuide.md](SignalLab/Docs/RetainCycleLabInvestigationGuide.md)                               |
| Hang Lab investigation write-up         | [SignalLab/Docs/HangLabInvestigationGuide.md](SignalLab/Docs/HangLabInvestigationGuide.md)                                             |


When suggesting verification steps to a human, mention freeing **disk space** if simulator installs or DerivedData fail with “no space left on device.”

## UI screenshots and navigation (SignalLab)

This project is **not** a browser or proxy app. Ignore workflows that reference unrelated bundle IDs or flags such as `--screenshot-browser-mode` unless you are working in a different repository.

Screenshot PNGs land under `**SignalLab/memlog/ui-review/`** (same layout idea as JoesProxy’s `memlog/ui-review/`), produced by `**SignalLab/Scripts/grab_screenshot.sh**`.

### Principles

- Prefer **launch arguments** plus **accessibility identifiers** so screenshots do not depend on fragile tap sequences through `List` rows.
- Treat identifiers under the `SignalLab.*` and `LabDetail.*` prefixes as part of the **UI contract** for tests and automation; fix the app when queries are brittle.
- Screenshot output is `**XCTAttachment`** PNGs on UI test methods—open the **.xcresult** in Xcode (Tests → run → Attachments). Avoid spamming retries if Simulator or `xcodebuild` is unhealthy; capture the error once.

### Launch arguments (implemented)


| Argument                                            | Purpose                                                                                                                                         |
| --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `--uitesting-screenshot-catalog`                    | Explicit catalog-only run (no deep link).                                                                                                       |
| `--uitesting-screenshot-lab <id>`                   | Cold launch straight into lab detail for slug `<id>` (`crash`, `break_on_failure`, `breakpoint`, `retain_cycle`, `hang`, `cpu_hotspot`, `thread_performance_checker`, `zombie_objects`, `thread_sanitizer`, `malloc_stack_logging`, …). `break_on_failure` is the stable internal slug for **Exception Breakpoint Lab**. |
| `--uitesting-screenshot-accessibility-dynamic-type` | With the flags above, applies a large SwiftUI dynamic type size for accessibility screenshots (`grab_screenshot.sh --text-size accessibility`). |


Parsing lives in `SignalLab/SignalLab/App/iOSLaunchArguments.swift` (`SignalLabLaunchArguments`).

### Stable identifiers (non-exhaustive)

- `SignalLab.catalog.list` — catalog `List`
- `SignalLab.catalog.row.<labId>` — row for that scenario
- `SignalLab.detail.<labId>` — detail root container for a lab surface (e.g. `break_on_failure` for Exception Breakpoint Lab; title changed, slug did not)
- `LabDetail.runScenario`, `LabDetail.reset`, `LabDetail.implementationPicker` — detail scaffold
- `BreakpointLab.searchField`, `BreakpointLab.categoryPicker` — Breakpoint Lab controls

### Running screenshot tests

From the directory that contains `SignalLab.xcodeproj`:

```bash
xcodebuild -scheme SignalLab \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:SignalLabUITests/SignalLabScreenshotUITests \
  test
```

Or use `**SignalLab/Scripts/grab_screenshot.sh**` (JoesProxy-style: runs each UI test, exports attachments with `xcresulttool`, writes timestamped PNGs under `memlog/ui-review/`).

```bash
# Standard dynamic type (default)
SignalLab/Scripts/grab_screenshot.sh

# Larger type for accessibility marketing / App Store
SignalLab/Scripts/grab_screenshot.sh --text-size accessibility

# Custom simulator
SignalLab/Scripts/grab_screenshot.sh --destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

`**capture_ui_screenshots.sh**` is a thin wrapper that invokes `grab_screenshot.sh`.

### If you are porting guidance from another repo

Replace browser-specific modes with **catalog / crash / exception / breakpoint / retain / hang / cpu** in `grab_screenshot.sh`. Prefer **timestamped files** in `memlog/ui-review/` so prior captures are preserved (same spirit as JoesProxy’s `joesproxy-screenshot-*.png` naming).
