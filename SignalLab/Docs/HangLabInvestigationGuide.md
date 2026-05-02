# Hang Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Debugger UI**) if **Pause**, **main thread**, or **stack frames** are unfamiliar.

Hang Lab calls `Thread.sleep(forTimeInterval: 4.0)` **synchronously on the main actor** — the same thread responsible for touch delivery and rendering. While that line executes, the UI is unresponsive. `Thread.sleep` is the starkest possible demonstration: any blocking call on the main thread produces the same symptom.

## Your first two signals (before any Xcode tool)

Both appear without opening a single tool:

1. **The scroll probes don't move.** Tap Run, try to drag the chip row — nothing. The main thread owns event delivery; when it's blocked, touches go nowhere.
2. **The progress spinner never appears.** The runner sets `isProcessingReport = true` before the blocking call, but the main thread never gets a chance to paint that frame. When the work finishes the spinner is already back to false.

## Recommended first tool

**Debugger pause** while the UI is frozen. You want the **main thread** stack, not a background queue.

## Step-by-step

1. Run from Xcode with Hang Lab open.
2. Tap **Run scenario**, then **scroll** the probes until the UI ignores you. Observe that the spinner above the chips never appeared.
3. Tap **Run scenario** again. The moment the UI freezes, click **Pause (⏸)** in the Xcode debug bar — you have about 4 seconds.
4. **Xcode opens at frame 0 — this is often Swift runtime or system assembly. That is normal and expected.** Do not try to read the assembly.
5. In the **Debug navigator** call stack, scroll down and click **`HangLabScenarioRunner.trigger()`** — that frame navigates directly to Swift source.
6. You land on `Thread.sleep(forTimeInterval: 4.0)`. Read the block comment above it — it explains the mechanism and lists real-world APIs that produce the same hang (`Data(contentsOf:)`, large JSON decodes, blocking database scans).
7. Confirm the selected thread is **Thread 1** (`com.apple.main-thread`) — that is the run loop thread the hang starves.

## Root cause (teaching)

The main thread is responsible for **event delivery and rendering**. Any call that blocks the calling thread — sleeping, CPU work, file I/O, a network read — **starves the run loop** when made on the main thread.

`Thread.sleep(forTimeInterval: 4.0)` is the starkest example because the intent is unambiguous. In production the same symptom appears from:

| Blocking API | Real-world context |
|---|---|
| `Data(contentsOf: url)` | Synchronous network or file read |
| `JSONDecoder().decode(T.self, from:)` | Large-payload parse on main thread |
| `for row in db.execute(query)` | Blocking database scan |
| Heavy computation in a `for` loop | Image processing, crypto, compression |

Moving any of these to `Task.detached`, `async/await`, or a background queue lets the main thread keep servicing gestures and renders while the work runs elsewhere.

This is different from **CPU Hotspot Lab**:

- **Hang Lab:** the UI feels **stuck** and gestures stop responding
- **CPU Hotspot Lab:** the UI still works, but each interaction feels **heavier than it should**

This is also different from **Retain Cycle Lab**: a dismissed screen can leak (live-instance counts rise) while scrolling still works — here the symptom is **gestures freezing** during heavy main-thread work.

## Checklist

- [ ] You felt the scroll probes stop responding and observed the spinner never appear.
- [ ] You paused the debugger during the freeze, scrolled past frame 0 (assembly), and clicked `HangLabScenarioRunner.trigger()` to land on Swift source.
- [ ] You can point to `Thread.sleep(forTimeInterval: 4.0)` as the blocking line and explain why any call there starves the run loop.
- [ ] You can name two real-world APIs that would cause the same hang if called from the main thread.

## Code map

- `HangLabWorkload.simulateReportProcessing(seed:iterationCount:)` — pure CPU loop
- `HangLabScenarioRunner.trigger()` — synchronous main-actor invocation
- `iOSHangLabDetailView` — scroll probes + status text
