# Concurrency Isolation Lab — Investigation Guide

## Xcode terminology

Read [`XcodeToolingCheatSheet.md`](XcodeToolingCheatSheet.md) (**Console and Issue navigator**) if the **Issue navigator** or **Sendable** warnings are unfamiliar.

**Phase 2.** Use this lab when **completion order is flaky** or Xcode flags **Sendable / isolation** issues—not when two threads corrupt the same memory without a lock (**Thread Sanitizer Lab**).

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`concurrencyIsolationLab`)

---

## Teaching question

**When is the first tool the Issue navigator or structured `async` work, not Thread Sanitizer?**

---

## Symptom

- Logs or UI state sometimes show **step B before step A** when both were launched with unstructured `Task.detached`.
- Compiler or Issue navigator warnings about capturing **non-Sendable** types in `@Sendable` contexts.

---

## Recommended first tool

**Xcode Issue navigator** and **repeated Broken runs** watching the completion log (`alpha` / `beta` order).

---

## Boundaries

| Topic | Use instead |
|-------|-------------|
| Unsynchronized writes to one counter | **Thread Sanitizer Lab** |
| UI updates from wrong thread | **Background Thread UI Lab** |
| Main queue self-deadlock | **Deadlock Lab** |

---

## Step-by-step

1. Run **Broken** several times; note when `alpha` precedes `beta` and when it does not.
2. Read Sendable-related diagnostics for the lab’s non-Sendable token capture.
3. Run **Fixed**; confirm **always** `alpha`, then `beta`.
4. Refactor one production feature from multiple fire-and-forget `detached` tasks to a single `async` function with explicit ordering.
5. Only then, if shared mutable memory is still suspect, enable **Thread Sanitizer**.

---

## Checklist

- [ ] You can restate why flaky ordering is a different class of bug than a TSan data race.  
- [ ] You can point to the structured pattern that makes Fixed mode deterministic.  
