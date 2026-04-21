# SignalLab Lab Best Practices

This document captures the design principles that emerged while refining **Crash Lab**.

The goal is to make every lab:

- intuitive on first contact
- easy to follow under debugger pressure
- focused on one teaching outcome
- designed so each learner action produces an immediate payoff

Use this document as a checklist when creating, revising, or reviewing any lab.

## Core principle

Every action the learner takes should produce useful evidence.

A lab should not ask the learner to click, navigate, pause, inspect, or configure something unless doing so gives them a clear and immediate win.

Bad lab design feels like:

- "Click here because that is what debuggers do."
- "Move up the call stack because maybe context exists there."
- "Inspect locals" when the locals are noisy, generic, or irrelevant.

Good lab design feels like:

- "Click this frame and you will see the exact broken value."
- "Read this message and it already names the wrong type."
- "Move up one caller frame and the payload becomes obvious."

## What the learner should get from a lab

Each lab should answer four things cleanly:

1. What symptom did I observe?
2. What is the first tool I should use?
3. What useful evidence will that tool show me?
4. How do I confirm my conclusion in Fixed mode?

If any of those answers are vague, the lab is probably not ready.

## Design for the user win

The lab should be built around a specific learner win.

Examples:

- Crash Lab:
  - learner win: "I can point to the exact broken value in the debugger."
- Breakpoint Lab:
  - learner win: "I can point to the branch that skips the intended condition."
- Retain Cycle Lab:
  - learner win: "I can point to the retaining path that keeps the object alive."
- Hang Lab:
  - learner win: "I can point to the work blocking the main thread."

Before adding copy or code, write the win in one sentence.

If the current implementation does not support that win clearly, change the implementation.

## Shape the implementation for debugger readability

The implementation exists to support the lesson.

That means:

- prefer readable locals over technically compact code
- prefer one obvious local over several indirect ones
- prefer values that are self-explanatory in Xcode Variables view
- prefer names that match the mental model of the lab

For teaching labs, this is usually better:

```swift
let brokenCountText = "three"
let brokenJSONText = """
...
"""
```

than this:

```swift
let data = ...
let payload = ...
let preview = ...
```

if the latter makes the debugger harder to read.

## Eliminate irrelevant locals

If a local does not help the learner understand the bug, remove it from the useful frame.

Examples of low-value locals:

- generic `Data`
- intermediate storage used only for implementation plumbing
- values that duplicate the same concept with no added clarity
- "preview" values that add naming noise without teaching value

Examples of high-value locals:

- `brokenCountText = "three"`
- `brokenJSONText = ...`
- `mode = "broken"`
- `run = 1`

The useful frame should feel curated.

## Make call stack navigation worth it

Do not tell the learner to move up the call stack unless the caller frame contains clearer or more useful context.

If moving up one frame does not reveal something better than the crash frame, redesign the implementation until it does.

Call stack navigation should teach:

- what the failing function assumed
- who called it
- what input or state reached it

The learner should feel:

- "Ah, this is why moving up one frame helped."

not:

- "I moved up because the instructions said to."

## Prefer one-step gains

The best labs often use a one-step gain:

- read one message
- click one frame
- inspect one local
- see one obvious value

The first payoff should happen quickly.

For beginner labs, if the learner must do three or four abstract steps before they see useful evidence, the lab is too indirect.

## Use unmistakable values

If the lesson depends on spotting a wrong value, make the value unmistakable.

Prefer:

- `"three"` instead of `"3"`
- `missingCountField` instead of `nil` hidden in a large structure
- obvious wrong values over subtle ones

The learner should not have to debate whether the value is broken.

## Keep the first tool honest

The first tool listed in the lab should match the actual fastest path to useful evidence.

Examples:

- Crash Lab:
  - first tool: console message, then useful caller-frame navigation
- Breakpoint Lab:
  - first tool: one plain line breakpoint
- Retain Cycle Lab:
  - first tool: visible lifetime signal, then Memory Graph
- Hang Lab:
  - first tool: pause during freeze and inspect main thread

Do not name a tool first if the real evidence comes from somewhere else.

## The implementation may need to change to support the teaching goal

Do not treat the sample app implementation as fixed.

If the current code does not produce a clean debugger experience:

- rename locals
- split functions
- inline values
- separate broken vs fixed paths
- move the interesting values into the caller frame
- remove noise from the frame the learner is told to inspect

The lab implementation is part of the curriculum design.

## Broken and Fixed paths should support the lesson differently

Broken mode should make the bug easy to see.

Fixed mode should make the confirmation easy to see.

They do not need identical internal structure if separating them improves readability and teaching.

For example:

- Broken path may use a dedicated helper so the caller frame has clean locals.
- Fixed path may use a separate helper so its state is not mixed into the Broken debugging story.

Separation is good if it improves clarity.

## Write instructions against real evidence, not theory

Do not write instructions like:

- "find the first frame with SignalLab"

unless you have verified that the learner can really identify that frame easily in Xcode.

Do write instructions like:

- "click the `CrashImportParser` frame even if Xcode truncates the label"
- "move up one frame to `runBrokenImport()`"
- "inspect `brokenCountText` first"

Instructions should match exactly what the user will see.

## Keep the variable view simple

When designing a lab, ask:

- If the learner opens Variables on the intended frame, what are the first 3 things they see?

If the answer is noisy or technical, simplify the code.

A good intended Variables view should:

- have a small number of meaningful locals
- use names that explain themselves
- expose the broken state without extra decoding effort

## Lab review checklist

Use this before shipping or revising a lab.

### Teaching clarity

- What is the exact learner win?
- What symptom starts the lab?
- What is the first tool?
- What useful evidence does that tool reveal immediately?
- What is the Fixed validation?

### Debugger clarity

- Does the intended frame contain only meaningful locals?
- Are the local names readable and obvious?
- Is there an unmistakable broken value?
- Does moving up the call stack reveal better context?
- Are we asking the learner to inspect anything that does not pay off?

### Copy clarity

- Do the instructions name exactly what the learner should click?
- Do the instructions match what Xcode actually shows?
- Do we avoid generic phrases like "inspect the stack" when a more specific instruction exists?
- Is the “done when…” line concrete and observable?

## Review questions for every future lab

When refining a lab, ask:

1. What is the one thing the learner should be able to point to?
2. What is the fastest path to that evidence?
3. Does the current implementation make that evidence obvious?
4. If not, what code should change so it does?

If needed, redesign the lab implementation until the answer is strong.

## Summary

SignalLab labs should be designed for **clarity under pressure**.

That means:

- one clear symptom
- one clear first tool
- one clear learner win
- one clear validation step

Most importantly:

**The debugger experience is part of the lesson design.**

If the learner’s intended frame, locals, and navigation path are not clean, the lab is not finished yet.
