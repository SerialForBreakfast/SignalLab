# ADR-0002: Redesign The Memory Graph Lab Around Clear Ownership Evidence

## Status

Proposed.

This ADR should guide the next implementation pass for the current **Retain Cycle Lab** / Memory Graph curriculum. It records why the current fixture is not satisfying the pedagogy goals and compares better alternatives.

## Context

SignalLab wants the Memory Graph session to teach a beginner-friendly debugging skill:

> When an object is still alive, use Memory Graph to answer: **who is holding it?**

The current Retain Cycle Lab tries to teach that with a small Swift object graph:

```text
RetainCycleLabCheckoutScreen
  -> RetainCycleLabCloseButtonHandler
  -> RetainCycleLabCheckoutScreen
```

That is conceptually simple, but it is not reliably simple in Xcode Memory Graph. In practice, selecting the lab target can show a large SwiftUI / AttributeGraph / runner-centered graph. The learner sees many framework objects, truncated labels, allocation nodes, and unrelated retained strings before seeing the intended two-object lesson. The screenshot from the current run shows `RetainCycleLabScenarioRunner` as the selected node, surrounded by SwiftUI and AttributeGraph machinery. That is the opposite of the intended teaching moment.

The current lab is technically defensible but pedagogically weak:

- the retain cycle is not visually obvious
- the useful app-owned objects are not the first thing the learner sees
- the selected node can be the runner instead of the target model
- SwiftUI scaffolding dominates the graph
- the learner has to trust the written guide instead of seeing the evidence
- the exercise becomes "how do I operate this graph UI?" before "who owns this object?"

That violates SignalLab's lab best practices:

- every learner action should produce useful evidence
- Memory Graph targets should be named in learner-facing terms
- the expected ownership shape should be visible before opening Xcode
- if the graph requires selecting multiple ambiguous boxes, the fixture should be redesigned

## Decision Question

Should the first Memory Graph lab continue to be a **retain cycle** lab, or should it teach a simpler ownership/lifetime question first?

More specifically:

1. What fixture will produce the clearest Memory Graph evidence?
2. Is a retain cycle the best first example?
3. What implementation shape gives us a small, reliable, visually clear graph in Xcode?
4. How do we keep the lab realistic without letting realism bury the lesson?

## Pedagogical Goals

The Memory Graph session should optimize for the learner's first win.

The learner should be able to say:

1. I created one object that should not still be alive.
2. I searched for that object in Memory Graph.
3. I selected it.
4. I found the app object that is holding it.
5. I can explain the ownership path in one sentence.

That first win does **not** require a retain cycle. A retain cycle is only one answer to "why is this alive?"

The most important concept is:

> Memory Graph shows live objects and strong references. Start by finding the object, then inspect who owns it.

The retain-cycle concept can be a second step after the learner understands Memory Graph navigation.

## Current Problem Statement

The current Retain Cycle Lab asks Memory Graph to teach too many things at once:

- how to open Memory Graph
- how to reveal the left navigator
- how to search or browse app-owned types
- how to ignore SwiftUI / AttributeGraph objects
- how to identify the intended app model
- how to read arrows
- how to recognize a cycle
- how to connect that cycle back to source

For a beginner, that is too much. The intended two-object cycle is not the first visual fact on screen. The learner has to fight through Xcode's graph presentation.

## Is Retain Cycle The Best First Memory Graph Example?

Probably not.

A retain cycle is a good production bug, but it is not always the best **first Memory Graph lesson** because:

- cycles are not always visually highlighted in a way beginners expect
- closure/block cycles often introduce opaque intermediate nodes
- SwiftUI object graphs add substantial unrelated noise
- Memory Graph may center the selected object inside a large retained tree instead of drawing the simple loop
- a cycle requires understanding both object lifetime and graph topology at once

A simpler first lab would teach:

> This object is alive. Memory Graph tells you who is holding it.

Then a later or second pass can teach:

> The reason it stays alive is cyclic ownership.

## Vocabulary Choice

The current user request uses "stochastic." For this ADR, the requirement should be interpreted as:

- **not brittle**
- **not dependent on Xcode's default graph centering**
- **reliably reproducible across runs**
- **simple enough that the learner's first evidence is obvious**

The fixture should actually be deterministic, not stochastic. Randomness would make the lab worse. The learner should see the same target names and same ownership path every run.

## Options

## Option A: Keep The Current Swift Retain Cycle And Improve Copy

### Shape

Keep:

```text
RetainCycleLabCheckoutScreen
  -> RetainCycleLabCloseButtonHandler
  -> RetainCycleLabCheckoutScreen
```

