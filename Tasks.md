

# SignalLab Tasks

## Overview

SignalLab is a hands-on iOS learning app for junior and intermediate developers who want practical experience debugging real application problems with Xcode and Instruments.

This task plan is organized to support straightforward development with a clear MVP, strong separation of concerns, and incremental delivery. Each milestone is broken into focused tasks with requirements, acceptance criteria, testing expectations, and user stories where appropriate.

## Product Structure

To keep development manageable, SignalLab should be structured around a small set of shared concepts.

### Proposed top-level structure

- `SignalLabApp/`
- `App/`
- `Labs/`
- `Shared/`
- `Docs/`
- `Tests/`

### Proposed architecture concepts

- `LabCatalog`: The full set of labs shown in the app
- `LabScenario`: Metadata and behavior for a single lab
- `LabCategory`: Crash, Breakpoint, Memory, Hang, Performance, and future categories
- `InvestigationGuide`: The recommended debugging workflow for a lab
- `BrokenImplementation`: The intentionally problematic implementation used to reproduce the issue
- `FixedImplementation`: The corrected implementation used for comparison
- `LabViewModel`: Scenario state for the UI
- `ScenarioRunner`: Reproducible trigger logic for labs that can be started, repeated, reset, or compared

## Development Principles

### 1. One primary lesson per lab
Each lab must have one dominant teaching goal.

### 2. Fast reproduction
A learner should be able to trigger the bug quickly and consistently.

### 3. Broken and fixed comparison
Whenever possible, labs should provide a broken mode and a fixed mode.

### 4. Reusable infrastructure first
Build the app shell and shared lab infrastructure before building all scenario-specific screens.

### 5. Realistic examples
Prefer realistic app patterns like parsing, filtering, timers, main-thread work, and repeated expensive operations.

### 6. Test the business logic
Unit tests should focus on the underlying logic and state transitions, not trivial UI or framework behavior.

---

# MVP Definition

The MVP should include:

- Shared app shell and lab framework
- Home screen with lab catalog
- Lab detail screen with overview, controls, hints, and investigation guide summary
- Broken/fixed mode support
- The first 6 labs:
  - Crash Lab
  - Exception Breakpoint Lab
  - Breakpoint Lab
  - Retain Cycle Lab
  - Hang Lab
  - CPU Hotspot Lab
- Foundational project documentation

The MVP does not need to include:

- Advanced concurrency labs
- Heap growth lab
- Deadlock lab
- Signpost-specific labs
- Instructor mode
- Automation beyond basic reproducibility controls

The first post-MVP diagnostics expansion should prioritize:

- Thread Performance Checker Lab
- Zombie Objects Lab
- Thread Sanitizer Lab
- Malloc Stack Logging Lab

---

# Milestone 0: Foundation and App Shell

## Epic M0.1: Project setup and shared architecture

### Task M0.1.1: Establish project structure

**User Story**
As a developer, I want a clear project structure so new labs can be added without creating confusion or duplication.

**Requirements**
- Create a clear folder/module structure for app, shared logic, labs, docs, and tests.
- Keep shared lab abstractions separate from lab-specific implementations.
- Ensure the structure supports adding future labs without reworking the app shell.

**Acceptance Criteria**
- Project folders are organized by app shell, shared infrastructure, lab implementations, docs, and tests.
- Shared types are not duplicated across labs.
- New labs can be added by following a repeatable structure.

**Unit Testing**
- No direct unit tests required.
- Verify build integrity after moving or creating shared infrastructure.

### Task M0.1.2: Define shared lab domain models

**User Story**
As a developer, I want common lab models so all labs present information consistently.

**Requirements**
- Define core shared models such as `LabScenario`, `LabCategory`, `InvestigationGuide`, and `LabDifficulty` if used.
- Models should support title, summary, category, learning goals, reproduction steps, hints, tool recommendations, and broken/fixed availability.
- The design should be extensible for future labs.

**Acceptance Criteria**
- Shared models are used by the app shell and initial labs.
- Each lab can describe itself entirely through the shared model layer plus scenario-specific behavior.
- The metadata supports the planned lab catalog UI.

**Unit Testing**
- Unit test model initialization and expected metadata mapping where appropriate.
- Test any non-trivial mapping or sorting logic used by the catalog.

### Task M0.1.3: Define scenario execution abstractions

**User Story**
As a developer, I want a reusable scenario runner abstraction so labs can expose common actions like trigger, reset, and compare.

**Requirements**
- Define a shared abstraction for scenario execution.
- Support one-time trigger, reset, and optional repeat mode where appropriate.
- Allow a lab to declare whether broken/fixed mode is supported.

**Acceptance Criteria**
- The app shell can drive lab actions through shared abstractions.
- Labs are not tightly coupled to one-off UI wiring.
- The shared execution flow works for all 6 MVP labs.

**Unit Testing**
- Unit test state transitions for the shared scenario execution layer.
- Test reset behavior and broken/fixed mode switching where shared logic exists.

---

## Epic M0.2: App shell and navigation

### Task M0.2.1: Build home screen lab catalog

**User Story**
As a learner, I want a home screen listing the available labs so I can quickly understand the curriculum and navigate to a scenario.

**Requirements**
- Display the initial labs with name, category, summary, and difficulty if present.
- Support clean navigation to each lab detail screen.
- Keep the design extensible for future categories and labs.

**Acceptance Criteria**
- The home screen displays all MVP labs.
- Navigation to lab detail screens works correctly.
- Lab metadata is rendered consistently.

**Unit Testing**
- Unit test catalog ordering and grouping logic if it exists in view models or shared presenters.

### Task M0.2.2: Build shared lab detail screen scaffold

**User Story**
As a learner, I want a consistent lab detail screen so every investigation feels familiar and easy to follow.

**Requirements**
- The detail screen should support:
  - Overview
  - Learning goals
  - Reproduction steps
  - Suggested tools
  - Hints
  - Broken/fixed toggle where supported
  - Trigger and reset controls
- The detail scaffold should be reusable across all labs.

**Acceptance Criteria**
- Each MVP lab uses the same detail screen structure.
- Shared sections render correctly with lab-specific content.
- Controls are reusable and not duplicated across labs.

