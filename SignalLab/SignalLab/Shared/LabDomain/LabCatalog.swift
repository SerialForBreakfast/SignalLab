//
//  LabCatalog.swift
//  SignalLab
//
//  Static registry of MVP labs; scenario implementations are wired in later milestones.
//

import Foundation

/// Central list of all labs in the catalog (MVP + diagnostics + Phase 2).
enum LabCatalog {
    /// All MVP scenarios in **locked curriculum order** (`Docs/LabRefinement.md` task 1):
    /// Crash → … → CPU Hotspot → post-MVP diagnostics → Phase 2 (Heap Growth → Deadlock → Background Thread UI → Main Thread I/O).
    /// Keep `catalogSortIndex` aligned with this array when adding or reordering labs.
    static let scenarios: [LabScenario] = [
        crashLab,
        exceptionBreakpointLab,
        breakpointLab,
        retainCycleLab,
        hangLab,
        cpuHotspotLab,
        threadPerformanceCheckerLab,
        zombieObjectsLab,
        threadSanitizerLab,
        mallocStackLoggingLab,
        heapGrowthLab,
        deadlockLab,
        backgroundThreadUILab,
        mainThreadIOLab,
    ]

    /// Scenarios sorted for display (stable via ``LabScenario/catalogSortIndex``).
    static var scenariosSortedForDisplay: [LabScenario] {
        scenarios.sorted { lhs, rhs in
            if lhs.catalogSortIndex != rhs.catalogSortIndex {
                return lhs.catalogSortIndex < rhs.catalogSortIndex
            }
            return lhs.title < rhs.title
        }
    }

    /// Returns the scenario for a slug, if present.
    static func scenario(id: String) -> LabScenario? {
        scenarios.first { $0.id == id }
    }

    // MARK: - MVP labs

    private static let crashLab = LabScenario(
        id: "crash",
        title: "Crash Lab",
        summary: "Use Xcode's default stopped debugger state to explain a malformed local JSON import crash.",
        category: .crash,
        difficulty: .beginner,
        learningGoals: [
            "Find the first relevant frame in your code after a crash",
            "Inspect locals and caller context in the stopped debugger",
            "Identify the unsafe assumption in parsing",
        ],
        reproductionSteps: [
            "Keep Broken mode selected, then tap Run scenario to import `crash_import_sample.json` (bundled with the app).",
            "The second row omits `count`, so the app should stop in Xcode with the parser frame highlighted.",
            "In the stopped debugger, inspect the current row in Variables and find the first relevant frame in your code.",
            "Move one caller up to see who passed the malformed row into the parser.",
            "Switch to Fixed mode and run again; valid rows should import while the malformed row is skipped safely.",
        ],
        hints: [
            "The highlighted crash line matters, but caller frames explain how bad data reached it.",
            "The broken path assumes every dictionary contains an integer `count`.",
            "After you are comfortable with this default stop, use Exception Breakpoint Lab to compare exception-breakpoint stop policy—not before.",
        ],
        toolRecommendations: [
            "Debug navigator stack frames",
            "Variables view",
            "Caller frame navigation",
            "Long-form write-up: Docs/CrashLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Default debugger stop: stack frames + Variables view",
            steps: [
                "Run SignalLab from Xcode, open Crash Lab, keep Broken mode, and tap Run scenario.",
                "When Xcode stops, look at the highlighted parser line and the current row in Variables.",
                "In the debug navigator, find the first frame in your code rather than getting lost in system frames.",
                "Select one caller frame above the parser to see how the malformed row reached this code path.",
                "State the bad assumption in one sentence, then switch to Fixed mode and run again to confirm the malformed row is skipped.",
            ],
            validationChecklist: [
                "You're done when you can explain which assumption about `count` caused the crash and point to the row that violates it.",
                "You can explain why Fixed mode avoids the trap and still imports valid rows.",
            ]
        ),
        catalogSortIndex: 0
    )

