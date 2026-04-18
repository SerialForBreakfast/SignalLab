# Agent session — Xcode tooling docs audit (2026-04-18)

## Delivered

- Added `Docs/XcodeToolingCheatSheet.md` (debugger UI, breakpoints, schemes, Memory Graph, Instruments, console/Issue navigator, conceptual call-stack diagram, Apple doc links, `xcodebuild -version` note).
- Updated `Docs/Labs.md`: intro, “How to use this reference”, per-lab **Xcode primer** with links into the cheat sheet, clearer reproduction/investigation wording for all 17 labs.
- Updated all 17 `*InvestigationGuide.md` files with an **Xcode terminology** section pointing at the cheat sheet.
- Synced `LabCatalog.swift` reproduction/investigation/tool strings with `Labs.md`; added `Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md` to suggested tools; documented alignment in `LabCatalog` doc comment.

## Verification

- `xcodebuild -scheme SignalLab … build` succeeded after edits.
- Full `xcodebuild test` was started in this environment; allow extra time for Simulator/UI tests if re-running locally.