**Unit Testing**
- Unit test view model formatting and control-state derivation if applicable.

### Task M0.2.3: Build shared broken/fixed mode control

**User Story**
As a learner, I want to switch between broken and fixed implementations so I can compare behavior and validate the debugging results.

**Requirements**
- Provide a reusable control for selecting broken or fixed mode.
- Handle labs that only support one mode.
- Keep mode changes predictable and easy to reset.

**Acceptance Criteria**
- Broken/fixed mode can be selected where supported.
- Unsupported modes are hidden or clearly disabled.
- Resetting a lab returns it to a known state.

**Unit Testing**
- Unit test mode switching state and reset behavior.

---

## Epic M0.3: Documentation and contributor scaffolding

### Task M0.3.1: Add foundational docs

**User Story**
As a contributor, I want clear project docs so I can understand the purpose and development direction of SignalLab.

**Requirements**
- Provide at minimum:
  - `README.md`
  - `Tasks.md`
  - `Docs/Roadmap.md`
  - `Docs/LabDesignPrinciples.md`
- Documentation should align with the intended MVP.

**Acceptance Criteria**
- Core product docs exist and are internally consistent.
- Docs explain the project’s purpose, roadmap, and task breakdown.
- The first six labs are documented at a planning level.

**Unit Testing**
- No unit tests required.

---

# Post-MVP: Scheme Diagnostics Curriculum

These tasks formalize the next curriculum layer after the current MVP labs. The goal is to teach learners when a **scheme diagnostic** or **runtime checker** gives stronger evidence than manual debugging alone.

The intended order is locked unless a later refinement doc changes it explicitly:

1. Thread Performance Checker Lab
2. Zombie Objects Lab
3. Thread Sanitizer Lab
4. Malloc Stack Logging Lab

## Epic D1.1: Define the diagnostics-track curriculum

### Task D1.1.1: Add diagnostics-track ordering and boundaries to the curriculum docs

**User Story**  
As a contributor, I want the next generation of labs documented in a clear order so we do not add advanced diagnostics in an arbitrary sequence.

**Requirements**
- Document the recommended order for the scheme-diagnostics labs.
- Explain how each diagnostics lab differs from the current MVP labs.
- Keep the scope and teaching question for each diagnostics lab explicit.

**Acceptance Criteria**
- `Docs/LabRefinement.md` documents the diagnostics-track order and boundary notes.
- The ordering is explicit and not left to interpretation.
- The diagnostics labs are positioned as post-MVP expansion work, not mixed into the MVP definition.

**Unit Testing**
- No unit tests required.

**Status**
- Complete — `Docs/LabRefinement.md` now includes the diagnostics-track order, rationale, and boundary notes.

### Task D1.1.2: Define Thread Performance Checker Lab in writing

**User Story**  
As a learner, I want a lab that teaches how a scheme diagnostic can confirm main-thread misuse so I can connect a visible freeze to Xcode’s runtime warning.

**Requirements**
- Define a lab whose symptom is visible UI sluggishness or a freeze.
- Teach enabling and interpreting Thread Performance Checker.
- Keep the lab distinct from Hang Lab’s manual paused-debugger workflow.

**Acceptance Criteria**
- The lab has a clear teaching question, symptom, first tool, and validation loop.
- The doc explains why this lab is not just a duplicate of Hang Lab.

**Unit Testing**
- No unit tests required at the writing stage.

**Status**
- Complete — `Docs/LabRefinement.md` now defines the lab with teaching question, boundaries, and validation framing.

### Task D1.1.3: Define Zombie Objects Lab in writing

**User Story**  
As a learner, I want a lab that shows how Zombies turns an unclear memory crash into a direct diagnosis.

**Requirements**
- Define a scenario where an object is deallocated and then messaged later.
- Teach enabling Zombie Objects from scheme diagnostics.
- Explain what new evidence Zombies gives the learner.

**Acceptance Criteria**
- The lab has a clear teaching question, symptom, first tool, and validation loop.
- The lab boundary vs Retain Cycle Lab is explicit.

**Unit Testing**
- No unit tests required at the writing stage.

**Status**
- Complete — `Docs/LabRefinement.md` now defines the lab and its boundary vs Retain Cycle Lab.

### Task D1.1.4: Define Thread Sanitizer Lab in writing

**User Story**  
As a learner, I want a lab that proves unsafe concurrent access instead of leaving me guessing from intermittent wrong behavior.

**Requirements**
- Define a deterministic shared-state concurrency bug.
- Teach enabling Thread Sanitizer from scheme diagnostics.
- Distinguish a true concurrent-access bug from simple async ordering issues.

**Acceptance Criteria**
- The lab has a clear teaching question, symptom, first tool, and validation loop.
- The doc explains why this lab comes after Thread Performance Checker and Zombie Objects.

**Unit Testing**
- No unit tests required at the writing stage.

**Status**
- Complete — `Docs/LabRefinement.md` now defines the lab and distinguishes true concurrent-access bugs from generic async ordering issues.

### Task D1.1.5: Define Malloc Stack Logging Lab in writing

**User Story**  
As a learner, I want a lab that teaches how to recover allocation history for a suspicious object after simpler memory tools are no longer enough.

**Requirements**
- Define the learner question around allocation provenance.
- Teach enabling Malloc Stack Logging and using the resulting evidence.
- Keep this lab in an advanced position relative to Zombies and Retain Cycle work.

**Acceptance Criteria**
- The lab has a clear teaching question, symptom, first tool, and validation loop.
- The doc explains why this lab belongs later in the curriculum.

**Unit Testing**
- No unit tests required at the writing stage.

**Status**
- Complete — `Docs/LabRefinement.md` now defines the lab as an advanced allocation-provenance workflow and places it later in the curriculum.

---

## Epic D1.2: Ship post-MVP scheme diagnostics labs (catalog + guided shells)

### Task D1.2.1: Add Thread Performance Checker Lab to the app catalog

**User Story**  
As a learner who finished Hang Lab, I want a dedicated catalog entry for Thread Performance Checker so I know when to enable scheme diagnostics instead of only pausing the debugger.

**Requirements**
- Add `LabScenario` with stable id `thread_performance_checker` after CPU Hotspot Lab in `catalogSortIndex` order.
- Provide reproduction steps that reference Hang Lab and Xcode scheme diagnostics.
- No in-app Broken/Fixed toggle (exercise is Xcode + Hang Lab).

