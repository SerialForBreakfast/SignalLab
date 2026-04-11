# Lab Refinement

SignalLab already has labs that are functional and reproducible. That is necessary, but it is not enough.

The next step is to refine the labs so each one answers a very specific teaching question:

**What is this lab really teaching, and why is this the right tool for this moment in the curriculum?**

This document reframes the current MVP labs from a teaching-first perspective. The goal is to improve the learner experience, tighten scope, and avoid introducing advanced debugger features before the learner understands the default workflow.

---

## Core curriculum principle

Each lab should teach:

1. A clear symptom the learner can observe.
2. The first tool they should reach for.
3. The mental model that tool gives them.
4. A short validation loop in Fixed mode.

If a lab teaches too many things at once, the learner leaves with less.

A good SignalLab lab should not feel like:

- "Here is a broken sample app."
- "Here is a tool."
- "Try poking around until it makes sense."

It should feel like:

- "When you see **this** symptom, start with **this** tool."
- "Here is what that tool helps you learn."
- "Here is how to confirm your conclusion."

---

## Cross-cutting improvements

These improvements should apply to every lab, not just one.

### 1. Lead with the learner's question

The first thing a learner should understand is not the implementation detail. It is the debugging question.

Examples:

- Crash: "The app stopped. What do I look at first?"
- Breakpoint: "The app did not crash, but the result is wrong. How do I inspect the logic?"
- Retain cycle: "This screen went away, so why is the object still alive?"
- Hang: "The UI froze. How do I prove the main thread is blocked?"
- CPU hotspot: "The app is slow. How do I turn slowness into evidence?"

### 2. Prefer default workflows before specialized features

If Xcode or Instruments already gives the learner a strong default path, that path should usually come first.

Examples:

- After a crash, start with the stopped state, stack, frames, variables, and callers.
- For a logic bug, start with a line breakpoint before teaching conditional or action breakpoints.
- For a hang, start with visible UI unresponsiveness and the paused main thread before introducing profiling.

Specialized tools should appear when they clearly solve a problem the default workflow does not.

### 3. Make the symptom visible without explanation

The learner should be able to say what is wrong before reading the hints.

Examples:

- Crash: app terminates or stops in debugger.
- Breakpoint: returned results clearly violate the filter expectation.
- Retain cycle: live-instance count keeps climbing.
- Hang: scroll input stops responding.
- CPU hotspot: typing or interaction becomes obviously sluggish.

### 4. Write reproduction steps as observations, not just actions

Bad:

- "Tap Run scenario."
- "Open Memory Graph."

Better:

- "Tap Run scenario. The app should stop in Xcode."
- "Open and close the sheet three times. The live-instance count should keep climbing."

### 5. Fixed mode should prove the lesson, not just show green output

Fixed mode should answer:

**What changed in behavior, and why does that confirm the diagnosis?**

That means the learner should be able to compare:

- stopped vs no crash
- wrong results vs correct results
- leaked instances vs released instances
- frozen UI vs responsive UI
- hot path vs cheaper path

---

## Lab-by-lab refinement

## Crash Lab

### What it should really teach

**When the app crashes in Xcode, how do I use the default debugger state to find the cause?**

This should be the learner's first crash workflow:

1. The app stops.
2. Xcode highlights a line.
3. The learner looks at the stack.
4. The learner finds the relevant frame in their code.
5. The learner inspects variables and caller context.
6. The learner explains the bad assumption.

That is a clean, foundational lesson.

### What it currently teaches too early

The current framing leans on **exception breakpoints** as the primary teaching tool.

That is premature for an intro crash lab.

A beginner first needs confidence with:

- the stopped debugger state
- the call stack
- the current frame
- local variables
- moving to the caller

If we make exception breakpoints the hero too early, the learner may miss the more basic lesson:

**Xcode already gave you useful evidence the moment the app stopped.**

### Proposed new teaching goal

Crash Lab should become:

**"The app crashed. Use the Debug area, stack frames, and variables to explain why."**

### What to emphasize

- What a crash looks like under the debugger
- How to distinguish app frames from system frames
- Why the top highlighted line is important, but not always the whole story
- How to inspect the malformed row or missing field
- How the caller helps explain where unsafe assumptions entered the flow
- How Fixed mode confirms the diagnosis by validating input

### What to de-emphasize

