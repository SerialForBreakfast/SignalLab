# Crash Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Debugger UI**, **Call stack (concept)**) if **debug navigator**, **stack frame**, **console**, or **highlighted line** are unfamiliar.

This is your first crash. The goal is not to memorize a workflow — it is to get comfortable with what Xcode looks like when an app terminates unexpectedly, so that state no longer feels overwhelming.

## The scenario

A JSON import crashes because one row sent `count` as the text `"three"` instead of the integer `3`. The broken path uses `try!` to decode the JSON with a typed `Decodable` struct that expects `count: Int`. When the decoder finds text, it throws — and `try!` converts that throw into a crash.

Crash Lab is intentionally broken-only. The goal is to learn what Xcode shows you immediately after a crash, not to compare implementations yet.

## The three things Xcode shows you

Every time an app crashes under the Xcode debugger, the same three signals appear. Learn to read them in order.

### ① The highlighted line

The source editor highlights the line where execution stopped. In this lab that line is:

```swift
let rows = try! JSONDecoder().decode([CrashImportRow].self, from: data)
```

This is the assumption — the code said "decode this JSON and trust that every field is the right type." One row violated that contract.

### ② The console message

The console (bottom of the Xcode window) shows the full crash reason. Look for:

> Expected to decode Int but found a string instead.

That sentence, written by the Swift runtime, describes the entire bug. The payload sent `"three"` (text) where the code expected `3` (a number). You do not need to read any more code to understand what went wrong.

The console also shows the coding path — something like `Index 1, count` — which tells you it was the second row (`Index 1`) and the `count` field.

### ③ The call stack

The call stack on the left lists every function that was active when the crash happened, from the crash site at the top back to app startup at the bottom. Most frames belong to the Swift standard library or Apple frameworks.

Your job is to find the **CrashImportParser** frame and then move up one useful caller frame. In some Xcode layouts the frame label is visually truncated, so do not rely on seeing the full `SignalLab` module name. Look for the frame associated with `CrashImportParser.importLinesAssumingCompleteSchema(...)`, click it, then move up one frame to `CrashLabScenarioRunner.runBrokenImport()`.

Why move up one frame? Because that caller exposes the payload you need in **Variables**:

- `brokenCountText`
- `brokenJSONText`

That makes the action useful instead of ceremonial. You can point to `brokenCountText = "three"` immediately, then confirm the same malformed row appears inside `brokenJSONText`.

## Step-by-step workflow

1. **Reproduce the crash**
   - Run SignalLab from Xcode (⌘R).
   - Open Crash Lab, tap Run scenario.

2. **Read the highlighted line**
   - Note that Xcode stopped at the `try!` decode call inside `CrashImportParser`.
   - This is the assumption: "all rows match the schema."

3. **Read the console message**
   - Find "Expected to decode Int but found a string instead."
   - Note the coding path — it names the row index and the field.

4. **Navigate the call stack**
   - Click the `CrashImportParser` frame, even if Xcode truncates the label.
   - Move up one caller frame to `runBrokenImport()`.
   - In **Variables**, inspect `brokenCountText` first. You should see `"three"`.
   - Then inspect `brokenJSONText` and confirm the malformed second row uses that same value.

## Why `try!` is the broken pattern here

`try!` tells Swift: "I am certain this cannot fail — crash the app if I'm wrong." It is the right tool in exactly one situation: when you have a guarantee (a static resource, a compile-time constant) that makes failure truly impossible. JSON from a server, a file, or a bundled import is never that guarantee.

## What to carry forward

After this lab you should be able to answer these questions about any crash you encounter:

- Where did Xcode highlight execution?
- What does the console message say?
- Which frame in the call stack is useful to click first, and what caller frame reveals the payload?

**Next lab:** Exception Breakpoint Lab — run the same failure twice to compare where Xcode stops with and without an exception breakpoint.

## Validation checklist

- [ ] You can name the three things Xcode shows when an app crashes.
- [ ] You found the console message and can quote the line that described the type mismatch.
- [ ] You clicked the `CrashImportParser` frame, moved up one caller frame, and found `brokenCountText` plus `brokenJSONText`.
- [ ] You can point to the broken value `"three"` in `brokenCountText` or `brokenJSONText`.
- [ ] You can explain what `try!` does and why it turned this type mismatch into a crash.