**Acceptance Criteria**
- Lab appears in the catalog list with copy aligned to `Docs/LabRefinement.md` diagnostics track.
- `LabCatalog.swift`, `Docs/Labs.md`, and `Docs/ThreadPerformanceCheckerLabInvestigationGuide.md` stay in sync.
- UI test / screenshot hook can deep-link with `--uitesting-screenshot-lab thread_performance_checker`.

**Unit Testing**
- Catalog ordering and slug lookup tests include the new scenario.

**Status**
- Implemented — guided detail view + docs + screenshot tests; learner enables the checker in Xcode and reproduces via Hang Lab.

### Task D1.2.2: Add Zombie Objects Lab to the app catalog

**User Story**  
As a learner investigating late callbacks or ambiguous memory crashes, I want a catalog entry that teaches Zombie Objects vs Retain Cycle Lab.

**Acceptance Criteria**  
- Stable id `zombie_objects`; copy aligned to `Docs/LabRefinement.md` Zombie section.  
- `Docs/ZombieObjectsLabInvestigationGuide.md` + `Labs.md` + screenshot deep link.

**Status**  
- Implemented — Broken/Fixed in-app runner (`ZombieObjectsLabScenarioRunner` + Objective-C helper), bridging header, docs + UI tests (`grab_screenshot.sh` mode `zombie`).

### Task D1.2.3: Add Thread Sanitizer Lab to the app catalog

**User Story**  
As a learner seeing flaky concurrent wrong results, I want Thread Sanitizer framed against Breakpoint Lab and Hang Lab.

**Acceptance Criteria**  
- Stable id `thread_sanitizer`; investigation guide + Labs mirror.  
- Screenshot mode `tsan`.

**Status**  
- Implemented — Broken/Fixed in-app runner (`ThreadSanitizerLabScenarioRunner`: racy shared counter vs `NSLock`).

### Task D1.2.4: Add Malloc Stack Logging Lab to the app catalog

**User Story**  
As an intermediate learner, I want malloc stack logging documented after simpler memory tools so I ask “who allocated this?” at the right time.

**Acceptance Criteria**  
- Stable id `malloc_stack_logging`; guide + Labs + screenshot mode `malloc`.

**Status**  
- Implemented — Broken/Fixed in-app runner (`MallocStackLoggingLabScenarioRunner`: per-run allocation burst vs reused buffer).

---

## Epic P2.1: Phase 2 labs (heap growth, deadlock)

### Task P2.1.1: Heap Growth Lab

**User Story**  
As a learner who knows Retain Cycle Lab, I want to see footprint grow without a cycle so I can choose eviction policy instead of chasing purple graph edges.

**Acceptance Criteria**  
- Stable id `heap_growth`; Broken retains unbounded 256 KB chunks; Fixed caps at six chunks.  
- `HeapGrowthLabScenarioRunner`, `iOSHeapGrowthLabDetailView`, `Docs/HeapGrowthLabInvestigationGuide.md`, `Labs.md`, screenshot mode `heap` (`grab_screenshot.sh`).

**Unit Testing**  
- Fixed mode respects cap; Broken mode accumulates; reset clears.

**Status**  
- Implemented.

### Task P2.1.2: Deadlock Lab

**User Story**  
As a learner, I want a deterministic main-thread self-deadlock so I can contrast waiting with Hang Lab’s busy main thread.

**Acceptance Criteria**  
- Stable id `deadlock`; Broken uses `DispatchQueue.main.sync` from main; Fixed completes without sync.  
- In-app warning; UI tests must not tap Run in Broken.  
- `DeadlockLabScenarioRunner`, `iOSDeadlockLabDetailView`, `Docs/DeadlockLabInvestigationGuide.md`, `Labs.md`, screenshot mode `deadlock`.

**Unit Testing**  
- Fixed mode only (Broken deadlocks the process).

**Status**  
- Implemented.

### Task P2.2.1: Background Thread UI Lab

**User Story**  
As a learner, I want to see how background delivery of events interacts with SwiftUI state updates.

**Acceptance Criteria**  
- Stable id `background_thread_ui`; notification + `onReceive` pattern; Fixed uses `MainActor.run` before post.  
- Investigation guide + `Labs.md` + screenshot mode `bg_ui`.

**Status**  
- Implemented.

### Task P2.2.2: Main Thread I/O Lab

**User Story**  
As a learner, I want to separate disk wait on the main thread from CPU-heavy main-thread work.

**Acceptance Criteria**  
- Stable id `main_thread_io`; temp blob; Broken synchronous reads; Fixed detached read.  
- Scroll probes like Hang Lab; investigation guide + `Labs.md` + screenshot mode `main_io`.

**Status**  
- Implemented.

### Task P2.3.1: Scroll Hitch Lab

**User Story**  
As a learner, I want to connect uneven scrolling to per-row rendering cost rather than only CPU algorithms.

**Acceptance Criteria**  
- Stable id `scroll_hitch`; Broken heavy row chrome; Fixed lighter chrome; auto-scroll + horizontal probes.  
- Investigation guide + `Labs.md` + screenshot mode `scroll_hitch`.

**Status**  
- Implemented.

### Task P2.3.2: Startup Signpost Lab

**User Story**  
As a learner, I want named launch-style phases in Instruments Points of Interest, not one anonymous main-thread block.

**Acceptance Criteria**  
- Stable id `startup_signpost`; matching checksums Broken vs Fixed; `os_signpost` with POI `OSLog` category in Fixed.  
- Investigation guide + `Labs.md` + screenshot mode `startup_signpost`.

**Status**  
- Implemented.

### Task P2.3.3: Concurrency Isolation Lab

**User Story**  
As a learner, I want to fix flaky task ordering and Sendable warnings before defaulting to Thread Sanitizer.

**Acceptance Criteria**  
- Stable id `concurrency_isolation`; Broken dual `Task.detached` + non-Sendable token capture; Fixed sequential async ordering.  
- Investigation guide + `Labs.md` + screenshot mode `concurrency_iso`.

**Status**  
- Implemented.

---

# Milestone 1: Crash Lab MVP

