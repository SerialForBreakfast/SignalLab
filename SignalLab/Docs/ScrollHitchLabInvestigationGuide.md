# Scroll Hitch Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Instruments**) if **Core Animation**, frame pacing templates, or **Time Profiler** are unfamiliar.

**Phase 2.** Use this lab when **scrolling feels uneven** but you are not necessarily CPU-saturated the way **CPU Hotspot Lab** demonstrates.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`scrollHitchLab`)

---

## Teaching question

**What makes each row expensive to composite while it moves on screen?**

---

## Symptom

- Dropped or uneven frames while scrolling a long list.
- Horizontal gestures (probes) stutter during vertical auto-scroll in Broken mode.

---

## Recommended first tool

**Instruments** template that surfaces **frame timing / Core Animation** (exact name varies by Xcode version), recorded during the lab’s auto-scroll.

---

## Boundaries

| Topic | Use instead |
|-------|-------------|
| Keystroke-bound hot algorithms | **CPU Hotspot Lab** |
| Complete UI freeze | **Hang Lab** |
| Main-thread disk wait | **Main Thread I/O Lab** |

---

## Step-by-step

1. Run **Fixed** once; drag probes while the list scrolls.
2. Run **Broken** with the same gesture path.
3. Capture a short trace covering one auto-scroll; compare frame or compositing cost.
4. Map Broken’s per-row `.compositingGroup()` + large shadow to the trace.
5. In your UI, remove redundant offscreen passes before micro-optimizing algorithms.

---

## Checklist

- [ ] You can name one modifier stack that made rows more expensive in Broken mode.  
- [ ] You can explain why this is not the same lesson as CPU Hotspot Lab.  
