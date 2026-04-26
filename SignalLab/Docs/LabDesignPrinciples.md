# Lab Design Principles

SignalLab teaches debugging through **repeatable, realistic scenarios**. Every lab should reinforce the same product standards described in [ReadMe.md](../../ReadMe.md) and [Tasks.md](../../Tasks.md).

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

## Teach the reliable tool path

Do not build a lab around a diagnostic view's default selection unless that selection is deterministic across runs and Xcode versions. If the reliable path is a navigator, search field, filter, or inspector pane, teach that path directly and keep it to the minimum steps needed to reveal the evidence.

## Use learner-facing target names

Diagnostic targets should be named in terms the learner already understands from the lab. A Memory Graph object, breakpoint frame, or Instruments symbol should not require unexplained architecture nouns before the evidence makes sense.

For Memory Graph labs, show the expected ownership shape before opening Xcode. If the cycle only becomes visible after selecting several ambiguous objects, redesign the fixture around fewer, clearer app-owned types.

## Shape code so the tool earns its lesson

The source should not reveal the answer before the tool does. Put the learner's first useful evidence at the diagnostic stop, graph node, stack frame, or trace, then connect that evidence back to source.

## Avoid repetition as reproduction

Do not ask learners to repeat gestures just to manufacture evidence unless repetition is the diagnostic concept. Prefer one action that creates one clear artifact. Repetition is appropriate for heap growth, performance accumulation, and race timing labs where repeated behavior is the lesson.

## Authoring checklist (summary)

When proposing a new lab, capture:

- User story and primary lesson
- Requirements and acceptance criteria
- Deterministic reproduction steps
- Investigation guide aligned with the actual code
- How fixed mode proves the fix
- Unit tests for non-trivial fixed-path logic (not trivial math or framework smoke tests)

See [Tasks.md](../../Tasks.md) for the full MVP task structure and cross-cutting tasks.
