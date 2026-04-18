# Main Thread I/O Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Instruments**, **Debugger UI**) if **Time Profiler** or **main thread** stacks are unfamiliar.

**Phase 2.** Use this lab when the UI **hitches** because the main thread **waits on disk** (or similar blocking I/O), not because it is burning CPU.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`mainThreadIOLab`)

---

## Teaching question

**How do I separate “main thread is reading files” from “main thread is crunching data”?**

---

## Symptom

- Short freezes on navigation or button taps.
- Time Profiler shows **I/O** or **file read** frames on the main stack, not just hot Swift loops.

---

## Recommended first tool

**Instruments > Time Profiler** (plus interactive **scroll probes** in the lab UI during **Fixed** vs **Broken**).

---

## Boundaries

| Topic | Use instead |
|-------|-------------|
| Heavy JSON transform on main | **Hang Lab** (CPU narrative) |
| Network waits | Same pattern—move off main; this lab uses a **local file** for determinism |
| Allocation provenance | **Malloc Stack Logging Lab** |

---

## Step-by-step

1. Run **Fixed**, scroll chips during load—note responsiveness.
2. Run **Broken**, repeat—note hitch duration.
3. Capture a short Time Profiler trace for each mode.
4. Identify synchronous `Data(contentsOf:)` (or equivalent) on the main stack in Broken.
5. Refactor to `Task.detached`, async file APIs, or background queues, then re-profile.

---

## Checklist

- [ ] You can point to I/O vs CPU in a main-thread stack sample.  
- [ ] You have a concrete offload strategy for your own file path.  
