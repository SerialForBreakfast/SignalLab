# SignalLab — Labs reference

Keep this document open in your editor while you work. When the app stops under the debugger (for example in **Crash Lab**), you cannot scroll the in-app **Reproduction** or **Investigation guide** sections—everything below duplicates that content.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift`  
When you change catalog copy or add a lab, update this file in the same commit.

**Long-form guides:** see `Docs/CrashLabInvestigationGuide.md`, `Docs/ExceptionBreakpointLabInvestigationGuide.md`, `Docs/BreakpointLabInvestigationGuide.md`, `Docs/RetainCycleLabInvestigationGuide.md`, `Docs/HangLabInvestigationGuide.md`, `Docs/CPUHotspotLabInvestigationGuide.md`, `Docs/ThreadPerformanceCheckerLabInvestigationGuide.md`, `Docs/ZombieObjectsLabInvestigationGuide.md`, `Docs/ThreadSanitizerLabInvestigationGuide.md`, `Docs/MallocStackLoggingLabInvestigationGuide.md`, `Docs/HeapGrowthLabInvestigationGuide.md`, `Docs/DeadlockLabInvestigationGuide.md`.

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
- After you are comfortable with this default stop, use Exception Breakpoint Lab to compare exception-breakpoint stop policy—not before.

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
- Swift often traps with a clear faulting line; the Exception Breakpoint still helps when you want a consistent stop across failures or earlier context—compare and decide for this crash.

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

Search 500 diagnostic events and profile the sluggish keystrokes in Broken mode with Instruments Time Profiler.

### Learning goals

- Profile a slow-but-responsive interaction with Time Profiler
- Identify the hottest functions in the trace by self time
- Separate app hotspots (sort, DateFormatter, lowercased) from framework noise

### Reproduction

1. In Broken mode, type a short query such as `memory` or `cpu` in the search field and notice the lag per keystroke.
2. Switch to Fixed mode and type the same query — the list should update noticeably faster.
3. To profile: launch through Instruments > Time Profiler, record while typing in Broken mode, then look for `applyBroken`, `sorted`, and `DateFormatter.init` in the trace.
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
2. Launch through Instruments > Time Profiler; record while typing the same query several times.
3. Sort by Self Time and locate `CPUHotspotLabSearch.applyBroken` or the `sorted` and `DateFormatter.init` frames.
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

### Reproduction

1. Skim Hang Lab first: Broken mode blocks the scroll probes while heavy work runs synchronously on the main actor.
2. In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics, then enable Thread Performance Checker (exact label may vary slightly by Xcode version).
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

### Reproduction

1. Read Retain Cycle Lab’s contrast: there the object stays alive; Zombies target the opposite—something was freed and messaged too late.
2. In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics → enable Zombie Objects (label may vary slightly by Xcode version).
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

### Reproduction

1. Finish Breakpoint Lab mental model: wrong logic while the app runs is not the same as two threads mutating the same property unsafely.
2. In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics → enable Thread Sanitizer (exact checkbox label may vary).
3. Open this lab, **Broken**, **Run scenario**—main thread and a detached task increment one shared counter without a lock.
4. Read the sanitizer report: which address or variable, which two threads, which stack frames.
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

### Reproduction

1. Confirm you already know Memory Graph / leaks basics from Retain Cycle Lab and when Zombies help from Zombie Objects Lab.
2. In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics → enable Malloc Stack Logging (options may include “Malloc Stack” or similar by version).
3. Run **Broken** here—each tap allocates thousands of fresh row arrays; use Instruments Allocations (or your guide’s lldb path) to see the allocating stacks.
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

### Reproduction

1. Finish Retain Cycle Lab first so you know what a cycle looks like in Memory Graph.
2. Open Heap Growth Lab, **Broken**, tap **Run scenario** several times—each run retains another 256 KB chunk.
3. In Xcode’s Memory Graph or Instruments, observe live bytes rising even though references are linear (no cycle).
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

### Reproduction

1. Launch SignalLab **from Xcode** with the debugger attached.
2. Open Deadlock Lab, select **Fixed**, tap **Run scenario** once—should complete immediately.
3. Read the warning, then select **Broken** and tap **Run scenario**—the UI should freeze permanently.
4. Use Xcode’s pause control: main thread is blocked in `dispatch_sync` waiting on work that cannot run.
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
