

# SignalLab

SignalLab is a hands-on iOS learning app for junior and intermediate developers who want practical experience debugging real application problems with Xcode and Instruments.

The project is designed as a guided lab environment rather than a generic sample app. Each lab intentionally contains a realistic bug or performance problem, along with a reproducible trigger, a recommended investigation workflow, and a fixed implementation for comparison.

For **CLI build defaults**, preferred simulator settings, and other machine-readable notes aimed at contributors and coding agents, see **[AGENTS.md](../AGENTS.md)** at the repository root.

## Vision

SignalLab exists to help developers build confidence with debugging by practicing on controlled, repeatable scenarios that mirror common production issues.

Instead of reading about breakpoints, leaks, hangs, and profiling in the abstract, learners will launch a scenario, trigger the issue, inspect the evidence with Apple tooling, identify the cause, and validate the fix.

The app should feel like a polished, modern Apple-platform developer tool while remaining approachable for engineers who are still building intuition around stacks, memory ownership, responsiveness, and performance.

## Target Audience

SignalLab is primarily intended for:

- Junior iOS developers learning how to debug with Xcode
- Intermediate iOS developers who want more practical experience with Instruments
- Mentors, instructors, and interview coaches who want concrete debugging exercises
- Engineers who learn best by investigating realistic bugs rather than reading isolated examples

## Core Product Goals

SignalLab should help learners:

- Understand how to use breakpoints and inspect stack traces
- Build intuition around call stacks, frames, locals, and caller relationships
- Diagnose non-crashing logic bugs with line, conditional, and action breakpoints
- Find and explain memory leaks and ownership problems
- Identify hangs and main-thread abuse
- Use Time Profiler to locate hot code paths and repeated expensive work
- Compare broken and fixed implementations using the same debugging workflow
- Build a repeatable mental model for investigating app problems instead of guessing

## Non-Goals

The first version of SignalLab is intentionally constrained.

It is not intended to be:

- A general-purpose reference for every Xcode feature
- A broad survey of every possible Instruments template
- A production observability platform
- A replacement for Apple documentation
- A highly advanced concurrency lab on day one
- A networking-dependent demo that relies on unstable external services

The early focus is clarity, reproducibility, and strong teaching value.

## Product Concept

SignalLab is structured as a catalog of self-contained debugging labs.

Each lab should provide:

- A focused scenario with one dominant lesson
- A clear symptom that is visible in the UI or behavior
- A reproducible trigger that works quickly and consistently
- A recommended first tool to investigate the issue
- Hints that guide the learner without immediately giving away the answer
- A fixed mode or fixed implementation for comparison
- Notes explaining why the issue occurred and why the fix works

This approach keeps the learning experience concrete and repeatable.

## Design Theme

SignalLab uses a modern, dark-forward visual style inspired by Apple developer tools and observability interfaces.

The intended theme is:

- Calm, precise, and technical
- Beautiful and modern without becoming flashy
- Glassy, layered, and depth-aware where appropriate
- Highly readable with strong visual hierarchy
- Semantic in its use of color for warnings, faults, memory, success, and neutral tooling states

This theme supports the product goal of making debugging feel intentional and approachable.

## Learning Model

SignalLab is meant to support both guided learning and free exploration.

Each lab should be usable in several ways:

- Independent exploration by launching the lab and investigating the symptom
- Guided instruction with hints and recommended tools
- Mentor-led walkthroughs in training or interview prep settings
- Before-and-after comparison using broken and fixed implementations

The app should emphasize reasoning, not memorization.

## Initial Lab Roadmap

The first phase of the project focuses on five foundational labs that teach the most important debugging skills for junior and intermediate developers.

### 1. Crash Lab

This lab teaches the basics of exception breakpoints, stack traces, frame navigation, and local inspection.

Scenario:
A sample import flow loads malformed local data and crashes because the parser makes unsafe assumptions.

Key learning goals:

