# ADR-0001: Evaluate The Composable Architecture for SignalLab

## Status

Proposed for exploration. Do not migrate the whole app yet.

## Context

SignalLab is a SwiftUI app made of many small diagnostic labs. Most labs follow the same shape:

- catalog metadata lives in `LabCatalog`
- each lab has a SwiftUI detail view
- each lab owns a scenario runner conforming to `LabScenarioRunning`
- runners are usually `@Observable` reference types
- shared UI is provided by `iOSLabDetailScaffold`
- tests exercise runner state and catalog metadata

This has worked well for quickly adding labs, but the recent Breakpoint and Retain Cycle rewrites exposed recurring friction:

- Lab state and UI policy are spread across metadata, runner state, scaffold options, and per-lab views.
- `LabScenarioRunning` assumes every lab has `implementationMode`, `triggerInvocationCount`, and `reset`, even when a lab does not need those concepts.
- The shared scaffold can accidentally impose controls or copy that are wrong for a specific teaching flow.
- Tests usually verify runner methods directly, but they do not model the full user flow as a sequence of actions.
- As the lab count grows, consistency depends on convention rather than an explicit state/action contract.

The Composable Architecture (TCA) is a candidate architecture because it makes state, actions, reducers, dependencies, and tests explicit.

## Decision Question

Should SignalLab adopt TCA, and if so, how?

## Recommendation

Run a limited TCA pilot on one or two labs before deciding on app-wide adoption.

Good candidates:

1. **Breakpoint Lab**: clear state, deterministic action flow, useful reducer tests.
2. **Retain Cycle Lab**: intentionally minimal UI, useful for testing whether TCA adds clarity or ceremony.

Avoid migrating the whole catalog or every lab until the pilot proves that TCA reduces real complexity.

## What TCA Would Solve

### Explicit Lab State

Today, lab state is stored in runner classes with ad hoc properties:

```swift
@Observable
final class BreakpointLabScenarioRunner: LabScenarioRunning {
    var implementationMode: LabImplementationMode
    private(set) var triggerInvocationCount: Int = 0
    var lastResult: BreakpointLabOrderResult?
}
```

With TCA, each lab would define its exact state:

```swift
@Reducer
struct BreakpointLabFeature {
    @ObservableState
    struct State: Equatable {
        var runCount = 0
        var orderResult: BreakpointLabOrderResult?
    }

    enum Action: Equatable {
        case runScenarioTapped
        case resetTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .runScenarioTapped:
                state.runCount += 1
                state.orderResult = BreakpointLabDiscountCalculator.calculateStudentOrderTotal()
                return .none
            case .resetTapped:
                state = State()
                return .none
            }
        }
    }
}
```

The lab would only expose the state it actually needs. A lab with no reset or fixed mode would not carry those concepts.

### User Flow Tests

Current tests tend to call runner methods and inspect final properties. That works, but it does not describe the flow as clearly as the curriculum does.

TCA tests would read like the lab:

```swift
@Test
func breakpointLabRunShowsWrongDiscount() async {
    let store = TestStore(
        initialState: BreakpointLabFeature.State()
    ) {
        BreakpointLabFeature()
    }

    await store.send(.runScenarioTapped) {
        $0.runCount = 1
        $0.orderResult = .studentDiscountBug
    }
}
```

This is a better match for SignalLab because each lab is fundamentally a guided user flow.

### Better Boundaries Between Lab Logic and UI

Right now, a lab detail view often knows:

- which runner to construct
- which scaffold options to hide
- what footer to render
- how runner state maps to screen copy

With TCA, the feature can own state transitions while the view becomes a rendering layer:

```swift
struct BreakpointLabView: View {
    let store: StoreOf<BreakpointLabFeature>

    var body: some View {
        WithPerceptionTracking {
            LabDetailScreen(
                title: "Breakpoint Lab",
                runAction: { store.send(.runScenarioTapped) },
                result: store.orderResult
            )
        }
    }
}
```

This could help prevent the scaffold from imposing irrelevant controls like Fixed mode, Reset, or redundant guidance sections.

### Dependency Control

Some labs already touch time, async tasks, logging, notifications, or deterministic sample data. TCA dependencies would make these explicit and testable:

- clocks for async waits
- UUID/date generation if needed later
- notification posting
- scenario data providers
- logging clients

This is most useful for labs like Thread Sanitizer, Background Thread UI, Startup Signpost, Main Thread I/O, and future labs with more async behavior.

### Modular Lab Features

SignalLab already wants labs to be independent teaching modules. TCA maps cleanly to that:

```text
Labs/
  Breakpoint/
    BreakpointLabFeature.swift
    BreakpointLabView.swift
    BreakpointLabDiscountCalculator.swift
  RetainCycle/
    RetainCycleLabFeature.swift
    RetainCycleLabView.swift
    RetainCycleLabCheckoutScreen.swift
```

Each lab could become a feature with:

- `State`
- `Action`
- `Reducer`
- `View`
- domain helpers
- focused reducer tests

## Tradeoffs

### Added Dependency and Learning Curve

TCA is an external architecture dependency. SignalLab currently uses SwiftUI, Observation, and lightweight runner classes. Adding TCA means contributors must understand:

- reducers
- stores
- actions
- effects
- dependencies
- `TestStore`

That may be a poor fit for small labs whose state is just "tap button, show text."

