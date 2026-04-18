# Startup Signpost Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Instruments**) if **Points of Interest** or **os_signpost** lanes are unfamiliar.

**Phase 2.** Use this lab when you need **named intervals** on a timeline—not just “main thread was busy”—during **launch-style** or **blocking setup** work.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`startupSignpostLab`)

Implementation reference: `SignalLab/SignalLab/Labs/StartupSignpost/StartupSignpostLabScenarioRunner.swift` (`os_signpost` + `OSLog` category `PointsOfInterest`).

---

## Teaching question

**How do I turn one opaque main-thread blob into phases I can compare across builds?**

---

## Symptom

- Instruments shows CPU on the main thread without clear boundaries between config, assets, and “ready” work.
- You cannot tell which phase regressed after a change.

---

## Recommended first tool

**Instruments > Points of Interest** (or a template that overlays POI signposts), recording while tapping **Run scenario** in **Fixed** mode.

---

## Boundaries

| Topic | Use instead |
|-------|-------------|
| Who allocated this object | **Malloc Stack Logging Lab** |
| Data races | **Thread Sanitizer Lab** |
| Moving work off main | **Hang Lab** / async I/O labs |

---

## Step-by-step

1. Profile **Fixed**; confirm three intervals: `SignalLabStartupConfig`, `SignalLabStartupAssets`, `SignalLabStartupReady`.
2. Profile **Broken**; verify similar CPU time but **no** structured POI lanes.
3. Match footer **checksums** between modes for the same run count.
4. Add one signpost interval around your app’s heaviest synchronous launch closure.
5. Re-profile after optimizations and compare interval durations, not only total time.

---

## Checklist

- [ ] You can name all three signposted phases in this lab.  
- [ ] You can explain why checksums match between Broken and Fixed.  
