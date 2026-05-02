# Deadlock Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Debugger UI**) if **Pause**, **threads**, or **stack frames** are unfamiliar.

**Phase 2.** Use this lab when the UI **stops forever** and the main thread is **blocked waiting**, not busy computing.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`deadlockLab`)

---

## Teaching question

**What happens when code on the main thread synchronously waits for work that can only run on the main thread?**

---

## Symptom

- App **freezes** with **no** progress; often **zero** CPU if nothing else is running.
- Pausing in the debugger shows the main thread **stuck** in dispatch / sync machinery.

---

## Recommended first tool

**Xcode debugger: pause** and inspect the **main thread stack** (after reproducing from a debug session).

---

## Boundaries

| Topic | Use instead |
|-------|-------------|
| Main thread doing heavy work | **Hang Lab** |
| Two threads + shared mutable state | **Thread Sanitizer Lab** |
| Use-after-free messaging | **Zombie Objects Lab** |

---

## Step-by-step

1. Launch from **Xcode** with this lab open. **Warning: tap Run scenario only with the debugger attached — the process will hang indefinitely.**
2. Tap **Run scenario**, then immediately click **Pause** — observe the main thread waiting on `sync` to the same queue it is already occupying.
3. Stop the process; never leave the lab running unattended after tapping Run.
4. In your codebase, search for `sync` (or equivalent) onto **main** from contexts that may already be main.
5. Replace with `async`, structured tasks, or inline work — never main-on-main `sync`.

---

## Checklist

- [ ] You reproduced the freeze only under the debugger and could pause to inspect.
- [ ] You can state why this differs from Hang Lab's CPU-bound main thread.