- Add and use an exception breakpoint
- Inspect the crashing frame and its callers
- Identify the bad assumption in the parser
- Understand that the crash line is not always the full root cause

### 2. Breakpoint Lab

This lab teaches practical use of line breakpoints, conditional breakpoints, and log/action breakpoints for logic bugs that do not crash.

Scenario:
A search and filter flow produces incorrect results because one branch of the filtering logic ignores a required condition.

Key learning goals:

- Use breakpoints to inspect incorrect state
- Reduce noise with conditional breakpoints
- Log values without stopping every time
- Compare expected and actual behavior inside the filtering pipeline

### 3. Retain Cycle Lab

This lab teaches object lifetime debugging, ownership inspection, and basic memory investigation.

Scenario:
A detail screen starts a repeating timer and stores a closure in a way that prevents the screen from deallocating after dismissal.

Key learning goals:

- Reproduce a leak through repeated navigation
- Use Memory Graph to inspect retained objects
- Identify ownership chains that keep the object alive
- Confirm the fix by seeing deallocation occur correctly

### 4. Hang Lab

This lab teaches hang investigation and main-thread responsiveness analysis.

Scenario:
A report-loading flow performs heavy JSON parsing and transformation work on the main thread, causing the UI to freeze.

Key learning goals:

- Recognize a visible hang
- Pause execution during a freeze and inspect threads
- Identify work that should not be happening on the main thread
- Compare broken and fixed responsiveness behavior

### 5. CPU Hotspot Lab

This lab teaches Time Profiler and hot-path investigation.

Scenario:
A searchable list becomes sluggish because each keystroke triggers repeated expensive work, unnecessary sorting, and repeated helper creation.

Key learning goals:

- Profile a slow interaction with Time Profiler
- Identify the hottest functions in the trace
- Separate core causes from framework noise
- Validate that the optimized implementation improves responsiveness

## Future Lab Candidates

After the first five labs are complete, SignalLab may expand into additional topics such as:

- Heap growth versus true leaks
- Deadlocks and blocking wait misuse
- Race conditions and unsafe shared state
- Background-thread UI updates
- Rendering hitching and scrolling performance
- Swift concurrency misuse and isolation mistakes
- Startup performance
- Signposts and custom performance instrumentation

These are strong candidates, but they should come after the fundamentals are solid.

## Product Roadmap

### Phase 0: Foundation

Establish the reusable structure for the app.

Planned work:

- Create the app shell and lab catalog
- Define shared lab metadata and navigation patterns
- Build reusable UI for lab descriptions, triggers, hints, and fixed-mode comparison
- Set up documentation structure for labs and investigation guides

### Phase 1: Foundational Labs

Implement the first five labs.

Planned work:

- Crash Lab
- Breakpoint Lab
- Retain Cycle Lab
- Hang Lab
- CPU Hotspot Lab

Goal:
Ship a strong MVP that already teaches the most important debugging workflows.

### Phase 2: Diagnostics Expansion

Broaden the curriculum into more advanced debugging scenarios.

Planned work:

- Heap growth investigation
- Deadlock and blocking patterns
- Race-condition examples
- Additional performance and responsiveness scenarios

### Phase 3: Pedagogy and Curriculum

Turn the app into a more complete teaching product.

Planned work:

- Progressive difficulty levels
- Structured hint system
- Glossary of debugging terms
- Mentor and workshop prompts
- Lab completion and validation checklists

### Phase 4: Automation and Regression Workflows

Improve reproducibility and maintainability.

Planned work:

- Repeat-trigger controls for scenarios
- Optional automation for selected labs
- Before-and-after verification checklists
- Consistent comparison workflows for broken and fixed traces

## Product Principles

To keep SignalLab useful and teachable, every lab should follow a consistent set of principles.

### One primary lesson per lab

Each lab should teach one dominant concept. Supporting details are fine, but the learner should always know what the main lesson is.

### Fast reproduction

