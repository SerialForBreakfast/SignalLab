//
//  LabCatalog.swift
//  SignalLab
//
//  Static registry of MVP labs; scenario implementations are wired in later milestones.
//

import Foundation

/// Central list of all labs shipped in the MVP shell.
enum LabCatalog {
    /// All MVP scenarios in curriculum order.
    static let scenarios: [LabScenario] = [
        crashLab,
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
        summary: "Practice exception breakpoints and stack navigation using a malformed local JSON import.",
        category: .crash,
        difficulty: .beginner,
        learningGoals: [
            "Add and use an exception breakpoint",
            "Inspect the crashing frame and its callers",
            "Identify the unsafe assumption in parsing",
        ],
        reproductionSteps: [
            "On this screen, select Broken mode (tap Reset if you want the default lab state).",
            "Tap Run scenario to import `crash_import_sample.json` (bundled with the app).",
            "The second row omits `count`; the unsafe parser stops the process—debug with an exception breakpoint.",
            "Switch to Fixed mode and tap Run scenario again to see validation skip the bad row.",
        ],
        hints: [
            "The crash line is not always the full story—look at caller frames.",
            "The broken path assumes every dictionary contains an integer `count`.",
        ],
        toolRecommendations: [
            "Xcode exception breakpoint",
            "Debug navigator stack frames",
            "Variables view / lldb locals",
            "Long-form write-up: Docs/CrashLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Xcode Exception Breakpoint",
            steps: [
                "In the Breakpoint navigator, add an Exception Breakpoint (Swift and Objective-C exceptions).",
                "Build and run from Xcode, navigate to this Crash Lab screen, keep Broken mode, then tap Run scenario.",
                "When execution stops, inspect the top frame: note the force cast or unwrap on the JSON dictionary.",
                "Open the debug navigator and walk to the caller that feeds rows into the parser.",
                "Switch to Fixed mode and tap Run scenario again: confirm the malformed row is skipped with a clear message.",
            ],
            validationChecklist: [
                "You can name the incorrect assumption in the parser.",
                "You can explain why Fixed mode avoids the trap and still imports valid rows.",
            ]
        ),
        catalogSortIndex: 0
    )

    private static let breakpointLab = LabScenario(
        id: "breakpoint",
        title: "Breakpoint Lab",
        summary: "Use line, conditional, and action breakpoints to chase a non-crashing filter bug.",
        category: .breakpoint,
        difficulty: .beginner,
        learningGoals: [
            "Inspect incorrect state with breakpoints",
            "Reduce noise using conditions",
            "Log values without stopping every time",
        ],
        reproductionSteps: [
            "On this screen, keep Broken mode (tap Reset if you want the default lab state).",
            "Choose Electronics in Category, type Swift in Search, then tap Run scenario.",
            "Broken mode lists every electronics row because the name query is skipped once a category is set.",
            "Switch to Fixed mode with the same inputs and tap Run scenario again—no rows should match.",
            "Set a breakpoint in BreakpointLabFilter.applyCatalogFilter to inspect predicates.",
        ],
        hints: [
            "All filtering runs through BreakpointLabFilter.applyCatalogFilter(items:normalizedQuery:category:mode:).",
            "A conditional breakpoint on selectedCategory != nil reduces noise.",
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
                "Reproduce: category Electronics + query Swift + Run in Broken mode (several results).",
                "Add a line breakpoint at the start of applyCatalogFilter; inspect normalizedQuery and category.",
                "Step through Broken vs Fixed branches and note which predicate is dropped.",
                "Optional: convert to a conditional breakpoint so you only stop when a category is active.",
                "Switch to Fixed mode and confirm both category and name constraints apply.",
            ],
            validationChecklist: [
                "You can name the branch that ignores the search text in Broken mode.",
                "You can explain how Fixed mode combines category and name filters.",
            ]
        ),
        catalogSortIndex: 1
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
                "You can explain why the timer keeps the detail object alive in Broken mode.",
                "You can explain what Fixed mode does so the object can deallocate.",
            ]
        ),
        catalogSortIndex: 2
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
                "You can name the synchronous work running on the main thread in Broken mode.",
                "You can explain how Fixed mode moves CPU work off the main actor.",
            ]
        ),
        catalogSortIndex: 3
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
        ],
        toolRecommendations: [
            "Instruments Time Profiler",
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
                "You can name the primary redundant work in Broken mode.",
                "You can see a leaner hot path in Fixed mode.",
            ]
        ),
        catalogSortIndex: 4
    )
}