- Exception breakpoints as the main workflow
- Debugger configuration as the first lesson
- Any wording that implies "add this breakpoint first" before the learner understands the crash state itself

### Better framing for the lab

- Symptom: "The import crashes on the second row."
- First tool: "The default debugger view after the crash."
- Teaching outcome: "I can identify the bad assumption by reading the stack and inspecting the current row."
- Fixed validation: "The malformed row is skipped safely, proving the parser now handles invalid input."

---

## Proposed new lab: Exception Breakpoints

### What it should really teach

**When is the default crash stop not enough, and when does an exception breakpoint help?**

This is a strong concept, but it should be taught intentionally, not embedded inside the intro crash lesson.

### Why it deserves its own lab

Exception breakpoints are valuable when the learner already understands:

- what a normal crash stop looks like
- what a stack frame is
- why stopping earlier or more consistently can help

Then the learner can appreciate the actual value:

- catching failures earlier
- standardizing where execution stops
- breaking on thrown exceptions or runtime faults across flows
- comparing a default crash stop with an explicit debugger stop policy

### Good teaching question

**"What does an exception breakpoint give me that I did not already have?"**

If the lab cannot answer that clearly, it should not exist yet.

### Placement

This should come after Crash Lab, not before it.

### Working recommendation

Place this lab **immediately after Crash Lab**, but keep it intentionally narrow.

That sequence keeps the comparison fresh:

- Crash Lab teaches how to read the default stop you already have.
- Exception Breakpoint Lab teaches when changing debugger stop policy gives you more leverage.

If the lab starts expanding into a broader debugger-configuration lesson, move it later again. The placement only works if the lab stays short and comparison-based.

---

## Proposed diagnostics track

The current MVP labs teach core debugging workflows well:

- Crash Lab teaches the default stopped debugger state.
- Exception Breakpoint Lab teaches debugger stop policy.
- Breakpoint Lab teaches manual inspection of wrong logic.
- Retain Cycle Lab teaches ownership and object lifetime.
- Hang Lab teaches manual proof of main-thread blockage.
- CPU Hotspot Lab teaches profiling a slow path.

The next curriculum layer should teach **scheme diagnostics** and related runtime tooling on top of those basics.

These labs should stay out of the MVP-critical path, but they are strong candidates for the first post-MVP curriculum expansion because they teach learners how to turn on Xcode runtime help intentionally instead of guessing.

### Recommended order

1. **Thread Performance Checker Lab**  
   Teaching question: **"Why does the app feel stuck, and what scheme diagnostic proves it?"**
2. **Zombie Objects Lab**  
   Teaching question: **"How do I turn an ambiguous memory crash into a clear 'message sent to deallocated object' diagnosis?"**
3. **Thread Sanitizer Lab**  
   Teaching question: **"How do I prove unsafe concurrent access instead of guessing?"**
4. **Malloc Stack Logging Lab**  
   Teaching question: **"How do I recover allocation history for a suspicious object?"**

### Why this order

- **Thread Performance Checker** should come first because it extends Hang Lab naturally:
  - Hang Lab teaches the learner to pause the app and inspect the blocked main thread manually.
  - Thread Performance Checker should then teach how Xcode can surface the same family of issue as a scheme-level warning.
  - This keeps the new lab additive instead of duplicative.

- **Zombie Objects** should come next because it is concrete, visual, and easy to explain:
  - you have a memory-lifetime problem
  - the default symptom is ambiguous
  - enabling Zombies changes the failure into a clearer diagnosis

- **Thread Sanitizer** should come after that because it is more advanced:
  - the learner needs to understand that this is about unsafe concurrent access, not just async work finishing out of order
  - the lab should use a deterministic shared-state race, not a vague "sometimes wrong" demo

- **Malloc Stack Logging** should come last because it is powerful but more forensic:
  - it is best once the learner already understands leaks, deallocation bugs, and allocation history as a question worth asking
  - it should not be framed as a beginner memory workflow

### Boundary notes

- **Thread Performance Checker Lab** is **not** Hang Lab 2. It should teach:
  - how to enable the scheme diagnostic
  - what warning or evidence Xcode gives you
  - what that warning means
  - what code change the learner should investigate next

- **Zombie Objects Lab** is **not** Retain Cycle Lab. It should teach:
  - use-after-free style diagnosis
  - why enabling Zombies changes the crash message into something more actionable

