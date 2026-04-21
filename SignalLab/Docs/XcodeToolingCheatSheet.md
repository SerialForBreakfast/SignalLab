# Xcode tooling cheat sheet (SignalLab)

Use this page when lab copy mentions **debug navigator**, **stack frames**, **Instruments**, or **scheme diagnostics** and the words are unfamiliar. Lab steps intentionally reuse Apple’s vocabulary so you can transfer the same terms to Apple’s documentation and to Xcode’s UI.

**Version drift:** Button shapes and panel layouts change between Xcode releases. The *concepts* below stay stable; treat exact menu paths as “may vary slightly” unless your Xcode matches the maintainer’s tested version. On your Mac, run `xcodebuild -version` in Terminal to see which Xcode the command-line tools use. The SignalLab app running in Simulator **cannot** detect the host Xcode version.

**Screenshots:** This document uses text and a conceptual diagram instead of Xcode screenshots so it does not go stale when the chrome changes.

## Apple documentation (canonical)

- [Stepping through code and inspecting variables to isolate bugs](https://developer.apple.com/documentation/xcode/stepping-through-code-and-inspecting-variables-to-isolate-bugs) — breakpoints, variables, stepping
- [About the debug area](https://help.apple.com/xcode/mac/current/en.lproj/devda5478599.html) — debug bar, Variables list, console (labels may match your Xcode locale)

## Debugger UI (Xcode)

When you **Run** (⌘R) an app, Xcode attaches the **debugger**. If execution stops (breakpoint, crash, or **Pause**), you are in a **paused** session.

| Term | What it is |
|------|------------|
| **Source editor** | Middle of the window: shows your code. The **current line** (where the thread is stopped) is highlighted. |
| **Debug navigator** | **Left sidebar**, “Debug” tab (⌘6 while debugging): lists **threads**. Expanding a thread shows a **stack** — a list of **frames** (one per active function call). The **top** frame is where execution stopped; **below** are **callers**. |
| **Frame** | One row in the stack: a single function’s activation. Selecting a frame updates the editor and **Variables** to that call level. |
| **Call stack** | Ordered list of frames from **innermost** (where you stopped) to **outermost** (`main`, run loop, etc.). **Your code** is usually mixed with system frameworks — skip noise by finding the first frame whose name matches your module. |
| **Caller** | The function that **called** the current frame — the frame **immediately below** the selected one in the debug navigator (toward `main`). “Move one caller up” means **select the parent frame** in that list. |
| **Debug area** | **Bottom** of the window when shown (⌘⇧Y): contains the **Variables** list (locals for the **selected frame**), **console** output, and debugger controls (**Continue**, **Step Over**, etc.). |
| **Variables** | List of **locals**, **arguments**, and sometimes **registers** for the **selected** stack frame — not global state for the whole app. |

### Call stack (concept)

Execution stopped inside `parseRow` because `importInventory` called `parseRow`, and the run loop called `importInventory`:

```text
  ↑  top / newest  →  [parseRow]     ← debugger often opens here (fault line)
  |                   [importInventory]   ← caller: who asked for this row
  |                   [Button action …]
  ↓  bottom / oldest →  [main …]
```

Selecting **`importInventory`** lets you see **arguments** and **who passed the malformed row** into `parseRow`.

## Breakpoints

| Term | What it is |
|------|------------|
| **Breakpoint navigator** | Left sidebar, breakpoints tab: lists **line breakpoints**, **Exception Breakpoint**, **Symbolic Breakpoint**, etc. |
| **Line breakpoint** | Blue marker in the gutter: stop when that line runs. |
| **Exception Breakpoint** | Stops when an Objective-C exception or similar runtime exception is **raised** — policy differs from “crash only”; compare with Crash Lab vs Exception Breakpoint Lab. |

## Run scheme and diagnostics

**Product → Scheme → Edit Scheme → Run → Diagnostics** enables runtime tools (Thread Sanitizer, Zombie Objects, Malloc Stack Logging, Thread Performance Checker, etc.). Exact checkbox labels can vary by Xcode version.

## Memory Graph (Xcode)

Run the app from Xcode so the debugger is attached, then open Memory Graph with the **Debug Memory Graph** button in the debug bar. The button looks like three connected nodes. You can also use **Debug > Debug Workflow > View Memory** from the macOS menu bar.

Memory Graph pauses the app and shows live objects plus the references between them. Search for a type name in the Memory Graph navigator, select a node, and inspect the strong reference path that keeps it alive. Exact labels for closure/block nodes can vary by Xcode and OS version, so focus on the ownership shape rather than one exact string.

If capture fails with `LeakAgent` and a message that the target's `libmalloc` has not been initialized, keep the app running, interact with the scenario once more, and try **View Memory** again. If the error repeats, stop and rerun the app from Xcode. Treat this as a Memory Graph capture failure, not as a result from the lab.

## Instruments (separate app)

**Product → Profile** (⌘I) launches **Instruments** — a different window from the debugger. You **record** while using the app, then inspect **traces**.

| Term | What it is |
|------|------------|
| **Template** | Starting point (e.g. **Time Profiler**, **Allocations**, **Points of Interest**). Pick the template that matches the lab. |
| **Trace** | One recording session: timelines and statistics for that run. |
| **Frame** (Instruments) | Often means **call-tree frame** (function in a profile), not necessarily the same as a debugger stack frame — context matters. |
| **Self time** | Time spent **inside** a function, not in callees — used to find **hotspots**. |

## Console and Issue navigator

| Term | What it is |
|------|------------|
| **Debug console** | Bottom **debug area**: **stdout**, `print`, runtime warnings (e.g. main-thread checker). |
| **Issue navigator** | Left sidebar (⌘5): build issues and some **runtime** diagnostics surfaced by Xcode. |

## Which section should I read?

| If the lab emphasizes… | Start here |
|------------------------|------------|
| Crash / Hang / Deadlock / Zombie / TSan under debugger | **Debugger UI**, **Breakpoints** |
| Scheme checkboxes (Sanitizer, Zombies, Malloc stacks) | **Run scheme and diagnostics** |
| Memory Graph, leaks, growth | **Memory Graph**, **Instruments** (Allocations) |
| Time Profiler, CPU, scroll hitches, signposts | **Instruments** |

---

SignalLab’s long-form lab guides live beside this file: `CrashLabInvestigationGuide.md`, `HangLabInvestigationGuide.md`, etc.