    private static let exceptionBreakpointLab = LabScenario(
        id: "break_on_failure",
        title: "Exception Breakpoint Lab",
        summary: "After Crash Lab’s default stop, decide when Xcode’s Exception Breakpoint gives clearer or earlier context on the same failure family.",
        category: .crash,
        difficulty: .beginner,
        learningGoals: [
            "Compare the default crash stop with an exception breakpoint",
            "Recognize when changing stop policy gives clearer context",
            "Explain what the exception breakpoint adds beyond the stop you already had",
        ],
        reproductionSteps: [
            "On this screen, read the comparison steps, then use Crash Lab’s Broken JSON import in Xcode for both passes below.",
            "Pass 1: Reproduce that failure with no added breakpoint and note where Xcode stops by default.",
            "Pass 2: Add an Exception Breakpoint in the Breakpoint navigator and run the same failure again.",
            "Compare where each run stops and what context you get sooner or more consistently.",
        ],
        hints: [
            "This lab is about debugger stop policy, not line breakpoints for a logic bug.",
            "Use the same failure family as Crash Lab so the comparison stays focused on when Xcode stops.",
            "If the app is still running and the result is wrong, that is Breakpoint Lab instead of this lab.",
            "Swift often traps with a clear faulting line; the Exception Breakpoint still helps when you want a consistent stop across failures or earlier context—compare and decide for this crash.",
        ],
        toolRecommendations: [
            "Breakpoint navigator",
            "Xcode Exception Breakpoint",
            "Crash Lab for the default workflow baseline",
            "Long-form write-up: Docs/ExceptionBreakpointLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: false,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Xcode Exception Breakpoint compared against the default stop",
            steps: [
                "Run the failure once without adding a breakpoint so you can see Xcode's default stop behavior.",
                "Add an Exception Breakpoint from the Breakpoint navigator.",
                "Run the same failure again and compare where execution stops and what frames are visible.",
                "Note whether the breakpoint gives you earlier or clearer context than the default stop.",
            ],
            validationChecklist: [
                "You're done when you can explain what the exception breakpoint added over the default stop for this failure.",
            ]
        ),
        catalogSortIndex: 1
    )

    private static let breakpointLab = LabScenario(
        id: "breakpoint",
        title: "Breakpoint Lab",
        summary: "Use line, conditional, and action breakpoints to chase a non-crashing filter bug.",
        category: .breakpoint,
        difficulty: .beginner,
        learningGoals: [
            "Start with one line breakpoint at the shared decision point",
            "Inspect incorrect state and step through the bad branch",
            "Use conditional or log breakpoints only after the core stop is clear",
        ],
        reproductionSteps: [
            "Keep Broken mode selected, choose Electronics in Category, type Swift in Search, then tap Run scenario.",
            "Broken mode should list every electronics row even though none of the names contain Swift.",
            "Add one plain line breakpoint in `BreakpointLabFilter.applyCatalogFilter(...)`, then run the same inputs again.",
            "Inspect `normalizedQuery`, `category`, and `mode`, then step into the Broken branch to see which predicate is skipped.",
            "Switch to Fixed mode with the same inputs and run again; no rows should match.",
        ],
        hints: [
            "All filtering runs through BreakpointLabFilter.applyCatalogFilter(items:normalizedQuery:category:mode:).",
            "Start with a plain line breakpoint first; add a condition only after you know where the bad branch lives.",
            "This lab is about wrong logic while the app keeps running, not crash-stop policy or performance profiling.",
            "Comparing default crash stop vs Exception Breakpoint belongs in Exception Breakpoint Lab after Crash Lab—not here.",
        ],
        toolRecommendations: [
            "Line breakpoints",
            "Conditional breakpoints",
            "Log/action breakpoints",
            "Long-form write-up: Docs/BreakpointLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Line breakpoint on BreakpointLabFilter.applyCatalogFilter",
            steps: [
                "Reproduce: category Electronics + query Swift + Run in Broken mode so you can see the wrong result first.",
                "Add a line breakpoint at the start of applyCatalogFilter; inspect normalizedQuery, category, and mode.",
                "Step into the Broken path and note exactly where the query predicate is dropped.",
                "Optional: convert the same breakpoint to a conditional or log breakpoint once you understand the path.",
                "Switch to Fixed mode and confirm both category and name constraints apply.",
            ],
            validationChecklist: [
                "You're done when you can point to the branch that ignores the search text in Broken mode and explain why the result is wrong.",
                "You can explain how Fixed mode combines category and name filters.",
            ]
        ),
        catalogSortIndex: 2
    )

