# Main Thread I/O Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Instruments**, **Debugger UI**) if **Time Profiler** or **main thread** stacks are unfamiliar.

**Phase 2.** Use this lab when the UI **hitches** because the main thread **waits on disk** (or similar blocking I/O), not because it is burning CPU.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`mainThreadIOLab`)

---

## Teaching question

**How do I separate "main thread is reading files" from "main thread is crunching data"?**

---

## Symptom

- Short freezes on navigation or button taps.
- Time Profiler shows **I/O** or **file read** frames on the main stack, not just hot Swift loops.

---

## Recommended first tool

**Instruments > Time Profiler** (plus interactive **scroll probes** in the lab UI while the read runs).

---

## Boundaries

| Topic | Use instead |
|-------|-------------|
| Heavy JSON transform on main | **Hang Lab** (CPU narrative) |
| Network waits | Same pattern—move off main; this lab uses a **local file** for determinism |
| Allocation provenance | **Malloc Stack Logging Lab** |

---

## Step-by-step

1. Tap **Run scenario**, try to drag the scroll probes during the read — note the stall.
2. Capture a short Time Profiler trace.
3. Identify synchronous `Data(contentsOf:)` on the main stack.
4. Refactor to `Task.detached`, async file APIs, or background queues, then re-profile.

---

## Checklist

- [ ] You can point to I/O vs CPU in a main-thread stack sample.
- [ ] You have a concrete offload strategy for your own file path.