Add more guide text, screenshots, and stronger instructions to use the Memory Graph navigator/search field.

### Pros

- Minimal implementation churn.
- The source code is already simple.
- The intended ownership cycle is easy to explain in docs.
- Existing tests already validate the cycle.

### Cons

- Does not solve the screenshot problem.
- Memory Graph can still center on SwiftUI or the runner.
- The visible graph can still be visually dominated by framework objects.
- More instructions may compensate for a weak fixture instead of fixing it.
- The learner may complete the lab by reading the guide, not by understanding the graph.

### Assessment

Not sufficient. This keeps the technical idea but fails the first-payoff standard.

## Option B: Keep A Retain Cycle, But Build It From Objective-C / NSObject Debug Types

### Shape

Create explicitly named Obj-C or `NSObject` subclasses:

```objc
SignalLabMemoryGraphOwner
  strong SignalLabMemoryGraphHandler *handler

SignalLabMemoryGraphHandler
  strong SignalLabMemoryGraphOwner *owner
```

Optionally expose them to Swift through the existing bridge. Use names that appear cleanly in Memory Graph:

```text
SignalLabMemoryGraphOwner
SignalLabMemoryGraphHandler
```

### Pros

- More likely to appear with clean runtime type names.
- Avoids some Swift generic / closure / `@Observable` noise.
- The cycle is still a true retain cycle.
- Objective-C strong properties map well to the memory-management concept.
- The source can be beginner-readable: two strong references are enough.

### Cons

- Still may not draw the loop prominently.
- Still requires teaching cycle topology as the first Memory Graph lesson.
- Adds Obj-C implementation surface to a lab that is otherwise Swift-facing.
- If the object is only self-retained, it may be hard to find without an external anchor.
- If anchored by the runner, the runner may still dominate the graph.

### Assessment

Better than the current Swift model if we insist on retain cycle as the first Memory Graph lab, but still not the strongest first lesson.

## Option C: Use A Global Memory Graph Anchor With A Simple Non-Cyclic Leak

### Shape

Create a single, deliberately app-owned anchor that retains one target:

```text
SignalLabMemoryGraphAnchor
  -> MemoryGraphLeakedCheckoutSession
      -> MemoryGraphCart
      -> MemoryGraphReceiptDraft
```

The bug is not a cycle. The bug is that a long-lived anchor/registry/cache forgot to release a session.

Example source shape:

```swift
final class SignalLabMemoryGraphAnchor {
    static let shared = SignalLabMemoryGraphAnchor()
    var leakedSession: MemoryGraphLeakedCheckoutSession?
}

final class MemoryGraphLeakedCheckoutSession {
    let cart = MemoryGraphCart()
    let receiptDraft = MemoryGraphReceiptDraft()
}
```

Run scenario:

```swift
SignalLabMemoryGraphAnchor.shared.leakedSession = MemoryGraphLeakedCheckoutSession(id: "checkout-042")
```

Fixed/reset:

```swift
SignalLabMemoryGraphAnchor.shared.leakedSession = nil
```

### Pros

- Extremely clear first lesson: "this object is still alive because the anchor owns it."
- The path is a straight line, not a visually ambiguous loop.
- Search target can be either the anchor or the leaked session.
- The anchor gives Memory Graph a stable app-owned root separate from SwiftUI.
- The bug is realistic: registries, caches, coordinators, and singleton services often accidentally retain sessions.
- Reset/fixed behavior is trivial and testable.
- Avoids relying on Xcode to visually highlight a cycle.

### Cons

- It is not a retain cycle.
- If the lab remains titled "Retain Cycle Lab," the name becomes inaccurate.
- Learners will not yet learn cycle-specific reasoning.

### Assessment

Strongest first Memory Graph lab. It teaches Memory Graph as an ownership tool before teaching cycles.

This should likely become **Memory Graph Lab** or **Object Lifetime Lab**, with Retain Cycle moved to a follow-up lab.

## Option D: Use A Global Anchor Plus A Small Retain Cycle Island

### Shape

Combine the stable anchor from Option C with a cycle behind it:

```text
SignalLabMemoryGraphAnchor
  -> MemoryGraphCheckoutCoordinator
      -> MemoryGraphCloseHandler
          -> MemoryGraphCheckoutCoordinator
```

The anchor exists only to make the object island findable. The bug remains the strong back-reference.

Implementation:

