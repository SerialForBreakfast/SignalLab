# Lab Design Principles

SignalLab teaches debugging through **repeatable, realistic scenarios**. Every lab should reinforce the same product standards described in [ReadMe.md](../ReadMe.md) and [Tasks.md](../Tasks.md).

## One primary lesson

Each lab has a single dominant concept (crash investigation, breakpoints, leaks, hangs, CPU hotspots). Supporting detail is welcome, but the learner should always know what the main takeaway is.

## Fast reproduction

The symptom must appear **quickly and consistently**. Slow or flaky reproduction reduces teaching value and frustrates learners.

## Clear symptoms

The learner should see an obvious signal: crash, freeze, wrong results, failure to deallocate, or sluggish interaction.

## Broken and fixed comparison

When feasible, provide **broken** and **fixed** modes so the learner can validate conclusions against a known-good implementation.

## Realistic code patterns

Prefer scenarios that mirror production work: parsing, filtering, timers, main-thread processing, redundant view-related work. Avoid abstract puzzles unrelated to app development.

## Apple-native tooling first

Optimize for **Xcode** and **Instruments**: breakpoints and LLDB, Memory Graph, Leaks, Allocations, hang analysis, Time Profiler. Third-party tooling is out of scope for the MVP.

## Authoring checklist (summary)

When proposing a new lab, capture:

- User story and primary lesson
- Requirements and acceptance criteria
- Deterministic reproduction steps
- Investigation guide aligned with the actual code
- How fixed mode proves the fix
- Unit tests for non-trivial fixed-path logic (not trivial math or framework smoke tests)

See [Tasks.md](../Tasks.md) for the full MVP task structure and cross-cutting tasks.
