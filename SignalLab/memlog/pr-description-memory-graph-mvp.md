# PR: Ship Memory Graph Lab MVP

## Summary

This PR promotes the first memory workflow to an MVP-ready **Memory Graph Lab**. The lab now teaches one focused beginner question: **which app object is holding this object alive?**

The original retain-cycle lesson stays preserved as a later lab, while the MVP memory slot now uses a simpler, searchable Open Note object graph:

```text
MemoryGraphOpenNoteHolder
  -> MemoryGraphOpenNote
      -> MemoryGraphNoteBody
      -> MemoryGraphNoteAutosaveState
```

## What Changed

- Reworked Memory Graph Lab around the Open Note fixture so learners search for clear, learner-facing type names instead of abstract checkout/session/store terms.
- Updated the lab workflow to use **Set up lab** and teach the Memory Graph navigator, owner arrow, Backtrace panel, and reset comparison.
- Enabled Malloc Stack Logging in the shared Run scheme so allocation backtraces work by default.
- Simplified the shared lab detail UX:
  - one canonical workflow
  - workflow expanded by default
  - tools/hints kept secondary
  - less repeated goal/workflow/checklist copy
- Moved Retain Cycle Lab later in the curriculum while preserving its slug and terminology.
- Updated Memory Graph docs, lab catalog copy, task tracking, and memlog/ADR notes to reflect the MVP direction.
- Added a generated SignalLab app icon asset to the Xcode asset catalog.

## Validation

- `git diff --check`
- `xcodebuild build -scheme SignalLab -destination 'platform=iOS Simulator,OS=26.4.1,name=iPhone 17'`
- `xcodebuild test -scheme SignalLab -destination 'platform=iOS Simulator,OS=26.4.1,name=iPhone 17' -only-testing:SignalLabTests/MemoryGraphLabScenarioRunnerTests`

## Notes For Review

- The Memory Graph Lab is intentionally **not** a retain cycle. It teaches the basic Memory Graph ownership path first.
- Retain Cycle Lab remains the later ownership-loop lesson.
- Simulator Memory Graph capture can still fail with `LeakAgent` / `libmalloc` on some Xcode simulator combinations; the guide now treats that as a capture failure and recommends device capture when it repeats.
