# SignalLab — Per-Lab Audit

Assessed against three questions for each lab:
1. **Instructions** — are steps in the right order, unambiguous, and referencing the right code?
2. **Pedagogy** — does the lab reliably teach what it claims to teach?
3. **Code / logging** — is the key moment visible and logged well enough to confirm it fired?

Rating key: ✅ Ready · 🟡 Minor fixes · 🔴 Needs significant work

---

## 1. Crash Lab ✅

**What it does:** `runBrokenImport()` passes JSON with `"count": "three"` to an unsafe decoder, crashing the process.

**Instruction clarity:** Good. The three-step read order (console → source → call stack) is correct and specific. Frame names (`CrashImportParser`, `runBrokenImport`) and local names (`brokenCountText`, `brokenJSONText`) are named explicitly.

**Pedagogy:** Strong. The console message explains the crash in plain English before the learner touches any code. The caller-frame locals expose the exact bad value. Single-pass, no mode toggling.

**Logging:** `trigger run=X` + intentional crash warning. Appropriate.

**Recommended improvements:**
- The instruction "click the CrashImportParser frame even if Xcode truncates the name" is vague about what truncation looks like. A note that it may appear as `CrashImportParser.importLinesAssumingCompleteSchema` or just `CrashImportParser` would help.

---

## 2. Exception Breakpoint Lab 🟡

**What it does:** Calls Obj-C `ExceptionBreakpointLabRunCaughtSelection()`, catches the exception, and surfaces only a generic "Selection failed" message.

**Instruction clarity:** The two-pass structure (run without breakpoint, then with) is well-ordered. The specific locals (`brokenTableName`, `brokenRowID`, `exceptionReason`) give concrete targets.

**Pedagogy:** Solid concept. The unsatisfying first run motivates the tool.

**Recommended improvements:**
- **Missing: breakpoint type.** The instruction says "add an Exception Breakpoint" but doesn't specify "Objective-C Exception" in the type dropdown. A Swift Error breakpoint won't fire here. This will cause silent failure for many learners.
- The instruction "ignore objc_exception_throw and select the first app frame" should name the frame more precisely — `ExceptionBreakpointLabTriggerInvalidSelectionException` is the target, and learners don't know whether the first frame listed is always the Obj-C internal or the app frame.

---

## 3. Breakpoint Lab 🟡

**What it does:** Runs `BreakpointLabDiscountCalculator.calculateStudentOrderTotal`. The student order gets 5% instead of 20% because the wrong discount policy is looked up.

**Instruction clarity:** Generally good. The expected vs actual values ($114 vs $96) are concrete.

**Pedagogy:** Clean single-breakpoint exercise with a readable payoff.

**Recommended improvements:**
- **Missing: file navigation.** "Open BreakpointLabDiscountCalculator.swift" assumes the learner knows where to find it. No guidance on using the project navigator or ⌘⇧O (Open Quickly).
- "Add one plain line breakpoint on the first line inside `total(afterDiscountPercent:subtotal:)`" requires the learner to already know the method signature. The actual first line could be named: the `let discountMultiplier = ...` line.
- The root cause (wrong discount policy key returned for `.student`) is never explicitly named. The learner observes `discountPercent = 5` but the "why" — the policy lookup returns the wrong tier — is left implicit. Consider naming it in the checklist.

---

## 4. Memory Graph Lab 🟡

**What it does:** `MemoryGraphOpenNoteHolder.shared` keeps a `MemoryGraphOpenNote` alive via a strong property. Reset nils it out.

**Instruction clarity:** Mostly good. The ownership path is explicit.

**Pedagogy:** A strong foundation exercise — teaches arrow = strong reference before introducing cycles.

**Recommended improvements:**
- **Label mismatch:** reproductionSteps say "Tap **Set up lab**" but the runner uses `trigger()`, which the scaffold likely labels "Run scenario." Verify which label the button actually shows and make them match.
- **Missing prerequisite upfront:** Backtrace requires Malloc Stack Logging enabled in the scheme. This is buried in the investigation guide step 1 but missing from `reproductionSteps`. It should be step 1 of reproduction.
- The hint about Simulator's LeakAgent / libmalloc error is good, but it should appear earlier (before the Memory Graph steps, not after).