- **Thread Sanitizer Lab** is **not** just "async code is tricky." It should teach:
  - shared mutable state
  - concurrent access without a serialization rule
  - why the sanitizer gives stronger proof than print statements alone

- **Malloc Stack Logging Lab** is **not** a generic memory lab. It should teach:
  - allocation history
  - object provenance
  - how to ask "where did this come from?" after the learner already knows why that question matters

### Thread Performance Checker Lab

#### What it should really teach

**When the app feels stuck, how can a scheme diagnostic confirm the main-thread problem without relying only on manual pausing?**

This lab should sit immediately after Hang Lab in the learner's mental model, even if it ships later:

- Hang Lab teaches manual proof by pausing the app and inspecting the main thread.
- Thread Performance Checker Lab should teach how Xcode surfaces the same category of issue as a runtime warning when the scheme diagnostic is enabled.

#### The teaching shape

- Symptom: "The interaction feels stuck or unusually sluggish while work runs."
- First tool: "Enable Thread Performance Checker in the scheme diagnostics, then rerun."
- Mental model: "The checker is evidence that important work is happening on the wrong thread or with the wrong scheduling assumptions."
- Validation: "The warning disappears or the problematic call path changes after the fix."

#### What it should emphasize

- How to enable the checker in the Xcode scheme
- What warning Xcode surfaces and where the learner sees it
- How to connect that warning back to the code path already learned in Hang Lab
- Why the warning is useful even when the app does not crash

#### What it should not become

- A duplicate of Hang Lab's paused-debugger walkthrough
- A generic "performance is bad" lab
- A lesson about profiling hot functions; that remains CPU Hotspot Lab

#### Better framing for the lab

- Symptom: "The UI feels stuck during report processing."
- First tool: "Thread Performance Checker."
- Teaching outcome: "I can explain what runtime warning Xcode gives, where it points me, and why that warning supports the diagnosis."
- Fixed validation: "The same interaction no longer triggers the checker and the UI remains responsive."

### Zombie Objects Lab

#### What it should really teach

**How do I turn an unclear memory crash into a direct 'message sent to deallocated object' diagnosis?**

This is a strong diagnostics lab because the scheme toggle changes the kind of evidence the learner gets.

#### The teaching shape

- Symptom: "The app crashes later, after a screen or helper object should already be gone."
- First tool: "Enable Zombie Objects in the scheme diagnostics."
- Mental model: "The object died earlier; the crash is really about a later message being sent to released memory."
- Validation: "The learner can name the deallocated object and the code path that uses it too late."

#### What it should emphasize

- Why the default crash can feel ambiguous
- What enabling Zombies changes about the diagnostic message
- How the new message narrows the search to object lifetime and delayed use
- Why this is different from a retain cycle, where the object stays alive too long

#### What it should not become

- Retain Cycle Lab with different wording
- A broad memory-management survey
- A deep ARC internals lesson

#### Better framing for the lab

- Symptom: "A callback fires after the owning object is gone, and the crash is not obvious at first."
- First tool: "Zombie Objects."
- Teaching outcome: "I can use the new crash message to identify which released object is being touched."
- Fixed validation: "The late message path is removed or ownership changes so the object is still valid when touched."

### Thread Sanitizer Lab

#### What it should really teach

**How do I prove unsafe concurrent access instead of guessing from intermittent wrong behavior?**

This lab should be later because the learner must already distinguish:

- async ordering bugs, where completion order is wrong
- from true concurrent-access bugs, where two execution contexts touch shared mutable state unsafely

#### The teaching shape

- Symptom: "The result is intermittently wrong under repeated or concurrent actions."
- First tool: "Enable Thread Sanitizer."
- Mental model: "This is not just surprising timing; two code paths are accessing shared state without safe serialization."
- Validation: "The sanitizer stops reporting once the state is isolated, serialized, or otherwise made safe."

#### What it should emphasize

- Deterministic reproduction, not a flaky demo
- Shared mutable state as the real teaching target
- Why sanitizer evidence is stronger than print statements alone
- How the learner maps the report back to the unsafely shared state

#### What it should not become

- A vague "Swift concurrency is confusing" lab
- An async ordering lab disguised as a sanitizer lab
- A deep compiler / memory-model lecture

