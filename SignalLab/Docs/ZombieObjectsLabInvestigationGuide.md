# Zombie Objects Lab — Investigation Guide

**Post-MVP / scheme diagnostic.** Use **Zombie Objects** when a crash feels like **use-after-free** or a **late callback** after teardown, but the default trap or `EXC_BAD_ACCESS` text is too vague to act on.

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`zombieObjectsLab`)

---

## Teaching question

**How do I turn an unclear memory crash into a direct “you messaged a dead object” diagnosis?**

---

## Symptom

- Crash or trap **after** a screen, helper, or owner should be gone.
- Often involves **notifications**, **closures**, **timers**, or **async** completion after `deinit`.

---

## Recommended first tool

**Xcode Run → Diagnostics → Zombie Objects** (exact label may vary by Xcode version).

---

## Boundaries

| Topic | Use instead |
|-------|-------------|
| Object **stays** alive after dismiss | **Retain Cycle Lab** + Memory Graph |
| Main thread **frozen** | **Hang Lab** |
| **Concurrent** unsynchronized access | **Thread Sanitizer Lab** |

---

## Step-by-step

1. In SignalLab, open **Zombie Objects Lab**, choose **Broken**, and run **Run scenario** from Xcode (in-app use-after-release). Optionally reproduce once **without** Zombies first to feel a vaguer stop.
2. Enable **Zombie Objects**, relaunch from Xcode, run **Broken** again.
3. Read the new diagnostic: class name, zombie wording, or deallocated-instance hint.
4. Find the **late** code path (callback, observer, weak-vs-strong mistake) that ran after release.
5. Run **Fixed** in the lab to sanity-check the safe path (no dangling send), then fix real projects (invalidate, `weak`, tear down subscription, extend lifetime intentionally) and **disable** Zombies when done.

---

## Checklist

- [ ] Zombies enabled for the run that reproduced the bug.  
- [ ] You can contrast the crash text with Zombies on vs off.  
- [ ] You can explain why this is not Retain Cycle Lab’s “still alive” symptom.  