    private static let retainCycleLab = LabScenario(
        id: "retain_cycle",
        title: "Retain Cycle Lab",
        summary: "Explore object lifetime with a detail sheet whose timer keeps it alive in Broken mode.",
        category: .memory,
        difficulty: .intermediate,
        learningGoals: [
            "Reproduce a leak through repeated navigation",
            "Use Memory Graph to inspect ownership",
            "Confirm deallocation after the fix",
        ],
        reproductionSteps: [
            "On this screen, stay in Broken mode (tap Reset if you want the default lab state).",
            "Tap Run scenario to open the detail sheet, then Close. Repeat two or three times.",
            "Watch Live detail sessions climb—it should not return to zero until you restart the app.",
            "Switch to Fixed mode, tap Run scenario, then Close once; the live counter should drop after the sheet dismisses.",
            "Use Memory Graph to inspect retaining paths for `RetainCycleLabDetailHeart` in Broken mode.",
        ],
        hints: [
            "Follow the chain: RunLoop → Timer → closure → RetainCycleLabDetailHeart.",
            "Fixed mode calls stopTimerForTeardown() when the sheet disappears.",
            "A dismissed screen can still leak without freezing the UI; if the symptom is a freeze, move to Hang Lab instead.",
        ],
        toolRecommendations: [
            "Xcode Memory Graph",
            "Instruments Leaks",
            "Long-form write-up: Docs/RetainCycleLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Xcode Memory Graph after repeated open/close",
            steps: [
                "In Broken mode, open and dismiss the detail sheet several times without killing the app.",
                "Open Memory Graph; search for RetainCycleLabDetailHeart or your detail type and note multiple live instances.",
                "Expand retaining paths: expect Timer / RunLoop / block to appear in the broken configuration.",
                "Switch to Fixed mode: open and close once; confirm the live-session counter decreases.",
                "Capture Memory Graph again and compare instance counts.",
            ],
            validationChecklist: [
                "You're done when you can identify the retaining path that keeps the dismissed detail alive in Broken mode.",
                "You can explain why the timer keeps the detail object alive in Broken mode.",
                "You can explain what Fixed mode does so the object can deallocate.",
            ]
        ),
        catalogSortIndex: 3
    )

    private static let hangLab = LabScenario(
        id: "hang",
        title: "Hang Lab",
        summary: "See a main-thread freeze from heavy work, then compare with an off-main fix.",
        category: .hang,
        difficulty: .intermediate,
        learningGoals: [
            "Recognize a visible hang",
            "Pause during a freeze and inspect threads",
            "Identify work that must leave the main thread",
        ],
        reproductionSteps: [
            "On this screen, use Broken mode (tap Reset if you want the default lab state).",
            "Tap Run scenario, then immediately try to scroll the horizontal “Scroll probe” chips—they should stay frozen until processing finishes.",
            "Switch to Fixed mode, tap Run scenario again, and scroll during processing—the chips should remain draggable.",
            "Optional: pause the debugger during the Broken freeze and inspect the main thread stack for HangLabWorkload.simulateReportProcessing.",
        ],
        hints: [
            "Broken mode calls HangLabWorkload.simulateReportProcessing directly on the main actor.",
            "Fixed mode awaits Task.detached { … } before updating UI.",
            "If interaction is merely slow but still responsive, that is CPU Hotspot Lab rather than Hang Lab.",
            "If live-instance counts keep rising after you dismiss a screen but scrolling still works, that is Retain Cycle Lab—not a main-thread hang.",
        ],
        toolRecommendations: [
            "Pause in the debugger",
            "Debug navigator threads",
            "Instruments Time Profiler (supporting)",
            "Long-form write-up: Docs/HangLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Debugger pause while scrolling fails in Broken mode",
            steps: [
                "In Broken mode, tap Run and attempt to scroll the probe row during the stall.",
                "Pause the debugger; open the main thread stack and locate simulateReportProcessing or HangLabWorkload.",
                "Note that the same function runs in Fixed mode but from a detached task (off the main queue).",
                "Resume and compare how quickly the UI accepts gestures after each mode.",
            ],
            validationChecklist: [
                "You're done when you can point to the work blocking the main thread in Broken mode and explain why the UI freezes.",
                "You can name the synchronous work running on the main thread in Broken mode.",
                "You can explain how Fixed mode moves CPU work off the main actor.",
            ]
        ),
        catalogSortIndex: 4
    )

