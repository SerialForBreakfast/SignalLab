# Break on Failure Lab — Investigation Guide

This guide defines the planned **Break on Failure Lab** curriculum: compare the same failure with and without an **Exception Breakpoint** so the learner can answer a simple question:

**What did changing debugger stop policy give me that the default crash stop did not?**

The point is not to memorize a breakpoint type. The point is to compare two debugging workflows on the same failure family.

## Symptom

- **Default run:** Xcode already stops when the app hits a runtime failure, but the stop may not always feel early enough or consistent enough for the learner.
- **Breakpoint run:** After adding an Exception Breakpoint, Xcode may stop in a way that gives earlier or clearer context for the same failure.

## Recommended first tool

**Xcode Exception Breakpoint**, but only after the learner has already used **Crash Lab** to understand the default stop.

## Step-by-step workflow

1. **Establish the baseline**  
   - Run the same failure once **without** adding a breakpoint.
   - Note where Xcode stops, what frame is selected, and how much context you already have.

2. **Add the breakpoint**  
   - Open the Breakpoint navigator (`⌘8`).
   - Click **+** → **Exception Breakpoint**.
   - Leave the default configuration for the first comparison run.

3. **Run the same failure again**  
   - Reproduce the same failure path.
   - Compare where the debugger stops and what information is immediately available.

4. **Answer the comparison question**  
   - Did the breakpoint stop you earlier?
   - Did it stop in a clearer frame?
   - Did it reduce guesswork compared with the default stop?

5. **State the value clearly**  
   - Finish with one sentence:
     - “The default stop was already enough here.”
     - or
     - “The exception breakpoint helped because it stopped earlier / more clearly / more consistently.”

## Swift trap vs Objective-C exception note

This lab should explain the real debugging situation, not just the control name.

In a Swift-heavy app, many failures feel like **runtime traps** rather than classic Objective-C `NSException` crashes. The learner does not need the full runtime taxonomy up front, but they do need the honest takeaway:

- sometimes Xcode's default stop is already enough
- sometimes a debugger breakpoint policy gives you better context
- the lab is about **when that extra stop policy helps**

## Teaching summary

Crash Lab teaches:

- “The app stopped. Read the stack, locals, and caller.”

Break on Failure Lab teaches:

- “Now compare that default stop with an explicit failure breakpoint and decide whether it gave you anything better.”

Breakpoint Lab teaches something different:

- “The app did not stop on its own, so choose one line breakpoint and inspect the wrong logic.”

## Checklist

- [ ] You’re done when you can explain what the exception breakpoint added over the default stop for this failure.  
- [ ] You can describe one case where the default stop is already sufficient.  
- [ ] You can describe one reason a breakpoint-based stop policy may still be useful.
