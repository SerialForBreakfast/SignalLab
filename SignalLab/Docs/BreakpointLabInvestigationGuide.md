# Breakpoint Lab — Investigation Guide

This guide matches **Breakpoint Lab**: a small catalog filter where **Broken** mode applies **only** the category filter when a category is selected, silently ignoring the name search. **Fixed** mode always intersects **category** (if any) **and** **name substring** (if non-empty).

## Symptom

- **Repro:** Category = **Electronics**, Search = **Swift**, tap **Run scenario**.
- **Broken:** You see **every electronics item** (USB-C Hub, headphones, keyboard, …) even though none of the names contain “Swift”.
- **Fixed:** **Zero rows** — there is no electronics item whose name matches “Swift”.

## Recommended first tool

**Line breakpoint** on `BreakpointLabFilter.applyCatalogFilter(items:normalizedQuery:category:mode:)` — one place where all filtering happens, easy to compare variables each run.

## Step-by-step workflow

1. **Stabilize the repro**  
   - Broken mode → Electronics + `Swift` → Run. Note the **count** of rows.  
   - Fixed mode → same inputs → Run. Note the count is **0**.

2. **Set a line breakpoint**  
   - Open `BreakpointLabFilter.swift`.  
   - Click the gutter on the first line inside `applyCatalogFilter`.  
   - Run again from Xcode; when you hit the breakpoint, inspect:
     - `normalizedQuery` (should be `"Swift"`)
     - `category` (should be `.electronics`)
     - `mode`

3. **Step through the Broken path**  
   - Step into `applyBroken`.  
   - Observe that when `category` is non-`nil`, the function returns **after** the category filter **without** consulting `normalizedQuery`.

4. **Use a conditional breakpoint (optional)**  
   - Edit the breakpoint → **Condition**, e.g. `category != nil && !normalizedQuery.isEmpty`.  
   - Re-run: you only stop on the interesting case.

5. **Try a log breakpoint (optional)**  
   - Edit breakpoint → **Add Action** → **Log Message**, e.g. `category={{category}}, query={{normalizedQuery}}`.  
   - Check the debug console without stopping every time.

6. **Validate Fixed mode**  
   - Switch to Fixed, same inputs, Run.  
   - Confirm `applyFixed` applies category **then** name filter.

## Root cause (teaching summary)

The broken implementation **short-circuits**: “If the user picked a category, return all items in that category.” The **name query is never applied** in that branch, so the UI looks like search is broken.

The fixed path **always** applies both constraints: optional category narrowing, then optional name match.

## Checklist

- [ ] You can quote the condition that causes the query to be skipped.  
- [ ] You can predict Broken vs Fixed counts for Electronics + `Swift`.  
- [ ] You used either a **conditional** or **log** breakpoint to reduce noise.

## Code reference

- Filter entry point: `BreakpointLabFilter.applyCatalogFilter`  
- UI + runner: `BreakpointLabScenarioRunner`, `iOSBreakpointLabDetailView`
