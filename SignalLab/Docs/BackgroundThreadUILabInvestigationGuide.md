# Background Thread UI Lab — Investigation Guide

**Phase 2.** Use this lab when **callbacks, notifications, or async completions** might **mutate SwiftUI state off the main actor**.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`backgroundThreadUILab`)

---

## Teaching question

**Why does the thread that delivers my event matter for SwiftUI and UIKit updates?**

---

## Symptom

- Purple runtime warnings about **publishing** or **updating** from a background thread.
- Intermittent UI corruption or crashes after network/timer callbacks.

---

## Recommended first tool

**Xcode console + Issue navigator** while reproducing with **Broken** mode.

---

## Boundaries

| Topic | Use instead |
|-------|-------------|
| Main thread busy computing | **Hang Lab** |
| Main thread waiting on self | **Deadlock Lab** |
| Data races on shared memory | **Thread Sanitizer Lab** |

---

## Step-by-step

1. Run **Fixed** and confirm clean console for the ping path.
2. Run **Broken** and capture the exact warning string.
3. Map the path: `Task.detached` → `NotificationCenter.post` → `onReceive` → `@State` mutation.
4. Fix: `await MainActor.run { ... }`, `@MainActor` types, or `DispatchQueue.main.async`.
5. Re-run until the warning is gone for that path.

---

## Checklist

- [ ] You can draw the thread boundary from producer to UI observer.  
- [ ] You can restate the fix as “deliver on main before touching UI state.”  