## Epic M1.1: Crash Lab implementation

### Task M1.1.1: Define Crash Lab scenario and data set

**User Story**
As a learner, I want a realistic crashing data-import scenario so I can learn how to investigate a parser failure.

**Requirements**
- Create a local sample data flow that includes malformed data.
- The broken implementation should crash due to an unsafe parsing assumption.
- The fixed implementation should validate or handle bad input safely.

**Acceptance Criteria**
- The crash is reproducible from the UI.
- The malformed record is deterministic.
- The fixed mode avoids the crash and surfaces the issue appropriately.

**Unit Testing**
- Unit test the fixed parser behavior.
- Unit test safe handling of malformed records.
- Do not unit test intentional crash behavior directly unless the design supports safe isolation.

### Task M1.1.2: Build Crash Lab UI and trigger flow

**User Story**
As a learner, I want a clear action to trigger the crash so I can focus on investigation instead of setup.

**Requirements**
- Add a trigger button to start the import flow.
- Provide a short scenario overview and reproduction instructions.
- Include tool recommendations for the default stopped debugger workflow: stack frames, current frame, locals, and caller context.

**Acceptance Criteria**
- The learner can trigger the crash in under 15 seconds.
- The lab clearly explains what to inspect.
- The first recommended workflow is the default debugger stop, not adding an exception breakpoint.
- The detail screen follows shared structure.

**Unit Testing**
- Unit test any view model state used for action availability and lab metadata presentation.

### Task M1.1.3: Write Crash Lab investigation guide

**User Story**
As a learner, I want explicit investigation steps so I can use the default stopped debugger state to understand a crash correctly.

**Requirements**
- Describe how to inspect the current frame, caller frames, and local state.
- Explain how to find the first relevant frame in app code after the stop.
- Explain the root cause and the fixed behavior.

**Acceptance Criteria**
- The guide is concise, accurate, and aligned with the lab implementation.
- It teaches the intended default crash workflow without overwhelming the learner or leading with exception breakpoints.

**Unit Testing**
- No unit tests required.

---

# Milestone 2: Breakpoint Lab MVP

## Epic M2.1: Breakpoint Lab implementation

### Task M2.1.1: Define Breakpoint Lab filtering scenario

**User Story**
As a learner, I want a non-crashing logic bug so I can use breakpoints to understand incorrect behavior.

**Requirements**
- Build a filtering/search scenario with incorrect logic in broken mode.
- The issue should be visible in the results.
- The fixed implementation should centralize and correct the filtering behavior.

**Acceptance Criteria**
- Incorrect results are easy to observe.
- The bug is deterministic.
- The fixed mode produces expected results.

**Unit Testing**
- Unit test filtering logic for broken and fixed implementations where practical.
- Focus on business logic inputs and outputs.

### Task M2.1.2: Add breakpoint-friendly observation points

**User Story**
As a learner, I want clear breakpoint targets so I can practice line, conditional, and action breakpoints effectively.

**Requirements**
- Ensure there is a single clear function or path where filtering is applied.
- Make relevant variables easy to inspect.
- Include scenario text explaining suggested breakpoint strategies.

**Acceptance Criteria**
- The learner can place a breakpoint in the core filtering function.
- Conditional breakpoint use meaningfully reduces noise.
- Action/log breakpoint use is feasible and instructive.

**Unit Testing**
- No direct unit tests required beyond the filtering logic tests.

### Task M2.1.3: Write Breakpoint Lab investigation guide

**User Story**
As a learner, I want a guide that helps me understand when and why to use different breakpoint types.

**Requirements**
- Explain line, conditional, and action/log breakpoints.
- Explain what values to inspect.
- Connect the debugging workflow to the visible incorrect results.

**Acceptance Criteria**
- The guide clearly supports the intended learning outcomes.
- The guide maps directly to the scenario implementation.

**Unit Testing**
- No unit tests required.

---

# Milestone 3: Retain Cycle Lab MVP

## Epic M3.1: Retain Cycle Lab implementation

### Task M3.1.1: Define leaking detail-screen scenario

**User Story**
As a learner, I want a realistic object-lifetime bug so I can understand memory ownership issues.

**Requirements**
- Implement a detail screen that should deallocate after dismissal.
- Broken mode should leak through a timer, closure, or both.
- Fixed mode should release correctly.

**Acceptance Criteria**
- Repeated navigation reproduces leaked instances.
- Broken mode does not deallocate correctly.
- Fixed mode deallocates correctly.

**Unit Testing**
- Unit test any shared ownership-related logic that can be safely tested.
- Prefer integration-style app validation for actual deallocation behavior when needed.

### Task M3.1.2: Add leak visibility indicators

**User Story**
As a learner, I want visible signs of leaked objects so I can confirm behavior before opening Instruments.

**Requirements**
- Provide a simple instance count, lifecycle log, or other visible indicator.
- Ensure the signal is understandable without relying only on console output.

**Acceptance Criteria**
- The learner can see object accumulation in broken mode.
- The learner can see the count stabilize or reset in fixed mode.

**Unit Testing**
- Unit test counter/lifecycle state logic if separated from the UI.

### Task M3.1.3: Write Retain Cycle Lab investigation guide

**User Story**
As a learner, I want to understand how to move from visible leak symptoms to ownership inspection in Memory Graph.

**Requirements**
- Explain how to reproduce the leak.
- Explain what to look for in Memory Graph.
- Explain the ownership chain that causes retention.
- Explain how the fixed mode changes object lifetime.

**Acceptance Criteria**
- The guide aligns with the actual ownership model in the app.
- The guide helps the learner confirm deallocation after the fix.

**Unit Testing**
- No unit tests required.

---

# Milestone 4: Hang Lab MVP

## Epic M4.1: Hang Lab implementation

### Task M4.1.1: Define visible main-thread hang scenario

**User Story**
As a learner, I want a lab that visibly freezes so I can learn how to inspect hangs and main-thread work.

**Requirements**
- Build a scenario where the UI becomes visibly unresponsive.
- Broken mode should perform heavy work on the main thread.
- Fixed mode should keep the UI responsive while completing the task.

**Acceptance Criteria**
- The hang is visible and reproducible.
- The scenario works reliably on supported development targets.
- Fixed mode shows improved responsiveness.

