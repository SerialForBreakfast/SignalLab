//
//  LabCatalog.swift
//  SignalLab
//
//  Static registry of MVP labs; scenario implementations are wired in later milestones.
//

import Foundation

/// Central list of all labs shipped in the MVP shell.
enum LabCatalog {
    /// All MVP scenarios in **locked curriculum order** (`Docs/LabRefinement.md` task 1):
    /// Crash → Exception Breakpoint → Breakpoint → Retain Cycle → Hang → CPU Hotspot.
    /// Keep `catalogSortIndex` aligned with this array when adding or reordering labs.
    static let scenarios: [LabScenario] = [
        crashLab,
        exceptionBreakpointLab,
        breakpointLab,
        retainCycleLab,
        hangLab,
        cpuHotspotLab,
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
        summary: "Profile sluggish search to find repeated expensive work and unnecessary sorting.",
        category: .performance,
        difficulty: .intermediate,
        learningGoals: [
            "Profile an interaction with Time Profiler",
            "Identify hottest functions in the trace",
            "Separate app hotspots from framework noise",
        ],
        reproductionSteps: [
            "On this screen, use the searchable list once it ships in a later milestone.",
            "Type or search to trigger Broken-mode slowness.",
            "Profile the same interaction after switching to Fixed mode.",
        ],
        hints: [
            "Look for repeated allocation or sorting on each keystroke.",
            "Focus on your code before chasing system libraries.",
            "If the UI fully freezes and gestures stop, that is Hang Lab rather than CPU Hotspot Lab.",
        ],
        toolRecommendations: [
            "Instruments Time Profiler",
            "Long-form write-up: Docs/CPUHotspotLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Instruments Time Profiler",
            steps: [
                "Record a trace while reproducing the sluggish interaction.",
                "Sort by self time and locate your scenario’s hot functions.",
                "Relate hotspots to redundant work called from the search path.",
                "Re-profile Fixed mode to confirm improvement.",
            ],
            validationChecklist: [
                "You're done when you can name the primary redundant work in Broken mode and explain why the interaction feels slow rather than frozen.",
                "You can see a leaner hot path in Fixed mode.",
            ]
        ),
        catalogSortIndex: 5
    )
}