    private static let cpuHotspotLab = LabScenario(
        id: "cpu_hotspot",
        title: "CPU Hotspot Lab",
        summary: "Search 500 diagnostic events and profile the sluggish keystrokes in Broken mode with Instruments Time Profiler.",
        category: .performance,
        difficulty: .intermediate,
        learningGoals: [
            "Profile a slow-but-responsive interaction with Time Profiler",
            "Identify the hottest functions in the trace by self time",
            "Separate app hotspots (sort, DateFormatter, lowercased) from framework noise",
        ],
        reproductionSteps: [
            "In Broken mode, type a short query such as ‘memory’ or ‘cpu’ in the search field and notice the lag per keystroke.",
            "Switch to Fixed mode and type the same query — the list should update noticeably faster.",
            "To profile: launch through Instruments > Time Profiler, record while typing in Broken mode, then look for `applyBroken`, `sorted`, and `DateFormatter.init` in the trace.",
            "Re-profile in Fixed mode to confirm the hot path is gone.",
        ],
        hints: [
            "Broken mode has three compounding problems per keystroke: a full sort of 500 items, one DateFormatter allocation per item, and lowercased() called per item per search.",
            "Sort the trace by Self Time and look for your own code before chasing system libraries.",
            "If the UI fully freezes and gestures stop working, that is Hang Lab — CPU Hotspot Lab stays responsive but feels sluggish.",
            "DateFormatter is a heavyweight Objective-C object; creating one inside a tight loop is a classic iOS performance mistake.",
        ],
        toolRecommendations: [
            "Instruments Time Profiler",
            "Long-form write-up: Docs/CPUHotspotLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Instruments Time Profiler — record while typing in the search field",
            steps: [
                "In Broken mode, type a query and confirm the UI is sluggish but still responds to gestures.",
                "Launch through Instruments > Time Profiler; record while typing the same query several times.",
                "Sort by Self Time and locate `CPUHotspotLabSearch.applyBroken` or the `sorted` and `DateFormatter.init` frames.",
                "Identify all three hotspots: repeated sort, DateFormatter per item, and per-call lowercased().",
                "Switch to Fixed mode, re-profile the same interaction, and confirm the hot path is eliminated.",
            ],
            validationChecklist: [
                "You’re done when you can name all three redundant operations in Broken mode and explain why the interaction is slow but not frozen.",
                "You can point to at least one hot frame in your code in the Broken trace.",
                "You can explain what Fixed mode pre-computes to remove each hotspot.",
            ]
        ),
        catalogSortIndex: 5
    )

    /// Post-MVP scheme diagnostic: Thread Performance Checker (after Hang Lab in the learner’s mental model; ships after MVP performance lab).
    private static let threadPerformanceCheckerLab = LabScenario(
        id: "thread_performance_checker",
        title: "Thread Performance Checker Lab",
        summary: "After Hang Lab’s pause-and-inspect proof, enable Xcode’s Thread Performance Checker to surface main-thread misuse as a runtime warning.",
        category: .hang,
        difficulty: .intermediate,
        learningGoals: [
            "Enable Thread Performance Checker from the Xcode scheme",
            "Connect a runtime diagnostic to the same main-thread story as Hang Lab",
            "Explain what the checker adds beyond pausing the debugger manually",
        ],
        reproductionSteps: [
            "Skim Hang Lab first: Broken mode blocks the scroll probes while heavy work runs synchronously on the main actor.",
            "In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics, then enable Thread Performance Checker (exact label may vary slightly by Xcode version).",
            "Build and run SignalLab from Xcode, open Hang Lab, choose Broken mode, tap Run scenario, and try scrolling during the stall.",
            "Watch Xcode’s Issue navigator or the runtime console for a Thread Performance Checker warning tied to main-queue work.",
            "Compare with Fixed mode (or CPU Hotspot Lab’s sluggish-but-responsive symptom) so you do not confuse checker warnings with Time Profiler hotspots.",
        ],
        hints: [
            "This lab is scheme diagnostics, not Hang Lab’s pause-and-read-stack workflow—use both together.",
            "If the UI is merely sluggish but still scrolls, profile with CPU Hotspot Lab instead of expecting a checker storm.",
            "If objects stay alive after dismissal, that is Retain Cycle Lab—checker warnings are about thread misuse, not lifetime.",
        ],
        toolRecommendations: [
            "Xcode scheme → Run → Diagnostics → Thread Performance Checker",
            "Hang Lab (Broken vs Fixed) for the same workload shape",
            "Long-form write-up: Docs/ThreadPerformanceCheckerLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: false,
        supportsFixedMode: false,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Xcode scheme: enable Thread Performance Checker, then rerun from Xcode",
            steps: [
                "Confirm you can reproduce Hang Lab’s Broken-mode freeze so you have a concrete main-thread story in mind.",
                "Enable Thread Performance Checker in the Run scheme diagnostics and relaunch the app from Xcode.",
                "Trigger the same Broken-mode hang and read the warning Xcode surfaces—note the symbol or queue it cites.",
                "Contrast that evidence with what you learned from pausing during the freeze in Hang Lab.",
                "Optional: switch Hang Lab to Fixed mode and confirm the warning no longer appears for the same gesture path.",
            ],
            validationChecklist: [
                "You’re done when you can describe one Thread Performance Checker warning you saw and how it supports a main-thread diagnosis.",
                "You can explain what this adds compared with only pausing the debugger during a freeze.",
            ]
        ),
        catalogSortIndex: 6
    )

