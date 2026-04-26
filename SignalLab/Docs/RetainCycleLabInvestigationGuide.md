# Retain Cycle Lab — Investigation Guide

## Goal

Use Xcode Memory Graph to answer one question:

> Why does the checkout screen point back to itself through another object?

The first object to find is `RetainCycleLabCheckoutScreen`.

## Flow

1. Run SignalLab from Xcode and open **Retain Cycle Lab**.
2. Tap **Run scenario** once.
3. Open Memory Graph with the three-node debug bar button, or use **Debug > Debug Workflow > View Memory**.
4. If the left Memory Graph navigator is hidden, show it with Xcode's left sidebar button.
5. In the left navigator, expand `SignalLab.debug.dylib`.
6. Select `RetainCycleLabCheckoutScreen`.
7. Read the retaining path around the selected node.

The canvas may initially show SwiftUI, AttributeGraph, or another framework object. That is normal. Use the left navigator to select the lab object directly.

In this debug build, the checkout screen may appear nested under `SignalLab.debug.dylib`. That nesting is expected; it is still the app object created by the lab.

## What To Look For

The useful shape is two named app objects pointing back to each other:

```text
RetainCycleLabCheckoutScreen
  -> RetainCycleLabCloseButtonHandler
  -> RetainCycleLabCheckoutScreen
```

The names are the lesson. The checkout screen owns the handler for its Close button. The handler wrongly owns the checkout screen. Because the path returns to the same checkout screen, neither object can be released.

## Source Check

After Memory Graph shows the ownership shape, open `RetainCycleLabCheckoutScreen.swift`.

The checkout screen owns the close-button handler:

```swift
checkoutScreen.closeButtonHandler = closeButtonHandler
```

Then the handler keeps a strong reference back to the checkout screen:

```swift
closeButtonHandler.checkoutScreen = checkoutScreen
```

That back-reference is the bug.

## If Capture Fails

If Memory Graph fails with a `LeakAgent` / `libmalloc` initialization error, keep the app running, interact with the lab once more, then try **View Memory** again. If it repeats, stop and run the app again from Xcode.

Treat that as a Memory Graph capture problem, not evidence about the retain cycle.

## Checklist

- [ ] You tapped Run scenario once before opening Memory Graph.
- [ ] You found `RetainCycleLabCheckoutScreen` in the left Memory Graph navigator.
- [ ] You described the cycle as checkout screen -> close-button handler -> checkout screen.
