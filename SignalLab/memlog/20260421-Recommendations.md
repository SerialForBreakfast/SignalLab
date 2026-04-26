# 2026-04-21 Lab Recommendations

This memo applies the current [BestPractices.md](BestPractices.md) guidance to the labs from **Retain Cycle Lab** onward.

The main lesson from the Retain Cycle Lab iteration is blunt: a lab is not clear just because the underlying code is technically correct. The user must know what evidence they are looking for before they open Xcode, and the tool target must be named in language the lab already introduced.

## Cross-Cutting Recommendations

### 1. Give Every Lab One Explicit Learner Win

Each lab should state, internally and in docs, the one sentence the learner should be able to say at the end.

Good examples:

- Retain Cycle: "I can point to `RetainCycleLabCheckoutScreen -> RetainCycleLabCloseButtonHandler -> RetainCycleLabCheckoutScreen`."
- Hang: "I can pause during the freeze and point to main-thread work blocking the run loop."
- CPU Hotspot: "I can point to one app-owned hot frame in Time Profiler."
- Thread Sanitizer: "I can name the shared state and the two conflicting access paths."

If the learner win requires several caveats, the lab is probably teaching too much at once.

### 2. Show Expected Evidence Before Opening Xcode

The app UI should preview the evidence the learner is trying to find:

- Memory Graph labs: expected object path or ownership shape.
- Debugger pause labs: expected main-thread frame name.
- Instruments labs: expected symbol, signpost interval, allocation type, or frame-time symptom.
- Scheme diagnostic labs: expected warning family and where it appears.

This avoids "hunt around the tool until something seems relevant."

### 3. Rename Targets Into Learner Vocabulary

Do not ask learners to find "session", "manager", "coordinator", "token", or "node" unless the lab UI has already explained that thing.

Prefer names that encode the lesson:

- `RetainCycleLabCheckoutScreen`
- `RetainCycleLabCloseButtonHandler`
- `MainThreadIOLabSynchronousFileReader`
- `ThreadSanitizerLabSharedCounter`
- `MallocStackLoggingLabRowArrayFactory`

The Memory Graph and Instruments target name should be a teaching asset, not an implementation leak.

### 4. Reconsider Broken/Fixed Per Lab

Broken/Fixed is useful when the comparison directly proves the diagnostic conclusion. It is noise when the lesson is only about finding evidence.

Keep Broken/Fixed when:

- the learner needs a before/after trace
- the fixed path proves a real engineering choice
- the UI can compare symptoms without extra ceremony

Hide it when:

- the lab is a tool-navigation exercise
- fixed mode requires explaining code instead of the diagnostic
- the picker distracts from one target action

### 5. Stop Using Repetition As Proof Unless Repetition Is The Bug

Avoid "run this three times" or "open and close repeatedly" unless the diagnostic concept is accumulation or nondeterminism.

Allowed:

- Heap Growth: repeated runs create memory growth.
- CPU/scroll performance: repeated interaction gives the profiler samples.
- Concurrency ordering: repeated runs reveal nondeterminism.

Avoid:

- repeated checkout opens just to make Memory Graph easier
- repeated toggling to compensate for vague diagnostic text
- fixed/broken cycling before the learner has seen first evidence

### 6. Scheme Diagnostic Labs Need a Preflight Pattern

Thread Performance Checker, Zombies, Thread Sanitizer, and Malloc Stack Logging all require scheme changes. These labs should use a consistent UI section:

```text
Before running:
1. Product > Scheme > Edit Scheme
2. Run > Diagnostics
3. Enable <diagnostic>

Expected evidence:
<exact warning/crash/report family>
```

The lab should also say when to turn the diagnostic back off.

### 7. Prefer Tool-Specific Lab UI Over Generic Scaffold Copy

The generic sections are useful for catalog consistency, but advanced tool labs need a compact, task-specific surface. The lab screen should not duplicate reproduction, hints, steps, and validation in slightly different words.

Recommended simplified lab UI:

- **Symptom**: what the app does
- **Do this in Xcode**: exact tool path
- **Look for**: exact symbol/object/message
- **Done when**: one sentence

## Per-Lab Recommendations

## Retain Cycle Lab

**Current status:** Recently improved, but must be validated in real Memory Graph.

**Learner win:** The learner can identify a two-object ownership loop in Memory Graph:

```text
RetainCycleLabCheckoutScreen
  -> RetainCycleLabCloseButtonHandler
  -> RetainCycleLabCheckoutScreen
```

**Recommendations:**