**Unit Testing**
- Unit test any underlying processing logic that can be run independently of the UI.
- Avoid brittle tests that depend on timing-sensitive UI behavior.

### Task M4.1.2: Build Hang Lab UI and trigger flow

**User Story**
As a learner, I want a straightforward way to trigger the freeze so I can spend time investigating rather than setting up the issue.

**Requirements**
- Provide a clear action to start the heavy workload.
- Provide a scenario summary and suggested tools.
- Make the broken/fixed comparison explicit.

**Acceptance Criteria**
- The learner can trigger the issue quickly.
- The UI makes the intended symptom obvious.
- The lab supports reset and repeated exploration.

**Unit Testing**
- Unit test action availability and mode-based state if handled in view models.

### Task M4.1.3: Write Hang Lab investigation guide

**User Story**
As a learner, I want a guide that teaches me how to inspect the main thread during a freeze.

**Requirements**
- Explain how to reproduce the hang.
- Explain how to pause during the freeze and inspect threads.
- Explain why the main thread is the first place to look.
- Explain how the fixed implementation changes the workflow.

**Acceptance Criteria**
- The guide matches the actual scenario.
- The guide is understandable for junior and intermediate developers.

**Unit Testing**
- No unit tests required.

---

# Milestone 5: CPU Hotspot Lab MVP

## Epic M5.1: CPU Hotspot Lab implementation

### Task M5.1.1: Define sluggish search scenario

**User Story**
As a learner, I want a slow but non-frozen screen so I can use Time Profiler to find hot paths.

**Requirements**
- Build a search or filtering scenario that becomes sluggish during interaction.
- Broken mode should include repeated expensive work, unnecessary sorting, or repeated helper creation.
- Fixed mode should reduce redundant work and improve responsiveness.

**Acceptance Criteria**
- Lag is noticeable without fully freezing the app.
- The hot path is deterministic enough to profile.
- Fixed mode is meaningfully more responsive.

**Unit Testing**
- Unit test core search/filter business logic.
- Unit test caching or optimization behavior where appropriate.

### Task M5.1.2: Add profiling-friendly data and UI

**User Story**
As a learner, I want the slow interaction to be easy to reproduce so Time Profiler captures meaningful evidence.

**Requirements**
- Use a data set large enough to make the hotspot visible.
- Keep the UI simple enough that the main lesson remains clear.
- Expose straightforward user actions like typing or re-running a search.

**Acceptance Criteria**
- The learner can reproduce the sluggish interaction quickly.
- The UI keeps the focus on performance investigation.
- The lab remains understandable without additional setup.

**Unit Testing**
- No direct UI-performance tests required for MVP.
- Business logic tests should validate correctness independent of profiling.

### Task M5.1.3: Write CPU Hotspot Lab investigation guide

**User Story**
As a learner, I want a guide that helps me use Time Profiler without getting lost in framework noise.

**Requirements**
- Explain how to profile the slow interaction.
- Explain how to identify hot functions.
- Explain what repeated expensive work the learner should find.
- Explain how to compare broken and fixed behavior.

**Acceptance Criteria**
- The guide reflects the actual hotspot sources in the implementation.
- The guide is practical and concise.

**Unit Testing**
- No unit tests required.

---

# Cross-Cutting MVP Tasks

## Task X1: Define visual design system for MVP

**User Story**
As a learner, I want SignalLab to feel polished and modern so the product feels intentional and pleasant to use.

**Requirements**
- Establish core colors, spacing, typography, and shared component styling.
- Support the dark-forward SignalLab theme.
- Ensure readability and consistency across the app shell and labs.

**Acceptance Criteria**
- Shared visual styling is applied consistently.
- The home screen and lab screens feel cohesive.
- Design choices support clarity rather than distracting from the lesson.

**Unit Testing**
- No unit tests required.

## Task X2: Define sample-data and scenario-data strategy

**User Story**
As a developer, I want a consistent approach to local sample data so scenarios remain deterministic and easy to maintain.

**Requirements**
- Use local data only for MVP.
- Separate lab data from shared infrastructure.
- Ensure malformed or heavy data sets are clearly owned by their lab.

**Acceptance Criteria**
- Scenario data is deterministic.
- Labs do not depend on network availability.
- Data ownership is clear and maintainable.

**Unit Testing**
- Unit test any parsing or transformation logic associated with local data.

## Task X3: Define lab authoring checklist

**User Story**
As a contributor, I want a checklist for adding new labs so future work stays consistent with the product vision.

**Requirements**
- Document required sections for any new lab:
  - User story
  - Primary lesson
  - Requirements
  - Acceptance criteria
  - Testing expectations
  - Investigation guide
- Keep the checklist lightweight and actionable.

**Acceptance Criteria**
- A contributor can use the checklist to propose a new lab.
- The checklist aligns with the product principles in this document.

**Unit Testing**
- No unit tests required.

## Task X4: Refine MVP labs around explicit teaching outcomes

**User Story**
As a learner, I want each lab to teach one clear debugging workflow so I can build reliable instincts instead of memorizing isolated bugs.

**Requirements**
- Reframe each MVP lab around:
  - learner question
  - visible symptom
  - first tool
  - mental model
  - Fixed-mode proof
- Ensure lab copy describes what the learner should observe, not only what buttons to press.
- Keep adjacent labs clearly differentiated by symptom and first tool.

**Acceptance Criteria**
- Each MVP lab has a clearly stated primary teaching outcome.
- Reproduction steps are observation-oriented.
- Fixed mode explains what behavior changed and why that confirms the diagnosis.
- Lab boundaries are clear:
  - Crash vs Exception Breakpoint
  - Breakpoint vs CPU Hotspot
  - Hang vs CPU Hotspot
  - Retain Cycle vs Hang

**Unit Testing**
- No direct unit tests required.
- Existing tests should continue to validate fixed-path business logic after copy and guide changes.

## Task X5: Lock curriculum order and title the Exception lab

**User Story**
As a contributor, I want the curriculum order and new lab naming decided before broad copy rewrites so I do not have to reorder the catalog and documentation twice.

**Requirements**
- Lock the working sequence:
  - Crash Lab
  - Exception Breakpoint Lab
  - Breakpoint Lab
  - Retain Cycle Lab
  - Hang Lab
  - CPU Hotspot Lab
