# SignalLab — Labs reference

Keep this document open in your editor while you work. When the app stops under the debugger (for example in **Crash Lab**), you cannot scroll the in-app **Reproduction** or **Investigation guide** sections—everything below duplicates that content.

**Source of truth (from repository root):** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift`  
When you change catalog copy or add a lab, update this file in the same commit.

**Xcode UI and Instruments terminology:** see [`Docs/XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (debug navigator, stack frames, Variables, Instruments templates, schemes). Read the sections linked from each lab’s **Xcode primer** before your first run.

**Long-form guides:** see `Docs/XcodeToolingCheatSheet.md` (shared terminology), then `Docs/CrashLabInvestigationGuide.md`, `Docs/ExceptionBreakpointLabInvestigationGuide.md`, `Docs/BreakpointLabInvestigationGuide.md`, `Docs/RetainCycleLabInvestigationGuide.md`, `Docs/HangLabInvestigationGuide.md`, `Docs/CPUHotspotLabInvestigationGuide.md`, `Docs/ThreadPerformanceCheckerLabInvestigationGuide.md`, `Docs/ZombieObjectsLabInvestigationGuide.md`, `Docs/ThreadSanitizerLabInvestigationGuide.md`, `Docs/MallocStackLoggingLabInvestigationGuide.md`, `Docs/HeapGrowthLabInvestigationGuide.md`, `Docs/DeadlockLabInvestigationGuide.md`, `Docs/BackgroundThreadUILabInvestigationGuide.md`, `Docs/MainThreadIOLabInvestigationGuide.md`, `Docs/ScrollHitchLabInvestigationGuide.md`, `Docs/StartupSignpostLabInvestigationGuide.md`, `Docs/ConcurrencyIsolationLabInvestigationGuide.md`.

---

## How to use this reference

1. Skim the **Xcode primer** under each lab — it points to the right section of [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) for that lab’s tools.
2. Follow **Reproduction** with SignalLab running from Xcode when the lab needs the debugger, Instruments, or scheme diagnostics.
3. Use the matching **Investigation guide** in the repo when you cannot scroll the in-app text.

---

## Table of contents

