# Breakpoint Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Breakpoints**, **Debugger UI**) if **line breakpoints**, **Variables**, or **step** controls are unfamiliar.

This guide matches **Breakpoint Lab**: a student order shows a wrong total while the app keeps running. The goal is to pause inside the total helper and read the values being passed into the calculation.

## Symptom

- **Repro:** Tap **Run scenario** on the predefined student order.
- **Visible result:** The app completes normally, but the student order receives only **5%** off.
- **Expected result:** The student order should receive **20%** off.
- **Wrong total:** `$114.00`
- **Expected total:** `$96.00`

This lab is for **wrong results while the process keeps running**. Comparing **default crash stop vs Exception Breakpoint** belongs in **Exception Breakpoint Lab** (after Crash Lab), not here.

## Recommended first tool

**Line breakpoint** in `BreakpointLabDiscountCalculator.total(afterDiscountPercent:subtotal:)`, on the first line inside the helper. At that stop, the Variables view should show `discountPercent` and `subtotal` even though the source line that chose the discount is elsewhere.

## Step-by-step workflow

1. **Observe the wrong result**
   - Run SignalLab from Xcode and open **Breakpoint Lab**.
   - Tap **Run scenario**.
   - Confirm the app did not crash, but the student order received **5%** instead of **20%**.

2. **Set one line breakpoint**
   - Open `BreakpointLabDiscountCalculator.swift`.
   - Find `total(afterDiscountPercent:subtotal:)`.
   - Add a plain line breakpoint on `let discountMultiplier = Decimal(100 - discountPercent) / Decimal(100)`.

3. **Run the same scenario again**
   - Tap **Run scenario** again.
   - When Xcode pauses, do not add conditions or actions yet.

4. **Read the paused-frame locals**
   - `discountPercent` should be `5`.
   - `subtotal` should be `120`.
   - The lab UI already told you the expected student discount is `20%`.

5. **Step once**
   - Step over the `discountMultiplier` calculation.
   - `discountMultiplier` becomes `0.95`, so the wrong `$114.00` total follows directly from the `5` value.

## Root cause (teaching summary)

The app did not crash because the code produced a valid number. The number is wrong because the total helper received `discountPercent == 5` when the student order expects **20%**. A line breakpoint is useful here because it reveals the live inputs to the calculation without relying on source-reading the rule that chose them.

Conditional and log breakpoints are useful refinements after you know the useful stop location. They are not required for this lab.

## Checklist

- [ ] You can explain why this bug needs a breakpoint instead of a crash workflow.
- [ ] You can point to `discountPercent` as the value that makes the total wrong.
- [ ] You can explain the wrong total without using conditional breakpoints, log breakpoints, or Fixed mode.

## Code reference

- Discount calculation: `BreakpointLabDiscountCalculator.total(afterDiscountPercent:subtotal:)`
- UI + runner: `BreakpointLabScenarioRunner`, `iOSBreakpointLabDetailView`
