# SignalLab — Labs reference

Keep this document open in your editor while you work. When the app stops under the debugger (for example in **Crash Lab**), you cannot scroll the in-app **Reproduction** or **Investigation guide** sections—everything below duplicates that content.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift`  
When you change catalog copy or add a lab, update this file in the same commit.

**Long-form guides:** see `Docs/CrashLabInvestigationGuide.md`, `Docs/BreakpointLabInvestigationGuide.md`, `Docs/RetainCycleLabInvestigationGuide.md`, `Docs/HangLabInvestigationGuide.md`.

---

## Table of contents

1. [Crash Lab](#crash-lab) (`crash`)
2. [Breakpoint Lab](#breakpoint-lab) (`breakpoint`)
3. [Retain Cycle Lab](#retain-cycle-lab) (`retain_cycle`)
4. [Hang Lab](#hang-lab) (`hang`)
5. [CPU Hotspot Lab](#cpu-hotspot-lab) (`cpu_hotspot`)

---

## Crash Lab

| Field | Value |
|--------|--------|
| **ID** | `crash` |
| **Category** | Crash |
| **Difficulty** | Beginner |
| **Broken mode** | Yes |
| **Fixed mode** | Yes |

### Summary

Practice exception breakpoints and stack navigation using a malformed local JSON import.

### Learning goals

- Add and use an exception breakpoint
- Inspect the crashing frame and its callers
- Identify the unsafe assumption in parsing

### Reproduction

1. On this screen, select Broken mode (tap Reset if you want the default lab state).
2. Tap Run scenario to import `crash_import_sample.json` (bundled with the app).
3. The second row omits `count`; the unsafe parser stops the process—debug with an exception breakpoint.
4. Switch to Fixed mode and tap Run scenario again to see validation skip the bad row.

### Hints

- The crash line is not always the full story—look at caller frames.
- The broken path assumes every dictionary contains an integer `count`.

### Suggested tools

- Xcode exception breakpoint
- Debug navigator stack frames
- Variables view / lldb locals
- Long-form write-up: `Docs/CrashLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Xcode Exception Breakpoint

**Steps**

1. In the Breakpoint navigator, add an Exception Breakpoint (Swift and Objective-C exceptions).
2. Build and run from Xcode, navigate to this Crash Lab screen, keep Broken mode, then tap Run scenario.
3. When execution stops, inspect the top frame: note the force cast or unwrap on the JSON dictionary.
4. Open the debug navigator and walk to the caller that feeds rows into the parser.
5. Switch to Fixed mode and tap Run scenario again: confirm the malformed row is skipped with a clear message.

**Validate**

- You can name the incorrect assumption in the parser.
- You can explain why Fixed mode avoids the trap and still imports valid rows.

---

## Breakpoint Lab

| Field | Value |
|--------|--------|
| **ID** | `breakpoint` |
| **Category** | Breakpoint |
| **Difficulty** | Beginner |
| **Broken mode** | Yes |
| **Fixed mode** | Yes |

### Summary

Use line, conditional, and action breakpoints to chase a non-crashing filter bug.

### Learning goals

- Inspect incorrect state with breakpoints
- Reduce noise using conditions
- Log values without stopping every time

### Reproduction

1. On this screen, keep Broken mode (tap Reset if you want the default lab state).
2. Choose Electronics in Category, type Swift in Search, then tap Run scenario.
3. Broken mode lists every electronics row because the name query is skipped once a category is set.
4. Switch to Fixed mode with the same inputs and tap Run scenario again—no rows should match.
5. Set a breakpoint in `BreakpointLabFilter.applyCatalogFilter` to inspect predicates.

### Hints

- All filtering runs through `BreakpointLabFilter.applyCatalogFilter(items:normalizedQuery:category:mode:)`.
- A conditional breakpoint on `selectedCategory != nil` reduces noise.

### Suggested tools

