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

## Shape code so the tool earns its lesson

A lab should not make the root cause more obvious by reading source than by using the intended tool.

Prefer:

- visible symptom first
- one clear tool action
- runtime evidence in the tool
- source reading after the learner has seen the evidence

Avoid:

- putting the broken value directly beside the instructed breakpoint
- requiring multiple breakpoints before any useful state appears
- hiding the cause so deeply that the learner has to reverse-engineer unrelated code

The answer may live elsewhere in the implementation, but the intended tool should reveal it faster and more clearly than casual source scanning.

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

Ordering rule by category:

- Crash: console first.
- Breakpoint: stop-frame locals first.
- Memory: visible counter or footprint first.
- Hang: the freeze itself first.
- Performance: the Instruments trace first.

## Avoid repetition as reproduction

Do not make the learner repeat the same gesture several times unless repetition is the actual diagnostic concept.

Repeated tapping, opening, closing, or navigating often feels like ritual instead of debugging. It also makes the lab more fragile because the learner has to track state across multiple identical actions before any tool produces evidence.

Prefer:

- one tap that creates one wrong result
- one open screen that creates one inspectable object
- one allocation/growth action that produces one visible delta
- one close/dismiss action that proves whether cleanup happened

Avoid:

- "open and close this screen three times" when one retained instance would teach the same lesson
- asking the learner to stack several leaked objects before Memory Graph becomes useful
- requiring repeated setup just to make a counter look more dramatic
- using repetition to compensate for an unclear target object or weak tool payoff

Repetition is appropriate only when the repetition itself is the bug or the measurement:

- Heap Growth Lab may repeat an allocation action because the lesson is accumulating memory.
- Performance labs may repeat an interaction while recording because the trace needs enough samples.
- Race or concurrency labs may repeat an action if nondeterminism is the point, but the instructions should say that explicitly.

If one action can produce the evidence, design the lab around that one action.

## Use unmistakable values

If the lesson depends on spotting a wrong value, make the value unmistakable.

Prefer:

- `"three"` instead of `"3"`
- `missingCountField` instead of `nil` hidden in a large structure
- obvious wrong values over subtle ones

The learner should not have to debate whether the value is broken.

## Make diagnostic messages beginner-readable

If the learner's first useful evidence is a console message, exception reason, warning, assertion, or runtime banner, write that message like a diagnosis, not like internal jargon.

The message should answer:

1. What did the app try to do?
2. Which specific value or object was involved?
3. Why was that action invalid?

Prefer:

- `"The app tried to select row 'row-404' in 'Archived Shipments', but that row does not exist."`

over:

- `"Hidden invalid selection: table='Archived Shipments' missing rowID='row-404'"`
- `"Selection bug: table 'Archived Shipments' tried to select missing row 'row-404'"`

Use labels like "hidden", "invalid", "fault", "trap", or "bug" only if they help the learner understand the concrete failure. If they merely describe the debugging concept, remove them.

The debugger message is part of the lab design. Iterate on it the same way you iterate on locals and call-stack frames.

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

## Teach reliable tool navigation, not default selection

Do not depend on Xcode opening a diagnostic view with the right object, frame, thread, or track already selected unless that behavior has been verified and is stable.

For tools with navigators or sidebars, teach the reliable navigation path directly:

- Memory Graph: show the left navigator if it is hidden, then select the target type.
- Debug navigator: name the thread or frame the learner should click.
- Instruments: name the track and symbol the learner should select.

Avoid wording like:

- "Xcode should show..."
- "Ignore the other nodes..."
- "If it does not select the right object..."

Prefer:

- "Open the left Memory Graph navigator."
- "Select `SignalLab.RetainCycleLabCheckoutScreen`."
- "Read the retaining path around that selected node."

The learner should learn how to find the evidence, not hope the tool opens in the right place.

## Name tool targets in learner language

If a lab asks the learner to find an object in Memory Graph, a frame in LLDB, or a symbol in Instruments, the target name must already make sense from the lab UI.

Avoid introducing tool-only nouns such as "session node", "manager", "coordinator", "predicate", or "handler" unless the UI has already explained what that thing represents. A learner should not have to understand the app's internal architecture before the diagnostic tool becomes useful.

Prefer names that carry the bug story:

- `RetainCycleLabCheckoutScreen`
- `RetainCycleLabCloseButtonHandler`
- `BreakpointLabDiscountCalculator`

Avoid names that require extra explanation:

- `Session`
- `ControllerHost`
- `GraphOwner`
- `PredicateEvaluator`

For Memory Graph specifically, show the expected ownership shape in the lab before asking the learner to open Xcode. If the useful evidence requires selecting multiple unexplained boxes, following a visually ambiguous graph, or accepting "Xcode may not draw the loop clearly," redesign the fixture until the object names and arrows tell the lesson directly.

## Per-category immediate-payoff targets

Different lab categories earn their first payoff in different ways. Use the right shape for the category instead of forcing every lab into the same debugger ritual.

### Crash

- First payoff: the runtime explains the bug in plain English in the console.
- Second payoff: one curated caller frame shows the broken value directly.
- Not ready until the learner can point to one obvious bad value without decoding generic storage.

### Exception Breakpoint

- First payoff without the tool: the app keeps running but shows a vague recovered failure that hides the useful context.
- First payoff with the tool: the exception breakpoint stops at the hidden throw site, and the exception reason plus locals explain the concrete invalid action.
- Not ready until the exception reason is beginner-readable and the useful frame shows the named values that the app-level message hid.

### Breakpoint

- First payoff: the paused stop frame shows readable locals that explain the wrong branch.
- The learner should not need bridged Objective-C types, deep stepping, or multiple breakpoints before the bug story is visible.
- Not ready until one plain line breakpoint yields useful state immediately.

### Memory

- First payoff: the app shows a visible lifetime or footprint signal before the learner opens a tool.
- Memory Graph, Zombies, or allocation tools should answer a question the visible signal already made worth asking.
- Not ready until the learner can say what stayed alive or kept growing before opening Xcode tooling.

### Hang

- First payoff: the learner physically feels the freeze or blocked interaction.
- Second payoff: Pause reveals one specific blocking frame to look for.
- Not ready until the learner can both feel the stall and find the blocking work quickly on the main thread.

### Performance

- First payoff: an Instruments trace reveals at least one hot frame in app code.
- The learner should not need to reverse-engineer buried system frames before naming the expensive work.
- Not ready until the trace makes one app-owned cost easy to name.

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
