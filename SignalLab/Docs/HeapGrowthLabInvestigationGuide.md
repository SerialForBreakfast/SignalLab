# Heap Growth Lab — Investigation Guide

**Phase 2.** Use this lab when **footprint or allocation volume** climbs because you **keep buffers alive**, not because objects form a **retain cycle**.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`heapGrowthLab`)

---

## Teaching question

**How do I tell “we never release work buffers” apart from “two objects keep each other alive”?**

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

1. Run **Fixed** in this lab five times and note chunk count caps at six.
2. Reset, run **Broken** five times—chunk count and approximate bytes should rise each time.
3. Open **Allocations** (or Memory Graph) and capture before/after snapshots for Broken vs Fixed.
4. Write one sentence: why this growth is **not** explained as a retain cycle.
5. Pick a production policy: max cache entries, LRU eviction, or time-based flush.

---

## Checklist

- [ ] You contrasted Broken (unbounded) with Fixed (capped) using tooling, not guesses.  
- [ ] You can explain the difference vs Retain Cycle Lab in one sentence.  
