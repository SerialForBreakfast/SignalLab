# Retain Cycle Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Memory Graph**) if **retaining paths** or the Memory Graph UI are unfamiliar.

This lab uses a **detail sheet** backed by `RetainCycleLabDetailHeart`, a reference type that owns a **repeating `Timer`**.

## What you should see

- **Live detail sessions** (on the lab screen) is a running count of hearts that have been created and **not yet deallocated**.
- **Broken mode:** Each time you **Run scenario** → open the sheet → **Close**, the counter **does not go down**. Opening repeatedly **increases** the counter because each heart’s timer retains it strongly.
- **Fixed mode:** After you dismiss the sheet, the timer is **invalidated** in `onDisappear`, the heart can **deallocate**, and the counter **drops**.

## Recommended first tool

**Xcode Memory Graph** after reproducing several open/close cycles in Broken mode — you want multiple live instances and a clear retaining path.

## Reproduction (Broken)

1. Select **Broken** mode (or tap **Reset** to return to defaults).
2. Tap **Run scenario** → **Close** on the sheet. Repeat **3+** times.
3. Observe **Live detail sessions** ≥ number of opens (often equal if nothing else holds old hearts).

## Investigation steps

1. **Memory Graph → Filter** for `RetainCycleLabDetailHeart` (or search your module name).
2. Select one leaked instance and open the **strong references** / retaining path.
3. Expand the retaining path from one live `RetainCycleLabDetailHeart` node. You should see a chain like `RunLoop` → `NSTimer` / `Timer` → closure / block → `RetainCycleLabDetailHeart`.
4. In source, open `RetainCycleLabDetailHeart.startTimer()` and compare **Broken** (`[self]` capture) vs **Fixed** (`[weak self]` plus explicit teardown).

## Fixed mode validation

1. Switch to **Fixed**.
2. Tap **Run scenario**, then **Close**.
3. **Live detail sessions** should **decrease** shortly after dismiss (async main-queue updates may take a frame).
4. Capture Memory Graph again — you should see **fewer** live hearts than after the Broken drill.

## Teaching summary

- **Broken:** `Timer.scheduledTimer`’s closure captures **`self` strongly**. The run loop keeps the timer; the timer keeps the closure; the closure keeps the heart → **sheet UI can go away, but the model object stays alive**.
- **Fixed:** **`[weak self]`** avoids the timer owning the heart forever, and **`stopTimerForTeardown()`** runs on `onDisappear` so the timer is torn down deterministically when the UI goes away.

This is a lifetime lab, not a responsiveness lab:

- if the screen dismisses but objects stay alive, use **Memory Graph**
- if the UI visibly freezes while work runs, use **Hang Lab**

## Checklist

- [ ] You’re done when you can identify the retaining path that keeps the dismissed detail alive in Broken mode.  
- [ ] You can draw the retain chain for Broken mode in one sentence.  
- [ ] You can point to the line that must change for a minimal fix.  
- [ ] Fixed mode + Memory Graph shows improved lifetime vs Broken.

## Code map

- `RetainCycleLabDetailHeart` — timer + capture semantics  
- `RetainCycleLabSessionTracker` — visible live count  
- `iOSRetainCycleLabDetailView` / `iOSRetainCycleLabSheetView` — presentation + Fixed `onDisappear`  
