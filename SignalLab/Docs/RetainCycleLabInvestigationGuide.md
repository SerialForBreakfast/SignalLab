# Retain Cycle Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Memory Graph**) if retaining paths or the Memory Graph UI are unfamiliar.

## The scenario

Each time you tap Run scenario, a `RetainCycleLabCheckoutSession` is created and presented in a checkout sheet. The checkout session stores a `completionHandler` closure. When you close the sheet, the checkout session should deallocate. In Broken mode it does not, and the goal is to use Memory Graph search to find the closed checkout sessions before reading the source fix.

- **Broken mode:** each checkout session stays alive after dismissal — the live counter climbs and never drops.
- **Fixed mode:** each checkout session deallocates when the sheet closes — the counter drops immediately.

## Your first evidence: the live counter

Before opening any Xcode tool, the app already tells you what is wrong.

Open and close the checkout sheet three times in Broken mode. The **Live checkout sessions** counter reads `3`. You expected `0`. Three checkout sessions that should be gone are still alive.

That number is concrete, observable evidence of a leak. You do not need Memory Graph to know the leak exists — you need it to understand *why*.

## Opening Memory Graph

Memory Graph shows every object currently alive in your app's heap, and the references holding each one alive.

**How to open it:**
- Click Xcode's **Debug Memory Graph** button in the debug bar. It looks like three connected nodes:

  ```text
  o
  |\
  o-o
  ```

- Or use **Debug > Debug Workflow > View Memory** from the macOS menu bar.

The app must be running under Xcode's debugger. If the menu item or button is disabled, run the app from Xcode again, reproduce the leak, and try while the app is still running. Opening Memory Graph pauses the app and replaces the normal Debug navigator stack with memory graph results.

If Xcode shows `Failed to generate memory graph` with `LeakAgent` and says the target's `libmalloc` has not been initialized, keep the app running, interact with the lab once more, then try **View Memory** again. If it repeats, stop the run and launch the app again from Xcode before repeating the leak steps. This is a capture/setup failure, not evidence about the retain cycle.

## Finding the leaked sessions

Use the Memory Graph navigator's filter/search field before interpreting the graph. Type:

```
RetainCycleLabCheckoutSession
```

Depending on the Xcode version, the type may appear as `RetainCycleLabCheckoutSession` or with a module prefix such as `SignalLab.RetainCycleLabCheckoutSession`. You should see one node for each leaked checkout session — three nodes if you opened and closed the sheet three times. Each one is an object that should have been freed when you closed its sheet.

If the search finds no `RetainCycleLabCheckoutSession` nodes, return to the app and check the **Live checkout sessions** counter. It should be above `0` before you capture Memory Graph. If it is `0`, reproduce Broken mode again by opening and closing the checkout sheet.

## Reading the retaining path

Click one `RetainCycleLabCheckoutSession` node. Xcode shows the references around that object. Use the selected node's graph and inspector to find the **retaining path** — the chain of strong references keeping that object alive.

Names vary slightly across Xcode and OS versions, but the important shape is:

```
RetainCycleLabCheckoutSession
    └── completionHandler, closure context, or __NSMallocBlock__
            └── RetainCycleLabCheckoutSession   ← same object
```

**Your checkout session type is on both ends.** The checkout session holds a closure, and the closure holds the checkout session. Neither can be freed because each is waiting for the other to go first. This is a retain cycle.

## Finding the broken line

Open `RetainCycleLabCheckoutSession.swift` and find the `init` method. In the Broken branch:

```swift
case .broken:
    completionHandler = {
        self.handleCompletion()  // ← unqualified self — strong capture
    }
```

The unqualified `self` in the closure capture is the broken assumption. Swift closures capture values strongly by default. Storing this closure as a property on the checkout session creates the cycle.

## The fix

```swift
case .fixed:
    completionHandler = { [weak self] in
        self?.handleCompletion()  // ← weak capture — no cycle
    }
```

`[weak self]` tells Swift: hold a weak reference to the checkout session inside the closure. A weak reference does not prevent deallocation. When the sheet closes and no other strong references exist, the checkout session is freed — and the closure's `self?` becomes `nil`.

The change is one token in the capture list.

## Fixed mode validation

Switch to Fixed mode. Open and close the sheet once. The **Live checkout sessions** counter drops from 1 to 0 within a frame of dismissal.

Open Memory Graph again. Filter for `RetainCycleLabCheckoutSession`. No nodes appear — the checkout session deallocated cleanly.

## Teaching summary

| | Broken | Fixed |
|---|---|---|
| Capture | `self` (strong) | `[weak self]` |
| Cycle | checkout session -> closure -> checkout session | none |
| After dismiss | checkout session stays alive | checkout session deallocates |
| Counter | climbs, never drops | drops after each close |

## Checklist

- [ ] The Live checkout sessions counter reached 3 after three open/close cycles in Broken mode.
- [ ] You found `RetainCycleLabCheckoutSession` nodes in Memory Graph.
- [ ] You read the retaining path and saw the same checkout session type on both ends, even if Xcode used slightly different closure/block labels.
- [ ] You pointed to `self.handleCompletion()` as the strong capture.
- [ ] Fixed mode dropped the counter to 0 after one open/close cycle.

## Code map

- `RetainCycleLabCheckoutSession` — owns the `completionHandler` closure; Broken/Fixed capture semantics live here
- `RetainCycleLabSessionTracker` — maintains the `liveSessionCount` shown in the UI
- `iOSRetainCycleLabDetailView` — lab shell with the live counter
- `iOSRetainCycleLabSheetView` — sheet that holds the checkout session via `@StateObject`