- Line breakpoints
- Conditional breakpoints
- Log/action breakpoints
- Long-form write-up: `Docs/BreakpointLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Line breakpoint on `BreakpointLabFilter.applyCatalogFilter`

**Steps**

1. Reproduce: category Electronics + query Swift + Run in Broken mode (several results).
2. Add a line breakpoint at the start of `applyCatalogFilter`; inspect `normalizedQuery` and `category`.
3. Step through Broken vs Fixed branches and note which predicate is dropped.
4. Optional: convert to a conditional breakpoint so you only stop when a category is active.
5. Switch to Fixed mode and confirm both category and name constraints apply.

**Validate**

- You can name the branch that ignores the search text in Broken mode.
- You can explain how Fixed mode combines category and name filters.

---

## Retain Cycle Lab

| Field | Value |
|--------|--------|
| **ID** | `retain_cycle` |
| **Category** | Memory |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes |
| **Fixed mode** | Yes |

### Summary

Explore object lifetime with a detail sheet whose timer keeps it alive in Broken mode.

### Learning goals

- Reproduce a leak through repeated navigation
- Use Memory Graph to inspect ownership
- Confirm deallocation after the fix

### Reproduction

1. On this screen, stay in Broken mode (tap Reset if you want the default lab state).
2. Tap Run scenario to open the detail sheet, then Close. Repeat two or three times.
3. Watch Live detail sessions climb—it should not return to zero until you restart the app.
4. Switch to Fixed mode, tap Run scenario, then Close once; the live counter should drop after the sheet dismisses.
5. Use Memory Graph to inspect retaining paths for `RetainCycleLabDetailHeart` in Broken mode.

### Hints

- Follow the chain: RunLoop → Timer → closure → `RetainCycleLabDetailHeart`.
- Fixed mode calls `stopTimerForTeardown()` when the sheet disappears.

### Suggested tools

- Xcode Memory Graph
- Instruments Leaks
- Long-form write-up: `Docs/RetainCycleLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Xcode Memory Graph after repeated open/close

**Steps**

1. In Broken mode, open and dismiss the detail sheet several times without killing the app.
2. Open Memory Graph; search for `RetainCycleLabDetailHeart` or your detail type and note multiple live instances.
3. Expand retaining paths: expect Timer / RunLoop / block to appear in the broken configuration.
4. Switch to Fixed mode: open and close once; confirm the live-session counter decreases.
5. Capture Memory Graph again and compare instance counts.

**Validate**

- You can explain why the timer keeps the detail object alive in Broken mode.
- You can explain what Fixed mode does so the object can deallocate.

---

## Hang Lab

| Field | Value |
|--------|--------|
| **ID** | `hang` |
| **Category** | Hang |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes |
| **Fixed mode** | Yes |

### Summary

See a main-thread freeze from heavy work, then compare with an off-main fix.

### Learning goals

- Recognize a visible hang
- Pause during a freeze and inspect threads
- Identify work that must leave the main thread

### Reproduction

1. On this screen, use Broken mode (tap Reset if you want the default lab state).
2. Tap Run scenario, then immediately try to scroll the horizontal “Scroll probe” chips—they should stay frozen until processing finishes.
3. Switch to Fixed mode, tap Run scenario again, and scroll during processing—the chips should remain draggable.
4. Optional: pause the debugger during the Broken freeze and inspect the main thread stack for `HangLabWorkload.simulateReportProcessing`.

### Hints

- Broken mode calls `HangLabWorkload.simulateReportProcessing` directly on the main actor.
- Fixed mode awaits `Task.detached { … }` before updating UI.

### Suggested tools

- Pause in the debugger
- Debug navigator threads
- Instruments Time Profiler (supporting)
- Long-form write-up: `Docs/HangLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Debugger pause while scrolling fails in Broken mode

**Steps**

1. In Broken mode, tap Run and attempt to scroll the probe row during the stall.
2. Pause the debugger; open the main thread stack and locate `simulateReportProcessing` or `HangLabWorkload`.
3. Note that the same function runs in Fixed mode but from a detached task (off the main queue).
4. Resume and compare how quickly the UI accepts gestures after each mode.

**Validate**

- You can name the synchronous work running on the main thread in Broken mode.
- You can explain how Fixed mode moves CPU work off the main actor.

---

## CPU Hotspot Lab

| Field | Value |
|--------|--------|
| **ID** | `cpu_hotspot` |
| **Category** | Performance |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes |
| **Fixed mode** | Yes |

### Summary

Profile sluggish search to find repeated expensive work and unnecessary sorting.

> **Status:** Interactive UI for this lab is still largely a stub in the app; the steps below describe the intended exercise once the searchable list ships.

### Learning goals

- Profile an interaction with Time Profiler
- Identify hottest functions in the trace
- Separate app hotspots from framework noise

### Reproduction

1. On this screen, use the searchable list once it ships in a later milestone.
2. Type or search to trigger Broken-mode slowness.
3. Profile the same interaction after switching to Fixed mode.

### Hints

- Look for repeated allocation or sorting on each keystroke.
- Focus on your code before chasing system libraries.

### Suggested tools

- Instruments Time Profiler

### Investigation guide

**Start with:** Instruments Time Profiler

**Steps**

1. Record a trace while reproducing the sluggish interaction.
2. Sort by self time and locate your scenario’s hot functions.
3. Relate hotspots to redundant work called from the search path.
4. Re-profile Fixed mode to confirm improvement.

**Validate**

- You can name the primary redundant work in Broken mode.
- You can see a leaner hot path in Fixed mode.
