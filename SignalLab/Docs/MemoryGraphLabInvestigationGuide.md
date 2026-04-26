# Memory Graph Lab — Investigation Guide

## Goal

Use Xcode Memory Graph to answer one beginner question:

> This checkout session is still alive. Which app object is holding it?

This lab is intentionally **not** Retain Cycle Lab. The first skill is finding a named object and reading a straight ownership path.

## Flow

1. Run SignalLab from Xcode and open **Memory Graph Lab**.
2. In **Broken** mode, tap **Run scenario** once.
3. Open Memory Graph with the three-node debug bar button, or use **Debug > Debug Workflow > View Memory**.
4. If the left Memory Graph navigator is hidden, show it with Xcode's left sidebar button.
5. Search for `MemoryGraphLeakedCheckoutSession`.
6. Select the app-owned session object.
7. Find `MemoryGraphSessionStore` holding that session.

The canvas may initially show SwiftUI, AttributeGraph, or another framework object. That is normal. Use search or the left navigator to select the lab object directly.

## What To Look For

The useful shape is a short ownership path:

```text
MemoryGraphSessionStore
  -> MemoryGraphLeakedCheckoutSession
      -> MemoryGraphCartSnapshot
      -> MemoryGraphReceiptDraft
```

The lesson is the owner: `MemoryGraphSessionStore` still references the checkout session, so the session remains alive.

## Source Check

After Memory Graph shows the owner path, open `MemoryGraphLabScenarioRunner.swift`.

Broken mode stores the session:

```swift
currentSession = session
```

Fixed mode creates the same kind of session but does not keep it in the store:

```swift
currentSession = nil
```

## If Capture Fails

If Memory Graph fails with a `LeakAgent` / `libmalloc` initialization error, keep the app running, interact with the lab once more, then try **View Memory** again. If it repeats, stop and run the app again from Xcode.

Treat that as a Memory Graph capture problem, not evidence about the lab.

## Checklist

- [ ] You tapped Run scenario once in Broken mode before opening Memory Graph.
- [ ] You found `MemoryGraphLeakedCheckoutSession` with search or the left navigator.
- [ ] You identified `MemoryGraphSessionStore` as the owner keeping the session alive.
- [ ] You can explain why this lab is not a retain cycle.