- Choose a learner-facing title and one-line summary for the Exception lab.
- Keep the tool name accurate somewhere even if the catalog title is more learner-centered.

**Acceptance Criteria**
- `LabCatalog` ordering plan, `Tasks.md`, and `LabRefinement.md` agree on curriculum order.
- The Exception lab has an approved learner-facing title and summary.
- Reviewers can tell where the new lab belongs before app wiring begins.

**Unit Testing**
- No unit tests required.

## Task X6: Rewrite Crash Lab as the default crash-debugging introduction

**User Story**
As a beginner iOS developer, I want the first crash lab to teach me what to do when Xcode already stopped on a crash so I can diagnose a runtime failure without extra debugger setup.

**Requirements**
- Reframe Crash Lab around the default debugger state after a crash.
- Teach:
  - identify the relevant app frame
  - inspect current locals / malformed data
  - move to one caller for context
- De-emphasize exception breakpoints in Crash Lab copy and guides.
- Keep Fixed mode focused on safe validation of malformed input.

**Acceptance Criteria**
- Crash Lab no longer presents exception breakpoints as the primary first tool.
- Crash Lab copy, catalog metadata, and guide consistently emphasize stack, frame, variables, and caller context.
- Crash Lab includes a concise learner-facing completion target.

**Unit Testing**
- Preserve existing parser and scenario tests.
- Add tests only if implementation behavior changes, not for copy-only updates.

## Task X7: Define a dedicated Exception Breakpoint Lab in writing

**User Story**
As a learner who already understands the default crash workflow, I want a focused lab on exception breakpoints so I can understand when changing debugger stop policy adds value.

**Requirements**
- Define:
  - learner question
  - symptom
  - first tool
  - A/B comparison against default crash/trap behavior
  - Fixed-mode or second-run validation
- Explain the feature honestly in a Swift-heavy app, including the difference between a named Xcode control and the real failure symptoms it helps debug.
- Add the corresponding long-form guide file.

**Acceptance Criteria**
- The lab is distinct from Crash Lab and Breakpoint Lab in written curriculum materials.
- The learner can explain what the exception breakpoint adds beyond the default crash stop.
- The curriculum map row for the new lab is concrete rather than vague.
- The guide exists and matches the locked curriculum order and approved title.

**Unit Testing**
- No tests required for documentation-only planning work.

## Task X8: Implement a dedicated Exception Breakpoint Lab in the app

**User Story**
As a learner, I want the new Exception lab to appear in the app so I can follow the curriculum in order rather than only reading about it in docs.

**Requirements**
- Add a new `LabScenario` id and place it immediately after Crash Lab.
- Add routing in `iOSLabDetailView`.
- Add a runner or guided stub with strong copy if a full interactive scenario is not ready yet.
- Ensure project/target wiring is complete.

**Acceptance Criteria**
- The new lab appears in the app list in the locked order.
- The lab can be opened from the catalog.
- Reproduction text tells the learner what to do in Xcode even if the first implementation is a guided stub.

**Unit Testing**
- Add scenario-level tests if the new lab introduces shared runner or state logic.
- No tests required if the first pass is app wiring plus guided copy only.

## Task X9: Tighten Breakpoint Lab teaching order in copy

**User Story**
As a learner, I want Breakpoint Lab to introduce one simple breakpoint before more advanced variations so I do not mistake noise-reduction tools for the core lesson.

**Requirements**
- Reframe Breakpoint Lab copy so the order is:
  - reproduce wrong result
  - add one plain line breakpoint
  - inspect state
  - step through the bad branch
  - then introduce conditional and log breakpoints as refinements

**Acceptance Criteria**
- A reader sees “one breakpoint → inspect → step” before any noise-reduction advice.
- Breakpoint Lab still distinguishes itself clearly from Crash Lab and CPU Hotspot Lab.

**Unit Testing**
- No unit tests required for copy-only changes.

## Task X10: Add learner-facing “done when…” criteria to every lab

**User Story**
As a learner, I want a simple completion check for each lab so I know when I have actually learned the intended debugging skill.

**Requirements**
- First pass is docs/catalog only.
- Add one sentence per lab using the pattern:
  - “You’re done when you can …”
- Keep each sentence observable and skill-based.
- Align the wording with each investigation guide’s validation checklist.
- Do not add new model or UI fields in the first pass.

**Acceptance Criteria**
- Every MVP lab has exactly one concise completion sentence.
- The completion sentence matches the lab’s primary lesson and does not drift into secondary concepts.
- `LabCatalog`, `Labs.md`, and supporting guides use compatible validation language.
- No app UI/model scope is introduced in the first pass.

**Unit Testing**
- No unit tests required.

## Task X11: Add Crash Lab micro-skills without scope creep

**User Story**
As a beginner learner, I want Crash Lab to teach a few high-value debugger moves so I can investigate confidently without being overwhelmed.

**Requirements**
- Add only these three micro-skills to Crash Lab guidance:
  - find the first relevant app frame
  - inspect current locals / malformed row
  - move one caller up for context
- Do not expand Crash Lab into an lldb tutorial or exception-breakpoint lab.

**Acceptance Criteria**
- Those three beats appear explicitly once in Crash Lab reproduction or guide content.
- Crash Lab remains focused on the default stopped debugger state.

**Unit Testing**
- No unit tests required for copy-only changes.

## Task X12: Keep curriculum docs and lab metadata in sync

**User Story**
As a contributor, I want curriculum changes to update all relevant docs and metadata together so learners do not see conflicting teaching guidance.

**Requirements**
- Update the following together whenever a lab’s teaching goal or first tool changes:
  - `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift`
  - `SignalLab/Docs/Labs.md`
  - lab investigation guides
  - `SignalLab/Docs/LabRefinement.md` when curriculum intent changes
- Ensure curriculum map, lab ordering, and learner-facing titles stay consistent.

**Acceptance Criteria**
- No lab has conflicting first-tool guidance across app metadata and docs.
- Curriculum map and lab reference reflect the same ordering and boundaries.
- Reviewers can verify a curriculum change by reading one commit instead of reconstructing intent across multiple follow-ups.

