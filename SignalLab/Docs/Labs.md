# SignalLab — Labs reference

Keep this document open in your editor while you work. When the app stops under the debugger, use the matching lab section here as the offline reference.

**Source of truth (from repository root):** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift`  
When you change catalog copy or add a lab, update this file in the same commit.

**Xcode UI and Instruments terminology:** see [`Docs/XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (debug navigator, stack frames, Variables, Instruments templates, schemes). Read the sections linked from each lab's **Xcode primer** before your first run.

**Long-form guides:** see `Docs/XcodeToolingCheatSheet.md` (shared terminology), then `Docs/CrashLabInvestigationGuide.md`, `Docs/ExceptionBreakpointLabInvestigationGuide.md`, `Docs/BreakpointLabInvestigationGuide.md`, `Docs/MemoryGraphLabInvestigationGuide.md`, `Docs/HangLabInvestigationGuide.md`, `Docs/CPUHotspotLabInvestigationGuide.md`, `Docs/ThreadPerformanceCheckerLabInvestigationGuide.md`, `Docs/ZombieObjectsLabInvestigationGuide.md`, `Docs/ThreadSanitizerLabInvestigationGuide.md`, `Docs/MallocStackLoggingLabInvestigationGuide.md`, `Docs/RetainCycleLabInvestigationGuide.md`, `Docs/HeapGrowthLabInvestigationGuide.md`, `Docs/DeadlockLabInvestigationGuide.md`, `Docs/BackgroundThreadUILabInvestigationGuide.md`, `Docs/MainThreadIOLabInvestigationGuide.md`, `Docs/ScrollHitchLabInvestigationGuide.md`, `Docs/StartupSignpostLabInvestigationGuide.md`, `Docs/ConcurrencyIsolationLabInvestigationGuide.md`.

---

## How to use this reference

1. Skim the **Xcode primer** for the tool surface.
2. Follow **Reproduction** to set up the app state.
3. Use **Investigation guide** only when you need more detail than the in-app workflow.

---

## Table of contents

