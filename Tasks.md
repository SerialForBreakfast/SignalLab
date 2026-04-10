

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
- The first 5 labs:
  - Crash Lab
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
- The shared execution flow works for all 5 MVP labs.

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
- The first five labs are documented at a planning level.

**Unit Testing**
- No unit tests required.

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
- Include tool recommendations for exception breakpoints and stack inspection.

**Acceptance Criteria**
- The learner can trigger the crash in under 15 seconds.
- The lab clearly explains what to inspect.
- The detail screen follows shared structure.

**Unit Testing**
- Unit test any view model state used for action availability and lab metadata presentation.

### Task M1.1.3: Write Crash Lab investigation guide

**User Story**
As a learner, I want explicit investigation steps so I can practice exception breakpoints and stack traces correctly.

**Requirements**
- Explain how to add an exception breakpoint.
- Describe how to inspect the current frame, caller frames, and local state.
- Explain the root cause and the fixed behavior.

**Acceptance Criteria**
- The guide is concise, accurate, and aligned with the lab implementation.
- It teaches the intended workflow without overwhelming the learner.

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

---

# MVP Exit Criteria

The MVP is complete when:

- The app launches into a working lab catalog.
- All 5 initial labs can be opened from the home screen.
- Each lab has a clear overview, learning goals, reproduction flow, and suggested tools.
- Broken/fixed comparison is implemented where appropriate.
- The crash, logic bug, leak, hang, and CPU hotspot scenarios are reproducible.
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
