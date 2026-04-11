# Agent session — Phase 2 labs: heap growth + deadlock (2026-04-11)

- Added **Heap Growth Lab** (`heap_growth`): `HeapGrowthLabScenarioRunner` (256 KB chunks; Broken unbounded, Fixed ring max 6), `iOSHeapGrowthLabDetailView.swift`.
- Added **Deadlock Lab** (`deadlock`): `DeadlockLabScenarioRunner` (Broken `DispatchQueue.main.sync` from main), `iOSDeadlockLabDetailView.swift` with freeze warning.
- Catalog sort indices 10–11; `LabCatalogTests` expects 12 scenarios; `SignalLabLog` categories `HeapGrowthLab`, `DeadlockLab`.
- Docs: `Docs/HeapGrowthLabInvestigationGuide.md`, `Docs/DeadlockLabInvestigationGuide.md`; `Labs.md`, `Roadmap.md`, `ReadMe.md`, `Tasks.md` (Epic P2.1), `LabRefinement.md`, `AGENTS.md`.
- Screenshots: `grab_screenshot.sh` modes `heap`, `deadlock`; `SignalLabScreenshotUITests` (does not tap Run on Deadlock Broken).
- Unit tests: `HeapGrowthLabScenarioRunnerTests`, `DeadlockLabScenarioRunnerTests` (Fixed only for deadlock).