    /// Post-MVP: Zombie Objects scheme diagnostic — clarify use-after-free style crashes vs Retain Cycle Lab.
    private static let zombieObjectsLab = LabScenario(
        id: "zombie_objects",
        title: "Zombie Objects Lab",
        summary: "Turn an ambiguous memory crash into a clear “message sent to zombie / deallocated instance” diagnosis using Xcode’s Zombie Objects diagnostic.",
        category: .memory,
        difficulty: .intermediate,
        learningGoals: [
            "Enable Zombie Objects from the Run scheme diagnostics",
            "Contrast an unclear crash with the sharper message Zombies provide",
            "Separate use-after-free style bugs from retain cycles (objects that stay alive too long)",
        ],
        reproductionSteps: [
            "Read Retain Cycle Lab’s contrast: there the object stays alive; Zombies target the opposite—something was freed and messaged too late.",
            "In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics → enable Zombie Objects (label may vary slightly by Xcode version).",
            "Open this lab, choose **Broken**, tap **Run scenario** from Xcode—Objective-C messages a deallocated object (`__unsafe_unretained` after the pool drains).",
            "Run again with Zombies off to feel the vaguer failure, then enable Zombies and compare the diagnostic text.",
            "Switch to **Fixed** and run once: messaging stays inside the autorelease pool—no dangling reference.",
        ],
        hints: [
            "Retain Cycle Lab: live-instance counts climb—Zombies: the crash says you messaged memory that was already released.",
            "Zombies trade memory for clarity; turn them off when you are done investigating.",
            "Do not confuse this with Hang Lab or Thread Sanitizer—those are responsiveness and concurrent access, not deallocation timing.",
        ],
        toolRecommendations: [
            "Xcode scheme → Run → Diagnostics → Zombie Objects",
            "Retain Cycle Lab (contrast: retention vs zombie)",
            "Long-form write-up: Docs/ZombieObjectsLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Xcode scheme: enable Zombie Objects, then run this lab’s Broken mode from Xcode",
            steps: [
                "Without Zombies, run Broken once and note how vague the stop feels (symbol-only or generic `EXC_BAD_ACCESS`).",
                "Enable Zombie Objects, relaunch, run Broken again, and read the clearer zombie / deallocated wording.",
                "Identify which type or instance the runtime names as zombie or deallocated.",
                "Run **Fixed** to confirm the safe path avoids messaging after release.",
                "Disable Zombies after you have a fix hypothesis to avoid unnecessary overhead.",
            ],
            validationChecklist: [
                "You’re done when you can quote how the crash message changed with Zombies on and what object it implicates.",
                "You can state one way the symptom differs from Retain Cycle Lab’s “still alive” story.",
            ]
        ),
        catalogSortIndex: 7
    )