#### Better framing for the lab

- Symptom: "Rapid concurrent actions sometimes leave the same shared value in the wrong state."
- First tool: "Thread Sanitizer."
- Teaching outcome: "I can explain which shared state is being touched concurrently and why the sanitizer report proves it."
- Fixed validation: "The same stress case no longer reports a race after the state is isolated or serialized."

### Malloc Stack Logging Lab

#### What it should really teach

**How do I recover the allocation history of a suspicious object when I need provenance, not just current state?**

This should be explicitly advanced. The learner should already know why allocation history is worth asking about before they see this tool.

#### The teaching shape

- Symptom: "I know this object or allocation is suspicious, but I still need to answer where it came from."
- First tool: "Enable Malloc Stack Logging and inspect allocation history."
- Mental model: "Sometimes the key debugging question is not only 'what is alive now?' but 'where was this allocated?'"
- Validation: "The learner can point to the code path that created the suspicious allocation and explain why that matters."

#### What it should emphasize

- Allocation provenance rather than generic memory debugging
- How this differs from Zombies and Retain Cycle workflows
- Why this tool is more forensic and should come later
- A narrow, concrete question for the learner to answer from the allocation history

#### What it should not become

- A beginner memory lab
- A substitute for Retain Cycle Lab or Zombies
- A giant tour of every malloc diagnostic switch

#### Better framing for the lab

- Symptom: "I found a suspicious object or leak-like survivor, but I still need to know where it was created."
- First tool: "Malloc Stack Logging."
- Teaching outcome: "I can recover the allocation path for the suspicious object and connect it to a concrete code site."
- Fixed validation: "After the fix, the same suspicious allocation path is gone or no longer grows unexpectedly."

---

## Breakpoint Lab

### What it should really teach

**When the app does not crash but the result is wrong, how do I use breakpoints to inspect logic without getting lost?**

This is a good second step after Crash Lab because it shifts the learner from:

- "The app stopped for me."

to:

- "I need to decide where and when to stop."

### What to emphasize

- Start with one line breakpoint at the shared filter entry point
- Observe concrete wrong behavior before touching code
- Use the same inputs in Broken and Fixed mode
- Step through the branch where the query gets ignored
- Only then introduce conditional breakpoints and log breakpoints as ways to reduce noise

### Refinement opportunity

The current lab already has the right mechanics. The main improvement is teaching order:

1. Reproduce obvious wrong results.
2. Add one plain line breakpoint.
3. Inspect state.
4. Step through the bad branch.
5. Introduce conditional and action breakpoints as refinements, not prerequisites.

### Better framing for the lab

- Symptom: "The search result is wrong, but nothing crashed."
- First tool: "A line breakpoint at the filter entry point."
- Teaching outcome: "I can see which condition is skipped and why the result is wrong."
- Fixed validation: "The same inputs now apply both filters and return the expected result."

---

## Retain Cycle Lab

### What it should really teach

**How do I connect what I see in the UI to object lifetime and retaining paths?**

This lab should not just be about "there is a timer retain cycle." It should teach a more transferable skill:

**The UI disappearing does not guarantee the underlying object was released.**

### What to emphasize

- A visible lifetime signal before opening Memory Graph
- Repetition as evidence, not just as interaction
- The idea that "dismissed" and "deallocated" are different facts
- Memory Graph as a way to answer "who is still holding this object?"
- Fixed mode as proof that teardown or weak capture changes lifetime

### Refinement opportunity

This lab is already close. The biggest improvement is to make the teaching point less implementation-specific.

Instead of centering the lesson on:

- "Timer bad, weak self good"

the lab should center it on:

- "How do I prove an object is still alive, and how do I find what retains it?"

The timer is the scenario. Lifetime diagnosis is the lesson.

### Better framing for the lab

- Symptom: "I closed the screen, but live instances keep increasing."
- First tool: "Visible live-instance count, then Memory Graph."
- Teaching outcome: "I can identify the retaining path keeping the dismissed screen alive."
- Fixed validation: "The object deallocates after dismissal, confirming the retention problem was removed."

---

## Hang Lab

### What it should really teach

**How do I tell whether the main thread is blocked, and how do I prove it?**

This is a strong lab because the symptom is physical and immediate. The learner can feel it.

### What to emphasize

