# Deadlock Lab — Investigation Guide

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

1. Launch from **Xcode**, open this lab, run **Fixed** once—confirm completion.
2. Switch to **Broken**, tap **Run scenario**, then **pause**—note main waiting on `sync` to the same queue.
3. Stop the process; never leave Broken running unattended.
4. In your codebase, search for `sync` (or equivalent) onto **main** from contexts that may already be main.
5. Replace with `async`, structured tasks, or inline work—never main-on-main `sync`.

---

## Checklist

- [ ] You reproduced the freeze only under the debugger and could pause to inspect.  
- [ ] You can state why this differs from Hang Lab’s CPU-bound main thread.  
