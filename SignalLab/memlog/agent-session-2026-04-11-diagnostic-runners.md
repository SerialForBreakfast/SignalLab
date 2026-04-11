# Agent session — diagnostic lab runners (2026-04-11)

- Added Objective-C **Zombie Objects** helper (`ZombieObjectsLabUseAfterRelease`), app bridging header (`SignalLab/SignalLab-Bridging-Header.h`), and `SWIFT_OBJC_BRIDGING_HEADER` on the SignalLab target.
- Implemented **Broken/Fixed** runners: `ZombieObjectsLabScenarioRunner`, `ThreadSanitizerLabScenarioRunner`, `MallocStackLoggingLabScenarioRunner`; split detail views into `iOSZombieObjectsLabDetailView.swift`, `iOSThreadSanitizerLabDetailView.swift`, `iOSMallocStackLoggingLabDetailView.swift`; shared `LabGuidedDiagnosticLayout.swift`.
- Updated `LabCatalog.swift`, `Labs.md`, investigation guides, `LabRefinement.md`, `Tasks.md` (D1.2.2–D1.2.4 status).
- Unit tests: `ZombieObjectsLabScenarioRunnerTests`, `ThreadSanitizerLabScenarioRunnerTests`, `MallocStackLoggingLabScenarioRunnerTests`.
- Verified: `xcodebuild` build + full `test` (SignalLabTests + SignalLabUITests) on iPhone 17 simulator.