- UI responsiveness as the primary signal
- The difference between "work is happening" and "the main thread is blocked"
- Pausing the app during the freeze and inspecting the main thread stack
- Recognizing that the same work can exist in both Broken and Fixed modes, but where it runs changes the user experience

### Refinement opportunity

The lab should stay focused on responsiveness, not drift into generic performance profiling.

Time Profiler can be mentioned as supporting context, but the first lesson should remain:

**If the UI freezes, inspect the main thread.**

### Better framing for the lab

- Symptom: "The scroll probes stop responding while work runs."
- First tool: "Pause during the freeze and inspect the main thread."
- Teaching outcome: "I can prove the heavy work is running on the main thread."
- Fixed validation: "The same workload no longer blocks gestures because the heavy work moved off-main."

---

## CPU Hotspot Lab

### What it should really teach

**When interaction feels slow but not frozen, how do I use Time Profiler to find the hot path?**

This lab should not compete with Hang Lab.

Hang Lab teaches:

- blocked responsiveness
- main-thread starvation

CPU Hotspot Lab should teach:

- expensive repeated work
- slow-but-still-functioning interaction
- ranking evidence by cost in a profiler

### What it should feel like

- Typing still works, but it feels sluggish
- The app is not dead, just inefficient
- The learner records a trace and identifies the expensive repeated path

### Refinement opportunity

This lab is currently the weakest because it is still conceptual. When it is implemented, it should clearly avoid overlapping with Hang Lab.

The symptom should be:

- "This interaction is slower than it should be."

not:

- "The UI is frozen."

### Better framing for the lab

- Symptom: "Search updates are noticeably sluggish on each keystroke."
- First tool: "Instruments Time Profiler."
- Teaching outcome: "I can identify the most expensive repeated work in my code."
- Fixed validation: "The hot path becomes cheaper and the interaction feels faster."

---

## Recommended curriculum order

The order of the labs should reinforce a progression in debugging maturity.

### Suggested sequence

This is the locked working order and should match **Formalized follow-up tasks → Lock curriculum order** unless a later curriculum decision explicitly changes it:

1. **Crash Lab** — default debugger workflow after a stop.
2. **Exception Breakpoint Lab** — when changing stop policy adds value (narrow, comparison-based; catalog id `break_on_failure`).
3. **Breakpoint Lab** — deliberate stops for non-crashing logic bugs.
4. **Retain Cycle Lab** — lifetime and retaining paths.
5. **Hang Lab** — blocked main thread / frozen UI.
6. **CPU Hotspot Lab** — sluggish but responsive interaction; Time Profiler.

If Exception Breakpoint Lab grows in scope, it can move later; update this list and the curriculum map in the same edit.

### Curriculum map (one page)

Use this table when adding labs or editing copy so symptoms, first tools, and boundaries stay distinct. If a new lab blurs two rows, split the teaching goal or merge scenarios intentionally.

| Lab | Symptom (what the learner notices) | First tool (reach for this first) | Anti-confusion (adjacent labs / common mix-ups) |
|-----|-------------------------------------|-----------------------------------|--------------------------------------------------|
| **Crash Lab** | Process stops; Xcode shows faulting line, stack, and locals. | Default debugger state: **Debug navigator stack**, current frame, **Variables**, walk to **caller** for context. | **Not** Breakpoint Lab (no crash, wrong logic). **Not** Exception Breakpoint Lab here—intro crash workflow only; exception policy is the next lab. |
| **Exception Breakpoint Lab** | Same failure family as Crash Lab; you want to compare **where/when** Xcode stops with vs without an exception breakpoint. | **Exception breakpoint** (Breakpoint navigator) + compare to the **default stop** you already saw in Crash Lab. | **Not** Crash Lab (you already learned the default stop). **Not** Breakpoint Lab (line breakpoints for non-crashing logic). **Comes before** Breakpoint Lab in the locked order. |
| **Breakpoint Lab** | Same inputs, wrong rows or wrong filter outcome; app keeps running. | **Line breakpoint** at the shared decision point (e.g. filter entry); inspect state, then step. | **Not** Crash Lab (no stop unless you set breakpoints). **Not** CPU Hotspot (correctness, not cost). |
| **Retain Cycle Lab** | UI dismissed but “something is still alive” (e.g. live-instance count rises). | **Visible lifetime signal**, then **Memory Graph** / retaining paths. | **Not** Hang Lab (can be responsive yet leaked). **Not** Breakpoint Lab (not a wrong branch result). |
| **Hang Lab** | Gestures / scroll **freeze** while work runs; UI feels **stuck**. | **Pause** during freeze; **main thread** stack shows blocking work. | **Not** CPU Hotspot Lab (sluggish but **not** dead; tracing is the lead tool). **Not** Crash Lab (no termination). |
| **CPU Hotspot Lab** | Interaction **works** but feels **slow** (e.g. each keystroke is heavy). | **Instruments Time Profiler**; rank cost, tie to your code. | **Not** Hang Lab (frozen UI vs slow UI). **Not** Breakpoint Lab (performance, not wrong predicate). |

