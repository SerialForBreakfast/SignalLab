# Agent session — curriculum audit (2026-04-18)

## Assessment

- **Tasks.md**: MVP + diagnostics (D1.2.x) + Phase 2 (P2.x) entries marked implemented; cross-cutting X1–X14 are mostly curriculum/copy tasks without per-line status in Tasks.
- **Code vs tasks**: `LabCatalog.swift` and `LabCatalogTests.swift` agree on **17** scenarios and locked slug order; `grab_screenshot.sh` MODES align with documented slugs.

## Drift found and fixed

- **ReadMe.md** still described **five** foundational labs, omitted **Exception Breakpoint Lab**, and framed **Crash Lab** around exception breakpoints first—contradicting `LabCatalog.swift`, `Tasks.md` (X5/X6), and `LabRefinement.md`.

## Execution

- Updated `ReadMe.md`: Initial Lab Roadmap (six MVP labs + pointer to catalog), Crash / Exception / Breakpoint numbering, Phase 1/Phase 2 roadmap text (diagnostics + Phase 2 slice), Future Lab Candidates tightened.
- **Tests**: `xcodebuild -scheme SignalLab -destination 'platform=iOS Simulator,id=C132735B-09A0-4F64-9EDF-DD586483A27A' test` completed with **TEST SUCCEEDED** (unit + UI tests). A follow-up `-only-testing:SignalLabTests` run also exited 0 for a faster logic-only check.

## Suggested next steps (not done this session)

- Optional: add explicit **Status** lines in `Tasks.md` for X1–X4, X7, X9–X14 after a doc pass.
