# Memory Graph Lab — Investigation Guide

## Goal

Use Xcode Memory Graph to answer one beginner question:

> This checkout session is still alive. Which app object is holding it?

This lab is intentionally **not** Retain Cycle Lab. The first skill is navigating to a named app object and reading one straight keep-alive path.

The shared SignalLab Run scheme already enables **Malloc Stack Logging** at **Product > Scheme > Edit Scheme > Run > Diagnostics > Memory Management**. That scheme setting is what lets Memory Graph show allocation backtraces for this lab.

## Flow

1. Run SignalLab from Xcode and open **Memory Graph Lab**.
2. Tap **Set up lab**. The app creates one checkout session and stores it in `MemoryGraphSessionStore`.
3. Open Memory Graph with the three-node debug bar button, or use **Debug > Debug Workflow > View Memory**.
4. If the left Memory Graph navigator is hidden, show it with Xcode's left sidebar button.
5. In the left navigator, expand **SignalLab**, then **SignalLab.debug.dylib**.
6. Select `MemoryGraphSessionStore`.
7. Follow the `currentSession` arrow to `MemoryGraphCheckoutSession`.
8. Select `MemoryGraphCheckoutSession`, open the right inspector, and expand **Backtrace**.
9. Select the `MemoryGraphCheckoutSession.__allocating_init(identifier:)` frame.
10. Click the tiny `arrow.up.forward.circle`-style jump-to-source button at the far right of that selected row. It can be hard to see when the row text is truncated.
11. Return to the app, tap **Reset**, capture Memory Graph again, and confirm `currentSession` no longer keeps the checkout session alive.

The canvas may initially show SwiftUI, AttributeGraph, or another framework object. That is normal. Use the left navigator hierarchy to select the lab object directly.

## What To Look For

The useful shape is a short keep-alive path. For this lab, read each arrow as **keeps alive**: the object at the tail has a strong reference to the object at the arrowhead.

```text
MemoryGraphSessionStore
  keeps alive -> MemoryGraphCheckoutSession
      keeps alive -> MemoryGraphCheckoutCart
      keeps alive -> MemoryGraphCheckoutReceipt
```

The lesson is the `currentSession` arrow: `MemoryGraphSessionStore` still references the checkout session, so the session remains alive. There is no arrow that loops back to `MemoryGraphSessionStore`, so this is not a retain cycle.

## Backtrace

The shared SignalLab scheme enables malloc stack logging for Run so Memory Graph can show allocation backtraces. If the right inspector says malloc stack logging is not enabled, stop the app, confirm **Product > Scheme > Edit Scheme > Run > Diagnostics > Memory Management > Malloc Stack Logging** is checked, then run the app again from Xcode before capturing Memory Graph.

In the right inspector, expand **Backtrace** for `MemoryGraphCheckoutSession`. The useful frame is `MemoryGraphCheckoutSession.__allocating_init(identifier:)`. Select that row, then click the tiny jump-to-source arrow at the far right of the row to open the allocation source line. Jumping to that frame closes the loop:

```text
live object -> owner arrow -> allocation backtrace -> source line
```

## Source Check

After Memory Graph shows the keep-alive path, open `MemoryGraphLabScenarioRunner.swift`.

Set up lab stores the session:

```swift
currentSession = session
```

Reset clears the store:

```swift
currentSession = nil
```

## If Capture Fails

Simulator captures can fail before Xcode's LeakAgent can scan the app process:

```text
failed to create a VMUTaskMemoryScanner, probably because the target's libmalloc hasn't been initialized
Domain: LeakAgent
Code: -1
```

This is a capture setup failure, not evidence about the lab. Use a device for the Memory Graph capture when Simulator repeatedly reports this error.

## Checklist

- [ ] You tapped Set up lab once before opening Memory Graph.
- [ ] You navigated to `MemoryGraphSessionStore` under `SignalLab.debug.dylib`.
- [ ] You read the arrow from `MemoryGraphSessionStore` to `MemoryGraphCheckoutSession` as "the store keeps the session alive."
- [ ] You used the right inspector Backtrace and the row's far-right jump-to-source arrow to navigate to the allocation source line.
- [ ] You used Reset to confirm the stored session disappears from the keep-alive path.
