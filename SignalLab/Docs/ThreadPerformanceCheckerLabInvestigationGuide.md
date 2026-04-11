# Thread Performance Checker Lab — Investigation Guide

**Post-MVP / scheme diagnostics.** This lab extends **Hang Lab**: you already proved a main-thread freeze by pausing the debugger; here you enable **Thread Performance Checker** so Xcode can surface the same *category* of problem as a **runtime warning** while the app runs.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`threadPerformanceCheckerLab`)  
Update this file in the same commit as catalog or `Docs/Labs.md` changes.

---

## Teaching question

**When the UI feels stuck, what does Thread Performance Checker add beyond pausing during the freeze?**

---

## Symptom

- Same family as **Hang Lab** Broken mode: work on the main thread makes gestures feel stuck or very sluggish during a run.
- Unlike **CPU Hotspot Lab**, the issue is not “slow but smooth typing”—it is **main-thread blocking** during a workload.

---

## Recommended first tool

**Xcode Run scheme → Diagnostics → Thread Performance Checker** (exact checkbox label may vary slightly by Xcode version).

---

## Step-by-step

1. **Re-ground in Hang Lab**  
   Run **Hang Lab** in **Broken** mode, tap **Run scenario**, try to scroll the probes during the stall. You should recall the “main thread is busy” story from the paused stack.

2. **Enable the checker**  
   **Product → Scheme → Edit Scheme… → Run → Diagnostics** → enable **Thread Performance Checker**. Clean build is not required; run again from Xcode.

3. **Reproduce**  
   Repeat the Hang Lab Broken flow. Watch the **Issue navigator** and **console** for a runtime diagnostic that references main-queue / UI work (wording depends on OS and Xcode).

4. **Compare evidence**  
   Write one sentence: what the checker reported vs what you saw when you **paused** in Hang Lab. They should tell the same story with different mechanisms.

5. **Optional validation**  
   Switch Hang Lab to **Fixed** mode and repeat. The warning should not recur for the same gesture path if the heavy work left the main actor during the hot phase.

---

## Boundaries

| Lab | Role |
|-----|------|
| **Hang Lab** | Manual proof: pause, read main-thread stack |
| **Thread Performance Checker Lab** | Scheme diagnostic: runtime warning while running |
| **CPU Hotspot Lab** | Sluggish but responsive UI; **Time Profiler** for cost |
| **Retain Cycle Lab** | Object lifetime; Memory Graph |

---

## Checklist

- [ ] You enabled Thread Performance Checker in the scheme and reran from Xcode.  
- [ ] You reproduced **Hang Lab** Broken mode and saw a relevant diagnostic.  
- [ ] You can explain what the checker added compared with only using the debugger pause.  