```swift
final class SignalLabMemoryGraphAnchor {
    static let shared = SignalLabMemoryGraphAnchor()
    var coordinator: MemoryGraphCheckoutCoordinator?
}

final class MemoryGraphCheckoutCoordinator {
    var closeHandler: MemoryGraphCloseHandler?
}

final class MemoryGraphCloseHandler {
    var coordinator: MemoryGraphCheckoutCoordinator?
}
```

Run scenario:

```swift
let coordinator = MemoryGraphCheckoutCoordinator()
let handler = MemoryGraphCloseHandler()
coordinator.closeHandler = handler
handler.coordinator = coordinator
SignalLabMemoryGraphAnchor.shared.coordinator = coordinator
```

### Pros

- Keeps the retain-cycle lesson.
- The anchor makes the object island easier to find.
- The expected path has only three app types.
- Tests can verify the anchor and cycle.
- The lab can tell the learner to search for `SignalLabMemoryGraphAnchor` first, then follow one path.

### Cons

- The anchor itself is a legitimate owner, which can muddy the cycle diagnosis.
- A beginner may ask: "If the anchor owns it, why do I care about the cycle?"
- To prove the cycle matters, the lab must clear the anchor while the cycle remains alive. That adds another step.
- If the learner captures Memory Graph before clearing the anchor, the first visible reason is the anchor, not the cycle.

### Assessment

Good as a **second Memory Graph step**:

1. Run once: anchor retains graph so it is easy to find.
2. Tap "Release anchor but leave cycle" or run a second phase.
3. Capture Memory Graph again: coordinator/handler remain alive because they retain each other.

But that is more complex than the desired beginner session.

## Option E: Closure Capture Cycle

### Shape

Use a realistic Swift closure cycle:

```text
CheckoutViewModel
  -> onClose closure
      -> captures CheckoutViewModel
```

### Pros

- Very realistic Swift/iOS bug.
- Strongly connected to production code.
- Teaches a common `[weak self]` fix.

### Cons

- Memory Graph often displays closure/block internals opaquely.
- Intermediate nodes can have confusing names.
- Visually worse than a two-object class cycle.
- The learner may need to understand closure capture mechanics before understanding Memory Graph.

### Assessment

Bad first Memory Graph fixture. Useful later, after the learner already understands Memory Graph basics.

## Option F: Timer / RunLoop Cycle

### Shape

Use a classic timer retain cycle:

```text
RunLoop
  -> Timer
      -> closure/target
          -> owner
              -> Timer
```

### Pros

- Realistic and common enough historically.
- Shows framework ownership participating in app leaks.
- Good for explaining why "dismissed" does not mean "deallocated."

### Cons

- Involves framework nodes, run loops, timer internals, closures/targets.
- Not visually minimal.
- Can reintroduce the same graph-noise problem.
- May teach timer trivia instead of Memory Graph basics.

### Assessment

Not appropriate for the first Memory Graph lesson. It is a later, more realistic leak lab.

## Option G: Use Instruments Leaks Instead Of Memory Graph

### Shape

Move the first memory-lifetime lab to Instruments Leaks or Allocations instead of Xcode Memory Graph.

### Pros

- May surface leaks in a more workflow-oriented way.
- Stronger for real-world leak sessions.
- Keeps Memory Graph out of the critical beginner path if it is too noisy.

### Cons

- Instruments has more setup overhead.
- The app already has other Instruments-heavy labs.
- The learner still needs a simple object identity story.
- Leaks can miss intentionally retained-but-unreleased objects if they are still reachable.

### Assessment

Not the right replacement for this slot. Memory Graph is still valuable, but the fixture must be simpler.

## Recommended Decision

Rename and reframe the first Memory Graph lesson as:

> **Memory Graph Lab** or **Object Lifetime Lab**

Do **not** make the first Memory Graph session depend on visually recognizing a retain cycle.

Use **Option C: Global Memory Graph Anchor With A Simple Non-Cyclic Leak** as the first lab.

Then add or keep a separate later lab:

> **Retain Cycle Lab**

implemented with either:

- Option B: Objective-C / NSObject two-object cycle, or
- Option D: anchored cycle with a two-phase release path

This sequence is pedagogically cleaner:

1. **Memory Graph Lab:** "Who is holding this object alive?"
2. **Retain Cycle Lab:** "What if the owners form a loop?"
3. **Heap Growth Lab:** "What if memory grows without a cycle?"
4. **Zombie Objects Lab:** "What if the object died too early?"
5. **Malloc Stack Logging Lab:** "Where was this object allocated?"

## Proposed New First Memory Graph Lab

### Working Title

**Memory Graph Lab**

Alternative names:

