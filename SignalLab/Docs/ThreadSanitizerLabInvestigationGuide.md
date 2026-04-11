# Thread Sanitizer Lab — Investigation Guide

**Post-MVP / scheme diagnostic.** **Thread Sanitizer (TSan)** catches **data races**: two threads accessing the same memory where at least one is a write, without proper synchronization.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`threadSanitizerLab`)

---

## Teaching question

**How do I prove unsafe concurrent access instead of guessing from intermittent wrong UI?**

---

## Symptom

- Wrong value **sometimes** under rapid taps, background work, or parallel tasks.
- Not reliably explained by a **single wrong branch** (Breakpoint Lab) or a **synchronous** main-thread block (Hang Lab).

---

## Recommended first tool

**Xcode Run → Diagnostics → Thread Sanitizer** (expect slower runs).

---

## Boundaries

| Symptom | First tool |
|---------|------------|
| Wrong branch, deterministic | **Breakpoint Lab** |
| UI frozen, main thread busy | **Hang Lab** |
| Slow but responsive | **CPU Hotspot Lab** + Time Profiler |
| Concurrent unsynchronized memory | **Thread Sanitizer** |

---

## Step-by-step

1. Build a **deterministic** stress path (not “maybe wrong once a day”).
2. Enable **Thread Sanitizer**, run from Xcode, execute the stress until TSan stops.
3. From the report: identify **both** threads, the **address**, and **your** frames.
4. Add **serialization** (main actor, lock, serial queue, actor) or remove shared mutable state.
5. Re-run with TSan until the race on that path is gone.

---

## Checklist

- [ ] TSan enabled for the repro run.  
- [ ] You can name the shared state and the two conflicting accesses.  
- [ ] You can explain why Breakpoint Lab would not be the right primary tool.  
