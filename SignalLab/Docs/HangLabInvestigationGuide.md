# Hang Lab — Investigation Guide

Hang Lab runs the **same CPU-heavy function** (`HangLabWorkload.simulateReportProcessing`) in two ways:

| Mode | Where the work runs | What you feel |
|------|---------------------|---------------|
| **Broken** | Main actor, **synchronously** inside `trigger()` | UI stops updating; horizontal scroll “probes” won’t move until work finishes |
| **Fixed** | `Task.detached` (off main), then UI updates on main | Progress UI can update; scroll stays interactive during the heavy phase |

## Reproduction

1. **Broken:** Reset → Run scenario → try to scroll the chip row **during** the run. Expect a **hard freeze**.
2. **Fixed:** Switch mode → Run → scroll **during** the run. Expect **continued responsiveness** (spinner / status may update).

## Recommended first tool

**Debugger pause** while the UI is frozen (Broken mode). You want the **main thread** stack, not a background queue.

## Step-by-step

1. Run from Xcode with Hang Lab open in **Broken** mode.
2. Tap **Run scenario**, then **scroll** the probes until the UI ignores you.
3. Click **Pause** in the debug bar.
4. In the **Debug navigator**, select the **main thread** (often “Thread 1” / `com.apple.main-thread`).
5. Scan the stack for **`HangLabWorkload.simulateReportProcessing`** or **`simulateReportProcessing`** — that is the work blocking the run loop.
6. Switch to **Fixed**, run again, and optionally pause: the main thread should **not** be stuck in that tight loop during the heavy phase (work runs on a worker thread).

## Root cause (teaching)

The main thread is responsible for **event delivery and rendering**. Long synchronous CPU work on that thread **starves** the run loop, so touches and animations appear “hung.”

Moving the same computation to **`Task.detached`** (or another off-main API) lets the main thread keep servicing gestures while workers crunch numbers.

This is different from **CPU Hotspot Lab**:

- **Hang Lab:** the UI feels **stuck** and gestures stop responding
- **CPU Hotspot Lab:** the UI still works, but each interaction feels **heavier than it should**

This is also different from **Retain Cycle Lab**: a dismissed screen can leak (live-instance counts rise) while scrolling still works—here the symptom is **gestures freezing** during heavy main-thread work.

## Checklist

- [ ] You’re done when you can point to the work blocking the main thread in Broken mode and explain why the UI freezes.  
- [ ] You can point to the call site that runs work on the main actor in Broken mode.  
- [ ] You can explain why Fixed mode’s `await Task.detached { … }` changes thread behavior.  
- [ ] You felt the difference in scroll responsiveness between modes.

## Code map

- `HangLabWorkload.simulateReportProcessing(seed:iterationCount:)` — pure CPU loop  
- `HangLabScenarioRunner.trigger()` — Broken vs Fixed orchestration  
- `iOSHangLabDetailView` — scroll probes + status text  