---

## 5. Hang Lab ✅

**What it does:** `Thread.sleep(forTimeInterval: 4.0)` on `@MainActor`. Inline, annotated, readable.

**Instruction clarity:** Correct order. Pre-run instructions in the view, assembly-is-normal warning, and explicit "click `trigger()` frame not `simulateReportProcessing`" guidance are all in place.

**Pedagogy:** The sleep is immediately legible in the debugger. The status message confirms the spinner-never-appeared teaching point.

**Logging:** `trigger run=X`, `run finished checksum=X`. Good.

**No significant issues.**

---

## 6. CPU Hotspot Lab 🟡

**What it does:** `applyBroken` re-sorts 500 items, allocates one `DateFormatter` per item, and calls `lowercased()` per item per keystroke.

**Instruction clarity:** The Instruments-first order was just fixed (feel lag in normal run → launch through Instruments → profile while typing). Good.

**Pedagogy:** Three named hotspots, all visible in Time Profiler. `applyFixed` is readable in source.

**Logging:** Query-change logging was just added. Good.

**Recommended improvements:**
- **Lag may be subtle on modern hardware.** On a fast simulator, 500 `DateFormatter` allocations take ~10–30 ms per keystroke — perceptible but not dramatic. The instructions should note: type the same query many times quickly to accumulate samples before stopping the trace.
- **"Hide System Libraries" filter** is mentioned in the investigation guide but not the catalog steps. Without this filter, learners will be lost in system frames.
- `applyFixed` is "not wired to the UI" — a learner who tries to activate it will be confused when nothing changes. A one-line note in the UI or catalog that it exists only as source reference would prevent this.

---

## 7. Thread Performance Checker Lab 🔴

**What it does:** Uses Hang Lab's runner (no dedicated runner — "NOT FOUND"). The lab is a scheme-diagnostics exercise.

**Instruction clarity:** Tells the learner to open Hang Lab's tab to trigger the hang, which means navigating away from this lab's screen. This is a confusing UX.

**Pedagogy — critical issue:** `Thread.sleep(forTimeInterval: 4.0)` may not trigger Thread Performance Checker. TPC fires for main-thread violations like UI updates from background threads or heavy main-thread I/O, not for sleeping. If TPC doesn't fire, the learner has no payoff and no way to know if the setup was wrong or the tool simply doesn't apply.

**Recommended improvements:**
- **Verify that TPC fires** for `Thread.sleep` in the current Hang Lab implementation. If it doesn't, either:
  - Restore a CPU-loop variant of Hang Lab specifically for TPC (TPC DOES fire for main-thread CPU work), or
  - Change the lab to use Main Thread I/O Lab as the trigger (TPC reliably fires for `Data(contentsOf:)` on main).
- If the lab has no runner/UI of its own, the instructions should say so explicitly — "this lab has no Run scenario button; navigate to Hang Lab to trigger the workload."
- The investigation guide step says "trigger the same hang" without saying which lab's button to tap.

---

## 8. Zombie Objects Lab 🟡

**What it does:** Calls `ZombieObjectsLabTriggerUnsafeUseAfterRelease()` (Obj-C), which messages a deallocated object. Crashes without Zombies; gives a clear "message sent to deallocated instance" message with Zombies.

**Instruction clarity:** The two-pass structure is right. The scheme setup is specific.

**Pedagogy:** The contrast between a vague `EXC_BAD_ACCESS` and a named zombie message is the core lesson. It works.

**Recommended improvements:**
- **"Optional: run again with Zombies off"** — this is actually the core two-pass structure, not optional. Reframe it as a required step: "Run once with Zombies off first to experience the vague failure, then enable Zombies and run again."
- **Missing: what the zombie message says.** Tell the learner what to look for — something like "message sent to deallocated instance of class `SomeClass`" — so they know when the tool worked.
- The investigation guide steps don't mention the two-pass structure at all — they start with Zombies already enabled. The diagnostic contrast is the point; start without it.

---

## 9. Thread Sanitizer Lab 🟡