    /// Post-MVP: Thread Sanitizer — prove data races vs guessing from flaky UI.
    private static let threadSanitizerLab = LabScenario(
        id: "thread_sanitizer",
        title: "Thread Sanitizer Lab",
        summary: "Use Xcode’s Thread Sanitizer to prove unsafe concurrent access to shared mutable state—not just surprising async order.",
        category: .hang,
        difficulty: .intermediate,
        learningGoals: [
            "Enable Thread Sanitizer from the Run scheme diagnostics",
            "Tell a data race apart from a wrong-branch logic bug or a main-thread freeze",
            "Map a sanitizer report back to the shared state that needs serialization",
        ],
        reproductionSteps: [
            "Finish Breakpoint Lab mental model: wrong logic while the app runs is not the same as two threads mutating the same property unsafely.",
            "In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics → enable Thread Sanitizer (exact checkbox label may vary).",
            "Open this lab, **Broken**, **Run scenario**—main thread and a detached task increment one shared counter without a lock.",
            "Read the sanitizer report: which address or variable, which two threads, which stack frames.",
            "Switch to **Fixed** (same counter, one `NSLock`, both sides wait) and rerun with TSan until that path is clean.",
        ],
        hints: [
            "Hang Lab is synchronous main-thread starvation; TSan is concurrent unsynchronized writes/reads to the same memory.",
            "If results are wrong but a single thread owns the state, use Breakpoint Lab—not this lab.",
            "TSan slows the app; use it when you suspect a race, not for every performance pass.",
        ],
        toolRecommendations: [
            "Xcode scheme → Run → Diagnostics → Thread Sanitizer",
            "Hang Lab and CPU Hotspot Lab (contrast: freeze / cost vs race)",
            "Long-form write-up: Docs/ThreadSanitizerLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Xcode scheme: enable Thread Sanitizer, then run this lab’s Broken mode from Xcode",
            steps: [
                "Enable Thread Sanitizer and run **Broken** until Xcode stops with a race report on the shared counter.",
                "Extract: conflicting threads, shared variable, and call sites from the report.",
                "Run **Fixed** and confirm the merged counter reaches the expected total with no TSan issue for this path.",
                "Contrast with an async ordering bug (completion A before B) where TSan stays quiet.",
                "Apply the same serialization idea to your own shared state when you leave the lab.",
            ],
            validationChecklist: [
                "You’re done when you can name the shared state TSan flagged and why two threads conflicted.",
                "You can explain why Breakpoint Lab or Hang Lab would be the wrong first tool for that symptom.",
            ]
        ),
        catalogSortIndex: 8
    )

    /// Post-MVP: Malloc Stack Logging — allocation provenance after simpler memory tools.
    private static let mallocStackLoggingLab = LabScenario(
        id: "malloc_stack_logging",
        title: "Malloc Stack Logging Lab",
        summary: "When you need “where was this allocated?” not just “what is alive now,” enable Malloc Stack Logging and read allocation backtraces.",
        category: .memory,
        difficulty: .intermediate,
        learningGoals: [
            "Enable Malloc Stack Logging (or equivalent scheme memory diagnostics) for a suspicious allocation",
            "Recover stack traces that show which code path created an object or buffer",
            "Place this tool after Zombies and Retain Cycle—you are doing provenance, not first-pass leaks",
        ],
        reproductionSteps: [
            "Confirm you already know Memory Graph / leaks basics from Retain Cycle Lab and when Zombies help from Zombie Objects Lab.",
            "In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics → enable Malloc Stack Logging (options may include “Malloc Stack” or similar by version).",
            "Run **Broken** here—each tap allocates thousands of fresh row arrays; use Instruments Allocations (or your guide’s lldb path) to see the allocating stacks.",
            "Run **Fixed** twice: first run warms a reusable buffer; second run should show `0` fresh row arrays in the footer.",
            "Turn logging off when finished—this diagnostic is heavy on overhead and disk.",
        ],
        hints: [
            "This is forensic: use when “who created this?” matters, not as a default leak sweep.",
            "Zombies answer “you messaged the dead”; malloc stacks answer “who birthed this bytes”.",
            "Retain Cycle Lab shows who still holds live references—different question from creation-site history.",
        ],
        toolRecommendations: [
            "Xcode scheme → Run → Diagnostics → Malloc Stack Logging",
            "Instruments Allocations / lldb malloc_history (as appropriate to your Xcode version)",
            "Long-form write-up: Docs/MallocStackLoggingLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Xcode scheme: enable Malloc Stack Logging, then run Broken once under Instruments or lldb",
            steps: [
                "Enable malloc stack recording per scheme instructions and rerun from Xcode.",
                "Run **Broken** once and capture stacks for the row-array allocation hot path in this module.",
                "Run **Fixed** twice and note the second run’s `0` fresh row arrays—contrast with Broken’s burst.",
                "Open the stack / history UI your toolchain provides and tie one frame to a concrete call site.",
                "Disable the diagnostic and document the fix path (reuse, pooling, or fewer per-run allocations).",
            ],
            validationChecklist: [
                "You’re done when you can point to one allocation stack that explains where a suspicious object came from.",
                "You can explain why Memory Graph alone was not enough for that question.",
            ]
        ),
        catalogSortIndex: 9
    )

    // MARK: - Phase 2 labs

