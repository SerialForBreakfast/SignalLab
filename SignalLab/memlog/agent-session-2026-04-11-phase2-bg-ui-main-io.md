# Agent session — Phase 2: Background Thread UI + Main Thread I/O (2026-04-11)

- **Background Thread UI Lab** (`background_thread_ui`): `BackgroundThreadUILabScenarioRunner` posts `BackgroundThreadUILabNotifications.didSignal` from `Task.detached` (Broken) vs `await MainActor.run { post }` (Fixed); `iOSBackgroundThreadUILabDetailView` uses `onReceive` + `lastObservedPing`.
- **Main Thread I/O Lab** (`main_thread_io`): `MainThreadIOLabScenarioRunner` — Broken: 10× synchronous `Data(contentsOf:)` on main (256 KB temp blob in Caches); Fixed: detached read + main update; `iOSMainThreadIOLabDetailView` with scroll probes.
- Catalog indices 12–13; 14 scenarios total; `LabCatalogTests`, `SignalLabLog` categories, `SignalLabScreenshotUITests`, `grab_screenshot.sh` modes `bg_ui` / `main_io`.
- Docs: `BackgroundThreadUILabInvestigationGuide.md`, `MainThreadIOLabInvestigationGuide.md`; `Labs.md`, `Roadmap.md`, `ReadMe.md`, `Tasks.md` (P2.2), `LabRefinement.md`, `AGENTS.md`.