**What it does:** Main thread and `DispatchQueue.global` both increment a raw-pointer `ThreadSanitizerSharedCounter` without synchronization.

**Instruction clarity:** The setup path (scheme → Diagnostics → TSan) is correct.

**Pedagogy:** Good concept. The raw pointer approach is necessary under Swift 6 strict concurrency.

**Recommended improvements:**
- **TSan requires a full rebuild, not just re-run.** Enabling TSan and pressing the Play button without rebuilding won't produce reports. The instruction should say: after enabling TSan, use ⌘R to rebuild and relaunch, not just Continue.
- **`group.wait()` on the main thread** in the runner causes a brief main-thread stall on every tap (5,000 background increments while main waits). This may confuse learners who notice the UI pause and think it's a hang. Add a comment in the runner explaining this is intentional: the wait ensures both sides finish before showing the counter, not a teaching point itself.
- "run until Xcode stops" implies TSan reports are non-deterministic. Clarify that TSan should reliably report on the first or second run; if it doesn't fire, the TSan scheme setting likely didn't take effect (rebuild required).

---

## 10. Malloc Stack Logging Lab 🔴

**What it does:** Allocates 2,000 arrays of 32 strings each per trigger.

**Instruction clarity:** Very vague. "use Instruments → Allocations (or your guide's lldb path)" offers two paths without explaining either.

**Pedagogy:** The concept (provenance vs live count) is correct but the workflow is under-specified. A learner who follows the steps has no clear way to find the allocation stack for the row arrays.

**Recommended improvements:**
- **Write out the Allocations workflow explicitly:**
  1. Launch through Instruments (⌘I), choose Allocations template, Record.
  2. Tap Run scenario.
  3. Stop recording. In the Allocations table, filter by "SignalLab" or search for `Array<Array<String>>`.
  4. Select a row and expand the Backtrace column to see which call site created it.
- **Remove the `lldb malloc_history` path** or move it to a separate "advanced" section. It's not reliable across all Xcode versions and adds confusion for a lab aimed at intermediate learners.
- **Name the type to search for** in Allocations. The learner needs to know what to look for.

---

## 11. Heap Growth Lab 🟡

**What it does:** Appends a 256 KB `Data` chunk per trigger. `retainedChunkCount` and `approximateRetainedBytes` are exposed to the UI.

**Instruction clarity:** "capture a memory or allocations snapshot" — no guidance on how.

**Pedagogy:** The in-app counter rising with each tap is a strong, tool-free first signal. But the instructions don't call it out — they jump straight to Memory Graph.

**Recommended improvements:**
- **Lead with the in-app counter as first signal:** "Tap Run scenario three times and watch the live byte count in the UI climb. You don't need a tool yet — the number tells you footprint is growing."
- **Explain how to capture a snapshot:** either Xcode's Debug Memory Graph button (⌘6 equivalent) or Instruments Allocations stop-and-inspect workflow.
- **"Purple cycle in Memory Graph"** is unclear — Memory Graph shows cycles as purple arrows, but a learner who hasn't seen a cycle doesn't know what "purple" means. Say "you won't see any cycle arrows" instead.
- The reproduction steps currently say "Tap Run scenario several times" — change to a specific number (five) to match the investigation guide.

---

## 12. Deadlock Lab 🟡

**What it does:** `DispatchQueue.main.sync` from `@MainActor` — self-deadlock.

**Instruction clarity:** Appropriate destructive-scenario warnings. Good.

**Pedagogy:** The contrast with Hang Lab is the key teaching. But this contrast is now stale.

**Recommended improvements:**
- **Hang Lab contrast is stale.** The investigation guide says "there you often see heavy frames on the main stack; here you see waiting." Hang Lab now uses `Thread.sleep`, which also shows waiting frames — not compute frames. The contrast should now read: "Hang Lab's main thread is sleeping (waiting to be woken by a timer it controls). Deadlock Lab's main thread is waiting on a queue that cannot proceed because it's waiting for the main thread — a circular wait that never resolves."
- The catalog summary says "contrast with safe main-actor work" but there's no safe-path comparison anywhere. Either cut this phrase or add a hint about what the safe alternative looks like (`DispatchQueue.main.async` or `Task { @MainActor in ... }`).