---

## What should change next

This section is historical intent only.

The authoritative status tracker for open vs completed curriculum work is **Formalized follow-up tasks** below. If these bullets and the task statuses diverge, treat the task list as the source of truth.

### Content updates

- Rewrite Crash Lab copy to center the default crash debugger workflow.
- Remove exception breakpoints as the primary recommended first tool in Crash Lab.
- Reframe each lab's learning goals around the learner question, not the implementation detail.
- Rewrite reproduction steps to describe expected observations.
- Make Fixed mode validation more explicit in every guide.

### Structural updates

- Add a new planned lab for exception breakpoints.
- Keep Breakpoint Lab focused on line, conditional, and log breakpoints for non-crashing logic bugs.
- Ensure CPU Hotspot Lab is differentiated from Hang Lab by symptom and tool choice.

### App copy updates

These files likely need follow-up edits after alignment:

- `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift`
- `SignalLab/Docs/Labs.md`
- `SignalLab/Docs/CrashLabInvestigationGuide.md`
- `SignalLab/Docs/BreakpointLabInvestigationGuide.md`
- `SignalLab/Docs/RetainCycleLabInvestigationGuide.md`
- `SignalLab/Docs/HangLabInvestigationGuide.md`
- New: `SignalLab/Docs/ExceptionBreakpointLabInvestigationGuide.md` (once the lab exists)

---

## Open questions and tradeoffs

These are not blockers; they are decisions to make when implementing the curriculum.

### Where should Exception Breakpoint Lab sit?

**Decision: place it immediately after Crash Lab in the locked working order.**

The suggested order places it **last** so specialized debugger policy never appears before basics. An alternative is **immediately after Crash Lab**, while the crash workflow is fresh—then the comparison question (“What did this add?”) is very direct.

**Recommendation:** Pilot both mentally with a beginner outline. If Exception Breakpoint Lab is short and comparison-based, **after Crash Lab** can work. If it needs more setup (multiple scenarios, filters, actions), **later** avoids cognitive overload. The doc can be updated once you pick one.

**Current decision:** Default to placing it **immediately after Crash Lab** (see **Formalized follow-up tasks**, curriculum order). If the lab grows, move it later and update the suggested sequence + curriculum map together.

### Swift traps vs “exceptions” in the narrow sense

Today’s Crash Lab stops on a **Swift runtime failure** with a clear line and stack. Teaching **exception breakpoints** honestly may require clarifying what Xcode’s “Exception Breakpoint” catches in a **Swift-heavy** app vs Objective-C `NSException`, and when behavior differs from a simple trap. The new lab should name the **symptoms** where the breakpoint helps (e.g. failures that don’t land on your code first, or you want to stop on *all* throws in a flow)—not only the checkbox name.

### Optional micro-skills inside Crash Lab

Still optional, but high leverage for some learners:

- **Frame navigation** as an explicit sub-step (“step out” / select parent frame).
- **Console** as read-only confirmation (fatal message already there)—without turning the lab into an lldb course.
- **“Your code” vs system frames** with one concrete rule of thumb (e.g. first frame under your module or first non-SwiftUI frame in the sample).

**Current recommendation:** Keep Crash Lab micro-skills to exactly three lightweight ideas:

- find the first relevant frame in your code
- inspect the current locals / malformed row
- move one caller up for context

That keeps the intro lab practical without turning it into a debugger-tour checklist.

### Per-lab “done” criteria

For each lab, one sentence of **“You’re done when you can …”** (without hints) helps authors trim copy and helps learners self-check. These can live in `LabCatalog` validation checklists—you already lean that way; make the wording match observable behavior.