1. [Crash Lab](#crash-lab) (`crash`)
2. [Exception Breakpoint Lab](#exception-breakpoint-lab) (`break_on_failure`)
3. [Breakpoint Lab](#breakpoint-lab) (`breakpoint`)
4. [Retain Cycle Lab](#retain-cycle-lab) (`retain_cycle`)
5. [Hang Lab](#hang-lab) (`hang`)
6. [CPU Hotspot Lab](#cpu-hotspot-lab) (`cpu_hotspot`)
7. [Thread Performance Checker Lab](#thread-performance-checker-lab) (`thread_performance_checker`) — post-MVP scheme diagnostic
8. [Zombie Objects Lab](#zombie-objects-lab) (`zombie_objects`) — post-MVP scheme diagnostic
9. [Thread Sanitizer Lab](#thread-sanitizer-lab) (`thread_sanitizer`) — post-MVP scheme diagnostic
10. [Malloc Stack Logging Lab](#malloc-stack-logging-lab) (`malloc_stack_logging`) — post-MVP scheme diagnostic
11. [Heap Growth Lab](#heap-growth-lab) (`heap_growth`) — Phase 2
12. [Deadlock Lab](#deadlock-lab) (`deadlock`) — Phase 2
13. [Background Thread UI Lab](#background-thread-ui-lab) (`background_thread_ui`) — Phase 2
14. [Main Thread I/O Lab](#main-thread-io-lab) (`main_thread_io`) — Phase 2
15. [Scroll Hitch Lab](#scroll-hitch-lab) (`scroll_hitch`) — Phase 2
16. [Startup Signpost Lab](#startup-signpost-lab) (`startup_signpost`) — Phase 2
17. [Concurrency Isolation Lab](#concurrency-isolation-lab) (`concurrency_isolation`) — Phase 2

---

## Crash Lab

| Field | Value |
|--------|--------|
| **ID** | `crash` |
| **Category** | Crash |
| **Difficulty** | Beginner |
| **Broken mode** | Yes |
| **Fixed mode** | No |

### Summary

Your first crash. A JSON import terminates the app because `count` arrived as the text `"three"` instead of an integer. Learn the three things Xcode shows when an app crashes, then use one caller-frame jump to reveal the payload that caused it.

### Learning goals

- Recognize the three things Xcode shows when an app crashes: highlighted line, console message, and call stack
- Use the console crash message to name the bad field and wrong type before reading more code
- Move up one useful caller frame and find readable locals like `brokenCountText` and `brokenJSONText`

### Xcode primer

Read [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode) and [**Call stack (concept)**](XcodeToolingCheatSheet.md#call-stack-concept) in `XcodeToolingCheatSheet.md`. You will use the **source editor** (highlighted line), the **console** (crash message), and the **debug navigator** call stack.

### Reproduction

1. Run SignalLab from Xcode (⌘R) so the debugger attaches.
2. Tap Run scenario.
3. The app crashes. Xcode stops and shows three things — read each one before doing anything else:
4. **① Highlighted line** — the source editor highlights the line where execution stopped. This is the strict decode call inside `CrashImportParser` that assumed the JSON was safe.
5. **② Console message** — at the bottom of Xcode, find the text that says "Expected to decode Int but found a string instead." That sentence explains the entire crash.
6. **③ Call stack** — on the left, click the `CrashImportParser` frame even if Xcode truncates the name. Then move up one caller frame to `runBrokenImport()` and inspect the locals.
7. In Variables, look for `brokenCountText` and `brokenJSONText` in that caller frame. Confirm `brokenCountText` is `"three"` and `brokenJSONText` shows the malformed row.

### Hints

- Start with the console message — it usually explains the crash in plain English before you read a single line of code.
- The `CrashImportParser` frame may look truncated in Xcode; it is still your code and still the right first frame to click.
- Going up one caller frame is useful here because `runBrokenImport()` exposes readable locals: `brokenCountText` and `brokenJSONText`.
- Crash Lab is intentionally broken-only. The goal is to learn what Xcode shows you after a crash, not to compare implementations yet.

### Suggested tools

- Console output — read the crash message first
- Source editor — the highlighted line shows where execution stopped
- Call stack — click `CrashImportParser`, then move up one caller frame to inspect `brokenCountText` and `brokenJSONText`
- Long-form write-up: `Docs/CrashLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Console message — read it first, then use one caller-frame jump to reveal `brokenCountText` and `brokenJSONText`

**Steps**

1. Run from Xcode, open Crash Lab, tap Run scenario.
2. Read the highlighted line in the source editor — this is where the strict decode failed.
3. Read the console message. Find "Expected to decode Int but found a string instead." — the runtime is describing the bug.
4. In the call stack, click the `CrashImportParser` frame even if the name is visually truncated in Xcode.
5. Move up one caller frame to `runBrokenImport()` and inspect `brokenCountText` and `brokenJSONText` in Variables; confirm the second row shows `"count": "three"`.

**Validate**

- You can name the three things Xcode shows when an app crashes.
- You can quote the console message that described the type mismatch.
- You can point to `brokenCountText` or `brokenJSONText` in the caller frame and show the broken value `"three"`.
- You can explain why moving up one caller frame was useful in this crash.

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

### Xcode primer

You need [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode) (same stack/Variables ideas as Crash Lab) plus [**Breakpoints**](XcodeToolingCheatSheet.md#breakpoints) for the **Breakpoint navigator** and **Exception Breakpoint**.

### Reproduction

1. On this screen, read the comparison steps, then use Crash Lab’s Broken JSON import in Xcode for both passes below.
2. Pass 1: Reproduce that failure with no added breakpoint and note where Xcode stops by default (see **debug navigator** + **Variables**).
3. Pass 2: In the **Breakpoint navigator**, add an **Exception Breakpoint**, then run the same failure again.
4. Compare which **stack frame** is selected first and what locals you see sooner or more consistently.

### Hints

- This lab is about debugger stop policy, not line breakpoints for a logic bug.
- Use the same failure family as Crash Lab so the comparison stays focused on when Xcode stops.
- If the app is still running and the result is wrong, that is Breakpoint Lab instead of this lab.
- Swift often traps with a clear faulting line; the Exception Breakpoint still helps when you want a consistent stop across failures or earlier context—compare and decide for this crash.

### Suggested tools

- Breakpoint navigator
- Xcode Exception Breakpoint
- Crash Lab for the default workflow baseline
- Long-form write-up: `Docs/ExceptionBreakpointLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Xcode Exception Breakpoint compared against the default stop

**Steps**

1. Run the failure once without adding a breakpoint so you can see Xcode's default stop behavior (stack + Variables).
2. Add an **Exception Breakpoint** from the **Breakpoint navigator** (see cheat sheet).
3. Run the same failure again and compare which frame is selected and what appears in **Variables**.
4. Note whether the exception breakpoint gives you earlier or clearer context than the default stop.

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

### Xcode primer

Read [**Breakpoints**](XcodeToolingCheatSheet.md#breakpoints) and [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode). You will set a **line breakpoint** in the gutter, use **Continue** / **Step Over** / **Step Into** from the **debug bar**, and read **Variables** while paused.

### Reproduction

1. Keep Broken mode selected, choose Electronics in Category, type Swift in Search, then tap Run scenario.
2. Broken mode should list every electronics row even though none of the names contain Swift.
3. In Xcode, add one plain **line breakpoint** on `BreakpointLabFilter.applyCatalogFilter(...)`, then run the same inputs again.
4. When execution stops, inspect `normalizedQuery`, `category`, and `mode` in **Variables**, then **step** into the Broken branch to see which predicate is skipped.
5. Switch to Fixed mode with the same inputs and run again; no rows should match.

### Hints

- All filtering runs through `BreakpointLabFilter.applyCatalogFilter(items:normalizedQuery:category:mode:)`.
- Start with a plain line breakpoint first; add a condition only after you know where the bad branch lives.
- This lab is about wrong logic while the app keeps running, not crash-stop policy or performance profiling.
- Comparing default crash stop vs Exception Breakpoint belongs in Exception Breakpoint Lab after Crash Lab—not here.

### Suggested tools

- Line breakpoints
- Conditional breakpoints
- Log/action breakpoints
- Long-form write-up: `Docs/BreakpointLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Line breakpoint on `BreakpointLabFilter.applyCatalogFilter`

**Steps**

1. Reproduce: category Electronics + query Swift + Run in Broken mode so you can see the wrong result first.
2. Add a **line breakpoint** at the start of `applyCatalogFilter`; inspect `normalizedQuery`, `category`, and `mode` in **Variables**.
3. **Step** into the Broken path and note exactly where the query predicate is dropped.
4. Optional: edit the same breakpoint to add a **condition** or **log** once you understand the path.
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

### Xcode primer

Read [**Memory Graph**](XcodeToolingCheatSheet.md#memory-graph-xcode) in the cheat sheet. You will search for a type and follow **retaining paths** in the graph UI.

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

### Xcode primer

Read [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode) — especially **Pause**, **threads** in the **debug navigator**, and the **main thread** stack vs background threads.

### Reproduction

1. On this screen, use Broken mode (tap Reset if you want the default lab state).
2. Tap Run scenario, then immediately try to scroll the horizontal “Scroll probe” chips—they should stay frozen until processing finishes.
3. Switch to Fixed mode, tap Run scenario again, and scroll during processing—the chips should remain draggable.
4. Optional: click **Pause** in the debug bar during the Broken freeze, select the **main thread** in the **debug navigator**, and read the **stack** for `HangLabWorkload.simulateReportProcessing`.

### Hints

- Broken mode calls `HangLabWorkload.simulateReportProcessing` directly on the main actor.
- Fixed mode awaits `Task.detached { … }` before updating UI.
- If interaction is merely slow but still responsive, that is CPU Hotspot Lab rather than Hang Lab.
- If live-instance counts keep rising after you dismiss a screen but scrolling still works, that is Retain Cycle Lab—not a main-thread hang.

### Suggested tools

- Pause in the debugger
- Debug navigator threads
- Instruments Time Profiler (supporting)
- Long-form write-up: `Docs/HangLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Debugger pause while scrolling fails in Broken mode

**Steps**

1. In Broken mode, tap Run and attempt to scroll the probe row during the stall.
2. **Pause** the debugger; in the **debug navigator**, select the **main thread** and scan its **stack frames** for `simulateReportProcessing` or `HangLabWorkload`.
3. Note that the same function runs in Fixed mode but from a detached task (off the main queue).
4. **Continue** and compare how quickly the UI accepts gestures after each mode.

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

Search 500 diagnostic events and profile the sluggish keystrokes in Broken mode with Instruments Time Profiler.

### Learning goals

- Profile a slow-but-responsive interaction with Time Profiler
- Identify the hottest functions in the trace by self time
- Separate app hotspots (sort, DateFormatter, lowercased) from framework noise

### Xcode primer

Read [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app) — **Time Profiler** template, **record**, **trace**, and **Self time**.

### Reproduction

1. In Broken mode, type a short query such as `memory` or `cpu` in the search field and notice the lag per keystroke.
2. Switch to Fixed mode and type the same query — the list should update noticeably faster.
3. To profile: **Product → Profile** (⌘I), choose **Time Profiler**, **record** while typing in Broken mode, then sort the call tree by **Self time** and look for `applyBroken`, `sorted`, and `DateFormatter.init`.
4. Re-profile in Fixed mode to confirm the hot path is gone.

### Hints

- Broken mode has three compounding problems per keystroke: a full sort of 500 items, one DateFormatter allocation per item, and `lowercased()` called per item per search.
- Sort the trace by Self Time and look for your own code before chasing system libraries.
- If the UI fully freezes and gestures stop working, that is Hang Lab — CPU Hotspot Lab stays responsive but feels sluggish.
- `DateFormatter` is a heavyweight Objective-C object; creating one inside a tight loop is a classic iOS performance mistake.

### Suggested tools

- Instruments Time Profiler
- Long-form write-up: `Docs/CPUHotspotLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Instruments Time Profiler — record while typing in the search field

**Steps**

1. In Broken mode, type a query and confirm the UI is sluggish but still responds to gestures.
2. **Profile** with **Instruments → Time Profiler**; **record** while typing the same query several times.
3. Sort by **Self time** and locate `CPUHotspotLabSearch.applyBroken` or the `sorted` and `DateFormatter.init` symbols.
4. Identify all three hotspots: repeated sort, DateFormatter per item, and per-call `lowercased()`.
5. Switch to Fixed mode, re-profile the same interaction, and confirm the hot path is eliminated.

**Validate**

- You’re done when you can name all three redundant operations in Broken mode and explain why the interaction is slow but not frozen.
- You can point to at least one hot frame in your code in the Broken trace.
- You can explain what Fixed mode pre-computes to remove each hotspot.

---

## Thread Performance Checker Lab

| Field | Value |
|--------|--------|
| **ID** | `thread_performance_checker` |
| **Category** | Hang |
| **Difficulty** | Intermediate |
| **Broken mode** | No (Xcode-only exercise) |
| **Fixed mode** | No |

### Summary

After Hang Lab’s pause-and-inspect proof, enable Xcode’s Thread Performance Checker to surface main-thread misuse as a runtime warning.

### Learning goals

- Enable Thread Performance Checker from the Xcode scheme
- Connect a runtime diagnostic to the same main-thread story as Hang Lab
- Explain what the checker adds beyond pausing the debugger manually

### Xcode primer

Read [**Run scheme and diagnostics**](XcodeToolingCheatSheet.md#run-scheme-and-diagnostics) and [**Console and Issue navigator**](XcodeToolingCheatSheet.md#console-and-issue-navigator). You enable a scheme checkbox, then read warnings in the **Issue navigator** or **debug console**.

### Reproduction

1. Skim Hang Lab first: Broken mode blocks the scroll probes while heavy work runs synchronously on the main actor.
2. In Xcode: **Product → Scheme → Edit Scheme → Run → Diagnostics**, then enable **Thread Performance Checker** (exact label may vary slightly by Xcode version).
3. Build and run SignalLab from Xcode, open Hang Lab, choose Broken mode, tap Run scenario, and try scrolling during the stall.
4. Watch Xcode’s Issue navigator or the runtime console for a Thread Performance Checker warning tied to main-queue work.
5. Compare with Fixed mode (or CPU Hotspot Lab’s sluggish-but-responsive symptom) so you do not confuse checker warnings with Time Profiler hotspots.

### Hints

- This lab is scheme diagnostics, not Hang Lab’s pause-and-read-stack workflow—use both together.
- If the UI is merely sluggish but still scrolls, profile with CPU Hotspot Lab instead of expecting a checker storm.
- If objects stay alive after dismissal, that is Retain Cycle Lab—checker warnings are about thread misuse, not lifetime.

### Suggested tools

- Xcode scheme → Run → Diagnostics → Thread Performance Checker
- Hang Lab (Broken vs Fixed) for the same workload shape
- Long-form write-up: `Docs/ThreadPerformanceCheckerLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Xcode scheme: enable Thread Performance Checker, then rerun from Xcode

**Steps**

1. Confirm you can reproduce Hang Lab’s Broken-mode freeze so you have a concrete main-thread story in mind.
2. Enable Thread Performance Checker in the Run scheme diagnostics and relaunch the app from Xcode.
3. Trigger the same Broken-mode hang and read the warning Xcode surfaces—note the symbol or queue it cites.
4. Contrast that evidence with what you learned from pausing during the freeze in Hang Lab.
5. Optional: switch Hang Lab to Fixed mode and confirm the warning no longer appears for the same gesture path.

**Validate**

- You’re done when you can describe one Thread Performance Checker warning you saw and how it supports a main-thread diagnosis.
- You can explain what this adds compared with only pausing the debugger during a freeze.

---

## Zombie Objects Lab

| Field | Value |
|--------|--------|
| **ID** | `zombie_objects` |
| **Category** | Memory |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes — Objective-C use-after-release after autorelease pool drain |
| **Fixed mode** | Yes — messaging only while the object is alive in-pool |

### Summary

Turn an ambiguous memory crash into a clear “message sent to zombie / deallocated instance” diagnosis using Xcode’s Zombie Objects diagnostic.

### Learning goals

- Enable Zombie Objects from the Run scheme diagnostics
- Contrast an unclear crash with the sharper message Zombies provide
- Separate use-after-free style bugs from retain cycles (objects that stay alive too long)

### Xcode primer

Read [**Run scheme and diagnostics**](XcodeToolingCheatSheet.md#run-scheme-and-diagnostics) and [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode). Zombies change how the **debugger** presents a crash; compare console / **Variables** with Zombies on vs off.

### Reproduction

1. Read Retain Cycle Lab’s contrast: there the object stays alive; Zombies target the opposite—something was freed and messaged too late.
2. In Xcode: **Product → Scheme → Edit Scheme → Run → Diagnostics** → enable **Zombie Objects** (label may vary slightly by Xcode version).
3. Open this lab, choose **Broken**, tap **Run scenario** from Xcode—Objective-C messages a deallocated object (`__unsafe_unretained` after the pool drains).
4. Run again with Zombies off to feel the vaguer failure, then enable Zombies and compare the diagnostic text.
5. Switch to **Fixed** and run once: messaging stays inside the autorelease pool—no dangling reference.

### Hints

- Retain Cycle Lab: live-instance counts climb—Zombies: the crash says you messaged memory that was already released.
- Zombies trade memory for clarity; turn them off when you are done investigating.
- Do not confuse this with Hang Lab or Thread Sanitizer—those are responsiveness and concurrent access, not deallocation timing.

### Suggested tools

- Xcode scheme → Run → Diagnostics → Zombie Objects
- Retain Cycle Lab (contrast: retention vs zombie)
- Long-form write-up: `Docs/ZombieObjectsLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Xcode scheme: enable Zombie Objects, then run this lab’s Broken mode from Xcode

**Steps**

1. Without Zombies, run Broken once and note how vague the stop feels (symbol-only or generic `EXC_BAD_ACCESS`).
2. Enable Zombie Objects, relaunch, run Broken again, and read the clearer zombie / deallocated wording.
3. Identify which type or instance the runtime names as zombie or deallocated.
4. Run **Fixed** to confirm the safe path avoids messaging after release.
5. Disable Zombies after you have a fix hypothesis to avoid unnecessary overhead.

**Validate**

- You’re done when you can quote how the crash message changed with Zombies on and what object it implicates.
- You can state one way the symptom differs from Retain Cycle Lab’s “still alive” story.

---

## Thread Sanitizer Lab

| Field | Value |
|--------|--------|
| **ID** | `thread_sanitizer` |
| **Category** | Hang |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes — shared counter: main + detached task, no lock |
| **Fixed mode** | Yes — same counter serialized with one `NSLock` |

### Summary

Use Xcode’s Thread Sanitizer to prove unsafe concurrent access to shared mutable state—not just surprising async order.

### Learning goals

- Enable Thread Sanitizer from the Run scheme diagnostics
- Tell a data race apart from a wrong-branch logic bug or a main-thread freeze
- Map a sanitizer report back to the shared state that needs serialization

### Xcode primer

Read [**Run scheme and diagnostics**](XcodeToolingCheatSheet.md#run-scheme-and-diagnostics). Thread Sanitizer stops the app and opens a **report** listing threads, addresses, and **stack frames** — use the same mental model as [**Debugger UI → Frame**](XcodeToolingCheatSheet.md#debugger-ui-xcode).

### Reproduction

1. Finish Breakpoint Lab mental model: wrong logic while the app runs is not the same as two threads mutating the same property unsafely.
2. In Xcode: **Product → Scheme → Edit Scheme → Run → Diagnostics** → enable **Thread Sanitizer** (exact checkbox label may vary).
3. Open this lab, **Broken**, **Run scenario**—main thread and a detached task increment one shared counter without a lock.
4. Read the sanitizer report: which address or variable, which two threads, and which **stack** / frames implicate your code.
5. Switch to **Fixed** (same counter, one `NSLock`, both sides wait) and rerun with TSan until that path is clean.

### Hints

- Hang Lab is synchronous main-thread starvation; TSan is concurrent unsynchronized writes/reads to the same memory.
- If results are wrong but a single thread owns the state, use Breakpoint Lab—not this lab.
- TSan slows the app; use it when you suspect a race, not for every performance pass.

### Suggested tools

- Xcode scheme → Run → Diagnostics → Thread Sanitizer
- Hang Lab and CPU Hotspot Lab (contrast: freeze / cost vs race)
- Long-form write-up: `Docs/ThreadSanitizerLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Xcode scheme: enable Thread Sanitizer, then run this lab’s Broken mode from Xcode

**Steps**

1. Enable Thread Sanitizer and run **Broken** until Xcode stops with a race report on the shared counter.
2. Extract: conflicting threads, shared variable, and call sites from the report.
3. Run **Fixed** and confirm the merged counter reaches the expected total with no TSan issue for this path.
4. Contrast with an async ordering bug (completion A before B) where TSan stays quiet.
5. Apply the same serialization idea to your own shared state when you leave the lab.

**Validate**

- You’re done when you can name the shared state TSan flagged and why two threads conflicted.
- You can explain why Breakpoint Lab or Hang Lab would be the wrong first tool for that symptom.

---

## Malloc Stack Logging Lab

| Field | Value |
|--------|--------|
| **ID** | `malloc_stack_logging` |
| **Category** | Memory |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes — thousands of fresh row arrays every run |
| **Fixed mode** | Yes — warm reusable buffer; steady-state avoids row-array burst |

### Summary

When you need “where was this allocated?” not just “what is alive now,” enable Malloc Stack Logging and read allocation backtraces.

### Learning goals

- Enable Malloc Stack Logging (or equivalent scheme memory diagnostics) for a suspicious allocation
- Recover stack traces that show which code path created an object or buffer
- Place this tool after Zombies and Retain Cycle—you are doing provenance, not first-pass leaks

### Xcode primer

Read [**Run scheme and diagnostics**](XcodeToolingCheatSheet.md#run-scheme-and-diagnostics) and [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app) (**Allocations**). You are correlating **allocation backtraces** (which code path created bytes) with the scheme diagnostic.

### Reproduction

1. Confirm you already know Memory Graph / leaks basics from Retain Cycle Lab and when Zombies help from Zombie Objects Lab.
2. In Xcode: **Product → Scheme → Edit Scheme → Run → Diagnostics** → enable **Malloc Stack Logging** (options may include “Malloc Stack” or similar by version).
3. Run **Broken** here—each tap allocates thousands of fresh row arrays; use **Instruments → Allocations** (or your guide’s lldb path) to see the allocating **stacks**.
4. Run **Fixed** twice: first run warms a reusable buffer; second run should show `0` fresh row arrays in the footer.
5. Turn logging off when finished—this diagnostic is heavy on overhead and disk.

### Hints

- This is forensic: use when “who created this?” matters, not as a default leak sweep.
- Zombies answer “you messaged the dead”; malloc stacks answer “who birthed this bytes”.
- Retain Cycle Lab shows who still holds live references—different question from creation-site history.

### Suggested tools

- Xcode scheme → Run → Diagnostics → Malloc Stack Logging
- Instruments Allocations / lldb malloc_history (as appropriate to your Xcode version)
- Long-form write-up: `Docs/MallocStackLoggingLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Xcode scheme: enable Malloc Stack Logging, then run Broken once under Instruments or lldb

**Steps**

1. Enable malloc stack recording per scheme instructions and rerun from Xcode.
2. Run **Broken** once and capture stacks for the row-array allocation hot path in this module.
3. Run **Fixed** twice and note the second run’s `0` fresh row arrays—contrast with Broken’s burst.
4. Open the stack / history UI your toolchain provides and tie one frame to a concrete call site.
5. Disable the diagnostic and document the fix path (reuse, pooling, or fewer per-run allocations).

**Validate**

- You’re done when you can point to one allocation stack that explains where a suspicious object came from.
- You can explain why Memory Graph alone was not enough for that question.

---

## Heap Growth Lab

| Field | Value |
|--------|--------|
| **ID** | `heap_growth` |
| **Category** | Memory |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes — each run retains another 256 KB `Data` chunk (unbounded) |
| **Fixed mode** | Yes — ring buffer, at most six chunks |

### Summary

Tell climbing footprint and allocation churn apart from a retain cycle: Broken mode hoards large buffers; Fixed mode caps what stays live.

### Learning goals

- Contrast Memory Graph growth from unbounded caching with Retain Cycle Lab’s cyclic retention
- Use Instruments Allocations or memory gauges to see footprint rise without a cycle
- Apply a retention policy (cap, eviction, pool) once growth is confirmed

### Xcode primer

Read [**Memory Graph**](XcodeToolingCheatSheet.md#memory-graph-xcode) and [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app) (**Allocations**). Contrast **linear retention** (no purple cycle) with Retain Cycle Lab.

### Reproduction

1. Finish Retain Cycle Lab first so you know what a cycle looks like in Memory Graph.
2. Open Heap Growth Lab, **Broken**, tap **Run scenario** several times—each run retains another 256 KB chunk.
3. In **Xcode Memory Graph** or **Instruments → Allocations**, observe live bytes rising even though references are linear (no cycle).
4. Switch to **Fixed** and repeat: chunk count should stop at six; footprint should plateau.
5. Articulate when you would choose eviction vs fixing a cycle.

### Hints

- Retain Cycle Lab: objects keep each other alive—Heap Growth: you simply never release work buffers.
- Malloc Stack Logging Lab helps provenance; this lab is about **how much** stays live.
- If the UI is frozen but CPU is idle, consider Deadlock Lab instead of this one.

### Suggested tools

- Instruments > Allocations
- Xcode Memory Graph (compare with Retain Cycle Lab)
- Long-form write-up: `Docs/HeapGrowthLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Instruments > Allocations (or Memory Graph) while repeating Run scenario

**Steps**

1. Run **Broken** five times and capture a memory or allocations snapshot after the last run.
2. Note rising live bytes / chunk count without a purple cycle in Memory Graph.
3. Run **Fixed** five times and capture again—verify the cap (six chunks).
4. Write one sentence: why this is not Retain Cycle Lab.
5. Plan a real-world policy: max cache size, LRU, or periodic flush.

**Validate**

- You can explain why footprint grew in Broken mode without claiming a retain cycle.
- You can describe how Fixed mode enforces a bound and when that pattern applies in production.

---

## Deadlock Lab

| Field | Value |
|--------|--------|
| **ID** | `deadlock` |
| **Category** | Hang |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes — `DispatchQueue.main.sync` from the main thread (fatal wait) |
| **Fixed mode** | Yes — completes work inline without main-on-main sync |

### Summary

Reproduce a textbook main-thread deadlock with `DispatchQueue.main.sync` from the main thread, then contrast with safe main-actor work.

### Learning goals

- Recognize self-deadlock when a queue waits on itself
- Pause the debugger during a freeze and read thread wait states
- Separate deadlock (waiting) from Hang Lab’s busy main-thread CPU work

### Xcode primer

Read [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode) — **Pause** and **threads**. Compare **waiting** frames on the main thread with Hang Lab’s **busy** CPU frames.

### Reproduction

1. Launch SignalLab **from Xcode** with the debugger attached.
2. Open Deadlock Lab, select **Fixed**, tap **Run scenario** once—should complete immediately.
3. Read the warning, then select **Broken** and tap **Run scenario**—the UI should freeze permanently.
4. Click **Pause** in the debug bar: the **main thread** stack should show `dispatch_sync` / queue wait rather than heavy app compute.
5. Force-quit or stop the run, then stay on **Fixed** for normal exploration.

### Hints

- Hang Lab: main thread is **busy**—Deadlock Lab: main thread is **waiting** on itself.
- Never call `sync` onto a queue you are already executing on.
- Broken mode is intentionally destructive—do not use it in UI tests or screenshots that tap Run.

### Suggested tools

- Debug navigator thread stacks
- Pause / continue in Xcode
- Long-form write-up: `Docs/DeadlockLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Xcode debugger pause while the UI is frozen under Broken mode

**Steps**

1. Confirm **Fixed** runs complete—baseline that the button wiring works.
2. Switch to **Broken**, run once, then pause—the main thread should be stuck in sync machinery.
3. Contrast with Hang Lab: there you often see heavy frames on the main stack; here you see waiting.
4. In your own code, search for `sync` onto `.main` from contexts that might already be main.
5. Prefer `async`, structured concurrency, or inline work instead of main-on-main sync.

**Validate**

- You can state in one sentence why `main.sync` from main deadlocks.
- You can tell this symptom apart from Hang Lab’s CPU-bound freeze.

---

## Background Thread UI Lab

| Field | Value |
|--------|--------|
| **ID** | `background_thread_ui` |
| **Category** | Hang |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes — `NotificationCenter` post from `Task.detached` (no MainActor hop) |
| **Fixed mode** | Yes — post inside `MainActor.run` after detached hop |

### Summary

See why UI-facing callbacks should run on the main actor: Broken posts a notification from a detached task; Fixed posts after a MainActor hop.

### Learning goals

- Relate notification delivery threads to SwiftUI state updates
- Recognize Xcode warnings about publishing or updating UI off the main thread
- Prefer MainActor/async patterns when forwarding events to UI

### Xcode primer

Read [**Console and Issue navigator**](XcodeToolingCheatSheet.md#console-and-issue-navigator). Warnings may appear in the **debug console** or **Issue navigator** while the app runs.

### Reproduction

1. Open this lab and keep the **debug console** (debug area) visible.
2. Run **Fixed** once—note the last observed ping updates without threading complaints.
3. Run **Broken** once—watch for runtime diagnostics about background-thread updates.
4. Compare the runner’s status text: Fixed explicitly hops to MainActor before posting.
5. In your apps, audit `NotificationCenter`, callbacks, and delegates that mutate UI.

### Hints

- Hang Lab is CPU work on main; this lab is **which thread** delivers UI mutations.
- Combine/async sequences have similar rules—end on MainActor before touching `@State`.
- Deadlock Lab is about waiting; this lab is about crossing thread boundaries safely.

### Suggested tools

- Xcode console + runtime issues
- Main actor / Swift concurrency docs
- Long-form write-up: `Docs/BackgroundThreadUILabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Xcode console while toggling Broken vs Fixed

**Steps**

1. Run **Fixed** and confirm pings land cleanly.
2. Run **Broken** and capture any threading warning text verbatim.
3. Trace from `Task.detached` to `onReceive` in your mental model.
4. Refactor one real callback to `await MainActor.run` or `@MainActor` isolation.
5. Re-test until warnings disappear for that path.

**Validate**

- You can explain why posting from a detached task is risky for SwiftUI state.
- You can describe the fix pattern (main-queue / MainActor delivery) in one sentence.

---

## Main Thread I/O Lab

| Field | Value |
|--------|--------|
| **ID** | `main_thread_io` |
| **Category** | Hang |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes — ten synchronous `Data(contentsOf:)` reads on main (256 KB file) |
| **Fixed mode** | Yes — detached read, UI update on main when complete |

### Summary

Contrast repeated synchronous `Data(contentsOf:)` on the main thread with an off-main read—same bytes, different responsiveness story than Hang Lab’s pure CPU work.

### Learning goals

- Spot main-thread disk reads as responsiveness bugs
- Use scroll probes while Fixed mode loads asynchronously
- Choose async I/O or background queues before optimizing algorithms

### Xcode primer

Read [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app) (**Time Profiler**) and [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode) — **Pause** + **main thread** stack. You are distinguishing **I/O wait** from Hang Lab’s **CPU** work.

### Reproduction

1. Open Main Thread I/O Lab with **Fixed**, tap **Run scenario**, scroll the chips during the read—it should stay fluid.
2. Switch to **Broken**, tap **Run scenario**—the UI should hitch while ten synchronous reads complete.
3. **Product → Profile** → **Time Profiler**, or **Pause** the debugger in Broken mode and inspect the **main thread** stack: Broken shows file-read / I/O frames; Hang Lab shows compute-heavy frames.
4. Return to **Fixed** for day-to-day exploration.

### Hints

- Network on main is the same class of bug—this lab uses a local file to stay deterministic offline.
- CPU Hotspot Lab is about hot **compute**; this lab is about **waiting on storage**.
- If the app is deadlocked, use Deadlock Lab—not this one.

### Suggested tools

- Instruments > Time Profiler
- Main thread track / hang diagnostics in Xcode
- Long-form write-up: `Docs/MainThreadIOLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Interactive scroll during Fixed vs Broken runs

**Steps**

1. Baseline **Fixed**: run, scroll probes, confirm read completes.
2. Run **Broken** and feel the hitch; **Pause** and inspect the **main thread** stack for synchronous file read APIs.
3. Estimate how many synchronous reads your real feature does per gesture.
4. Move loads to `Task.detached`, `URLSession`, or async file APIs as appropriate.
5. Validate with the same Instruments pass you used for Broken.

**Validate**

- You can separate I/O wait from CPU burn on the main thread.
- You can point to the API you would change first in a production codebase.

---

## Scroll Hitch Lab

| Field | Value |
|--------|--------|
| **ID** | `scroll_hitch` |
| **Category** | Performance |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes — per-row `.compositingGroup()` + large shadow |
| **Fixed mode** | Yes — lighter shadow, no per-row compositing group |

### Summary

Auto-scroll a long list: Broken stacks compositing + heavy shadows per row; Fixed keeps scrolling smooth enough to profile frame pacing.

### Learning goals

- Relate scroll hitches to per-row rendering cost, not just CPU algorithms
- Use Instruments Core Animation or frame pacing views alongside Time Profiler
- Contrast this lab with CPU Hotspot Lab’s keystroke-bound hotspots

### Xcode primer

Read [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app). Use **Core Animation** or your Xcode’s scrolling / frame pacing template plus **Time Profiler** as needed — you care about **frame timing**, not only CPU self time.

### Reproduction

1. Open Scroll Hitch Lab and select **Fixed**, tap **Run scenario**, watch the vertical list auto-scroll.
2. While it scrolls, drag the horizontal “Probe” chips—they should stay reasonably responsive.
3. Switch to **Broken**, tap **Run scenario** again; the same auto-scroll should feel rougher and probes may stutter.
4. Profile with Instruments > Core Animation or the scrolling instrument your Xcode version provides; compare frame times.

### Hints

- Broken uses `.compositingGroup()` plus a large shadow on every row—each row becomes an expensive offscreen pass.
- CPU Hotspot Lab stays responsive but slow; this lab targets frame drops during scroll.
- Hang Lab is a full stop; here the scroll usually continues but unevenly.

### Suggested tools

- Instruments > Core Animation (or scrolling / frame pacing template for your Xcode version)
- Instruments > Time Profiler (supporting)
- Long-form write-up: `Docs/ScrollHitchLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Instruments while auto-scrolling the vertical list

**Steps**

1. Baseline **Fixed**: run once, note how the horizontal probes feel during auto-scroll.
2. Switch to **Broken**, run again, and capture a short Instruments trace covering the scroll.
3. Look for elevated frame time or compositing cost while rows with heavy shadows are on screen.
4. Compare the SwiftUI row chrome described in the runner vs Fixed’s lighter modifiers.
5. In your own lists, audit `.drawingGroup()`, `.compositingGroup()`, and stacked shadows inside `Lazy` stacks.

**Validate**

- You can explain one visual effect in Broken mode that makes scrolling more expensive.
- You can state how this symptom differs from CPU Hotspot Lab and Hang Lab.

---

## Startup Signpost Lab

| Field | Value |
|--------|--------|
| **ID** | `startup_signpost` |
| **Category** | Performance |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes — phased CPU on main, no `os_signpost` |
| **Fixed mode** | Yes — same phases with POI signposts |

### Summary

Simulate blocking launch phases on the main thread: Broken omits signposts; Fixed emits `os_signpost` intervals for Instruments Points of Interest.

### Learning goals

- Record `os_signpost` intervals in Instruments > Points of Interest
- Read cold/warm startup stories as named phases, not one anonymous main-thread blob
- Keep checksum parity between Broken and Fixed to prove the work is the same

### Xcode primer

Read [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app). Choose a template that shows **Points of Interest** / `os_signpost` lanes (name may vary by Xcode version).

### Reproduction

1. From Xcode, choose **Product → Profile** (⌘I) and pick **Points of Interest** (or a template that surfaces POI signposts).
2. Open Startup Signpost Lab, select **Fixed**, tap **Run scenario** while recording—expect three named intervals.
3. Switch to **Broken**, record again—the CPU time should be similar but POI lanes stay unstructured.
4. Compare checksums in the footer; both modes should report the same value for the same run number.

### Hints

- Signposts annotate work you already do—they are not a substitute for moving work off the main thread.
- Category `PointsOfInterest` on the `OSLog` is what makes intervals show up in the POI instrument.
- Malloc Stack Logging answers “who allocated this?”; signposts answer “what phase was running now?”

### Suggested tools

- Instruments > Points of Interest
- Instruments > Time Profiler
- Long-form write-up: `Docs/StartupSignpostLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Instruments > Points of Interest while running Fixed mode

**Steps**

1. Profile **Fixed** and tap **Run scenario** once per recording.
2. Identify `SignalLabStartupConfig`, `SignalLabStartupAssets`, and `SignalLabStartupReady` intervals.
3. Profile **Broken** with the same gesture and note the missing structured intervals.
4. Confirm matching checksums between modes for the same invocation count.
5. Add a named signpost around your own app’s heaviest launch closure before optimizing blindly.

**Validate**

- You can name the three signposted phases and what each represents in this lab.
- You can explain why checksums match even when signposts differ.

---

## Concurrency Isolation Lab

| Field | Value |
|--------|--------|
| **ID** | `concurrency_isolation` |
| **Category** | Hang |
| **Difficulty** | Intermediate |
| **Broken mode** | Yes — two `Task.detached` hops race logging order + non-Sendable capture |
| **Fixed mode** | Yes — sequential `async` steps on the main actor |

### Summary

Broken races two detached tasks that log completion order; Fixed runs the same labels sequentially—surface Xcode concurrency issues before Thread Sanitizer.

### Learning goals

- Separate flaky ordering from data races on shared memory
- Read Xcode’s Sendable and isolation warnings as a first-line tool
- Prefer structured `async`/`await` when completion order must be deterministic

### Xcode primer

Read [**Console and Issue navigator**](XcodeToolingCheatSheet.md#console-and-issue-navigator). **Issue navigator** (⌘5) lists analyzer and build issues; some Swift concurrency hints appear during build or as warnings alongside the **debug console**.

### Reproduction

1. Open Concurrency Isolation Lab, choose **Broken**, tap **Run scenario** and read the completion log.
2. Tap **Run scenario** again—`alpha` and `beta` may appear in a different order than the previous run.
3. Open the **Issue navigator** and the build log for **Sendable** / isolation warnings involving the lab’s non-Sendable token.
4. Switch to **Fixed**, run twice—the log should always read `alpha, beta`.
5. Contrast with Thread Sanitizer Lab: there two threads mutate one counter without a lock.

### Hints

- If the bug is “sometimes A runs before B,” structured concurrency is often the fix—not TSan.
- Thread Sanitizer Lab is for unsynchronized memory access; this lab is for task lifecycle and ordering.
- Background Thread UI Lab is about main-actor UI delivery; this lab is about how many detached tasks you launched.

### Suggested tools

- Xcode Issue navigator (Swift concurrency / Sendable)
- Swift Structured Concurrency documentation
- Long-form write-up: `Docs/ConcurrencyIsolationLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Start with:** Xcode Issue navigator + repeated Broken runs

**Steps**

1. Run **Broken** three times and screenshot or note the three completion-order strings.
2. Search warnings for capturing a non-Sendable type inside `Task.detached`.
3. Run **Fixed** and confirm deterministic `alpha` then `beta`.
4. Write one sentence: when you would still enable Thread Sanitizer after fixing ordering.
5. Refactor one real feature from double-`detached` fire-and-forget to a single `async` function.

**Validate**

- You can explain why completion order changed across Broken runs.
- You can state why Thread Sanitizer Lab is not the first tool for that symptom.
