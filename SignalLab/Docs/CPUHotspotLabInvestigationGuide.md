# CPU Hotspot Lab — Investigation Guide

This guide defines the intended **CPU Hotspot Lab** exercise: a searchable interaction that still works, but feels slower than it should because Broken mode repeats expensive work on each update.

## Symptom

- **Broken mode:** Typing or search updates still work, but each interaction feels heavy or delayed.
- **Fixed mode:** The same interaction feels lighter because redundant work is removed or reduced.

This is not the same symptom as **Hang Lab**:

- **CPU Hotspot Lab:** the UI is slow, but still responsive
- **Hang Lab:** the UI feels stuck and stops responding to gestures

## Recommended first tool

**Instruments Time Profiler** — this lab is about ranking cost and finding the hot path, not pausing the main thread during a hard freeze.

## Step-by-step workflow

1. **Reproduce the slow interaction**  
   - Start in **Broken** mode.
   - Perform the same search or typing interaction several times.
   - Confirm the UI still works, but feels sluggish.

2. **Record a Time Profiler trace**  
   - Launch the app through Instruments with **Time Profiler**.
   - Record while reproducing the slow interaction.

3. **Find your hottest work first**  
   - Sort by **Self Time** or the equivalent hot-path view.
   - Look for functions in your code before chasing framework frames.
   - Focus on repeated sorting, repeated helper creation, or repeated expensive transforms.

4. **Name the redundant work**  
   - Finish the investigation with one sentence:
     - “This interaction is slow because we repeat `X` on every update.”

5. **Validate with Fixed mode**  
   - Re-run the same interaction in **Fixed** mode.
   - Confirm the hot path is leaner and the interaction feels faster.

## Teaching summary

This lab teaches:

- “The app is not frozen, but it is doing too much work.”
- “Use Time Profiler to rank cost and find the repeated expensive path.”

It is adjacent to, but different from:

- **Breakpoint Lab:** wrong logic while the app keeps running
- **Hang Lab:** blocked responsiveness from work on the main thread

## Checklist

- [ ] You’re done when you can name the primary redundant work in Broken mode and explain why the interaction feels slow rather than frozen.  
- [ ] You can point to at least one hot function in your code from the trace.  
- [ ] You can explain what became cheaper in Fixed mode.
