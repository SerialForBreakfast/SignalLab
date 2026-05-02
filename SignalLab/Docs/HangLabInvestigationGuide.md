# Hang Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Debugger UI**) if **Pause**, **main thread**, or **stack frames** are unfamiliar.

Hang Lab calls `HangLabWorkload.simulateReportProcessing` **synchronously on the main actor** — the same thread responsible for touch delivery and rendering. While that work runs, the UI is unresponsive.

## Your first two signals (before any Xcode tool)

Both appear without opening a single tool:

1. **The scroll probes don't move.** Tap Run, try to drag the chip row — nothing. The main thread owns event delivery; when it's blocked, touches go nowhere.
2. **The progress spinner never appears.** The runner sets `isProcessingReport = true` before the blocking call, but the main thread never gets a chance to paint that frame. When the work finishes the spinner is already back to false.

## Recommended first tool

**Debugger pause** while the UI is frozen. You want the **main thread** stack, not a background queue.

## Step-by-step

1. Run from Xcode with Hang Lab open.
2. Tap **Run scenario**, then **scroll** the probes until the UI ignores you. Observe that the spinner above the chips never appeared.
3. Tap **Run scenario** again and immediately click **Pause** in the debug bar — you have a short window while the main thread is blocked.
4. In the **Debug navigator**, select the **main thread** (often "Thread 1" / `com.apple.main-thread`).
5. Scan the stack for **`HangLabWorkload.simulateReportProcessing`** or **`simulateReportProcessing`** — that is the work blocking the run loop.

## Root cause (teaching)

The main thread is responsible for **event delivery and rendering**. Long synchronous CPU work on that thread **starves** the run loop, so touches and animations appear "hung."

Moving the same computation to **`Task.detached`** (or another off-main API) lets the main thread keep servicing gestures while workers crunch numbers.

This is different from **CPU Hotspot Lab**:

- **Hang Lab:** the UI feels **stuck** and gestures stop responding
- **CPU Hotspot Lab:** the UI still works, but each interaction feels **heavier than it should**

This is also different from **Retain Cycle Lab**: a dismissed screen can leak (live-instance counts rise) while scrolling still works — here the symptom is **gestures freezing** during heavy main-thread work.

## Checklist

- [ ] You can point to the work blocking the main thread and explain why the UI freezes.
- [ ] You can identify `HangLabWorkload.simulateReportProcessing` in the paused main-thread stack.
- [ ] You felt the scroll probes stop responding and observed the spinner never appear.

## Code map

- `HangLabWorkload.simulateReportProcessing(seed:iterationCount:)` — pure CPU loop
- `HangLabScenarioRunner.trigger()` — synchronous main-actor invocation
- `iOSHangLabDetailView` — scroll probes + status text
