# Agent notes (SignalLab)

This file captures **project-specific preferences** so assistants use the same defaults for builds, paths, and tooling. It does not replace product specs in [SignalLab/ReadMe.md](SignalLab/ReadMe.md) or the task breakdown in [SignalLab/Tasks.md](SignalLab/Tasks.md).

## Repository layout

- **Xcode project:** [SignalLab/SignalLab.xcodeproj](SignalLab/SignalLab.xcodeproj) — run `xcodebuild` from the **`SignalLab`** directory that contains this `.xcodeproj` (not the parent repo folder unless that is where the project lives in your clone).
- **App sources (synchronized group):** `SignalLab/SignalLab/` — `App/`, `Shared/`, `Labs/`.
- **Unit tests:** `SignalLab/SignalLabTests/`.
- **Contributor / curriculum docs:** `SignalLab/Docs/` (kept outside the synced app sources so markdown is not bundled as app resources by default).

## Builds and tests (command line only)

Prefer **CLI** for builds and tests. Do not rely on opening the Xcode GUI.

**Scheme:** `SignalLab`

**Preferred simulator (maintainer default):**

- **Device type:** iPhone17,1 (simulator hardware class as shown in Xcode / device info).
- **OS:** iOS **26.3** (build **23D127**).

**Example `xcodebuild` destination** (adjust the **name** if your install labels the runtime differently; use `xcrun simctl list devices available` to confirm):

```bash
cd SignalLab   # directory containing SignalLab.xcodeproj
xcodebuild -scheme SignalLab \
  -destination 'platform=iOS Simulator,OS=26.3,name=iPhone 17' \
  build

xcodebuild -scheme SignalLab \
  -destination 'platform=iOS Simulator,OS=26.3,name=iPhone 17' \
  test
```

If multiple runtimes or devices match, prefer the pairing above, or pass an explicit simulator **UDID**:

```bash
-destination 'platform=iOS Simulator,id=<UDID>'
```

Resolve `<UDID>` with `xcrun simctl list devices available` for an **iPhone 17** (or equivalent iPhone17,1) simulator on **iOS 26.3**.

## Swift and project conventions (summary)

- **UI / target-specific Swift** in this repo uses an **`iOS` filename prefix** (e.g. `iOSLabCatalogView.swift`) for clarity if additional Apple platforms are added later.
- Prefer **Swift concurrency** (`async`/`await`, structured tasks); keep UI work on the **main actor**; document non-obvious isolation on public APIs.
- **Dependencies:** Swift Package Manager only (exact versions when adding packages); no CocoaPods or Carthage.
- **Tests:** Swift Testing; focus on **business logic** and state, not trivial framework smoke tests. Do not skip or disable tests to force green CI.

## Where to look first

| Topic | Location |
|--------|----------|
| Vision, roadmap, lab curriculum | [SignalLab/ReadMe.md](SignalLab/ReadMe.md) |
| Milestones, tasks, acceptance criteria | [SignalLab/Tasks.md](SignalLab/Tasks.md) |
| Phases / principles (short) | [SignalLab/Docs/Roadmap.md](SignalLab/Docs/Roadmap.md), [SignalLab/Docs/LabDesignPrinciples.md](SignalLab/Docs/LabDesignPrinciples.md) |
| Crash Lab investigation write-up | [SignalLab/Docs/CrashLabInvestigationGuide.md](SignalLab/Docs/CrashLabInvestigationGuide.md) |
| Breakpoint Lab investigation write-up | [SignalLab/Docs/BreakpointLabInvestigationGuide.md](SignalLab/Docs/BreakpointLabInvestigationGuide.md) |
| Retain Cycle Lab investigation write-up | [SignalLab/Docs/RetainCycleLabInvestigationGuide.md](SignalLab/Docs/RetainCycleLabInvestigationGuide.md) |
| Hang Lab investigation write-up | [SignalLab/Docs/HangLabInvestigationGuide.md](SignalLab/Docs/HangLabInvestigationGuide.md) |

When suggesting verification steps to a human, mention freeing **disk space** if simulator installs or DerivedData fail with “no space left on device.”