**Unit Testing**
- No unit tests required.

## Task X13: Audit adjacent-lab boundaries

**User Story**
As a learner, I want neighboring labs to feel distinct so I learn the right debugging workflow for the right symptom.

**Requirements**
- Audit copy for these pairs:
  - Crash vs Exception Breakpoint
  - Exception Breakpoint vs Breakpoint
  - Breakpoint vs CPU Hotspot
  - Hang vs CPU Hotspot
  - Retain Cycle vs Hang
- Add at least one sentence in hints or reproduction where a distinction is not obvious.

**Acceptance Criteria**
- Each adjacent pair has at least one explicit differentiator in the written guidance.
- The curriculum map remains aligned with the lab copy after the audit.

**Unit Testing**
- No unit tests required.

## Task X14: Clarify Swift trap vs Objective-C exception language

**User Story**
As a learner, I want the Exception lab to explain the real debugging situation clearly so I understand what the Xcode control helps with in a Swift-heavy app.

**Requirements**
- Clarify where exception breakpoints help in practice rather than only naming the checkbox.
- Explain the relationship between Swift traps, Objective-C exceptions, and the debugger stop behavior in language appropriate for beginners.
- Keep the guidance symptom-first.

**Acceptance Criteria**
- A beginner can answer “What does this add over the stop I already had?”
- The Exception lab guide and short catalog guidance use accurate, non-misleading language.

**Unit Testing**
- No unit tests required.

---

# Pedagogy Audit Epic

This epic turns `SignalLab/memlog/BestPractices.md` into concrete refinement work across the current curriculum. `SignalLab/Docs/LabRefinement.md` is the decision log; `LabCatalog.swift` and `Docs/Labs.md` are the execution-facing mirrors.

## Group P1: Immediate pedagogy clarifications

### Task PA1.1: Expand BestPractices with per-category immediate-payoff targets

**User Story**
As a contributor, I want explicit per-category payoff rules so future labs are judged by the right first learner win instead of a generic checklist.

**Requirements**
- Add per-category guidance for Crash, Breakpoint, Memory, Hang, and Performance.
- Record the ordering rule for the first payoff by category.
- Keep the language implementation-shaping, not aspirational only.

**Acceptance Criteria**
- `BestPractices.md` states what “first payoff” means for each category.
- The “Prefer one-step gains” section includes the category ordering rule.
- A contributor can use the file to decide whether a lab’s first tool is honest.

**Unit Testing**
- No unit tests required.

### Task PA1.2: Make Hang Lab pause guidance mandatory

**User Story**
As a learner, I want the Hang Lab copy to tell me the core proving step directly so I do not miss the paused-stack evidence.

**Requirements**
- Remove “Optional” framing around Pause in Hang Lab reproduction copy.
- Tell the learner to freeze the UI, pause immediately, and find `HangLabWorkload.simulateReportProcessing`.
- Keep catalog and `Docs/Labs.md` aligned.

**Acceptance Criteria**
- Hang Lab reproduction text makes Pause a required proving step.
- The expected main-thread frame is named explicitly.
- Catalog and `Docs/Labs.md` match.

**Unit Testing**
- No unit tests required.

### Task PA1.3: Clarify Retain Cycle retaining-path wording

**User Story**
As a learner, I want a concrete target path in Memory Graph so opening the tool pays off immediately.

**Requirements**
- Tighten the retaining-path wording in `LabCatalog.swift`, `Docs/Labs.md`, and `Docs/RetainCycleLabInvestigationGuide.md`.
- Use explicit but honest wording: a chain like `RunLoop -> NSTimer/Timer -> closure/block -> RetainCycleLabDetailHeart`.
- Reinforce that the visible live-session counter is what justifies opening Memory Graph.

**Acceptance Criteria**
- The retaining-path text is concrete and consistent across the catalog and docs.
- The guide and catalog point to the same ownership story.

**Unit Testing**
- No unit tests required.

## Group P2: Wave 1 high-risk lab refinements

### Task PA2.1: Refine Exception Breakpoint Lab around explicit comparison outcomes

**User Story**
As a learner, I want to know exactly what the exception breakpoint added over the default stop so the lab feels like a decision, not a settings tour.

**Requirements**
- Add an explicit comparison outcome model: no added value, earlier stop, or clearer frame.
- Keep the lab tightly scoped to default-stop vs exception-breakpoint comparison.
- Align `LabRefinement.md`, catalog copy, and guide.

**Acceptance Criteria**
- The lab ends with one concrete statement about what changed on the breakpoint run.
- The copy does not drift into generic breakpoint configuration.

**Unit Testing**
- No unit tests required.

### Task PA2.2: Strengthen visible learner wins for the highest-risk labs

**User Story**
As a learner, I want the first action in each advanced lab to reveal evidence quickly so the tools feel worth using.

**Requirements**
- Audit and tighten the first payoff for:
  - Retain Cycle Lab
  - Zombie Objects Lab
  - Thread Sanitizer Lab
  - Malloc Stack Logging Lab
  - Background Thread UI Lab
  - Main Thread I/O Lab
  - Startup Signpost Lab
  - Concurrency Isolation Lab
- For each lab, record in `LabRefinement.md`:
  - learner win
  - first tool
  - first immediate payoff
  - current pedagogy gap
  - recommended code/copy change
  - “done when…” line

**Acceptance Criteria**
- Each listed lab has a concrete first-payoff recommendation in `LabRefinement.md`.
- The highest-risk labs are framed around evidence, not just tool setup.

**Unit Testing**
- No unit tests required.

### Task PA2.3: Reduce workflow ambiguity in diagnostics-heavy labs

**User Story**
As a learner, I want one primary workflow per advanced lab so I am not deciding between multiple tooling paths before I understand the lesson.

**Requirements**
- Choose one primary workflow for Malloc Stack Logging.
- Make Zombie Objects and Thread Sanitizer foreground the primary evidence source before secondary explanation.
- Keep boundaries vs Retain Cycle, Breakpoint, Hang, and async-ordering bugs explicit.

**Acceptance Criteria**
- Each diagnostics-heavy lab names one primary workflow and one primary evidence type.
- Adjacent-lab confusion is reduced in the guide/copy recommendations.

**Unit Testing**
- No unit tests required.