**Current recommendation:** Add a single learner-facing “You’re done when…” line to every lab and keep it aligned with the investigation guide validation checklist.

### Solo learner vs classroom

The doc assumes a motivated solo user. If SignalLab is also used **live**, consider a one-line note per lab: **minimum time**, **one demo beat** (what the instructor shows first), and **one common wrong turn**—useful for workshops without bloating the app.

---

## Summary

SignalLab should teach debugging workflows, not just present broken code.

The core refinement is:

- **Crash Lab** should teach how to investigate a crash using the default debugger state.
- **Exception breakpoints** belong in their **own lab immediately after Crash Lab** (in the locked order), where their value is clear and comparable to the default stop.
- **Breakpoint Lab** should teach deliberate stopping for logic bugs.
- **Retain Cycle Lab** should teach lifetime diagnosis, not just timer trivia.
- **Hang Lab** should teach how to prove the main thread is blocked.
- **CPU Hotspot Lab** should teach how to profile slow interactions that still work.

If we keep asking "What is this really teaching?" the labs will become more useful, more memorable, and more coherent as a curriculum.

---

## Formalized follow-up tasks

These tasks convert the refinement direction into concrete project work.

**How to use this list**

- Treat **curriculum decisions (1–2)** as gates: finish them before large copy rewrites so you do not reorder the catalog twice.
- **Done when** lines are acceptance checks; skip none for shipped labs.
- Any change that touches **first tool** or **symptom** for a lab must include **`LabCatalog.swift` + `Labs.md` + that lab’s long-form guide** in one PR (task 10).

### Curriculum decisions

1. **Lock curriculum order**  
   Confirm the working sequence:  
   **Crash Lab → Exception Breakpoint Lab → Breakpoint Lab → Retain Cycle Lab → Hang Lab → CPU Hotspot Lab.**  
   **Done when:** `LabCatalog.scenarios` / `catalogSortIndex` and **Suggested sequence** above match; navigation order in the app matches.  
   **Status:** Locked — `LabCatalog` documents the order; `catalogSortIndex` 0…5; `LabCatalogTests.scenariosSortedForDisplay_matchesLockedCurriculumSlugs` asserts slug order; curriculum map table reordered to match.

2. **Choose learner-facing title for Exception Breakpoint Lab**  
   Keep the implementation/tool name accurate somewhere (subtitle or tools list), but pick a catalog title that states the *learner question* (e.g. when stop policy beats default).  
   **Done when:** Title + one-line summary are approved and reflected in `LabCatalog` and `Labs.md`.  
   **Status:** Complete — catalog title **Exception Breakpoint Lab**; summary ties to Crash Lab’s default stop; stable id remains `break_on_failure`; mirrored in `Labs.md` and `ExceptionBreakpointLabInvestigationGuide.md`.

### Content tasks

3. **Rewrite Crash Lab around the default debugger workflow**  
   Update summary, learning goals, reproduction (observation-style), hints, `recommendedFirstTool`, and investigation guide: stack → your frame → locals / bad row → caller → Fixed validation. Remove “add exception breakpoint first” as the hero path.  
   **Done when:** Crash guide + `Labs.md` + catalog match; a quick read answers “What do I look at first after the stop?” without extra breakpoint setup.  
   **Status:** Complete in catalog + `Labs.md` + `CrashLabInvestigationGuide.md` (revisit only if curriculum wording shifts).

4. **Define Exception Breakpoint Lab as a separate curriculum item**  
   In writing first: learner question, symptom, first tool, **A/B comparison** (default stop vs exception breakpoint on the same or paired scenario), Fixed or “second run” validation, and explicit **Swift trap vs Obj-C exception** note where relevant.  
   **Done when:** `ExceptionBreakpointLabInvestigationGuide.md` (or chosen name) exists and the curriculum map row for this lab is non-vague.  
   **Status:** Guide + catalog + in-app guided shell complete; keep Swift/Obj-C nuance in guide + catalog hints as tooling evolves.

