# Retain Cycle Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Memory Graph**) if retaining paths or the Memory Graph UI are unfamiliar.

## The scenario

Each time you tap Run scenario, a `RetainCycleLabSession` is created and presented in a sheet. The session stores a `completionHandler` closure. In Broken mode, that closure captures `self` strongly — the session holds a reference to itself through its own stored closure. When you close the sheet, the session should deallocate, but the cycle prevents it.

- **Broken mode:** each session stays alive after dismissal — the live counter climbs and never drops.
- **Fixed mode:** each session deallocates when the sheet closes — the counter drops immediately.

## Your first evidence: the live counter

Before opening any Xcode tool, the app already tells you what is wrong.

Open and close the session sheet three times in Broken mode. The **Live detail sessions** counter reads `3`. You expected `0`. Three objects that should be gone are still alive.

That number is concrete, observable evidence of a leak. You do not need Memory Graph to know the leak exists — you need it to understand *why*.

## Opening Memory Graph

Memory Graph shows every object currently alive in your app's heap, and the references holding each one alive.

**How to open it:**
- Click the three-circle icon in the Xcode debug bar (between the memory gauge and the thread navigator), or
- Use **Debug → View Memory Graph Hierarchy** from the menu bar

The app pauses. A graph appears showing all live objects.

## Finding the leaked sessions

In the **filter field** at the bottom of the Memory Graph navigator, type:

```
RetainCycleLabSession
```

You will see one node for each leaked session — three nodes if you opened the sheet three times. Each one is an object that should have been freed when you closed its sheet.

## Reading the retaining path

Click one `RetainCycleLabSession` node. Xcode shows the **retaining path** — the chain of references keeping that object alive.

You will see:

```
RetainCycleLabSession
    └── completionHandler (closure / __NSMallocBlock__)
            └── RetainCycleLabSession   ← same object
```

**Your type is on both ends.** The session holds a closure, and the closure holds the session. Neither can be freed because each is waiting for the other to go first. This is a retain cycle.

Compare this to the Timer-based pattern you might have seen elsewhere: `RunLoop → NSTimer → closure → YourObject`. In this lab, the cycle is shorter and entirely in your code — no system objects in the middle.

## Finding the broken line

Open `RetainCycleLabSession.swift` and find the `init` method. In the Broken branch:

```swift
case .broken:
    completionHandler = {
        self.handleCompletion()  // ← unqualified self — strong capture
    }
```

The unqualified `self` in the closure capture is the broken assumption. Swift closures capture values strongly by default. Storing this closure as a property on `self` creates the cycle.

## The fix

```swift
case .fixed:
    completionHandler = { [weak self] in
        self?.handleCompletion()  // ← weak capture — no cycle
    }
```

`[weak self]` tells Swift: hold a weak reference to the session inside the closure. A weak reference does not prevent deallocation. When the sheet closes and no other strong references exist, the session is freed — and the closure's `self?` becomes `nil`.

The change is one token in the capture list.

## Fixed mode validation

Switch to Fixed mode. Open and close the sheet once. The **Live detail sessions** counter drops from 1 to 0 within a frame of dismissal.

Open Memory Graph again. Filter for `RetainCycleLabSession`. No nodes appear — the session deallocated cleanly.

## Teaching summary

| | Broken | Fixed |
|---|---|---|
| Capture | `self` (strong) | `[weak self]` |
| Cycle | session → closure → session | none |
| After dismiss | session stays alive | session deallocates |
| Counter | climbs, never drops | drops after each close |

## Checklist

- [ ] The Live detail sessions counter reached 3 after three open/close cycles in Broken mode.
- [ ] You found `RetainCycleLabSession` nodes in Memory Graph.
- [ ] You read the retaining path and saw your type on both ends.
- [ ] You pointed to `self.handleCompletion()` as the strong capture.
- [ ] Fixed mode dropped the counter to 0 after one open/close cycle.

## Code map

- `RetainCycleLabSession` — owns the `completionHandler` closure; Broken/Fixed capture semantics live here
- `RetainCycleLabSessionTracker` — maintains the `liveSessionCount` shown in the UI
- `iOSRetainCycleLabDetailView` — lab shell with the live counter
- `iOSRetainCycleLabSheetView` — sheet that holds the session via `@StateObject`
