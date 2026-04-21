# SignalLab Roadmap

This document summarizes delivery phases. The canonical narrative lives in [ReadMe.md](../../ReadMe.md).

## Phase 0: Foundation

- App shell, lab catalog, shared lab metadata and navigation
- Reusable lab detail scaffold with broken/fixed comparison controls
- Documentation for roadmap, lab design principles, and contributor expectations

## Phase 1: Foundational Labs (MVP)

Ship six labs end to end:

1. Crash Lab — default crash debugger workflow and one useful caller-frame jump
2. Exception Breakpoint Lab — compare the default stop with an exception breakpoint
3. Breakpoint Lab — line, conditional, and action breakpoints for logic bugs
4. Retain Cycle Lab — Memory Graph and ownership
5. Hang Lab — main-thread freezes and thread stacks
6. CPU Hotspot Lab — Time Profiler and hot paths

## Phase 2: Diagnostics Expansion

Shipped in app: Phase 2 labs through **Concurrency Isolation Lab** (`concurrency_isolation`) — including **Scroll Hitch** (`scroll_hitch`) and **Startup Signpost** (`startup_signpost`). Next candidates: tie-ins to new Instruments templates, optional advanced strict-concurrency labs, or Phase 3 pedagogy work.

## Phase 3: Pedagogy and Curriculum

Difficulty progression, structured hints, glossary, mentor/workshop prompts, completion checklists.

## Phase 4: Automation and Regression

Repeat-trigger controls, optional lab automation, verification checklists for traces.

For task-level breakdown and acceptance criteria, see [Tasks.md](../../Tasks.md).