1. [Crash Lab](#crash-lab) (`crash`)
2. [Exception Breakpoint Lab](#exception-breakpoint-lab) (`break_on_failure`)
3. [Breakpoint Lab](#breakpoint-lab) (`breakpoint`)
4. [Memory Graph Lab](#memory-graph-lab) (`memory_graph`)
5. [Hang Lab](#hang-lab) (`hang`)
6. [CPU Hotspot Lab](#cpu-hotspot-lab) (`cpu_hotspot`)
7. [Thread Performance Checker Lab](#thread-performance-checker-lab) (`thread_performance_checker`) — post-MVP scheme diagnostic
8. [Zombie Objects Lab](#zombie-objects-lab) (`zombie_objects`) — post-MVP scheme diagnostic
9. [Thread Sanitizer Lab](#thread-sanitizer-lab) (`thread_sanitizer`) — post-MVP scheme diagnostic
10. [Malloc Stack Logging Lab](#malloc-stack-logging-lab) (`malloc_stack_logging`) — post-MVP scheme diagnostic
11. [Retain Cycle Lab](#retain-cycle-lab) (`retain_cycle`) — later memory graph cycle lesson
12. [Heap Growth Lab](#heap-growth-lab) (`heap_growth`) — Phase 2
13. [Deadlock Lab](#deadlock-lab) (`deadlock`) — Phase 2
14. [Background Thread UI Lab](#background-thread-ui-lab) (`background_thread_ui`) — Phase 2
15. [Main Thread I/O Lab](#main-thread-io-lab) (`main_thread_io`) — Phase 2
16. [Scroll Hitch Lab](#scroll-hitch-lab) (`scroll_hitch`) — Phase 2
17. [Startup Signpost Lab](#startup-signpost-lab) (`startup_signpost`) — Phase 2
18. [Concurrency Isolation Lab](#concurrency-isolation-lab) (`concurrency_isolation`) — Phase 2

---

## Crash Lab

| Field | Value |
|--------|--------|
| **ID** | `crash` |
| **Category** | Crash |
| **Difficulty** | Beginner |

### Summary

Your first crash. A JSON import terminates the app because `count` arrived as the text `"three"` instead of an integer. Learn the three things Xcode shows when an app crashes, then use one caller-frame jump to reveal the payload that caused it.

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
- Crash Lab always triggers the crash. The goal is to learn what Xcode shows you after a crash, not to compare implementations yet.

### Suggested tools

- Console output — read the crash message first
- Source editor — the highlighted line shows where execution stopped
- Call stack — click `CrashImportParser`, then move up one caller frame to inspect `brokenCountText` and `brokenJSONText`
- Long-form write-up: `Docs/CrashLabInvestigationGuide.md` (in the repo)

### Investigation guide

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

### Summary

Reveal a caught Objective-C exception that the app normally hides behind a vague recovered failure message.

### Xcode primer

You need [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode) (same stack/Variables ideas as Crash Lab) plus [**Breakpoints**](XcodeToolingCheatSheet.md#breakpoints) for the **Breakpoint navigator** and **Exception Breakpoint**.

### Reproduction

1. Run SignalLab from Xcode and open this lab. Do not add an Exception Breakpoint yet.
2. Pass 1: Tap Run scenario. The app keeps running and only reports: Selection failed. The app recovered, but hid the table and row details.
3. Pass 2: In the **Breakpoint navigator**, add an **Exception Breakpoint**, then run the same scenario again.
4. When Xcode stops, ignore `objc_exception_throw` and select the first app frame: `ExceptionBreakpointLabTriggerInvalidSelectionException`.
5. In Variables, read `brokenTableName`, `brokenRowID`, and `exceptionReason`. Those locals are the useful context the app-level message hid.

### Hints

- This lab is about hidden exceptions, not line breakpoints for ordinary logic bugs.
- Crash Lab teaches what to do when Xcode already stops. This lab teaches how to stop when the app catches the exception and keeps going.
- The catch is intentional: it simulates a recovery layer that prevents a crash but drops the table and row details you need to diagnose the issue.
- The normal run should feel unsatisfying on purpose: the app only says selection failed.
- Use an Exception Breakpoint as a quick hypothesis test when a generic failure may have started as a thrown Objective-C exception.
- The useful evidence is the raise frame with `brokenTableName`, `brokenRowID`, and `exceptionReason`.

### Suggested tools

- Breakpoint navigator
- Xcode Exception Breakpoint
- Debug navigator stack + Variables view for `brokenTableName`, `brokenRowID`, and `exceptionReason`
- Long-form write-up: `Docs/ExceptionBreakpointLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Run this lab once without adding a breakpoint. Confirm the app keeps running and shows only a generic recovered failure.
2. Ask the tool-selection question: was there an exception before this generic failure message?
3. Add an **Exception Breakpoint** from the **Breakpoint navigator** (see cheat sheet).
4. Run the same scenario again. When Xcode stops, select `ExceptionBreakpointLabTriggerInvalidSelectionException` if `objc_exception_throw` is selected first.
5. Read `brokenTableName`, `brokenRowID`, and `exceptionReason`. Explain how those locals reveal the cause that the app message hid.

**Validate**

- You're done when you can explain why the no-breakpoint run gave too little information.
- You can support the exception breakpoint's value with the hidden raise frame and the first Objective-C locals you saw there.

---

## Breakpoint Lab

| Field | Value |
|--------|--------|
| **ID** | `breakpoint` |
| **Category** | Breakpoint |
| **Difficulty** | Beginner |

### Summary

Use one line breakpoint to diagnose a wrong discount calculation while the app keeps running.

### Xcode primer

Read [**Breakpoints**](XcodeToolingCheatSheet.md#breakpoints) and [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode). You will set a **line breakpoint** in the gutter, use **Continue** / **Step Over** / **Step Into** from the **debug bar**, and read **Variables** while paused.

### Reproduction

1. Run SignalLab from Xcode and open **Breakpoint Lab**.
2. Tap **Run scenario** and observe that the student order receives only `5%` off.
3. Open `BreakpointLabDiscountCalculator.swift`.
4. Add one plain **line breakpoint** on the first line inside `total(afterDiscountPercent:subtotal:)`.
5. Tap **Run scenario** again.
6. When Xcode pauses, inspect `discountPercent` and `subtotal`.
7. Explain why the final total is `$114.00` instead of `$96.00`.

### Hints

- This is not a crash. The app keeps running, so Xcode will not stop unless you add a breakpoint.
- Start with one plain line breakpoint. Do not add a condition yet.
- The useful evidence is in the paused frame's local variables.
- The value to question is `discountPercent`.
- Conditional and log breakpoints are refinements after the first stop is already useful.

### Suggested tools

- Xcode line breakpoint
- Debug bar: Continue and Step Over
- Variables view
- Long-form write-up: `Docs/BreakpointLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Run once without a breakpoint and observe the wrong total.
2. Add one **line breakpoint** on the first line inside `total(afterDiscountPercent:subtotal:)`.
3. Run again and wait for Xcode to pause.
4. Read `discountPercent` and `subtotal` in the paused frame.
5. Confirm that `discountPercent` is `5` even though the student order expects `20%`.
6. Step over once to see `discountMultiplier` become `0.95` and drive the wrong total.

**Validate**

- You can explain why this bug needs a breakpoint instead of a crash workflow.
- You can point to `discountPercent` as the value that makes the total wrong.
- You can explain the wrong total without using conditional or log breakpoints.

---

## Memory Graph Lab

| Field | Value |
|--------|--------|
| **ID** | `memory_graph` |
| **Category** | Memory |
| **Difficulty** | Beginner |
| **Scenario** | `MemoryGraphOpenNoteHolder` keeps one open note alive |
| **Reset** | Clears the open note after the learner has found the keep-alive path |

### Summary

Create one open note, keep it alive, and use Xcode Memory Graph to see which object holds it.

### Xcode primer

Read [**Memory Graph**](XcodeToolingCheatSheet.md#memory-graph-xcode) in the cheat sheet. You will use the left Memory Graph navigator to expand the app binary and select a named app object.

### Reproduction

1. Run SignalLab from Xcode and open **Memory Graph Lab**.
2. Tap **Set up lab**. The app creates one open note and keeps it in `MemoryGraphOpenNoteHolder`.
3. Open Memory Graph with the three-node debug bar button, or use **Debug > Debug Workflow > View Memory**.
4. If the left Memory Graph navigator is hidden, show it with Xcode's left sidebar button.
5. In the left navigator, expand **SignalLab**, then **SignalLab.debug.dylib**.
6. Select `MemoryGraphOpenNoteHolder`.
7. Follow the `openNote` arrow to `MemoryGraphOpenNote`. Read that arrow as: the holder keeps the note alive.
8. Select `MemoryGraphOpenNote`, open the right inspector, and expand **Backtrace**.
9. Select the `MemoryGraphOpenNote` allocation frame and use its jump-to-source button.
10. Tap **Reset**, capture Memory Graph again, and confirm `openNote` no longer points to the note.

### Hints

- This lab is intentionally not a retain cycle. Learn how to navigate to a live object and read who keeps it alive first.
- The canvas may initially open on SwiftUI or AttributeGraph objects; use the left navigator instead.
- The key target names are `MemoryGraphOpenNote` and `MemoryGraphOpenNoteHolder`.
- For this lab, an arrow means a strong reference: the object at the tail keeps the object at the arrowhead alive.
- If Memory Graph capture fails on Simulator with `LeakAgent` / `libmalloc`, that is an Xcode simulator capture failure, not lab evidence. Use a device capture for this lab when Simulator repeatedly reports this error.
- Retain Cycle Lab keeps its existing slug and terminology, but appears later after this simpler ownership lesson.

### Suggested tools

- Xcode Memory Graph left navigator
- Xcode Memory Graph right inspector Backtrace
- Backtrace row jump-to-source button: `arrow.up.forward.circle`
- Xcode tooling cheat sheet: `Docs/XcodeToolingCheatSheet.md`
- Long-form write-up: `Docs/MemoryGraphLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Confirm the shared Run scheme has **Malloc Stack Logging** enabled: **Product → Scheme → Edit Scheme → Run → Diagnostics → Memory Management**.
2. Tap **Set up lab** to create the open note.
3. Open Memory Graph and select `MemoryGraphOpenNoteHolder` under `SignalLab.debug.dylib`.
4. Follow `openNote` to `MemoryGraphOpenNote`.
5. Use the right inspector **Backtrace** to jump from `MemoryGraphOpenNote` to the source line that created it.
6. Tap **Reset**, capture Memory Graph again, and confirm the holder no longer keeps the note alive.

**Validate**

- You can read the arrow from `MemoryGraphOpenNoteHolder` to `MemoryGraphOpenNote` as a keep-alive reference.
- You can use Backtrace to reach the source line that allocated the note.
- You can explain what changed after Reset.

---

## Hang Lab

| Field | Value |
|--------|--------|
| **ID** | `hang` |
| **Category** | Hang |
| **Difficulty** | Intermediate |

### Summary

See a main-thread freeze from heavy CPU work running synchronously on the main actor.

### Xcode primer

Read [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode) — especially **Pause**, **threads** in the **debug navigator**, and the **main thread** stack vs background threads.

### Reproduction

1. Tap Run scenario, then immediately try to scroll the horizontal "Scroll probe" chips — they should stay frozen until processing finishes.
2. While the UI is frozen, click **Pause** in the debug bar. In the **debug navigator**, select the **main thread** and find `HangLabWorkload.simulateReportProcessing` in the stack — that is the work blocking the run loop.

### Hints

- The lab calls `HangLabWorkload.simulateReportProcessing` directly on the main actor.
- If interaction is merely slow but still responsive, that is CPU Hotspot Lab rather than Hang Lab.
- If live-instance counts keep rising after you dismiss a screen but scrolling still works, that is Retain Cycle Lab—not a main-thread hang.

### Suggested tools

- Pause in the debugger
- Debug navigator threads
- Instruments Time Profiler (supporting)
- Long-form write-up: `Docs/HangLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Tap Run scenario and attempt to scroll the probe row during the stall.
2. **Pause** the debugger; in the **debug navigator**, select the **main thread** and scan its **stack frames** for `simulateReportProcessing` or `HangLabWorkload`.
3. **Continue** and observe how long it takes for the UI to accept gestures again.

**Validate**

- You're done when you can point to the work blocking the main thread and explain why the UI freezes.
- You can name the synchronous work running on the main thread.
- You can explain how moving CPU work off the main actor (for example, awaiting a `Task.detached`) would fix the freeze.

---

## CPU Hotspot Lab

| Field | Value |
|--------|--------|
| **ID** | `cpu_hotspot` |
| **Category** | Performance |
| **Difficulty** | Intermediate |

### Summary

Search 500 diagnostic events and profile the sluggish keystrokes with Instruments Time Profiler. The lab always uses the slow `applyBroken` search path; `applyFixed` exists in the source code as a reference for comparison.

### Xcode primer

Read [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app) — **Time Profiler** template, **record**, **trace**, and **Self time**.

### Reproduction

1. Type a short query such as `memory` or `cpu` in the search field and notice the lag per keystroke.
2. To profile: **Product → Profile** (⌘I), choose **Time Profiler**, **record** while typing, then sort the call tree by **Self time** and look for `applyBroken`, `sorted`, and `DateFormatter.init`.
3. To see the optimized path, read `applyFixed` in the source code.

### Hints

- There are three compounding problems per keystroke: a full sort of 500 items, one DateFormatter allocation per item, and `lowercased()` called per item per search.
- Sort the trace by Self Time and look for your own code before chasing system libraries.
- If the UI fully freezes and gestures stop working, that is Hang Lab — CPU Hotspot Lab stays responsive but feels sluggish.
- `DateFormatter` is a heavyweight Objective-C object; creating one inside a tight loop is a classic iOS performance mistake.

### Suggested tools

- Instruments Time Profiler
- Long-form write-up: `Docs/CPUHotspotLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Type a query and confirm the UI is sluggish but still responds to gestures.
2. **Profile** with **Instruments → Time Profiler**; **record** while typing the same query several times.
3. Sort by **Self time** and locate `CPUHotspotLabSearch.applyBroken` or the `sorted` and `DateFormatter.init` symbols.
4. Identify all three hotspots: repeated sort, DateFormatter per item, and per-call `lowercased()`.
5. Read `applyFixed` in the source code to understand how pre-computation removes each hotspot.

**Validate**

- You're done when you can name all three redundant operations and explain why the interaction is slow but not frozen.
- You can point to at least one hot frame in your code in the Time Profiler trace.
- You can explain what `applyFixed` pre-computes to remove each hotspot.

---

## Thread Performance Checker Lab

| Field | Value |
|--------|--------|
| **ID** | `thread_performance_checker` |
| **Category** | Hang |
| **Difficulty** | Intermediate |

### Summary

After Hang Lab's pause-and-inspect proof, enable Xcode's Thread Performance Checker to surface main-thread misuse as a runtime warning.

### Xcode primer

Read [**Run scheme and diagnostics**](XcodeToolingCheatSheet.md#run-scheme-and-diagnostics) and [**Console and Issue navigator**](XcodeToolingCheatSheet.md#console-and-issue-navigator). You enable a scheme checkbox, then read warnings in the **Issue navigator** or **debug console**.

### Reproduction

1. Skim Hang Lab first: it blocks the scroll probes while heavy work runs synchronously on the main actor.
2. In Xcode: **Product → Scheme → Edit Scheme → Run → Diagnostics**, then enable **Thread Performance Checker** (exact label may vary slightly by Xcode version).
3. Build and run SignalLab from Xcode, open Hang Lab, tap Run scenario, and try scrolling during the stall.
4. Watch Xcode's Issue navigator or the runtime console for a Thread Performance Checker warning tied to main-queue work.
5. Compare with CPU Hotspot Lab's sluggish-but-responsive symptom so you do not confuse checker warnings with Time Profiler hotspots.

### Hints

- This lab is scheme diagnostics, not Hang Lab's pause-and-read-stack workflow—use both together.
- If the UI is merely sluggish but still scrolls, profile with CPU Hotspot Lab instead of expecting a checker storm.
- If objects stay alive after dismissal, that is Retain Cycle Lab—checker warnings are about thread misuse, not lifetime.

### Suggested tools

- Xcode scheme → Run → Diagnostics → Thread Performance Checker
- Hang Lab for the same workload shape
- Long-form write-up: `Docs/ThreadPerformanceCheckerLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Confirm you can reproduce Hang Lab's freeze so you have a concrete main-thread story in mind.
2. Enable Thread Performance Checker in the Run scheme diagnostics and relaunch the app from Xcode.
3. Trigger the same hang and read the warning Xcode surfaces — note the symbol or queue it cites.
4. Contrast that evidence with what you learned from pausing during the freeze in Hang Lab.

**Validate**

- You're done when you can describe one Thread Performance Checker warning you saw and how it supports a main-thread diagnosis.
- You can explain what this adds compared with only pausing the debugger during a freeze.

---

## Zombie Objects Lab

| Field | Value |
|--------|--------|
| **ID** | `zombie_objects` |
| **Category** | Memory |
| **Difficulty** | Intermediate |

### Summary

Turn an ambiguous memory crash into a clear "message sent to zombie / deallocated instance" diagnosis using Xcode's Zombie Objects diagnostic. The lab always triggers an Objective-C use-after-release after the autorelease pool drains.

### Xcode primer

Read [**Run scheme and diagnostics**](XcodeToolingCheatSheet.md#run-scheme-and-diagnostics) and [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode). Zombies change how the **debugger** presents a crash; compare console / **Variables** with Zombies on vs off.

### Reproduction

1. Read Retain Cycle Lab's contrast: there the object stays alive; Zombies target the opposite—something was freed and messaged too late.
2. In Xcode: **Product → Scheme → Edit Scheme → Run → Diagnostics** → enable **Zombie Objects** (label may vary slightly by Xcode version).
3. Open this lab and tap **Run scenario** from Xcode — Objective-C messages a deallocated object (`__unsafe_unretained` after the pool drains).
4. Read the zombie diagnostic text and name the object that was messaged after deallocation.
5. Optional: run again with Zombies off to compare how vague the failure becomes.

### Hints

- Retain Cycle Lab: live-instance counts climb — Zombies: the crash says you messaged memory that was already released.
- Zombies trade memory for clarity; turn them off when you are done investigating.
- Do not confuse this with Hang Lab or Thread Sanitizer — those are responsiveness and concurrent access, not deallocation timing.

### Suggested tools

- Xcode scheme → Run → Diagnostics → Zombie Objects
- Retain Cycle Lab (contrast: retention vs zombie)
- Long-form write-up: `Docs/ZombieObjectsLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Enable Zombie Objects, relaunch, run once, and read the clearer zombie / deallocated wording.
3. Identify which type or instance the runtime names as zombie or deallocated.
4. Disable Zombies after you have a fix hypothesis to avoid unnecessary overhead.

**Validate**

- You're done when you can quote how the crash message changed with Zombies on and what object it implicates.
- You can state one way the symptom differs from Retain Cycle Lab's "still alive" story.

---

## Thread Sanitizer Lab

| Field | Value |
|--------|--------|
| **ID** | `thread_sanitizer` |
| **Category** | Hang |
| **Difficulty** | Intermediate |

### Summary

Use Xcode's Thread Sanitizer to prove unsafe concurrent access to shared mutable state — the lab always races a shared counter from both the main thread and a detached task with no lock.

### Xcode primer

Read [**Run scheme and diagnostics**](XcodeToolingCheatSheet.md#run-scheme-and-diagnostics). Thread Sanitizer stops the app and opens a **report** listing threads, addresses, and **stack frames** — use the same mental model as [**Debugger UI → Frame**](XcodeToolingCheatSheet.md#debugger-ui-xcode).

### Reproduction

1. Finish Breakpoint Lab mental model: wrong logic while the app runs is not the same as two threads mutating the same property unsafely.
2. In Xcode: **Product → Scheme → Edit Scheme → Run → Diagnostics** → enable **Thread Sanitizer** (exact checkbox label may vary).
3. Open this lab and tap **Run scenario** — the main thread and a detached task increment one shared counter without a lock.
4. Read the sanitizer report: which address or variable, which two threads, and which **stack** / frames implicate your code.

### Hints

- Hang Lab is synchronous main-thread starvation; TSan is concurrent unsynchronized writes/reads to the same memory.
- If results are wrong but a single thread owns the state, use Breakpoint Lab — not this lab.
- TSan slows the app; use it when you suspect a race, not for every performance pass.

### Suggested tools

- Xcode scheme → Run → Diagnostics → Thread Sanitizer
- Hang Lab and CPU Hotspot Lab (contrast: freeze / cost vs race)
- Long-form write-up: `Docs/ThreadSanitizerLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Enable Thread Sanitizer and tap Run scenario until Xcode stops with a race report on the shared counter.
2. Extract: conflicting threads, shared variable, and call sites from the report.
3. Contrast with an async ordering bug (completion A before B) where TSan stays quiet.
4. Apply the same serialization idea (one `NSLock` or actor isolation) to your own shared state when you leave the lab.

**Validate**

- You're done when you can name the shared state TSan flagged and why two threads conflicted.
- You can explain why Breakpoint Lab or Hang Lab would be the wrong diagnostic surface for that symptom.

---

## Malloc Stack Logging Lab

| Field | Value |
|--------|--------|
| **ID** | `malloc_stack_logging` |
| **Category** | Memory |
| **Difficulty** | Intermediate |

### Summary

When you need "where was this allocated?" not just "what is alive now," enable Malloc Stack Logging and read allocation backtraces. The lab always allocates thousands of fresh row arrays every tap.

### Xcode primer

Read [**Run scheme and diagnostics**](XcodeToolingCheatSheet.md#run-scheme-and-diagnostics) and [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app) (**Allocations**). You are correlating **allocation backtraces** (which code path created bytes) with the scheme diagnostic.

### Reproduction

1. Confirm you already know Memory Graph / leaks basics from Retain Cycle Lab and when Zombies help from Zombie Objects Lab.
2. In Xcode: **Product → Scheme → Edit Scheme → Run → Diagnostics** → enable **Malloc Stack Logging** (options may include "Malloc Stack" or similar by version).
3. Tap Run scenario — each tap allocates thousands of fresh row arrays; use **Instruments → Allocations** (or your guide's lldb path) to see the allocating **stacks**.
4. Capture the row-array allocation stack in Instruments → Allocations.
5. Turn logging off when finished — this diagnostic is heavy on overhead and disk.

### Hints

- This is forensic: use when "who created this?" matters, not as a default leak sweep.
- Zombies answer "you messaged the dead"; malloc stacks answer "who birthed these bytes".
- Retain Cycle Lab shows who still holds live references — different question from creation-site history.

### Suggested tools

- Xcode scheme → Run → Diagnostics → Malloc Stack Logging
- Instruments Allocations / lldb malloc_history (as appropriate to your Xcode version)
- Long-form write-up: `Docs/MallocStackLoggingLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Enable malloc stack recording per scheme instructions and rerun from Xcode.
2. Tap Run scenario once and capture stacks for the row-array allocation hot path in this module.
3. Open the stack / history UI your toolchain provides and tie one frame to a concrete call site.
4. Disable the diagnostic and document the fix path (reuse, pooling, or fewer per-run allocations).

**Validate**

- You're done when you can point to one allocation stack that explains where a suspicious object came from.
- You can explain why Memory Graph alone was not enough for that question.

---

## Retain Cycle Lab

| Field | Value |
|--------|--------|
| **ID** | `retain_cycle` |
| **Category** | Memory |
| **Difficulty** | Intermediate |

### Summary

Use Memory Graph to find a checkout screen that is kept alive by a close-button handler.

### Xcode primer

Read [**Memory Graph**](XcodeToolingCheatSheet.md#memory-graph-xcode) in the cheat sheet. You will use the left Memory Graph navigator and follow **retaining paths** in the graph UI.

### Reproduction

1. Tap Run scenario once to create the checkout screen example.
2. In Xcode, open Memory Graph with the debug bar button that looks like three connected nodes, or use Debug > Debug Workflow > View Memory.
3. If the left Memory Graph navigator is hidden, show it with Xcode's left sidebar button.
4. In the left navigator, expand `SignalLab.debug.dylib` and select `RetainCycleLabCheckoutScreen`.
5. Confirm it points to `RetainCycleLabCloseButtonHandler`.
6. Confirm the close-button handler points back to `RetainCycleLabCheckoutScreen`.

### Hints

- Retain Cycle Lab keeps its existing slug and terminology, but appears later than Memory Graph Lab.
- The left Memory Graph navigator is the intended path for this lab; the canvas may open on a SwiftUI object first.
- Seeing `RetainCycleLabCheckoutScreen` nested under `SignalLab.debug.dylib` is expected in this debug build.
- Xcode may show the type as `RetainCycleLabCheckoutScreen` or `SignalLab.RetainCycleLabCheckoutScreen`.
- If the type list is long, use the Memory Graph search field and type `RetainCycleLabCheckoutScreen`.
- Both important boxes are app types: `RetainCycleLabCheckoutScreen` and `RetainCycleLabCloseButtonHandler`.
- If Memory Graph fails with a `LeakAgent` / `libmalloc` initialization error, keep the app running, interact with the lab once more, then try View Memory again. If it repeats, stop and run the app again from Xcode.

### Suggested tools

- Xcode Memory Graph left navigator
- Xcode tooling cheat sheet: `Docs/XcodeToolingCheatSheet.md`
- Long-form write-up: `Docs/RetainCycleLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Tap Run scenario once.
2. Open Memory Graph with the three-node debug bar button or Debug > Debug Workflow > View Memory.
3. Show the left Memory Graph navigator if it is hidden.
4. Expand `SignalLab.debug.dylib` and select `RetainCycleLabCheckoutScreen`.
5. Confirm it points to `RetainCycleLabCloseButtonHandler`.
6. Confirm the handler points back to `RetainCycleLabCheckoutScreen`.

**Validate**

- You can find the checkout screen from the Memory Graph navigator without relying on the default canvas selection.
- You can describe the retaining path in one sentence: checkout screen -> close-button handler -> checkout screen.

---

## Heap Growth Lab

| Field | Value |
|--------|--------|
| **ID** | `heap_growth` |
| **Category** | Memory |
| **Difficulty** | Intermediate |

### Summary

Tell climbing footprint and allocation churn apart from a retain cycle: each tap retains another 256 KB `Data` chunk with no bound. Use Memory Graph or Instruments Allocations to observe the linear growth.

### Xcode primer

Read [**Memory Graph**](XcodeToolingCheatSheet.md#memory-graph-xcode) and [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app) (**Allocations**). Contrast **linear retention** (no purple cycle) with Retain Cycle Lab.

### Reproduction

1. Finish Retain Cycle Lab first so you know what a cycle looks like in Memory Graph.
2. Open Heap Growth Lab and tap **Run scenario** several times — each run retains another 256 KB chunk.
3. In **Xcode Memory Graph** or **Instruments → Allocations**, observe live bytes rising even though references are linear (no cycle).
4. Articulate when you would choose eviction vs fixing a cycle.

### Hints

- Retain Cycle Lab: objects keep each other alive — Heap Growth: you simply never release work buffers.
- Malloc Stack Logging Lab helps provenance; this lab is about **how much** stays live.
- If the UI is frozen but CPU is idle, consider Deadlock Lab instead of this one.

### Suggested tools

- Instruments > Allocations
- Xcode Memory Graph (compare with Retain Cycle Lab)
- Long-form write-up: `Docs/HeapGrowthLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Tap Run scenario five times and capture a memory or allocations snapshot after the last tap.
2. Note rising live bytes / chunk count without a purple cycle in Memory Graph.
3. Write one sentence: why this is not Retain Cycle Lab.
4. Plan a real-world policy: max cache size, LRU, or periodic flush.

**Validate**

- You can explain why footprint grew without claiming a retain cycle.
- You can describe a bounding strategy (ring buffer, LRU eviction, periodic flush) and when that pattern applies in production.

---

## Deadlock Lab

| Field | Value |
|--------|--------|
| **ID** | `deadlock` |
| **Category** | Hang |
| **Difficulty** | Intermediate |

### Summary

Reproduce a textbook main-thread deadlock with `DispatchQueue.main.sync` from the main thread — the lab always deadlocks when Run scenario is tapped.

### Xcode primer

Read [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode) — **Pause** and **threads**. Compare **waiting** frames on the main thread with Hang Lab's **busy** CPU frames.

### Reproduction

1. Launch SignalLab **from Xcode** with the debugger attached.
2. Open Deadlock Lab and read the warning before tapping Run scenario.
3. Tap **Run scenario** — the UI should freeze permanently.
4. Click **Pause** in the debug bar: the **main thread** stack should show `dispatch_sync` / queue wait rather than heavy app compute.
5. Stop the run in Xcode, then relaunch SignalLab for normal exploration.

### Hints

- Hang Lab: main thread is **busy** — Deadlock Lab: main thread is **waiting** on itself.
- Never call `sync` onto a queue you are already executing on.
- This scenario is intentionally destructive — do not use it in UI tests or screenshots that tap Run.

### Suggested tools

- Debug navigator thread stacks
- Pause / continue in Xcode
- Long-form write-up: `Docs/DeadlockLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Run once, then pause — the main thread should be stuck in sync machinery.
3. Contrast with Hang Lab: there you often see heavy frames on the main stack; here you see waiting.
4. In your own code, search for `sync` onto `.main` from contexts that might already be main.
5. Prefer `async`, structured concurrency, or inline work instead of main-on-main sync.

**Validate**

- You can state in one sentence why `main.sync` from main deadlocks.
- You can tell this symptom apart from Hang Lab's CPU-bound freeze.

---

## Background Thread UI Lab

| Field | Value |
|--------|--------|
| **ID** | `background_thread_ui` |
| **Category** | Hang |
| **Difficulty** | Intermediate |

### Summary

See why UI-facing callbacks should run on the main actor: the lab always posts a `NotificationCenter` notification from a `Task.detached` without a MainActor hop.

### Xcode primer

Read [**Console and Issue navigator**](XcodeToolingCheatSheet.md#console-and-issue-navigator). Warnings may appear in the **debug console** or **Issue navigator** while the app runs.

### Reproduction

1. Open this lab and keep the **debug console** (debug area) visible.
2. Tap Run scenario and watch for runtime diagnostics about background-thread updates.
3. In your apps, audit `NotificationCenter`, callbacks, and delegates that mutate UI.

### Hints

- Hang Lab is CPU work on main; this lab is **which thread** delivers UI mutations.
- Combine/async sequences have similar rules — end on MainActor before touching `@State`.
- Deadlock Lab is about waiting; this lab is about crossing thread boundaries safely.

### Suggested tools

- Xcode console + runtime issues
- Main actor / Swift concurrency docs
- Long-form write-up: `Docs/BackgroundThreadUILabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Tap Run scenario and capture any threading warning text verbatim.
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

### Summary

Contrast repeated synchronous `Data(contentsOf:)` on the main thread with an off-main read — same bytes, different responsiveness story than Hang Lab's pure CPU work. The lab always reads ten 256 KB files synchronously on the main thread.

### Xcode primer

Read [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app) (**Time Profiler**) and [**Debugger UI**](XcodeToolingCheatSheet.md#debugger-ui-xcode) — **Pause** + **main thread** stack. You are distinguishing **I/O wait** from Hang Lab's **CPU** work.

### Reproduction

1. Open Main Thread I/O Lab and tap **Run scenario** — the UI should hitch while ten synchronous reads complete.
2. **Product → Profile** → **Time Profiler**, or **Pause** the debugger and inspect the **main thread** stack: look for file-read / I/O frames (compare with Hang Lab's compute-heavy frames).

### Hints

- Network on main is the same class of bug — this lab uses a local file to stay deterministic offline.
- CPU Hotspot Lab is about hot **compute**; this lab is about **waiting on storage**.
- If the app is deadlocked, use Deadlock Lab — not this one.

### Suggested tools

- Instruments > Time Profiler
- Main thread track / hang diagnostics in Xcode
- Long-form write-up: `Docs/MainThreadIOLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Tap Run scenario and feel the hitch; **Pause** and inspect the **main thread** stack for synchronous file read APIs.
3. Estimate how many synchronous reads your real feature does per gesture.
4. Move loads to `Task.detached`, `URLSession`, or async file APIs as appropriate.
5. Validate with a Time Profiler pass after the change.

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

### Summary

Auto-scroll a long list that uses heavy per-row compositing and a large shadow on every row — profile frame pacing to see where rendering time goes.

### Xcode primer

Read [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app). Use **Core Animation** or your Xcode's scrolling / frame pacing template plus **Time Profiler** as needed — you care about **frame timing**, not only CPU self time.

### Reproduction

1. Open Scroll Hitch Lab and tap **Run scenario** to auto-scroll the vertical list.
2. While it scrolls, drag the horizontal "Probe" chips; the scroll should feel uneven.
3. Profile with Instruments > Core Animation or the scrolling instrument your Xcode version provides; examine frame times.

### Hints

- The lab uses `.compositingGroup()` plus a large shadow on every row — each row becomes an expensive offscreen pass.
- CPU Hotspot Lab stays responsive but slow; this lab targets frame drops during scroll.
- Hang Lab is a full stop; here the scroll usually continues but unevenly.

### Suggested tools

- Instruments > Core Animation (or scrolling / frame pacing template for your Xcode version)
- Instruments > Time Profiler (supporting)
- Long-form write-up: `Docs/ScrollHitchLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Tap Run scenario and capture a short Instruments trace covering the scroll.
3. Look for elevated frame time or compositing cost while rows with heavy shadows are on screen.
4. In your own lists, audit `.drawingGroup()`, `.compositingGroup()`, and stacked shadows inside `Lazy` stacks.

**Validate**

- You can explain one visual effect that makes scrolling more expensive.
- You can state how this symptom differs from CPU Hotspot Lab and Hang Lab.

---

## Startup Signpost Lab

| Field | Value |
|--------|--------|
| **ID** | `startup_signpost` |
| **Category** | Performance |
| **Difficulty** | Intermediate |

### Summary

Simulate blocking launch phases on the main thread and emit `os_signpost` intervals for Instruments Points of Interest.

### Xcode primer

Read [**Instruments**](XcodeToolingCheatSheet.md#instruments-separate-app). Choose a template that shows **Points of Interest** / `os_signpost` lanes (name may vary by Xcode version).

### Reproduction

1. From Xcode, choose **Product → Profile** (⌘I) and pick **Points of Interest** (or a template that surfaces POI signposts).
2. Open Startup Signpost Lab and tap **Run scenario** while recording — expect three named intervals.
3. Use the checksum in the footer only as a sanity check that the simulated work completed.

### Hints

- Signposts annotate work you already do — they are not a substitute for moving work off the main thread.
- Category `PointsOfInterest` on the `OSLog` is what makes intervals show up in the POI instrument.
- Malloc Stack Logging answers "who allocated this?"; signposts answer "what phase was running now?"

### Suggested tools

- Instruments > Points of Interest
- Instruments > Time Profiler
- Long-form write-up: `Docs/StartupSignpostLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Profile the lab and tap **Run scenario** once per recording.
2. Identify `SignalLabStartupConfig`, `SignalLabStartupAssets`, and `SignalLabStartupReady` intervals.
3. Add a named signpost around your own app's heaviest launch closure before optimizing blindly.

**Validate**

- You can name the three signposted phases and what each represents in this lab.
- You can explain why signposts annotate work rather than optimize it.

---

## Concurrency Isolation Lab

| Field | Value |
|--------|--------|
| **ID** | `concurrency_isolation` |
| **Category** | Hang |
| **Difficulty** | Intermediate |

### Summary

Two `Task.detached` hops race logging order and capture a non-Sendable type — surface Xcode concurrency issues before Thread Sanitizer. Completion order is non-deterministic across taps.

### Xcode primer

Read [**Console and Issue navigator**](XcodeToolingCheatSheet.md#console-and-issue-navigator). **Issue navigator** (⌘5) lists analyzer and build issues; some Swift concurrency hints appear during build or as warnings alongside the **debug console**.

### Reproduction

1. Open Concurrency Isolation Lab and tap **Run scenario** — read the completion log.
2. Tap **Run scenario** again — `alpha` and `beta` may appear in a different order than the previous run.
3. Open the **Issue navigator** and the build log for **Sendable** / isolation warnings involving the lab's non-Sendable token.
4. Contrast with Thread Sanitizer Lab: there two threads mutate one counter without a lock.

### Hints

- If the bug is "sometimes A runs before B," structured concurrency is often the fix — not TSan.
- Thread Sanitizer Lab is for unsynchronized memory access; this lab is for task lifecycle and ordering.
- Background Thread UI Lab is about main-actor UI delivery; this lab is about how many detached tasks you launched.

### Suggested tools

- Xcode Issue navigator (Swift concurrency / Sendable)
- Swift Structured Concurrency documentation
- Long-form write-up: `Docs/ConcurrencyIsolationLabInvestigationGuide.md` (in the repo)

### Investigation guide

**Steps**

1. Tap Run scenario three times and screenshot or note the three completion-order strings.
2. Search warnings for capturing a non-Sendable type inside `Task.detached`.
3. Understand how replacing both `Task.detached` calls with sequential `async` steps on the main actor gives deterministic `alpha` then `beta` output.
4. Write one sentence: when you would still enable Thread Sanitizer after fixing ordering.
5. Refactor one real feature from double-`detached` fire-and-forget to a single `async` function.

**Validate**

- You can explain why completion order changed across runs.
- You can state why Thread Sanitizer Lab is not the right diagnostic surface for that symptom.
