# Exception Breakpoint Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Debugger UI**, **Breakpoints**) if the **Breakpoint navigator** or **Exception Breakpoint** are unfamiliar.

This guide supports the **Exception Breakpoint Lab** (catalog id `break_on_failure`): use an Exception Breakpoint to reveal a caught Objective-C exception that the app normally hides behind a vague recovered failure.

**Question:** How do I stop at the original exception throw when the app catches it and keeps going?

## Symptom

Without an Exception Breakpoint, tapping **Run scenario** does not crash. The app catches the Objective-C exception and only shows:

> Selection failed. The app recovered, but hid the table and row details.

That vague message is the point. The normal app path has already erased the useful context.

## Why the exception is caught

This lab intentionally catches the exception. It is not teaching that table lookups should normally use Objective-C exceptions.

The catch simulates a real debugging pattern: a framework, compatibility layer, or app recovery path prevents a crash but translates the original failure into a generic message. That can be good for users because the app keeps running, but bad for debugging because the table name, row ID, and original reason are easy to lose.

The Exception Breakpoint is useful here because it stops before that recovery path runs.

## Recommended first tool

**Exception Breakpoint after observing the vague recovered failure.**

Crash Lab teaches the default crash stop. This lab teaches a different move: stop at the hidden throw site before a catch/recovery path turns the original cause into a generic symptom.

## Step-by-step workflow

1. **Establish the app-level symptom**  
   - Run this lab once **without** adding an Exception Breakpoint.
   - Confirm the app keeps running.
   - Read the generic message in the lab footer. Notice what it does not tell you: which table, which row, or why selection failed.

2. **Add the breakpoint**  
   - Open the Breakpoint navigator (`⌘8`).
   - Click **+** → **Exception Breakpoint**.
   - Leave the default configuration for the first run.

3. **Run the same scenario again**  
   - Xcode should stop when the Objective-C exception is thrown, before the catch path returns the generic message.
   - If Xcode selects `objc_exception_throw`, click the first app frame below it: `ExceptionBreakpointLabTriggerInvalidSelectionException`.

4. **Read the useful locals**  
   In the Variables view, look for:
   - `brokenTableName`
   - `brokenRowID`
   - `exceptionReason`

5. **State the value clearly**  
   Finish with one sentence:
   - “The Exception Breakpoint helped because the app normally caught the exception and hid the table/row details; the breakpoint stopped at the throw site where `brokenTableName`, `brokenRowID`, and `exceptionReason` were still visible.”

## The immediate payoff to look for

This lab only works if the difference is obvious:

- **Without breakpoint:** no debugger stop, no crash, only a generic recovered failure.
- **With breakpoint:** debugger stop at the hidden raise site, with domain-specific locals visible.

The learner win is not “exception breakpoints are for all crashes.” The learner win is narrower:

**Use an Exception Breakpoint when the original exception is thrown before the final symptom, especially when the app catches, translates, or hides it.**

## Boundary With Nearby Labs

Crash Lab teaches:

- “The app stopped on its own. Read the selected line, console, stack, and locals.”

Exception Breakpoint Lab teaches:

- “The app did not stop on its own. Add an Exception Breakpoint to intercept the hidden throw before recovery hides the useful context.”

Breakpoint Lab teaches something different:

- “The app did not stop because there was no exception. Choose one line breakpoint and inspect wrong logic.”

## Checklist

- [ ] You’re done when you can explain why the no-breakpoint run gave too little information.  
- [ ] You can find `ExceptionBreakpointLabTriggerInvalidSelectionException` after the Exception Breakpoint stops.  
- [ ] You can read `brokenTableName`, `brokenRowID`, and `exceptionReason` in Variables.  
- [ ] You can explain when this tool is useful: caught, translated, or hidden exceptions.
