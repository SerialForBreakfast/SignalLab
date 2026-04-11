# SignalLab — Labs reference

Keep this document open in your editor while you work. When the app stops under the debugger (for example in **Crash Lab**), you cannot scroll the in-app **Reproduction** or **Investigation guide** sections—everything below duplicates that content.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift`  
When you change catalog copy or add a lab, update this file in the same commit.

**Long-form guides:** see `Docs/CrashLabInvestigationGuide.md`, `Docs/ExceptionBreakpointLabInvestigationGuide.md`, `Docs/BreakpointLabInvestigationGuide.md`, `Docs/RetainCycleLabInvestigationGuide.md`, `Docs/HangLabInvestigationGuide.md`, `Docs/CPUHotspotLabInvestigationGuide.md`.

---

## Table of contents

1. [Crash Lab](#crash-lab) (`crash`)
2. [Exception Breakpoint Lab](#exception-breakpoint-lab) (`break_on_failure`)
3. [Breakpoint Lab](#breakpoint-lab) (`breakpoint`)
4. [Retain Cycle Lab](#retain-cycle-lab) (`retain_cycle`)
5. [Hang Lab](#hang-lab) (`hang`)
6. [CPU Hotspot Lab](#cpu-hotspot-lab) (`cpu_hotspot`)

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

Use Xcode's default stopped debugger state to explain a malformed local JSON import crash.

### Learning goals

- Find the first relevant frame in your code after a crash
- Inspect locals and caller context in the stopped debugger
- Identify the unsafe assumption in parsing

### Reproduction

1. Keep Broken mode selected, then tap Run scenario to import `crash_import_sample.json` (bundled with the app).
2. The second row omits `count`, so the app should stop in Xcode with the parser frame highlighted.
3. In the stopped debugger, inspect the current row in Variables and find the first relevant frame in your code.
4. Move one caller up to see who passed the malformed row into the parser.
5. Switch to Fixed mode and run again; valid rows should import while the malformed row is skipped safely.

### Hints

- The highlighted crash line matters, but caller frames explain how bad data reached it.
- The broken path assumes every dictionary contains an integer `count`.

### Suggested tools

- Debug navigator stack frames
- Variables view
- Caller frame navigation
- Long-form write-up: `Docs/CrashLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Default debugger stop: stack frames + Variables view

**Steps**

1. Run SignalLab from Xcode, open Crash Lab, keep Broken mode, and tap Run scenario.
2. When Xcode stops, look at the highlighted parser line and the current row in Variables.
3. In the debug navigator, find the first frame in your code rather than getting lost in system frames.
4. Select one caller frame above the parser to see how the malformed row reached this code path.
5. State the bad assumption in one sentence, then switch to Fixed mode and run again to confirm the malformed row is skipped.

**Validate**

- You’re done when you can explain which assumption about `count` caused the crash and point to the row that violates it.
- You can explain why Fixed mode avoids the trap and still imports valid rows.

---

## Exception Breakpoint Lab

| Field | Value |
|--------|--------|
| **ID** | `break_on_failure` |
| **Category** | Crash |
| **Difficulty** | Beginner |
| **Broken mode** | Yes |
| **Fixed mode** | No |

### Summary

After Crash Lab’s default stop, decide when Xcode’s Exception Breakpoint gives clearer or earlier context on the same failure family.

### Learning goals

- Compare the default crash stop with an exception breakpoint
- Recognize when changing stop policy gives clearer context
- Explain what the exception breakpoint adds beyond the stop you already had

### Reproduction

1. On this screen, read the comparison steps, then use Crash Lab’s Broken JSON import in Xcode for both passes below.
2. Pass 1: Reproduce that failure with no added breakpoint and note where Xcode stops by default.
3. Pass 2: Add an Exception Breakpoint in the Breakpoint navigator and run the same failure again.
4. Compare where each run stops and what context you get sooner or more consistently.

### Hints

- This lab is about debugger stop policy, not line breakpoints for a logic bug.
- Use the same failure family as Crash Lab so the comparison stays focused on when Xcode stops.
- If the app is still running and the result is wrong, that is Breakpoint Lab instead of this lab.

### Suggested tools

- Breakpoint navigator
- Xcode Exception Breakpoint
- Crash Lab for the default workflow baseline
- Long-form write-up: `Docs/ExceptionBreakpointLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Xcode Exception Breakpoint compared against the default stop

**Steps**

1. Run the failure once without adding a breakpoint so you can see Xcode's default stop behavior.
2. Add an Exception Breakpoint from the Breakpoint navigator.
3. Run the same failure again and compare where execution stops and what frames are visible.
4. Note whether the breakpoint gives you earlier or clearer context than the default stop.

**Validate**

- You’re done when you can explain what the exception breakpoint added over the default stop for this failure.

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

- Start with one line breakpoint at the shared decision point
- Inspect incorrect state and step through the bad branch
- Use conditional or log breakpoints only after the core stop is clear

### Reproduction

1. Keep Broken mode selected, choose Electronics in Category, type Swift in Search, then tap Run scenario.
2. Broken mode should list every electronics row even though none of the names contain Swift.
3. Add one plain line breakpoint in `BreakpointLabFilter.applyCatalogFilter(...)`, then run the same inputs again.
4. Inspect `normalizedQuery`, `category`, and `mode`, then step into the Broken branch to see which predicate is skipped.
5. Switch to Fixed mode with the same inputs and run again; no rows should match.

### Hints

- All filtering runs through `BreakpointLabFilter.applyCatalogFilter(items:normalizedQuery:category:mode:)`.
- Start with a plain line breakpoint first; add a condition only after you know where the bad branch lives.
- This lab is about wrong logic while the app keeps running, not crash-stop policy or performance profiling.

### Suggested tools

- Line breakpoints
- Conditional breakpoints
- Log/action breakpoints
- Long-form write-up: `Docs/BreakpointLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Line breakpoint on `BreakpointLabFilter.applyCatalogFilter`

**Steps**

1. Reproduce: category Electronics + query Swift + Run in Broken mode so you can see the wrong result first.
2. Add a line breakpoint at the start of `applyCatalogFilter`; inspect `normalizedQuery`, `category`, and `mode`.
3. Step into the Broken path and note exactly where the query predicate is dropped.
4. Optional: convert the same breakpoint to a conditional or log breakpoint once you understand the path.
5. Switch to Fixed mode and confirm both category and name constraints apply.

**Validate**

- You’re done when you can point to the branch that ignores the search text in Broken mode and explain why the result is wrong.
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
- A dismissed screen can still leak without freezing the UI; if the symptom is a freeze, move to Hang Lab instead.

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

- You’re done when you can identify the retaining path that keeps the dismissed detail alive in Broken mode.
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
- If interaction is merely slow but still responsive, that is CPU Hotspot Lab rather than Hang Lab.

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

- You’re done when you can point to the work blocking the main thread in Broken mode and explain why the UI freezes.
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
- If the UI fully freezes and gestures stop, that is Hang Lab rather than CPU Hotspot Lab.

### Suggested tools

- Instruments Time Profiler
- Long-form write-up: `Docs/CPUHotspotLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Instruments Time Profiler

**Steps**

1. Record a trace while reproducing the sluggish interaction.
2. Sort by self time and locate your scenario’s hot functions.
3. Relate hotspots to redundant work called from the search path.
4. Re-profile Fixed mode to confirm improvement.

**Validate**

- You’re done when you can name the primary redundant work in Broken mode and explain why the interaction feels slow rather than frozen.
- You can name the primary redundant work in Broken mode.
- You can see a leaner hot path in Fixed mode.