- Keep the new two-object fixture. It is better than the previous UIKit view-controller/session graph.
- Verify on device and simulator that `RetainCycleLabCheckoutScreen` appears in the left Memory Graph navigator after one run.
- Add a screenshot or short reference image to the guide showing the expected selected object and connected handler.
- Avoid saying "node" in learner-facing text unless first defined as "the box in Memory Graph."
- Keep Fixed mode hidden. The lab is teaching Memory Graph shape, not code repair.

**Best-practice driver:** Name tool targets in learner language; show expected evidence before opening Xcode.

## Hang Lab

**Current issue:** The lab has a strong visible symptom, but the instructions mix observing, fixed comparison, and debugger pause ordering.

**Learner win:** The learner can pause during the freeze and point to `HangLabWorkload.simulateReportProcessing` on the main thread.

**Recommendations:**

- Put the expected paused frame on the lab screen before the user runs: `HangLabWorkload.simulateReportProcessing`.
- Make Broken mode the primary first path. Fixed mode should be validation after the debugger evidence, not a prerequisite.
- Add a "Do this while frozen" row with the Pause icon and "select main thread" instruction.
- Reduce copy that contrasts every neighboring lab; keep only one line: "Frozen UI + busy main thread = Hang Lab."
- Consider extending the freeze duration slightly if users cannot pause before work completes.

**Best-practice driver:** One-step gain; make call stack navigation worth it.

## CPU Hotspot Lab

**Current issue:** The lab names three possible hotspots up front, which may make the profiler feel like confirmation of source knowledge rather than discovery.

**Learner win:** The learner can use Time Profiler to identify one app-owned hot frame and then explain the redundant work.

**Recommendations:**

- The UI should display the symptom and expected profiler target: "Look for app frames under `CPUHotspotLabSearch`."
- Avoid listing all three implementation problems before profiling. Let the trace reveal at least the first one.
- Add a compact "Profiler setup" section: Product > Profile > Time Profiler > Record > sort by Self Time.
- Make the first validation narrower: "Find one hot app frame." Then use docs to expand to the three redundant operations.
- Use a deterministic query, such as `memory`, and show it in UI so every learner records the same workload.

**Best-practice driver:** Keep first tool honest; source should not reveal the answer before the tool.

## Thread Performance Checker Lab

**Current issue:** The lab depends on Hang Lab and a scheme diagnostic, but the expected warning is not concrete enough.

**Learner win:** The learner can enable Thread Performance Checker and connect one warning to main-thread work.

**Recommendations:**

- Add a preflight diagnostic card with the exact scheme path.
- State the expected evidence family: a runtime warning about work or priority on the main thread. If the actual warning varies by Xcode version, list acceptable variants.
- Do not make the learner "skim Hang Lab" as a step. Instead, reuse Hang Lab's same run target and say "this diagnostic explains the same freeze differently."
- Include a "No warning?" troubleshooting row: confirm scheme diagnostic is enabled, relaunch from Xcode, run Broken mode.
- Hide Broken/Fixed in this lab if it is only delegating to Hang Lab. The mode choice belongs to the target lab, not the checker lab.

**Best-practice driver:** Scheme diagnostic preflight; expected evidence before tool use.

## Zombie Objects Lab

**Current issue:** The learner compares Zombies off and on, but the exact expected diagnostic text/object should be more prominent.

**Learner win:** The learner can explain that Zombies turns a vague use-after-free crash into a named deallocated-object diagnosis.

**Recommendations:**

- Put "opposite of Retain Cycle" in the UI as a short contrast:
  - Retain Cycle: object stayed alive.
  - Zombies: object was already deallocated.
- Show the expected object/type name from the Objective-C fixture before running.
- Start with Zombies enabled. Running without Zombies first is useful context, but it delays the payoff.
- Move the "without Zombies" comparison into an optional validation step.
- Add a clear "turn Zombies off afterward" row because scheme diagnostics persist.

**Best-practice driver:** One-step gain; diagnostic messages must be beginner-readable.

## Thread Sanitizer Lab

**Current issue:** The lab asks the user to extract threads, variable, and stacks from a sanitizer report, but the expected report target is not named clearly enough in the UI.

**Learner win:** The learner can point to `ThreadSanitizerLabSharedCounter` or equivalent shared state and explain two unsynchronized accesses.

**Recommendations:**

- Rename the shared counter type/property if needed so the TSan report contains a learner-facing name.
- Show the expected report anatomy in UI:
  - shared state
  - first access stack
  - second access stack