- Object Lifetime Lab
- Leaked Session Lab
- Retained Session Lab

Avoid "Retain Cycle" in the title unless the first evidence is actually a visible cycle.

### Learner Question

> This checkout session should be gone. Who is still holding it?

### Primary Lesson

Memory Graph is best used by searching for a named object, selecting it, and reading the strong reference path that keeps it alive.

### Symptom

The app shows:

```text
Created leaked checkout session: checkout-042
Expected: session should be released after the operation.
Actual: MemoryGraphSessionStore is still holding it.
```

This visible signal gives the learner a reason to open Memory Graph.

### First Tool

Xcode Memory Graph search/navigator.

### Target Types

Use names designed for the Xcode UI:

```text
MemoryGraphSessionStore
MemoryGraphLeakedCheckoutSession
MemoryGraphCartSnapshot
MemoryGraphReceiptDraft
```

The names should avoid generic words like `Runner`, `View`, `Handler`, `Box`, or `Coordinator` for the first lab. They should describe domain objects the learner already saw in the UI.

### Expected Graph Shape

```text
MemoryGraphSessionStore
  -> MemoryGraphLeakedCheckoutSession
      -> MemoryGraphCartSnapshot
      -> MemoryGraphReceiptDraft
```

The lesson is a straight ownership path.

### Broken Behavior

The store keeps a strong reference after the simulated checkout ends:

```swift
store.currentSession = session
```

### Fixed Behavior

The store releases the session after finishing:

```swift
store.currentSession = nil
```

### Validation

Broken mode:

- search `MemoryGraphLeakedCheckoutSession`
- confirm it is alive
- select it
- find the retaining owner `MemoryGraphSessionStore`

Fixed mode:

- run the same scenario
- open Memory Graph
- search `MemoryGraphLeakedCheckoutSession`
- confirm the old session is gone or no new retained session remains

### Why This Satisfies The Pedagogical Goal

It gives the learner:

- one named object
- one search term
- one owner
- one reason the object is alive
- one fixed-mode proof

There is no cycle topology, closure internals, or SwiftUI graph archaeology in the first win.

## Proposed Later Retain Cycle Lab

After the Memory Graph Lab works, add a true Retain Cycle Lab with the learner question:

> The store released the screen, so why are these two objects still alive?

### Recommended Fixture

Use `NSObject` or Objective-C classes with strong properties:

```text
MemoryGraphCheckoutCoordinator
  -> MemoryGraphCloseAction
  -> MemoryGraphCheckoutCoordinator
```

### Two-Phase Reproduction

1. **Create cycle:** create coordinator/action pair.
2. **Release external owner:** remove the store's strong reference.
3. **Capture Memory Graph:** the pair remains alive only because of the cycle.

This avoids the ambiguity of the anchor being the real owner.

### UI Copy

```text
Step 1 created a checkout coordinator and a close action.
Step 2 released the store's reference.
If the objects are still alive, something inside the pair is retaining itself.
```

### Expected Graph Shape

```text
MemoryGraphCheckoutCoordinator
  -> MemoryGraphCloseAction
  -> MemoryGraphCheckoutCoordinator
```

### Fixed Mode

Make the back-reference weak or nil out the close action:

```swift
weak var coordinator: MemoryGraphCheckoutCoordinator?
```

or:

```swift
closeAction.coordinator = nil
```

### Why This Belongs Second

The learner already knows how to:

- search for an app object
- select it
- inspect strong references
- ask "who owns this?"

Now the new concept is only:

> the owner path loops back to the object itself.

## Implementation Guidance

## Keep The Lab Objects Out Of SwiftUI State

Do not make the Memory Graph target the SwiftUI view, `@Observable` runner, or a property directly retained by the view tree. That pulls the learner into AttributeGraph and SwiftUI internals.

Prefer a debug/lab domain object owned by a static or app-level store:

```swift
enum MemoryGraphLabStore {
    static let shared = MemoryGraphSessionStore()
}
```

The SwiftUI runner should trigger the store, then display plain status text. It should not itself be the graph target.

## Use Learner-Facing Type Names

Bad first-lab names:

```text
RetainCycleLabScenarioRunner
AGSubgraph
AttributeGraph
SwiftUI.ModifiedContent
Closure
Box
```

Good first-lab names:

```text
MemoryGraphSessionStore
MemoryGraphLeakedCheckoutSession
MemoryGraphCartSnapshot
MemoryGraphReceiptDraft
```

The names should appear in:

- app UI
- catalog reproduction steps
- `Docs/Labs.md`
- long-form guide
- unit test names