## Group P3: Wave 2 tightening pass

### Task PA3.1: Tighten already-strong labs without changing their core lesson

**User Story**
As a learner, I want strong labs to stay simple while still giving me the fastest possible payoff.

**Requirements**
- Tighten the first payoff and anti-confusion wording for:
  - Breakpoint Lab
  - Hang Lab
  - CPU Hotspot Lab
  - Thread Performance Checker Lab
  - Heap Growth Lab
  - Deadlock Lab
  - Scroll Hitch Lab
- Keep the existing tool choice and curriculum boundaries intact.

**Acceptance Criteria**
- `LabRefinement.md` records one concrete improvement target for each listed lab.
- No listed lab expands its scope beyond its current dominant teaching goal.

**Unit Testing**
- No unit tests required.

## Group P4: Wave 3 maintenance and verification

### Task PA4.1: Maintain Crash Lab as the pedagogy benchmark

**User Story**
As a contributor, I want Crash Lab to remain the reference implementation so later labs can borrow its teaching shape.

**Requirements**
- Keep Crash Lab structurally broken-only.
- Limit follow-up work to wording polish and real-Xcode verification.
- Explicitly use Crash Lab as the benchmark in `LabRefinement.md`.

**Acceptance Criteria**
- No Fixed-mode comparison language returns to Crash Lab.
- `LabRefinement.md` marks Crash Lab as the current benchmark.

**Unit Testing**
- No unit tests required.

### Task PA4.2: Verify revised labs against the pedagogy rubric

**User Story**
As a contributor, I want a repeatable verification pass so pedagogy edits are checked against the same evidence standard.

**Requirements**
- For each revised lab, confirm:
  - the symptom is visible before hints
  - the named first tool produces useful evidence within one or two actions
  - the intended frame/view/report is readable and low-noise
  - the “done when…” line is concrete and observable
- Record this verification expectation in `LabRefinement.md` and follow it when shipping rewrites.

**Acceptance Criteria**
- The verification rubric is written down and reused.
- Revised labs can be checked against one shared standard.

**Unit Testing**
- No unit tests required.

---

# Suggested Build Order

## First build slice
- M0.1.1 Establish project structure
- M0.1.2 Define shared lab domain models
- M0.2.1 Build home screen lab catalog
- M0.2.2 Build shared lab detail screen scaffold
- M0.2.3 Build shared broken/fixed mode control
- M0.3.1 Add foundational docs

## Second build slice
- M1.1.1 Define Crash Lab scenario and data set
- M1.1.2 Build Crash Lab UI and trigger flow
- M1.1.3 Write Crash Lab investigation guide

## Third build slice
- M2.1.1 Define Breakpoint Lab filtering scenario
- M2.1.2 Add breakpoint-friendly observation points
- M2.1.3 Write Breakpoint Lab investigation guide

## Fourth build slice
- M3.1.1 Define leaking detail-screen scenario
- M3.1.2 Add leak visibility indicators
- M3.1.3 Write Retain Cycle Lab investigation guide

## Fifth build slice
- M4.1.1 Define visible main-thread hang scenario
- M4.1.2 Build Hang Lab UI and trigger flow
- M4.1.3 Write Hang Lab investigation guide

## Sixth build slice
- M5.1.1 Define sluggish search scenario
- M5.1.2 Add profiling-friendly data and UI
- M5.1.3 Write CPU Hotspot Lab investigation guide

## Seventh build slice
- Task X4 Refine MVP labs around explicit teaching outcomes
- Task X5 Lock curriculum order and title the Exception lab
- Task X6 Rewrite Crash Lab as the default crash-debugging introduction
- Task X7 Define a dedicated Exception Breakpoint Lab in writing
- Task X8 Implement a dedicated Exception Breakpoint Lab in the app
- Task X9 Tighten Breakpoint Lab teaching order in copy
- Task X10 Add learner-facing “done when…” criteria to every lab
- Task X11 Add Crash Lab micro-skills without scope creep
- Task X12 Keep curriculum docs and lab metadata in sync
- Task X13 Audit adjacent-lab boundaries
- Task X14 Clarify Swift trap vs Objective-C exception language

## Eighth build slice
- Task PA1.1 Expand BestPractices with per-category immediate-payoff targets
- Task PA1.2 Make Hang Lab pause guidance mandatory
- Task PA1.3 Clarify Retain Cycle retaining-path wording
- Task PA2.1 Refine Exception Breakpoint Lab around explicit comparison outcomes
- Task PA2.2 Strengthen visible learner wins for the highest-risk labs
- Task PA2.3 Reduce workflow ambiguity in diagnostics-heavy labs
- Task PA3.1 Tighten already-strong labs without changing their core lesson
- Task PA4.1 Maintain Crash Lab as the pedagogy benchmark
- Task PA4.2 Verify revised labs against the pedagogy rubric

---

# MVP Exit Criteria

The MVP is complete when:

- The app launches into a working lab catalog.
- All catalog labs (6 MVP scenarios plus post-MVP scheme diagnostics and Phase 2: Thread Performance Checker, Zombie Objects, Thread Sanitizer, Malloc Stack Logging, Heap Growth, Deadlock, Background Thread UI, Main Thread I/O, Scroll Hitch, Startup Signpost, Concurrency Isolation) can be opened from the home screen.
- Each lab has a clear overview, learning goals, reproduction flow, and suggested tools.
- Broken/fixed comparison is implemented where appropriate.
- The crash, exception-breakpoint (guided), breakpoint logic-bug, retain-cycle leak, hang, and CPU Hotspot (live search) scenarios are reproducible in the app; scheme-only labs (e.g. Thread Performance Checker) ship as guided catalog entries tied to Xcode and other labs.
- Business logic for the fixed implementations is covered by targeted unit tests where appropriate.
- Project documentation is sufficient for a contributor to understand the architecture and roadmap.

---

# Post-MVP Candidates

Once the MVP is stable, the next most valuable additions are:

- Heap Growth Lab
- Deadlock Lab
- Race Condition Lab
- Background Thread UI Update Lab
- Rendering Hitch Lab
- Concurrency Misuse Lab
- Glossary and hint progression system
- Mentor mode and workshop prompts
- More formal automation and validation workflows
