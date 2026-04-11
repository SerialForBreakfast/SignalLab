# Crash Lab — Investigation Guide

This guide matches the **Crash Lab** implementation: a bundled JSON inventory where the **second row omits the required `count` field**. Broken mode uses unsafe casts; Fixed mode validates and skips bad rows.

## Symptom

- **Broken mode:** The app **terminates** when the import reaches the malformed row (typically an `EXC_BAD_INSTRUCTION` or similar from a forced cast to `Int`).
- **Fixed mode:** Import **completes**; the UI reports how many valid lines loaded and **why** the bad row was skipped.

## Recommended first tool

**The default debugger stop in Xcode** — use the highlighted line, stack frames, Variables view, and one caller frame before adding extra debugger features.

## Step-by-step workflow

1. **Reproduce under the debugger**  
   - Run **SignalLab** from Xcode.  
   - Navigate to **Crash Lab**.  
   - Ensure **Broken** is selected (use **Reset** if unsure).  
   - Tap **Run scenario**.

2. **Inspect the faulting frame**  
   - When Xcode stops, note the **line** in the parser that assumed `count` was present.  
   - Open the **Variables** view and inspect the **current dictionary** / row being parsed.
   - Confirm that the malformed row is the one missing `count`.

3. **Find your frame, not just any frame**  
   - In the debug navigator, look for the first frame in **your code** instead of reading every system frame from the top.
   - The parser frame is usually the best starting point because it shows the failing assumption directly.

4. **Move one caller up**  
   - Select one **caller frame** above the parser.
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

- [ ] You’re done when you can explain which assumption about `count` caused the crash and point to the row that violates it.  
- [ ] You can point to the **exact line** that assumed `count` was safe.  
- [ ] You can describe **what Fixed mode** does differently and why the app stays alive.

## Sample data reference

Bundled file: `crash_import_sample.json` (also embedded in code as a fallback).  
Row `line-2` intentionally omits `count` for a deterministic lesson.