- Avoid presenting wrong ordering and data races too close together. The lab should focus on memory access conflict, not async ordering.
- Use one Broken run if the race reports deterministically. If not deterministic, explicitly say repetition is required because race detection depends on schedule timing.
- Fixed mode should be validation only: same counter, serialized access, no TSan report.

**Best-practice driver:** Name tool targets; repetition only when nondeterminism is the lesson.

## Malloc Stack Logging Lab

**Current issue:** The lab is conceptually strong but tool-heavy. It mixes scheme setup, Instruments, LLDB `malloc_history`, and fixed-mode buffer reuse.

**Learner win:** The learner can point to one allocation backtrace that shows where suspicious bytes were created.

**Recommendations:**

- Pick one primary workflow for the lab UI: Instruments Allocations first. Move LLDB `malloc_history` to the long-form guide.
- Rename the allocation source to a memorable app symbol such as `MallocStackLoggingLabRowArrayFactory`.
- Show the exact target allocation in the UI: "row arrays allocated by <symbol>."
- Do not require Fixed twice unless the second run is the actual lesson. If the warmup matters, label it as "Warm buffer once; measure second run."
- Add a "turn off Malloc Stack Logging" reminder because of overhead and disk impact.

**Best-practice driver:** Keep first tool honest; avoid multiple tool paths in the primary flow.

## Heap Growth Lab

**Current issue:** Repetition is appropriate here, but the learner needs a clearer visible memory signal before opening Instruments.

**Learner win:** The learner can explain that memory grows because retained chunks accumulate linearly, not because objects form a cycle.

**Recommendations:**

- Keep repeated runs; accumulation is the concept.
- Show a compact live panel:
  - retained chunk count
  - approximate retained bytes
  - cap in Fixed mode
- Rename retained buffers if needed so Memory Graph / Allocations shows a learner-facing type, not generic `Data`.
- Use a larger chunk size if 256 KB is too subtle in Xcode memory gauges.
- Add a visual contrast to Retain Cycle:

```text
Heap Growth: cache -> chunk -> chunk -> chunk
Retain Cycle: object A -> object B -> object A
```

**Best-practice driver:** Repetition is valid when accumulation is the lesson; show the first visible memory signal.

## Deadlock Lab

**Current issue:** The lab intentionally freezes permanently, so it must be more explicit about the destructive path and the expected paused stack.

**Learner win:** The learner can pause the frozen app and distinguish "waiting on itself" from CPU work.

**Recommendations:**

- Add a destructive-run warning directly above Run scenario when Broken mode is selected.
- Show expected paused evidence: `DispatchQueue.main.sync` / dispatch sync wait frames on the main thread.
- Avoid requiring Fixed first unless it proves a necessary baseline. If kept, label it "optional sanity check."
- Add an escape hatch: Stop in Xcode, relaunch, return to Fixed.
- Consider isolating Broken mode behind a separate "Trigger deadlock" button to prevent accidental taps during browsing.

**Best-practice driver:** Every action should have payoff; destructive scenarios need clear preflight and recovery.

## Background Thread UI Lab

**Current issue:** The lab depends on runtime warning behavior that may vary across SwiftUI/Xcode versions.

**Learner win:** The learner can identify that UI-facing state was updated from the wrong thread and fix delivery via MainActor.

**Recommendations:**

- Add an in-app thread label before and after run:
  - expected delivery thread
  - observed delivery thread
- Make the app itself show the wrong-thread evidence even if Xcode's runtime warning wording changes.
- Rename internal values to learner-facing terms: `observedDeliveryThread`, `expectedDeliveryThread`, `uiUpdateMessage`.
- If the console warning is not deterministic, do not make it the only success criterion.
- Fixed mode should show "posted after MainActor hop" in the status panel.

**Best-practice driver:** Diagnostic messages and visible values should be beginner-readable and deterministic.

## Main Thread I/O Lab

**Current issue:** The lab has a good symptom, but the expected stack evidence is broad: "file-read / I/O frames."

**Learner win:** The learner can pause during a hitch and point to synchronous file read work on the main thread.

**Recommendations:**

- Put the exact expected app frame on screen, such as `MainThreadIOLabScenarioRunner.runSynchronousReads`.
- Add a status panel showing read count and bytes read so the user knows the stall did real work.
- Use debugger pause as the primary first tool; Time Profiler can be supporting.
- Avoid asking users to estimate real-feature reads in the primary flow. Keep that in the long-form guide.
- Fixed mode validation should emphasize that bytes are the same; only thread placement changed.

**Best-practice driver:** Make call stack navigation worth it; one clear frame beats generic I/O wording.

## Scroll Hitch Lab

