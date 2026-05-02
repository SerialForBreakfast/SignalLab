# Heap Growth Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Memory Graph**, **Instruments**) if **Allocations** or footprint views are unfamiliar.

**Phase 2.** Use this lab when **footprint or allocation volume** climbs because you **keep buffers alive**, not because objects form a **retain cycle**.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`heapGrowthLab`)

---

## Teaching question

**How do I tell "we never release work buffers" apart from "two objects keep each other alive"?**

---

## Symptom

- Memory gauge or Instruments shows **steady growth** as you repeat an action.
- Memory Graph may show **many live objects** but **not** a tight purple cycle between two of your types.

---

## Recommended first tool

**Instruments > Allocations** (pair with **Memory Graph** for shape, not just size).

---

## Boundaries

| Topic | Use instead |
|-------|-------------|
| Cyclic ownership, dismiss still alive | **Retain Cycle Lab** |
| Who allocated this bytes | **Malloc Stack Logging Lab** |
| Main thread busy / frozen | **Hang Lab** or **Deadlock Lab** |

---

## Step-by-step

1. Tap **Run scenario** several times — chunk count and approximate bytes rise each time.
2. Open **Allocations** (or Memory Graph) and capture before/after snapshots.
3. Write one sentence: why this growth is **not** explained as a retain cycle.
4. Pick a production policy: max cache entries, LRU eviction, or time-based flush.

---

## Checklist

- [ ] You measured unbounded growth using tooling, not guesses.
- [ ] You can explain the difference vs Retain Cycle Lab in one sentence.