    /// Phase 2: Heap growth vs retain cycles — climbing RSS without a reference cycle.
    private static let heapGrowthLab = LabScenario(
        id: "heap_growth",
        title: "Heap Growth Lab",
        summary: "Tell climbing footprint and allocation churn apart from a retain cycle: Broken mode hoards large buffers; Fixed mode caps what stays live.",
        category: .memory,
        difficulty: .intermediate,
        learningGoals: [
            "Contrast Memory Graph growth from unbounded caching with Retain Cycle Lab’s cyclic retention",
            "Use Instruments Allocations or memory gauges to see footprint rise without a cycle",
            "Apply a retention policy (cap, eviction, pool) once growth is confirmed",
        ],
        reproductionSteps: [
            "Finish Retain Cycle Lab first so you know what a cycle looks like in Memory Graph.",
            "Open Heap Growth Lab, **Broken**, tap **Run scenario** several times—each run retains another 256 KB chunk.",
            "In Xcode’s Memory Graph or Instruments, observe live bytes rising even though references are linear (no cycle).",
            "Switch to **Fixed** and repeat: chunk count should stop at six; footprint should plateau.",
            "Articulate when you would choose eviction vs fixing a cycle.",
        ],
        hints: [
            "Retain Cycle Lab: objects keep each other alive—Heap Growth: you simply never release work buffers.",
            "Malloc Stack Logging Lab helps provenance; this lab is about **how much** stays live.",
            "If the UI is frozen but CPU is idle, consider Deadlock Lab instead of this one.",
        ],
        toolRecommendations: [
            "Instruments > Allocations",
            "Xcode Memory Graph (compare with Retain Cycle Lab)",
            "Long-form write-up: Docs/HeapGrowthLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Instruments > Allocations (or Memory Graph) while repeating Run scenario",
            steps: [
                "Run **Broken** five times and capture a memory or allocations snapshot after the last run.",
                "Note rising live bytes / chunk count without a purple cycle in Memory Graph.",
                "Run **Fixed** five times and capture again—verify the cap (six chunks).",
                "Write one sentence: why this is not Retain Cycle Lab.",
                "Plan a real-world policy: max cache size, LRU, or periodic flush.",
            ],
            validationChecklist: [
                "You can explain why footprint grew in Broken mode without claiming a retain cycle.",
                "You can describe how Fixed mode enforces a bound and when that pattern applies in production.",
            ]
        ),
        catalogSortIndex: 10
    )

    /// Phase 2: Classic main-queue self-deadlock (`dispatch_sync` main from main).
    private static let deadlockLab = LabScenario(
        id: "deadlock",
        title: "Deadlock Lab",
        summary: "Reproduce a textbook main-thread deadlock with `DispatchQueue.main.sync` from the main thread, then contrast with safe main-actor work.",
        category: .hang,
        difficulty: .intermediate,
        learningGoals: [
            "Recognize self-deadlock when a queue waits on itself",
            "Pause the debugger during a freeze and read thread wait states",
            "Separate deadlock (waiting) from Hang Lab’s busy main-thread CPU work",
        ],
        reproductionSteps: [
            "Launch SignalLab **from Xcode** with the debugger attached.",
            "Open Deadlock Lab, select **Fixed**, tap **Run scenario** once—should complete immediately.",
            "Read the warning, then select **Broken** and tap **Run scenario**—the UI should freeze permanently.",
            "Use Xcode’s pause control: main thread is blocked in `dispatch_sync` waiting on work that cannot run.",
            "Force-quit or stop the run, then stay on **Fixed** for normal exploration.",
        ],
        hints: [
            "Hang Lab: main thread is **busy**—Deadlock Lab: main thread is **waiting** on itself.",
            "Never call `sync` onto a queue you are already executing on.",
            "Broken mode is intentionally destructive—do not use it in UI tests or screenshots that tap Run.",
        ],
        toolRecommendations: [
            "Debug navigator thread stacks",
            "Pause / continue in Xcode",
            "Long-form write-up: Docs/DeadlockLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Xcode debugger pause while the UI is frozen under Broken mode",
            steps: [
                "Confirm **Fixed** runs complete—baseline that the button wiring works.",
                "Switch to **Broken**, run once, then pause—the main thread should be stuck in sync machinery.",
                "Contrast with Hang Lab: there you often see heavy frames on the main stack; here you see waiting.",
                "In your own code, search for `sync` onto `.main` from contexts that might already be main.",
                "Prefer `async`, structured concurrency, or inline work instead of main-on-main sync.",
            ],
            validationChecklist: [
                "You can state in one sentence why `main.sync` from main deadlocks.",
                "You can tell this symptom apart from Hang Lab’s CPU-bound freeze.",
            ]
        ),
        catalogSortIndex: 11
    )