## Prefer A Straight Line Before A Loop

The first Memory Graph diagram should be:

```text
A -> B -> C
```

not:

```text
A -> B -> C -> B
```

The learner must first trust that arrows mean ownership. Then a cycle becomes meaningful.

## Make Search The Official Path

Do not say "look at the graph and find..." as the first instruction.

Say:

1. Open Memory Graph.
2. Show the left navigator if hidden.
3. Use the search field.
4. Search for `MemoryGraphLeakedCheckoutSession`.
5. Select the app-owned type, not the SwiftUI view.
6. Read the owner path.

This is more reliable than relying on Xcode's initial canvas position.

## Provide A Screenshot Target

Once the fixture is changed, capture a reference screenshot for the guide. The screenshot should show:

- left navigator search result
- selected app-owned target
- a short ownership path
- no reliance on a random canvas default

If the screenshot still shows mostly SwiftUI / AttributeGraph nodes, the fixture is not done.

## Testing Guidance

Unit tests cannot assert Xcode Memory Graph rendering, but they can protect the fixture:

### Memory Graph Lab Tests

- Broken run creates a `MemoryGraphLeakedCheckoutSession`.
- Store retains the session after the simulated operation.
- Fixed run releases the session.
- Session contains readable child objects.
- Reset clears the store.

### Retain Cycle Lab Tests

- Broken cycle remains alive after external owner is released.
- Fixed path deallocates after external owner is released.
- The two app-owned types have readable names.
- Reset breaks any retained cycle.

### Manual Verification

Manual Memory Graph verification remains required:

1. Run on preferred simulator.
2. Trigger the lab once.
3. Open Memory Graph.
4. Search for the exact target type.
5. Confirm the graph path matches the guide.
6. Capture a reference screenshot.

## What To Change In The Product

## Short-Term

Do not keep iterating only on copy for the current Retain Cycle Lab. The screenshot shows the fixture is the problem.

Create a new implementation spike:

```text
MemoryGraphSessionStore
MemoryGraphLeakedCheckoutSession
MemoryGraphCartSnapshot
MemoryGraphReceiptDraft
```

Wire it into the current Retain Cycle Lab slot temporarily, then verify Memory Graph manually.

If the graph is clear, rename the lab to **Memory Graph Lab** / **Object Lifetime Lab** and update curriculum ordering.

## Medium-Term

Split the curriculum:

1. **Memory Graph Lab**: non-cyclic retained session.
2. **Retain Cycle Lab**: two-object cycle after external owner release.

This may increase the catalog by one lab, but it reduces cognitive load and improves teaching quality.

## Long-Term

Use the memory track as a sequence of questions:

| Lab | Question | Tool |
| --- | --- | --- |
| Memory Graph Lab | Who is holding this object alive? | Memory Graph |
| Retain Cycle Lab | Why does the owner path loop back? | Memory Graph |
| Heap Growth Lab | Why does memory grow without a cycle? | Allocations / Memory Graph |
| Zombie Objects Lab | What if the object died too early? | Zombie Objects |
| Malloc Stack Logging Lab | Where was this object allocated? | Malloc Stack Logging / Allocations |

This sequence is easier to teach than making Retain Cycle carry the entire Memory Graph introduction.

## Non-Goals

This ADR does not decide:

- the final catalog count
- whether the old `retain_cycle` slug must remain for compatibility
- exact UI styling for the replacement lab
- whether to use Swift-only classes or Objective-C classes in the final implementation

Those can be decided after a Memory Graph fixture spike proves the graph is visually clear.

## Open Questions

1. Should the existing `retain_cycle` slug be renamed, or should it remain stable while the title changes to **Memory Graph Lab**?
2. Should the true Retain Cycle Lab be a new slug, for example `retain_cycle_ownership_loop`?
3. Should the first Memory Graph fixture be Swift classes or Objective-C classes?
4. Should the Memory Graph Lab include Fixed mode immediately, or should Fixed mode wait until the learner has completed the basic graph search?
5. Should the reference screenshot live in `memlog/ui-review/` or in `Docs/` as a guide asset?

## Recommendation Summary

The current Retain Cycle Lab is not the right first Memory Graph lesson. The graph is visually noisy and the cycle is not obvious enough.

Use a simpler, deterministic, non-cyclic retained-session fixture first. Teach Memory Graph as:

> Search for a named object and identify who owns it.

Then teach retain cycles as a second Memory Graph lesson:

> The owner path loops back, so the objects keep each other alive.

This satisfies the pedagogical goals more completely than continuing to polish the current fixture.