### More Ceremony for Simple Labs

Some labs are intentionally simple. Crash Lab, Exception Breakpoint Lab, and Retain Cycle Lab may not need full reducer structure.

For example, Retain Cycle Lab now mostly needs:

- show a short instruction card
- open one checkout screen
- let Xcode Memory Graph do the teaching

A full TCA reducer for that may be architectural overhead unless it helps unify navigation or testing.

### Risk of Distracting from the Teaching Product

SignalLab's main product is debugging pedagogy. Architecture should support that goal, not become the project.

The recent Retain Cycle cleanup showed that simpler UI and clearer instructions mattered more than adding state machinery. TCA would not automatically solve unclear lab design.

### Migration Cost

An app-wide migration would touch:

- every lab detail view
- every scenario runner
- shared scaffold APIs
- unit tests
- screenshot tests
- launch/deep-link flows

That is not justified until a pilot proves a meaningful reduction in complexity.

### SwiftUI Observation Is Already Good Enough in Places

The current `@Observable` runner pattern is straightforward and native. For many labs, it is easy to read, easy to test, and avoids framework concepts.

TCA should replace it only where explicit action/state modeling improves the code.

## What It Would Look Like in Practice

### Phase 1: Add TCA for One Lab Only

Pick **Breakpoint Lab** as the first pilot.

Why:

- deterministic business result
- no dangerous crash path
- clear user actions
- existing tests can be converted cleanly
- state is small enough to review honestly

Proposed feature state:

```swift
@Reducer
struct BreakpointLabFeature {
    @ObservableState
    struct State: Equatable {
        var runCount = 0
        var displayedResult: BreakpointLabOrderResult?
    }

    enum Action: Equatable {
        case runScenarioButtonTapped
        case resetButtonTapped
    }
}
```

The existing `BreakpointLabDiscountCalculator` should stay as plain domain logic. TCA should coordinate state, not swallow all logic.

### Phase 2: Extract Shared Lab Chrome Only If Needed

After one pilot, evaluate whether shared UI should become a TCA parent feature:

```swift
@Reducer
struct LabDetailFeature {
    @ObservableState
    struct State: Equatable {
        var scenario: LabScenario
        var breakpoint: BreakpointLabFeature.State?
        var retainCycle: RetainCycleLabFeature.State?
    }

    enum Action {
        case breakpoint(BreakpointLabFeature.Action)
        case retainCycle(RetainCycleLabFeature.Action)
    }
}
```

Do this only if it simplifies routing and shared controls. Avoid a parent reducer that merely recreates the current switch statement with more ceremony.

### Phase 3: Decide Whether to Migrate More Labs

Good migration candidates:

- Breakpoint Lab
- CPU Hotspot Lab
- Heap Growth Lab
- Main Thread I/O Lab
- Startup Signpost Lab
- Concurrency Isolation Lab

Poor initial candidates:

- Crash Lab, because the broken path intentionally traps
- Zombie Objects Lab, because the diagnostic is scheme-driven and can crash
- Retain Cycle Lab, unless the pilot goal is to prove TCA can stay minimal
- Thread Performance Checker Lab, because it is mostly instructional wrapper around another lab

## Problems TCA Would Not Solve

TCA will not fix:

- unclear lab copy
- a bad diagnostic target in Xcode
- a tool path that is unreliable across Xcode versions
- source code that reveals the answer before the tool does
- screenshots or UI review drift

Those are curriculum and product design problems. The Best Practices doc remains the right tool for those.

## Evaluation Criteria

The pilot should be considered successful only if it improves at least two of these:

- Tests describe the user flow more clearly than current runner tests.
- The lab view becomes simpler.
- The lab no longer carries irrelevant scaffold concepts.
- State transitions are easier to reason about.
- Dependencies become more explicit and controllable.
- Adding a new similar lab becomes easier.

The pilot should be considered unsuccessful if:

- the reducer mostly forwards button taps to existing runner methods
- tests become longer without catching better behavior
- simple labs require lots of boilerplate
- contributors need to understand TCA internals to make copy/UI changes

## Suggested Pilot Acceptance Criteria

For a Breakpoint Lab TCA pilot:

- Add TCA as an SPM dependency.
- Implement `BreakpointLabFeature`.
- Replace `BreakpointLabScenarioRunner` usage in the Breakpoint detail view.
- Keep `BreakpointLabDiscountCalculator` as plain Swift domain logic.
- Add reducer tests that cover:
  - first run shows the wrong student discount result
  - reset clears the displayed result and run count
  - no fixed-mode state exists for this lab
- Keep the app UI behavior unchanged.
- Do not migrate unrelated labs during the pilot.

## Decision

Do not adopt TCA app-wide yet.

Run a small Breakpoint Lab pilot if the team wants to evaluate TCA in real project code. Treat the pilot as an experiment with clear exit criteria, not as a commitment to rewrite SignalLab.

## Consequences

If the pilot succeeds:

- SignalLab gets a repeatable architecture for stateful labs.
- Future complex labs can use reducer tests instead of ad hoc runner tests.
- Shared scaffold behavior can become more explicit and less assumption-driven.

If the pilot fails:

- Keep the current `@Observable` runner architecture.
- Continue improving lab design through Best Practices and targeted scaffold options.
- Avoid adding TCA ceremony where direct SwiftUI state is clearer.