5. **Implement Exception Breakpoint Lab in the app (minimal viable)**  
   New `LabScenario` id, `catalogSortIndex` after Crash, runner (can start as **guided stub** with strong copy if behavior is hard to fake), `iOSLabDetailView` route, Xcode target membership, and optional `SignalLabLog` category.  
   **Done when:** Lab appears in the list in the locked order and reproduction steps describe what to do in Xcode; expand runner later if stub.  
   **Status:** Shipped as `break_on_failure` + `iOSExceptionBreakpointLabDetailView` + stub runner; `SignalLabLog.exceptionBreakpointLab` logs when the detail scaffold appears.

6. **Tighten Breakpoint Lab teaching order in copy**  
   Reframe goals/reproduction/hints so **plain line breakpoint at filter entry** comes before conditional/log breakpoints as *refinements*.  
   **Done when:** A reader sees “one breakpoint → inspect → step” before “reduce noise.”  
   **Status:** Complete in catalog + `Labs.md` + guide ordering.

7. **Add “You’re done when…” to every lab**  
   First pass is **docs/catalog only**: one short learner-facing sentence each in `LabCatalog` copy and `Labs.md`, aligned with existing validation checklist bullets. If this proves valuable in the app UI, add a follow-up model/UI task later instead of expanding the first PR.  
   **Done when:** Every scenario in `LabCatalog` and `Labs.md` has matching “done” language; no new UI/model field is required for the first pass.  
   **Status:** Complete — each lab’s first validation bullet uses “You’re done when …”.

8. **Add Crash Lab micro-skills without scope creep**  
   In reproduction or guide only: (1) first relevant frame in app code, (2) inspect locals/malformed row, (3) select one caller for context—no lldb tutorial, no exception breakpoint.  
   **Done when:** Those three beats appear explicitly once; optional UI callouts if you add small in-app tips later.  
   **Status:** Complete in Crash reproduction + investigation steps.

### Consistency and quality tasks

9. **Update curriculum map and lab guides together**  
   After substantive edits to any lab, re-read the **Curriculum map** row for overlaps; adjust anti-confusion column if needed.  
   **Done when:** Map table still matches post-change catalog.  
   **Status:** Ongoing discipline — map reviewed with this iteration’s hint updates.

10. **Single PR rule for teaching drift**  
    If you change symptom, first tool, or core question: touch `LabCatalog.swift`, `Labs.md`, and the affected `Docs/*InvestigationGuide.md` together; add `LabRefinement.md` only when you change formal tasks or sequence.

11. **Audit adjacent-lab boundaries**  
    Re-read copy for: Crash vs Exception Breakpoint, Exception vs Breakpoint, Breakpoint vs CPU Hotspot, Hang vs CPU Hotspot, Retain vs Hang.  
    **Done when:** Each pair has at least one sentence in hints or reproduction that states the difference.  
    **Status:** Reinforced — Crash → Exception handoff; Exception vs Breakpoint; existing Hang/CPU/Retain hints retained.

12. **Clarify Swift trap vs Objective-C exception language**  
    In Exception Breakpoint Lab guide (and short catalog hint if needed): name symptoms where the Xcode control helps, not only the checkbox label.  
    **Done when:** A beginner can answer “What does this add over the stop I already had?”  
    **Status:** Catalog + `Labs.md` hint added alongside the long-form guide section.

### Pre-flight (before first commit)

- Grep the repo for `exception`, `Exception Breakpoint`, and `recommendedFirstTool` to find every Crash Lab mention to update.
- Run **`xcodebuild` build + tests** after catalog/navigation/runner changes.

### Optional (defer without blocking MVP)

- **Retain Cycle / Hang:** Reinforced — Hang Lab hint now states rising live counts without a scroll freeze point to Retain Cycle Lab; Retain hint already sent freeze cases to Hang Lab.
- **CPU Hotspot:** Shipped with live search (`CPUHotspotLabScenarioRunner` + `iOSCPUHotspotLabDetailView`); Time Profiler exercise uses the in-app field.
- **Thread Performance Checker (first diagnostics lab):** Catalog id `thread_performance_checker` — guided shell + `ThreadPerformanceCheckerLabInvestigationGuide.md`; exercise uses Xcode scheme + Hang Lab (see `Tasks.md` Epic D1.2).
- **Zombie / TSan / Malloc:** Catalog ids `zombie_objects`, `thread_sanitizer`, `malloc_stack_logging` — guided shells + investigation guides; in-app repros may use external samples until dedicated runners ship.
- **Classroom row** in Open questions: add min time + demo beat per lab when you have a workshop pilot.