A learner should be able to trigger the issue quickly. If the issue takes too long to reproduce, the lab becomes frustrating and loses teaching value.

### Clear symptoms

The issue should be visible and understandable.

Examples:

- The app crashes
- The UI freezes
- Results are wrong
- An object does not deallocate
- Search becomes sluggish

### Broken and fixed comparison

Whenever possible, each lab should provide a broken and fixed mode so the learner can compare behavior and validate the results of the investigation.

### Realistic bugs

The project should prefer realistic app patterns over contrived algorithm puzzles.

Examples of good scenario sources:

- Data import and parsing
- Search and filtering
- Timers and closures
- Main-thread JSON processing
- Expensive repeated UI-related work

### Apple-native tooling first

The product is built around learning Apple’s own debugging stack, especially:

- Xcode breakpoints and LLDB
- Call stack and thread inspection
- Xcode Memory Graph
- Instruments Leaks
- Instruments Allocations
- Hang analysis
- Time Profiler
- Early diagnostics and runtime checks

## Proposed App Structure

The codebase should eventually be organized around reusable lab concepts rather than one-off screens.

Possible structure:

- `SignalLabApp/`
- `Labs/`
- `Shared/`
- `Docs/`
- `Guides/`

Potential shared concepts:

- `LabCatalog`
- `LabScenario`
- `LabCategory`
- `InvestigationGuide`
- `BrokenImplementation`
- `FixedImplementation`

The exact implementation may evolve, but the project should preserve strong separation between shared infrastructure and lab-specific scenario code.

## In-App Experience Goals

The app should eventually support:

- A home screen with all labs grouped by category or difficulty
- Rich lab detail screens with overview, trigger controls, and hints
- A clear broken/fixed mode toggle
- Investigation guides that explain which tool to use first and why
- Visual summaries of symptoms, tool recommendations, and validation steps
- A polished, modern interface that feels at home on Apple platforms

## Documentation Strategy

SignalLab should be documented like a real teaching product.

Recommended documentation areas:

- Project vision and roadmap
- Lab design principles
- Investigation workflow checklists
- One guide per lab
- Contributor guidance for adding future labs
- Notes for mentors or workshop facilitators

Documentation should explain not only how to use the app, but also why each scenario was designed the way it was.

## Success Criteria

SignalLab is successful if a learner can:

- Launch a lab and reproduce the issue quickly
- Choose an appropriate first debugging tool
- Gather evidence from the debugger or Instruments
- Explain the root cause in simple terms
- Understand why the fix resolves the issue
- Build confidence debugging similar problems in real projects

## Current Status

SignalLab is currently in the planning and design phase.

Work completed so far includes:

- Product vision definition
- Audience and scope definition
- Design theme exploration
- Initial screen mockups
- Lab roadmap and prioritization
- First-pass curriculum planning for the initial five labs

The next major step is to turn the first five labs into detailed implementation specs and begin building the shared app framework.

## References

SignalLab is intended to complement Apple’s debugging and performance tooling documentation, not replace it.

Helpful Apple references include:

- Instruments tutorials
- Xcode hang analysis guidance
- Memory, thread, and crash diagnostics guidance
- WWDC sessions on heap analysis, hang investigation, and debugging tools

## Contributing Direction

As the project grows, new labs should only be added if they meet the product’s teaching standards.

A good new lab should:

- Have a clear primary lesson
- Reproduce consistently
- Use realistic code patterns
- Teach a meaningful Apple debugging workflow
- Include a clear fixed implementation or explanation
- Be understandable by the intended audience

## Summary

SignalLab is a polished, educational debugging lab for iOS developers.

Its purpose is to make Xcode debugging and Instruments feel practical, approachable, and memorable by teaching through direct investigation of realistic bugs.

The initial focus is a high-quality foundation and five excellent labs that cover crashes, breakpoints, leaks, hangs, and CPU hotspots. From there, the project can expand into a broader curriculum covering more advanced debugging scenarios.
