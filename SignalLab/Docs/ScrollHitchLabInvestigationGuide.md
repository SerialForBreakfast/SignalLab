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
- Horizontal gesture probes stutter during vertical auto-scroll.

---

## Recommended first tool

**Instruments** template that surfaces **frame timing / Core Animation** (exact name varies by Xcode version), recorded during the lab's auto-scroll.

---

## Boundaries

| Topic | Use instead |
|-------|-------------|
| Keystroke-bound hot algorithms | **CPU Hotspot Lab** |
| Complete UI freeze | **Hang Lab** |
| Main-thread disk wait | **Main Thread I/O Lab** |

---

## Step-by-step

1. Tap **Run scenario** — the list auto-scrolls with heavy per-row chrome.
2. Try dragging the horizontal probes during the auto-scroll.
3. Capture a short trace covering one auto-scroll; examine frame or compositing cost.
4. Map the per-row `.compositingGroup()` + large shadow to what the trace shows.
5. In your UI, remove redundant offscreen passes before micro-optimizing algorithms.

---

## Checklist

- [ ] You can name the modifier stack that makes rows expensive to composite.
- [ ] You can explain why this is not the same lesson as CPU Hotspot Lab.