**Current issue:** The lab likely needs clearer instrumentation guidance and a stronger visible frame-pacing signal.

**Learner win:** The learner can connect uneven scroll/frame timing to expensive per-row visual effects.

**Recommendations:**

- Add an in-app run panel:
  - active mode
  - auto-scroll state
  - expected expensive modifier in Broken mode
- Do not reveal every implementation detail before profiling. Say "look for expensive row rendering/compositing"; move exact modifiers to source check.
- Choose one primary Instruments path for the UI. If Core Animation template names vary, document variants in the guide.
- Consider adding signposts around the auto-scroll window so the trace has a named interval.
- Make the "probe chips" purpose explicit: they prove the UI still responds but frame pacing is uneven.

**Best-practice driver:** Expected evidence before tool use; do not reverse-engineer buried system frames.

## Startup Signpost Lab

**Current issue:** Fixed mode is the teaching mode because it emits signposts. That is acceptable, but it should be framed explicitly.

**Learner win:** The learner can see named startup phases in Instruments instead of one anonymous block of work.

**Recommendations:**

- Make Fixed mode the primary mode and rename the comparison mentally:
  - Uninstrumented
  - Signposted
- Consider hiding Broken/Fixed labels for this lab in favor of "Without Signposts" / "With Signposts."
- Show expected intervals in the UI before recording:
  - `SignalLabStartupConfig`
  - `SignalLabStartupAssets`
  - `SignalLabStartupReady`
- Keep checksum parity, but do not let it dominate the UI. It is validation, not the tool lesson.
- Add a "record one run per trace" instruction to keep the POI lane clean.

**Best-practice driver:** Tool target names should be learner-facing; mode labels should match the lesson.

## Concurrency Isolation Lab

**Current issue:** The lab currently mixes nondeterministic ordering, Sendable/isolation warnings, and Thread Sanitizer contrast.

**Learner win:** The learner can explain that unstructured detached tasks made completion order nondeterministic, and structured async work makes the order deterministic.

**Recommendations:**

- Decide whether the first tool is the app's completion log or the Issue navigator. The current flow says both.
- If the completion log is the first evidence, make it the primary UI:
  - run 1 order
  - run 2 order
  - expected fixed order
- If the Issue navigator is the first tool, make the non-Sendable warning deterministic and name the exact warning text family.
- Avoid requiring three runs unless variability is needed. If it is needed, label repetition as the point.
- Keep Thread Sanitizer contrast short; this lab should not teach TSan again.

**Best-practice driver:** Keep first tool honest; repetition only when nondeterminism is the lesson.

## Recommended Implementation Order

1. **Retain Cycle Lab validation**: verify the new two-object Memory Graph output and add a reference screenshot/guide language if needed.
2. **Hang + Main Thread I/O**: add exact expected paused frame names to UI and docs.
3. **Scheme diagnostic labs**: standardize preflight cards for Thread Performance Checker, Zombies, Thread Sanitizer, and Malloc Stack Logging.
4. **CPU Hotspot + Scroll Hitch**: reduce source-spoiling copy and add clearer profiler target panels.
5. **Heap Growth**: add visible chunk/byte signal and clearer linear-vs-cycle visual.
6. **Startup Signpost + Concurrency Isolation**: revisit mode labels and first-tool honesty.

## Fixed Mode And Reset Audit

Default stance: hide Fixed mode and hide Reset unless they add direct diagnostic value. A comparison control is not automatically educational. It often teaches "toggle the app" instead of "use the tool."

### Decision Rules

Keep **Fixed mode** only when the learner needs it to prove the diagnostic conclusion:

- performance trace before/after
- sanitizer warning before/after
- bounded-vs-unbounded memory behavior
- same workload, different thread placement

Hide **Fixed mode** when:

- the lab is about initial tool use
- the fixed path mainly teaches code repair
- the diagnostic evidence is already complete from the broken path
- the mode picker distracts from the exact object/frame/message to find

Keep **Reset / Restart** only when it clears state that otherwise prevents the next valid run:

- accumulated memory
- ongoing async work
- auto-scroll/profiling run state
- a destructive/frozen scenario that needs a clear recovery path

Hide **Reset / Restart** when:

- a second run simply overwrites the previous result
- the lab has no meaningful persistent state
- the button invites unnecessary experimentation before the learner has used the intended tool

### Recommended Mode/Reset Matrix

