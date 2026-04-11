# CPU Hotspot Lab — Investigation Guide

The in-app search scenario is fully implemented. This guide duplicates the catalog copy so you can read it while the debugger is attached (you cannot scroll the detail screen during a paused trace).

**Source of truth:** `SignalLab/SignalLab/Shared/LabDomain/LabCatalog.swift` (`cpuHotspotLab`)  
When you change catalog copy, update this file in the same commit (`Docs/Labs.md` too).

---

## Symptom

- **Broken mode:** Typing in the search field is sluggish — each keystroke triggers noticeable lag. The UI stays responsive (gestures work), but feels heavy.
- **Fixed mode:** The same query updates the list with no perceptible delay.

This is not the same symptom as **Hang Lab**:

| Lab | Symptom |
|-----|---------|
| CPU Hotspot Lab | UI is slow, but gestures and scroll still work |
| Hang Lab | UI stops responding to touches until work finishes |

## Recommended first tool

**Instruments Time Profiler** — this lab is about ranking cost and finding the hot path, not pausing the main thread during a hard freeze.

## Three hotspots in Broken mode

All three are in `CPUHotspotLabSearch.applyBroken(items:query:)`:

### Hotspot 1 — Full sort on every keystroke

```swift
let sorted = items.sorted { lhs, rhs in
    if lhs.priority != rhs.priority { return lhs.priority > rhs.priority }
    return lhs.timestamp > rhs.timestamp
}
```

All 500 items are sorted on every call. The relative order never changes between queries, so this work is always redundant. Fixed mode pre-sorts once at runner init time and passes `sortedItems` directly.

### Hotspot 2 — `DateFormatter` allocation per item

```swift
let formatter = DateFormatter()
formatter.dateFormat = "MMM d, HH:mm:ss"
formatter.locale = Locale(identifier: "en_US_POSIX")
let dateString = formatter.string(from: item.timestamp)
```

`DateFormatter` is a heavyweight Objective-C object. Creating one inside the `filter` closure means one allocation per item per keystroke — up to 500 initializations on every character typed. Fixed mode stores the formatted timestamp in `CPUHotspotLabItem.formattedTimestamp`, computed once at data-load time.

### Hotspot 3 — `lowercased()` per item per call

```swift
let nameMatch     = item.name.lowercased().contains(normalized)
let categoryMatch = item.category.lowercased().contains(normalized)
```

Rather than reading a pre-computed key, Broken mode lowercases each field on every filter pass. Fixed mode stores a combined `searchKey` (`lowercased name + category + formatted timestamp`) in the item struct and checks it with a single `contains`.

## Step-by-step workflow

1. **Confirm the symptom in Broken mode**
   - In the app, select Broken mode on CPU Hotspot Lab.
   - Type `memory` or `cpu` in the search field and note the lag.
   - The UI is still draggable — this is _sluggishness_, not a freeze.

2. **Record a Time Profiler trace**
   - From Xcode, choose **Product → Profile** (⌘I) to launch through Instruments.
   - Select **Time Profiler** and click Record.
   - Type the same query several times to build up samples.

3. **Find your hottest work**
   - In the call tree, sort by **Self Time**.
   - Filter the call tree to hide system frames (use the "Your Code" filter in Instruments, or look for frames with your module name).
   - You should see `applyBroken`, `sorted`, and `DateFormatter.init` / `NSDateFormatter.init` near the top.

4. **Name the redundant work**
   - Write one sentence for each hotspot:
     - "We re-sort 500 items on every keystroke even though the order never changes."
     - "We allocate a DateFormatter per item, which is an expensive initialization."
     - "We call lowercased() per item per search instead of pre-computing a search key."

5. **Validate with Fixed mode**
   - Switch to Fixed mode and type the same query.
   - Re-profile: the hot path should be gone.
   - `CPUHotspotLabSearch.applyFixed` should appear much lower in the self-time ranking.

## Teaching summary

This lab teaches:

- "The app is not frozen, but it is doing too much work per keystroke."
- "Use Time Profiler to rank cost and find the repeated expensive path."
- "Pre-computing expensive values (sort order, formatted strings, lowercased keys) moves one-time cost out of the hot path."

It is adjacent to, but different from:

- **Breakpoint Lab:** wrong _logic_ while the app keeps running (use breakpoints)
- **Hang Lab:** blocked responsiveness from synchronous work on the main thread (pause the debugger)

## Checklist

- [ ] You're done when you can name all three redundant operations in Broken mode and explain why the interaction feels slow rather than frozen.
- [ ] You can point to at least one hot frame in your code from the Broken-mode trace.
- [ ] You can explain what Fixed mode pre-computes to remove each hotspot.