    /// Phase 2: Posting work that touches UI expectations from a background context.
    private static let backgroundThreadUILab = LabScenario(
        id: "background_thread_ui",
        title: "Background Thread UI Lab",
        summary: "See why UI-facing callbacks should run on the main actor: Broken posts a notification from a detached task; Fixed posts after a MainActor hop.",
        category: .hang,
        difficulty: .intermediate,
        learningGoals: [
            "Relate notification delivery threads to SwiftUI state updates",
            "Recognize Xcode warnings about publishing or updating UI off the main thread",
            "Prefer MainActor/async patterns when forwarding events to UI",
        ],
        reproductionSteps: [
            "Open this lab and keep the Xcode console visible.",
            "Run **Fixed** once—note the last observed ping updates without threading complaints.",
            "Run **Broken** once—watch for runtime diagnostics about background-thread updates.",
            "Compare the runner’s status text: Fixed explicitly hops to MainActor before posting.",
            "In your apps, audit `NotificationCenter`, callbacks, and delegates that mutate UI.",
        ],
        hints: [
            "Hang Lab is CPU work on main; this lab is **which thread** delivers UI mutations.",
            "Combine/async sequences have similar rules—end on MainActor before touching `@State`.",
            "Deadlock Lab is about waiting; this lab is about crossing thread boundaries safely.",
        ],
        toolRecommendations: [
            "Xcode console + runtime issues",
            "Main actor / Swift concurrency docs",
            "Long-form write-up: Docs/BackgroundThreadUILabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Xcode console while toggling Broken vs Fixed",
            steps: [
                "Run **Fixed** and confirm pings land cleanly.",
                "Run **Broken** and capture any threading warning text verbatim.",
                "Trace from `Task.detached` to `onReceive` in your mental model.",
                "Refactor one real callback to `await MainActor.run` or `@MainActor` isolation.",
                "Re-test until warnings disappear for that path.",
            ],
            validationChecklist: [
                "You can explain why posting from a detached task is risky for SwiftUI state.",
                "You can describe the fix pattern (main-queue / MainActor delivery) in one sentence.",
            ]
        ),
        catalogSortIndex: 12
    )

    /// Phase 2: Synchronous file I/O blocking the main thread vs detached load.
    private static let mainThreadIOLab = LabScenario(
        id: "main_thread_io",
        title: "Main Thread I/O Lab",
        summary: "Contrast repeated synchronous `Data(contentsOf:)` on the main thread with an off-main read—same bytes, different responsiveness story than Hang Lab’s pure CPU work.",
        category: .hang,
        difficulty: .intermediate,
        learningGoals: [
            "Spot main-thread disk reads as responsiveness bugs",
            "Use scroll probes while Fixed mode loads asynchronously",
            "Choose async I/O or background queues before optimizing algorithms",
        ],
        reproductionSteps: [
            "Open Main Thread I/O Lab with **Fixed**, tap **Run scenario**, scroll the chips during the read—it should stay fluid.",
            "Switch to **Broken**, tap **Run scenario**—the UI should hitch while ten synchronous reads complete.",
            "Open Time Profiler or compare main-thread stacks: Broken shows I/O frames; Hang Lab shows compute.",
            "Return to **Fixed** for day-to-day exploration.",
        ],
        hints: [
            "Network on main is the same class of bug—this lab uses a local file to stay deterministic offline.",
            "CPU Hotspot Lab is about hot **compute**; this lab is about **waiting on storage**.",
            "If the app is deadlocked, use Deadlock Lab—not this one.",
        ],
        toolRecommendations: [
            "Instruments > Time Profiler",
            "Main thread track / hang diagnostics in Xcode",
            "Long-form write-up: Docs/MainThreadIOLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Interactive scroll during Fixed vs Broken runs",
            steps: [
                "Baseline **Fixed**: run, scroll probes, confirm read completes.",
                "Run **Broken** and feel the hitch; pause debugger to see main in file read.",
                "Estimate how many synchronous reads your real feature does per gesture.",
                "Move loads to `Task.detached`, `URLSession`, or async file APIs as appropriate.",
                "Validate with the same Instruments pass you used for Broken.",
            ],
            validationChecklist: [
                "You can separate I/O wait from CPU burn on the main thread.",
                "You can point to the API you would change first in a production codebase.",
            ]
        ),
        catalogSortIndex: 13
    )
}
