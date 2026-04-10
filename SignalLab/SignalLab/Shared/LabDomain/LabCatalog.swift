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
            "Open Crash Lab from the catalog.",
            "Select Broken mode (default after Reset).",
            "Tap Run scenario to import `crash_import_sample.json` (bundled with the app).",
            "The second row omits `count`; the unsafe parser stops the process—debug with an exception breakpoint.",
            "Switch to Fixed mode and Run scenario again to see validation skip the bad row.",
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
                "Run the app from Xcode, open Crash Lab, keep Broken mode, tap Run scenario.",
                "When execution stops, inspect the top frame: note the force cast or unwrap on the JSON dictionary.",
                "Open the debug navigator and walk to the caller that feeds rows into the parser.",
                "Switch to Fixed mode and run again: confirm the malformed row is skipped with a clear message.",
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
            "Open Breakpoint Lab and keep Broken mode (default after Reset).",
            "Choose Electronics in Category, type Swift in Search, tap Run scenario.",
            "Broken mode lists every electronics row because the name query is skipped once a category is set.",
            "Switch to Fixed mode with the same inputs and Run again—no rows should match.",
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
        summary: "Explore object lifetime with a detail screen that fails to deallocate in Broken mode.",
        category: .memory,
        difficulty: .intermediate,
        learningGoals: [
            "Reproduce a leak through repeated navigation",
            "Use Memory Graph to inspect ownership",
            "Confirm deallocation after the fix",
        ],
        reproductionSteps: [
            "Open the detail flow once implemented.",
            "Dismiss and repeat several times in Broken mode.",
            "Compare instance counts or lifecycle indicators.",
        ],
        hints: [
            "Timers and stored closures are common retain cycle sources.",
            "Ask who owns whom in the broken configuration.",
        ],
        toolRecommendations: [
            "Xcode Memory Graph",
            "Instruments Leaks",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Xcode Memory Graph",
            steps: [
                "Reproduce repeated presentation/dismissal.",
                "Capture a Memory Graph in Broken mode.",
                "Inspect retaining paths to the leaked object.",
                "Verify Fixed mode allows deallocation.",
            ],
            validationChecklist: [
                "You can describe the ownership chain keeping the object alive.",
                "You can see improved lifetime behavior in Fixed mode.",
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
            "Select Broken mode and trigger the report load once implemented.",
            "Observe UI unresponsiveness during processing.",
            "Repeat in Fixed mode for comparison.",
        ],
        hints: [
            "If the UI cannot scroll, suspect main-thread work.",
            "Thread stacks tell you what the main queue is doing.",
        ],
        toolRecommendations: [
            "Pause in the debugger",
            "Debug navigator threads",
            "Instruments Time Profiler (supporting)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Debugger pause during the freeze",
            steps: [
                "Trigger the hang in Broken mode.",
                "While frozen, pause execution.",
                "Inspect the main thread stack for heavy parsing or transformation.",
                "Compare responsiveness in Fixed mode.",
            ],
            validationChecklist: [
                "You can name the work running on the main thread in Broken mode.",
                "You can explain how Fixed mode restores responsiveness.",
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
            "Use the searchable list once implemented.",
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