---

## 13. Background Thread UI Lab 🔴

**What it does:** Posts a `NotificationCenter` notification from `DispatchQueue.global`. The view receives it via `onReceive`.

**Instruction clarity:** "watch the debug console for runtime diagnostics" — but doesn't say what the warning looks like.

**Pedagogy — critical issue:** Whether this lab produces a visible warning depends heavily on the Xcode version, iOS version, and how SwiftUI's `onReceive` is implemented. In recent SwiftUI versions, notification delivery threading may be handled transparently and produce no warning at all. If the learner sees nothing in the console, they have no way to know if the lab worked or if something is misconfigured.

**Code / instruction mismatch:** The investigation guide step 2 says "Trace from `Task.detached` to `onReceive`" — but the runner uses `DispatchQueue.global`, not `Task.detached`. These are different mechanisms and this is a code-instruction inconsistency.

**Recommended improvements:**
- **Verify that a runtime warning actually fires** in the current iOS/Xcode combination. If it doesn't, the lab needs a different mechanism — `Task.detached` posting off MainActor to `@Published` / `@Observable` is more reliably flagged by the concurrency runtime.
- **Fix the `Task.detached` vs `DispatchQueue.global` inconsistency** in the investigation guide step.
- **Show the learner what to look for** — quote or describe the exact warning string (e.g., "Publishing changes from background threads is not allowed").
- Consider whether the lab should use `Task.detached` in the runner (matching the investigation guide) since that's the modern Swift concurrency pattern the lab is meant to teach.

---

## 14. Main Thread I/O Lab 🟡

**What it does:** Reads a 256 KB temp file 10× synchronously on `@MainActor` using `Data(contentsOf:)`.

**Instruction clarity:** Two reproduction steps — the second offers "Time Profiler, or Pause the debugger" as alternatives without explaining that these require different launch paths. Time Profiler needs ⌘I first; the debugger is already attached on a normal ⌘R run.

**Pedagogy:** Real I/O wait on the main thread. Correct concept.

**Recommended improvements:**
- **Split the two tool paths** into separate numbered steps: (a) Pause the debugger during the stall and click `trigger()` to see `Data(contentsOf:)` on the main stack — no relaunch needed. (b) For a Time Profiler trace, launch through Instruments first (⌘I) then tap Run scenario while recording.
- **Hitch may be subtle on simulator.** Modern NVMe SSD or simulator's virtual I/O may read 256 KB in <1 ms. Consider increasing `blobByteCount` or `readIterations` if the hitch is imperceptible in testing.
- **Hang Lab contrast is stale** here too — "Hang Lab shows compute-heavy frames" should now say "Hang Lab shows a `Thread.sleep` wait; this lab shows `read` / `Data(contentsOf:)` I/O syscall frames."

---

## 15. Scroll Hitch Lab 🟡

**What it does:** A `LazyVStack` of 44 rows, each using `.compositingGroup()` + a large shadow. `trigger()` increments `autoScrollNonce` which the view uses to programmatically scroll.

**Instruction clarity:** "Profile with Instruments > Core Animation" — this template name may not exist verbatim in all Xcode versions.

**Pedagogy:** The compositing cost per row is real. The auto-scroll approach means the learner doesn't need to manually scroll. Good.

**Recommended improvements:**
- **Name the Instruments template precisely** for current Xcode. In recent versions the relevant template may be "Animation Hitches" or the "Scrolling" template rather than "Core Animation." Add a note: "the exact template name varies by Xcode version — look for Core Animation, Scrolling, or Animation Hitches."
- **"Drag the horizontal 'Probe' chips"** while auto-scroll is running is ambiguous — are the chips expected to respond (sluggishly) or not respond at all? Clarify: "try dragging the probe chips during the scroll — they may stutter or feel delayed, confirming the render budget is saturated."
- **Missing: what to look for in the trace.** The investigation guide says "look for elevated frame time or compositing cost" but doesn't say where — which track, which threshold, what the elevated value looks like vs normal.
- The investigation guide mentions `ScrollHitchLabRunner` but the actual type is `ScrollHitchLabScenarioRunner`. Fix the name.

