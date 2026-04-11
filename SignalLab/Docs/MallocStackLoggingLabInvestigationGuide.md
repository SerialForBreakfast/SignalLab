# Malloc Stack Logging Lab — Investigation Guide

**Post-MVP / advanced scheme diagnostic.** After **Memory Graph**, **leaks**, and **Zombies**, sometimes the question is **provenance**: *which code path allocated this object or buffer?*

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`mallocStackLoggingLab`)

---

## Teaching question

**How do I recover allocation history for a suspicious object when current liveness is not enough?**

---

## Symptom

- You know **something** is wrong (growth, wrong survivor, crash address) but need the **allocating stack**, not just retain edges.
- You already tried simpler memory workflows (Retain Cycle, Zombies) for a different question.

---

## Recommended first tool

**Xcode Run → Diagnostics → Malloc Stack Logging** (options and companion tools vary by Xcode version; pair with **Instruments** or **lldb** `malloc_history` as documented for your SDK).

---

## Boundaries

| Tool | Question |
|------|----------|
| **Memory Graph** | Who holds this **alive** now? |
| **Zombie Objects** | Did I message **after** dealloc? |
| **Malloc stack logging** | **Where** was this **allocated**? |

---

## Step-by-step

1. Name the suspicious allocation (counter, Instruments graph, or crash).
2. Enable **Malloc Stack Logging** in the scheme; run from Xcode.
3. Reproduce **minimally** so stacks are recorded.
4. Open allocation stack / history in your toolchain; find a frame in **your** module.
5. **Disable** logging after capture—cost is high for day-to-day work.

---

## Checklist

- [ ] Logging enabled only for the investigation window.  
- [ ] You captured at least one allocation backtrace tied to your code.  
- [ ] You can explain why Memory Graph alone did not answer the question.  