| Lab | Fixed mode? | Reset/Restart? | Rationale |
| --- | --- | --- | --- |
| Crash Lab | Hide | Hide | The lesson is first-crash evidence: highlighted line, console, stack, caller locals. Fixed mode and reset distract. |
| Exception Breakpoint Lab | Hide | Hide | The useful comparison is no breakpoint vs exception breakpoint, not broken vs fixed code. |
| Breakpoint Lab | Hide | Hide | One wrong visible result plus one line breakpoint is enough. Reset adds no evidence. |
| Retain Cycle Lab | Hide | Hide in UI | One retained graph target teaches Memory Graph. Internal reset can exist for tests, but learner-facing reset is noise. |
| Hang Lab | Consider hide initially; optional validation later | Hide unless async work can overlap | Fixed mode has value only after the learner pauses and finds `HangLabWorkload.simulateReportProcessing`. The first UI should prioritize Broken evidence. |
| CPU Hotspot Lab | Keep | Hide | Fixed mode is valuable because profiler comparison proves optimization. Reset is not useful; query changes are enough. |
| Thread Performance Checker Lab | Hide | Hide | This is a scheme diagnostic exercise over Hang Lab behavior. Mode choices belong in the target workload, not this lab. |
| Zombie Objects Lab | Likely hide from primary UI | Hide | The main lesson is Zombies-on diagnostic clarity. Fixed mode teaches code safety, but can be optional guide content after the tool payoff. |
| Thread Sanitizer Lab | Keep | Hide | Fixed mode is valuable because the same shared state should stop producing TSan reports after serialization. Reset is not meaningful if each run creates fresh work. |
| Malloc Stack Logging Lab | Consider hide; prefer "Measure Broken" + optional validation | Keep only if warm reusable buffer state matters | Fixed mode is only valuable if the learner measures fewer allocations. If warmup requires two runs, label it explicitly rather than exposing generic reset. |
| Heap Growth Lab | Keep | Keep | This is one of the strongest cases for both. Repeated runs accumulate state; reset clears retained chunks; Fixed proves bounded retention. |
| Deadlock Lab | Hide generic Fixed mode; use guarded destructive action | Restart/Stop guidance required, not generic Reset | Broken permanently freezes. A mode picker is risky. Prefer an explicit "Trigger deadlock" action with recovery instructions. |
| Background Thread UI Lab | Keep only if app shows deterministic thread evidence | Hide | Fixed mode proves MainActor delivery if the app surfaces observed vs expected thread. Reset adds no value. |
| Main Thread I/O Lab | Keep | Keep only to cancel/clear in-flight async read | Fixed mode proves same bytes, different thread placement. Reset is useful only if it cancels or clears visible in-flight state. |
| Scroll Hitch Lab | Keep | Keep if it stops/restarts auto-scroll | Fixed mode is useful for frame pacing comparison. Restart is useful if it creates a clean profiling window. |
| Startup Signpost Lab | Replace Broken/Fixed labels | Hide | The meaningful modes are "Without Signposts" and "With Signposts." Generic Fixed mode obscures the lesson. Reset does not help; one recording per run is enough. |
| Concurrency Isolation Lab | Keep if deterministic order validation remains central | Hide | Fixed mode proves structured ordering. Reset is unnecessary if the log clearly records runs or overwrites state. |

### High-Priority Metadata Changes To Consider

1. Hide Fixed mode for `zombie_objects` unless we redesign the UI around "diagnose first, validate fix later."
2. Hide Fixed mode for `deadlock`; replace with a dedicated destructive trigger and explicit Xcode Stop/relaunch guidance.
3. Hide Fixed mode for `thread_performance_checker`; keep it as a tool setup lab, not another Hang Lab mode surface.
4. Rename Startup Signpost's picker labels or hide the generic picker; "Fixed" is not the concept.
5. Audit all labs for visible Reset. Keep it only on `heap_growth`, maybe `scroll_hitch`, and maybe `main_thread_io` if cancellation is real.

### UI Recommendation

Split the generic scaffold controls into per-lab capabilities:

- `showsModePicker`
- `modePresentation`: `brokenFixed`, `diagnosticOnOff`, `instrumentedUninstrumented`, or custom labels
- `showsResetButton`
- `resetLabel`: `Reset`, `Stop auto-scroll`, `Clear retained chunks`, `Cancel read`

This avoids forcing every lab through the same Broken/Fixed/Reset vocabulary.

## Acceptance Standard For Future Lab Reviews

A lab is ready only when a reviewer can answer these without reading source:

1. What exact symptom should I observe?
2. What exact Xcode tool path do I use first?
3. What exact object, frame, warning, symbol, interval, or value am I looking for?
4. What sentence should I be able to say when I am done?
5. Does every required action produce new evidence?

If any answer is vague, the lab should be simplified before implementation.