---

## 16. Startup Signpost Lab 🟡

**What it does:** Three synchronous CPU phases on `@MainActor`, each wrapped in `os_signpost(.begin/.end)` with `PointsOfInterest` category.

**Instruction clarity:** The Instruments-first ordering is already correct (step 1 is "From Xcode, choose Product → Profile"). Good.

**Pedagogy:** The three named intervals (`SignalLabStartupConfig`, `SignalLabStartupAssets`, `SignalLabStartupReady`) are specific and verifiable.

**Recommended improvements:**
- **Template availability caveat.** "Pick Points of Interest" may not be an immediately visible template. In some Xcode versions it's under a filter or requires scrolling. Note: "If you don't see it listed, use the search field in the template picker and search for 'Points of Interest'."
- **Duplicate learning goal.** "Read cold/warm startup stories as named phases" and "Use named intervals instead of one anonymous main-thread blob" say the same thing. Remove the duplicate.
- **Missing context:** The work is synchronous on the main thread (so it also triggers hang detection). The instructions should note: "the 'hang detected' messages in the console are expected — the lab intentionally uses synchronous work to create visible intervals. Signposts annotate work; they don't fix blocking."

---

## 17. Concurrency Isolation Lab 🔴

**What it does:** Two `Task.detached` tasks hop to `MainActor` to append "alpha"/"beta" labels. A third task captures a non-Sendable `IsolationLabNonSendableToken`.

**Instruction clarity:** Mixes two separate problems — runtime ordering non-determinism and compile-time Sendable warnings — without clearly separating them.

**Pedagogy — critical issues:**

1. **Ordering may not be non-deterministic in practice.** Two tasks that immediately `await MainActor.run` are likely scheduled in FIFO order on the main actor. The learner may tap Run many times and always see `alpha, beta` — making the lab appear broken. Reliable non-determinism requires the tasks to do actual work on background threads before hopping to main.

2. **Build-time vs runtime distinction is blurred.** "Open the Issue navigator and the build log for Sendable / isolation warnings" — these are compiler warnings visible at any time, not produced by tapping Run scenario. The instructions imply they appear after running.

3. **Two separate problems in one lab.** Non-deterministic ordering (concurrency) and Sendable violations (isolation) are distinct concepts. Teaching both simultaneously dilutes both.

**Recommended improvements:**
- **Fix the non-determinism.** Add a `Task.sleep` or real async work before the `MainActor.run` hop so the tasks genuinely race. Currently the two hops are essentially synchronous from the scheduler's perspective.
- **Separate the two teaching points** into distinct steps: step 1–2 is the ordering observation (runtime), step 3 is the Sendable warning (build-time). Explicitly label which tool reveals each.
- **Clarify that Sendable warnings are always there** — they don't require tapping Run scenario. The learner should look at the Issue navigator before running anything.

---

## Cross-Lab Issues

### Hang Lab contrast is stale in three labs
Deadlock Lab, Main Thread I/O Lab, and Thread Performance Checker Lab all contrast themselves with "Hang Lab shows compute-heavy frames." Hang Lab now uses `Thread.sleep`, which shows waiting frames. All three need the contrast updated.

### Instruments-first order
CPU Hotspot Lab was just fixed. **Scroll Hitch Lab** and **Startup Signpost Lab** should be verified to confirm they both correctly lead with the Instruments launch step before the trigger action.

### Scheme-diagnostics labs need rebuild callouts
Thread Sanitizer, Zombie Objects, Thread Performance Checker, and Malloc Stack Logging all require either enabling a scheme diagnostic or changing a scheme setting. Only Thread Sanitizer currently lacks a note that the setting requires a full rebuild (⌘R or ⌘I), not just Continue.

### Labs with no visible first signal before opening a tool
Malloc Stack Logging, Thread Sanitizer, Thread Performance Checker, and Background Thread UI Lab have no in-app feedback that confirms the scenario fired correctly. Heap Growth Lab has the live counter. The scheme-diagnostics labs need at minimum a status message that says "scenario complete — N allocations / race iterations / notifications posted" so the learner knows to proceed to the tool.
