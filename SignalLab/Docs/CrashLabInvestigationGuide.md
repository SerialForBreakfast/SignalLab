# Crash Lab — Investigation Guide

This guide matches the **Crash Lab** implementation: a bundled JSON inventory where the **second row omits the required `count` field**. Broken mode uses unsafe casts; Fixed mode validates and skips bad rows.

## Symptom

- **Broken mode:** The app **terminates** when the import reaches the malformed row (typically an `EXC_BAD_INSTRUCTION` or similar from a forced cast to `Int`).
- **Fixed mode:** Import **completes**; the UI reports how many valid lines loaded and **why** the bad row was skipped.

## Recommended first tool

**Xcode Exception Breakpoint** — catches the failure at the throw/crash site before you guess where to set a line breakpoint.

## Step-by-step workflow

1. **Add the breakpoint**  
   - Open the Breakpoint navigator (`⌘8`).  
   - Click **+** → **Exception Breakpoint**.  
   - Leave default “Break on Objective-C and Swift exceptions” (or Swift-only if you prefer).

2. **Reproduce under the debugger**  
   - Run **SignalLab** from Xcode.  
   - Navigate to **Crash Lab**.  
   - Ensure **Broken** is selected (use **Reset** if unsure).  
   - Tap **Run scenario**.

3. **Inspect the faulting frame**  
   - When Xcode stops, note the **line** in the parser that assumed `count` was present.  
   - Open the **Variables** view (or `lldb`) and inspect the **current dictionary** / row being parsed.

4. **Walk the stack**  
   - In the debug navigator, select **caller frames** above the parser.  
   - Ask: *Who passed this row in? Is validation supposed to happen here or earlier?*

5. **Form a hypothesis**  
   - State the **bad assumption** in one sentence (e.g. “`count` is always present and always an `Int`”).

6. **Validate with Fixed mode**  
   - Select **Fixed** mode, tap **Run scenario** again.  
   - Confirm: valid rows import, malformed row is **skipped** with an explicit reason in the on-screen summary.

## Root cause (teaching summary)

The broken implementation treats loosely typed JSON (`[String: Any]`) as if every key the domain needs already exists and has the correct type. **One malformed record** violates that contract, so a **forced cast** fails at runtime.

The fixed path **validates** each field (or uses a safe decoding strategy), **skips** invalid rows, and **surfaces** what went wrong—without crashing.

## Suggested validation checklist

- [ ] You can point to the **exact line** that assumed `count` was safe.  
- [ ] You can explain **why** the second JSON object triggers the crash.  
- [ ] You can describe **what Fixed mode** does differently and why the app stays alive.

## Sample data reference

Bundled file: `crash_import_sample.json` (also embedded in code as a fallback).  
Row `line-2` intentionally omits `count` for a deterministic lesson.
