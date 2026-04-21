//
//  LabCatalog.swift
//  SignalLab
//
//  Static registry of MVP labs; scenario implementations are wired in later milestones.
//

import Foundation

/// Central list of all labs in the catalog (MVP + diagnostics + Phase 2).
///
/// Keep reproduction and investigation copy aligned with `Docs/Labs.md`. Shared Xcode UI vocabulary lives in `Docs/XcodeToolingCheatSheet.md` in the repository.
enum LabCatalog {
    /// All MVP scenarios in **locked curriculum order** (`Docs/LabRefinement.md` task 1):
    /// Crash → … → CPU Hotspot → post-MVP diagnostics → Phase 2 (… → Main Thread I/O → Scroll Hitch → Startup Signpost → Concurrency Isolation).
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
        scrollHitchLab,
        startupSignpostLab,
        concurrencyIsolationLab,
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
        summary: "Your first crash. A JSON import terminates the app because count arrived as the text \"three\" instead of an integer. Learn the three things Xcode shows when an app crashes, then use one caller-frame jump to reveal the payload that caused it.",
        category: .crash,
        difficulty: .beginner,
        learningGoals: [
            "Recognize the three things Xcode shows when an app crashes: highlighted line, console message, and call stack",
            "Use the console message to name the bad field and wrong type before reading more code",
            "Move up one useful caller frame and find readable locals like brokenCountText and brokenJSONText",
        ],
        reproductionSteps: [
            "Run SignalLab from Xcode (⌘R) so the debugger attaches.",
            "Tap Run scenario.",
            "The app crashes. Xcode stops and shows three things — read each one before doing anything else:",
            "① The highlighted line in the source editor — this is where execution stopped. It’s the strict decode line inside CrashImportParser that assumed the JSON was safe to decode.",
            "② The console message at the bottom — find the text that says \"Expected to decode Int but found a string instead.\" That sentence explains the entire crash.",
            "③ The call stack on the left — click the CrashImportParser frame even if Xcode truncates the name. Then move up one caller frame to runBrokenImport() and inspect the locals.",
            "In Variables, look for brokenCountText and brokenJSONText in that caller frame. Confirm brokenCountText is \"three\" and brokenJSONText shows the malformed row.",
        ],
        hints: [
            "Start with the console message — it usually explains the crash in plain English before you read a single line of code.",
            "The CrashImportParser frame may look truncated in Xcode; it is still your code and still the right first frame to click.",
            "Going up one caller frame is useful here because runBrokenImport() exposes readable locals: brokenCountText and brokenJSONText.",
            "Crash Lab is intentionally broken-only. The goal is to learn what Xcode shows you after a crash, not to compare implementations yet.",
        ],
        toolRecommendations: [
            "Console output — read the crash message first",
            "Source editor — the highlighted line shows where execution stopped",
            "Call stack — click CrashImportParser, then move up one caller frame to inspect brokenCountText and brokenJSONText",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/CrashLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: false,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Console message — read it first, then use one caller-frame jump to reveal brokenCountText and brokenJSONText",
            steps: [
                "Run from Xcode, open Crash Lab, tap Run scenario.",
                "When Xcode stops: read the highlighted line in the source editor. This is where the strict decode failed.",
                "Read the console message. Find \"Expected to decode Int but found a string instead.\" — the runtime is telling you the bug.",
                "In the call stack, click the CrashImportParser frame even if the label is truncated in Xcode.",
                "Move up one caller frame to runBrokenImport() and inspect brokenCountText plus brokenJSONText in Variables; confirm the second row shows \"count\": \"three\".",
            ],
            validationChecklist: [
                "You can name the three things Xcode shows when an app crashes.",
                "You can quote the console message that described the type mismatch.",
                "You can point to brokenCountText or brokenJSONText in the caller frame and show the broken value \"three\".",
                "You can explain why moving up one caller frame was useful in this crash.",
            ]
        ),
        catalogSortIndex: 0
    )

    private static let exceptionBreakpointLab = LabScenario(
        id: "break_on_failure",
        title: "Exception Breakpoint Lab",
        summary: "Reveal a caught Objective-C exception that the app normally hides behind a vague recovered failure message.",
        category: .crash,
        difficulty: .beginner,
        learningGoals: [
            "Recognize when the app catches an exception and hides the original cause",
            "Use an Exception Breakpoint to stop before the catch path erases the useful context",
            "Know when to try the tool: a vague recovered failure that does not name the concrete bad value",
            "Read the raise-site locals that explain the vague user-visible failure",
        ],
        reproductionSteps: [
            "Run SignalLab from Xcode and open this lab. Do not add an Exception Breakpoint yet.",
            "Pass 1: Tap Run scenario. The app keeps running and only reports: Selection failed. The app recovered, but hid the table and row details.",
            "Pass 2: In the Breakpoint navigator, add an Exception Breakpoint, then run the same scenario again.",
            "When Xcode stops, ignore objc_exception_throw and select the first app frame: ExceptionBreakpointLabTriggerInvalidSelectionException.",
            "In Variables, read brokenTableName, brokenRowID, and exceptionReason. Those locals are the useful context the app-level message hid.",
        ],
        hints: [
            "This lab is about hidden exceptions, not line breakpoints for ordinary logic bugs.",
            "Crash Lab teaches what to do when Xcode already stops. This lab teaches how to stop when the app catches the exception and keeps going.",
            "The catch is intentional: it simulates a recovery layer that prevents a crash but drops the table and row details you need to diagnose the issue.",
            "The normal run should feel unsatisfying on purpose: the app only says selection failed.",
            "Use an Exception Breakpoint as a quick hypothesis test when a generic failure may have started as a thrown Objective-C exception.",
            "The useful evidence is the raise frame with brokenTableName, brokenRowID, and exceptionReason.",
        ],
        toolRecommendations: [
            "Breakpoint navigator",
            "Xcode Exception Breakpoint",
            "Debug navigator stack + Variables view for brokenTableName, brokenRowID, and exceptionReason",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/ExceptionBreakpointLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: false,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Exception Breakpoint after observing the vague recovered failure",
            steps: [
                "Run this lab once without adding a breakpoint. Confirm the app keeps running and shows only a generic recovered failure.",
                "Ask the tool-selection question: was there an exception before this generic failure message?",
                "Add an Exception Breakpoint from the Breakpoint navigator.",
                "Run the same scenario again. When Xcode stops, select ExceptionBreakpointLabTriggerInvalidSelectionException if objc_exception_throw is selected first.",
                "Read brokenTableName, brokenRowID, and exceptionReason. Explain how those locals reveal the cause that the app message hid.",
            ],
            validationChecklist: [
                "You're done when you can explain why the no-breakpoint run gave too little information.",
                "You can support the exception breakpoint's value with the hidden raise frame and the first Objective-C locals you saw there.",
            ]
        ),
        catalogSortIndex: 1
    )

    private static let breakpointLab = LabScenario(
        id: "breakpoint",
        title: "Breakpoint Lab",
        summary: "Use one line breakpoint to diagnose a wrong discount calculation while the app keeps running.",
        category: .breakpoint,
        difficulty: .beginner,
        learningGoals: [
            "Use a line breakpoint when the app keeps running but produces a wrong result",
            "Inspect local variables at the paused line before changing code",
            "Explain the bad result from the calculation input discountPercent",
        ],
        reproductionSteps: [
            "Run SignalLab from Xcode and open Breakpoint Lab.",
            "Tap Run scenario and observe that the student order receives only 5% off.",
            "Open BreakpointLabDiscountCalculator.swift.",
            "Add one plain line breakpoint on the first line inside total(afterDiscountPercent:subtotal:).",
            "Tap Run scenario again.",
            "When Xcode pauses, inspect discountPercent and subtotal in the Variables view.",
            "Explain why the final total is $114.00 instead of $96.00.",
        ],
        hints: [
            "This is not a crash. The app keeps running, so Xcode will not stop unless you add a breakpoint.",
            "Start with one plain line breakpoint. Do not add a condition yet.",
            "The useful evidence is in the paused frame's local variables.",
            "The value to question is discountPercent.",
            "Conditional and log breakpoints are refinements after the first stop is already useful.",
        ],
        toolRecommendations: [
            "Xcode line breakpoint",
            "Debug bar: Continue and Step Over",
            "Variables view",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/BreakpointLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: false,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Line breakpoint in BreakpointLabDiscountCalculator.total(afterDiscountPercent:subtotal:)",
            steps: [
                "Run once without a breakpoint and observe the wrong total.",
                "Add one line breakpoint on the first line inside total(afterDiscountPercent:subtotal:).",
                "Run again and wait for Xcode to pause.",
                "Read discountPercent and subtotal in the paused frame.",
                "Confirm that discountPercent is 5 even though the student order expects 20.",
                "Step over once to see discountMultiplier become 0.95 and drive the wrong final total.",
            ],
            validationChecklist: [
                "You can explain why this bug needs a breakpoint instead of a crash workflow.",
                "You can point to discountPercent as the value that makes the total wrong.",
                "You can explain the wrong total without using conditional breakpoints, log breakpoints, or Fixed mode.",
            ]
        ),
        catalogSortIndex: 2
    )

    private static let retainCycleLab = LabScenario(
        id: "retain_cycle",
        title: "Retain Cycle Lab",
        summary: "A session stores a completion handler that captures itself strongly. The live counter is your first evidence — then Memory Graph shows you exactly why the session cannot deallocate.",
        category: .memory,
        difficulty: .intermediate,
        learningGoals: [
            "Read a live object counter as the first evidence of a leak — before opening any Xcode tool",
            "Use Memory Graph to find the retaining path: RetainCycleLabSession → completionHandler → RetainCycleLabSession",
            "Identify [self] vs [weak self] as the one token that creates or breaks the cycle",
        ],
        reproductionSteps: [
            "Stay in Broken mode. Tap Run scenario to open the session sheet, then Close. Repeat three times.",
            "Watch the Live detail sessions counter — it should read 3, not 0. Each dismissed session is still alive. That number is your first evidence.",
            "In Xcode, open Memory Graph: click the three-circle icon in the debug bar, or use Debug → View Memory Graph Hierarchy.",
            "In the Memory Graph filter field, type RetainCycleLabSession. You will see one node per leaked session.",
            "Click one node and expand its retaining path. You will see: RetainCycleLabSession → completionHandler (block) → RetainCycleLabSession. Your type is on both ends.",
            "In source, open RetainCycleLabSession.swift and find the Broken branch: `completionHandler = { self.handleCompletion() }`. The unqualified self is the strong capture.",
            "Switch to Fixed mode. Open and close once. The counter drops — the session deallocated because [weak self] broke the cycle.",
        ],
        hints: [
            "The counter is your first tool — if it does not climb in Broken mode, nothing else in this lab will work as expected.",
            "In Memory Graph, your type appears on both ends of the retaining path. That is the definition of a retain cycle.",
            "The entire fix is one token: change self to [weak self] in the closure capture list.",
            "A dismissed screen staying alive without freezing the UI is the memory leak pattern — if the UI freezes instead, that is Hang Lab.",
        ],
        toolRecommendations: [
            "Live detail sessions counter — first evidence, no Xcode tools needed",
            "Xcode Memory Graph — filter for RetainCycleLabSession, read the two-node retaining path",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/RetainCycleLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Live detail sessions counter — read this before opening Memory Graph",
            steps: [
                "In Broken mode, open and close the session sheet three times. Confirm the counter reads 3.",
                "Open Memory Graph (debug bar icon or Debug menu). Type RetainCycleLabSession in the filter field.",
                "Click one live instance. Read the retaining path: RetainCycleLabSession → completionHandler → RetainCycleLabSession. Both ends are your type.",
                "Open RetainCycleLabSession.swift, Broken branch: `completionHandler = { self.handleCompletion() }`. That unqualified self is the strong capture creating the cycle.",
                "Switch to Fixed mode, open and close once. Confirm the counter drops and Memory Graph shows no leaked instances.",
            ],
            validationChecklist: [
                "You can point to the exact token (self in the Broken branch) that creates the cycle.",
                "You can describe the retaining path in one sentence: the session's completionHandler captures the session, so the session keeps itself alive.",
                "You can explain what [weak self] does differently and why Fixed mode lets the session deallocate.",
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
            "Tap Run scenario, then immediately try to scroll the horizontal \"Scroll probe\" chips—they should stay frozen until processing finishes. Also notice the progress spinner never appears: the main thread was blocked before the UI could paint a single frame.",
            "Tap Run scenario again and quickly click Pause in the debug bar while the UI is frozen. In the debug navigator, select the main thread and find HangLabWorkload.simulateReportProcessing in the stack — that is the work blocking the run loop.",
            "Switch to Fixed mode, tap Run scenario again, and scroll during processing — the chips stay draggable and the spinner appears this time.",
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
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/HangLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Debugger pause while scrolling fails in Broken mode",
            steps: [
                "In Broken mode, tap Run and attempt to scroll the probe row during the stall.",
                "Pause the debugger; in the debug navigator, select the main thread and scan its stack frames for simulateReportProcessing or HangLabWorkload.",
                "Note that the same function runs in Fixed mode but from a detached task (off the main queue).",
                "Continue and compare how quickly the UI accepts gestures after each mode.",
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
            "To profile: Product → Profile (⌘I), choose Time Profiler, record while typing in Broken mode, then sort the call tree by Self time and look for `applyBroken`, `sorted`, and `DateFormatter.init`.",
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
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/CPUHotspotLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Instruments Time Profiler — record while typing in the search field",
            steps: [
                "In Broken mode, type a query and confirm the UI is sluggish but still responds to gestures.",
                "Profile with Instruments → Time Profiler; record while typing the same query several times.",
                "Sort by Self time and locate `CPUHotspotLabSearch.applyBroken` or the `sorted` and `DateFormatter.init` symbols.",
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
            "Watch the Issue navigator or the debug console for a Thread Performance Checker warning tied to main-queue work.",
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
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
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
        summary: "Turn an ambiguous memory crash into a clear \"message sent to zombie / deallocated instance\" diagnosis using Xcode’s Zombie Objects diagnostic.",
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
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
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
                "You can state one way the symptom differs from Retain Cycle Lab’s \"still alive\" story.",
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
            "Read the sanitizer report: which address or variable, which two threads, and which stack frames implicate your code.",
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
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
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
        summary: "When you need \"where was this allocated?\" not just \"what is alive now,\" enable Malloc Stack Logging and read allocation backtraces.",
        category: .memory,
        difficulty: .intermediate,
        learningGoals: [
            "Enable Malloc Stack Logging (or equivalent scheme memory diagnostics) for a suspicious allocation",
            "Recover stack traces that show which code path created an object or buffer",
            "Place this tool after Zombies and Retain Cycle—you are doing provenance, not first-pass leaks",
        ],
        reproductionSteps: [
            "Confirm you already know Memory Graph / leaks basics from Retain Cycle Lab and when Zombies help from Zombie Objects Lab.",
            "In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics → enable Malloc Stack Logging (options may include \"Malloc Stack\" or similar by version).",
            "Run **Broken** here—each tap allocates thousands of fresh row arrays; use Instruments → Allocations (or your guide’s lldb path) to see the allocating stacks.",
            "Run **Fixed** twice: first run warms a reusable buffer; second run should show `0` fresh row arrays in the footer.",
            "Turn logging off when finished—this diagnostic is heavy on overhead and disk.",
        ],
        hints: [
            "This is forensic: use when \"who created this?\" matters, not as a default leak sweep.",
            "Zombies answer \"you messaged the dead\"; malloc stacks answer \"who birthed this bytes\".",
            "Retain Cycle Lab shows who still holds live references—different question from creation-site history.",
        ],
        toolRecommendations: [
            "Xcode scheme → Run → Diagnostics → Malloc Stack Logging",
            "Instruments Allocations / lldb malloc_history (as appropriate to your Xcode version)",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
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
            "In Xcode Memory Graph or Instruments → Allocations, observe live bytes rising even though references are linear (no cycle).",
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
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
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
            "Click Pause in the debug bar: the main thread stack should show dispatch_sync / queue wait rather than heavy app compute.",
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
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
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
            "Open this lab and keep the debug console visible.",
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
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
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
            "Product → Profile → Time Profiler, or Pause the debugger in Broken mode and inspect the main thread stack: Broken shows file-read / I/O frames; Hang Lab shows compute-heavy frames.",
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
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/MainThreadIOLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Interactive scroll during Fixed vs Broken runs",
            steps: [
                "Baseline **Fixed**: run, scroll probes, confirm read completes.",
                "Run **Broken** and feel the hitch; Pause and inspect the main thread stack for synchronous file read APIs.",
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

    /// Phase 2: Scroll jank from expensive per-row SwiftUI chrome vs lighter effects.
    private static let scrollHitchLab = LabScenario(
        id: "scroll_hitch",
        title: "Scroll Hitch Lab",
        summary: "Auto-scroll a long list: Broken stacks compositing + heavy shadows per row; Fixed keeps scrolling smooth enough to profile frame pacing.",
        category: .performance,
        difficulty: .intermediate,
        learningGoals: [
            "Relate scroll hitches to per-row rendering cost, not just CPU algorithms",
            "Use Instruments Core Animation or frame pacing views alongside Time Profiler",
            "Contrast this lab with CPU Hotspot Lab’s keystroke-bound hotspots",
        ],
        reproductionSteps: [
            "Open Scroll Hitch Lab and select **Fixed**, tap **Run scenario**, watch the vertical list auto-scroll.",
            "While it scrolls, drag the horizontal \"Probe\" chips—they should stay reasonably responsive.",
            "Switch to **Broken**, tap **Run scenario** again; the same auto-scroll should feel rougher and probes may stutter.",
            "Profile with Instruments > Core Animation or the scrolling instrument your Xcode version provides; compare frame times.",
        ],
        hints: [
            "Broken uses `.compositingGroup()` plus a large shadow on every row—each row becomes an expensive offscreen pass.",
            "CPU Hotspot Lab stays responsive but slow; this lab targets frame drops during scroll.",
            "Hang Lab is a full stop; here the scroll usually continues but unevenly.",
        ],
        toolRecommendations: [
            "Instruments > Core Animation (or scrolling / frame pacing template for your Xcode version)",
            "Instruments > Time Profiler (supporting)",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/ScrollHitchLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Instruments while auto-scrolling the vertical list",
            steps: [
                "Baseline **Fixed**: run once, note how the horizontal probes feel during auto-scroll.",
                "Switch to **Broken**, run again, and capture a short Instruments trace covering the scroll.",
                "Look for elevated frame time or compositing cost while rows with heavy shadows are on screen.",
                "Compare the SwiftUI row chrome described in the runner vs Fixed’s lighter modifiers.",
                "In your own lists, audit `.drawingGroup()`, `.compositingGroup()`, and stacked shadows inside `Lazy` stacks.",
            ],
            validationChecklist: [
                "You can explain one visual effect in Broken mode that makes scrolling more expensive.",
                "You can state how this symptom differs from CPU Hotspot Lab and Hang Lab.",
            ]
        ),
        catalogSortIndex: 14
    )

    /// Phase 2: Same main-thread startup-style phases with vs without `os_signpost` for POI.
    private static let startupSignpostLab = LabScenario(
        id: "startup_signpost",
        title: "Startup Signpost Lab",
        summary: "Simulate blocking launch phases on the main thread: Broken omits signposts; Fixed emits `os_signpost` intervals for Instruments Points of Interest.",
        category: .performance,
        difficulty: .intermediate,
        learningGoals: [
            "Record `os_signpost` intervals in Instruments > Points of Interest",
            "Read cold/warm startup stories as named phases, not one anonymous main-thread blob",
            "Keep checksum parity between Broken and Fixed to prove the work is the same",
        ],
        reproductionSteps: [
            "From Xcode, choose Product → Profile (⌘I) and pick **Points of Interest** (or a template that surfaces POI signposts).",
            "Open Startup Signpost Lab, select **Fixed**, tap **Run scenario** while recording—expect three named intervals.",
            "Switch to **Broken**, record again—the CPU time should be similar but POI lanes stay unstructured.",
            "Compare checksums in the footer; both modes should report the same value for the same run number.",
        ],
        hints: [
            "Signposts annotate work you already do—they are not a substitute for moving work off the main thread.",
            "Category `PointsOfInterest` on the `OSLog` is what makes intervals show up in the POI instrument.",
            "Malloc Stack Logging answers \"who allocated this?\"; signposts answer \"what phase was running now?\"",
        ],
        toolRecommendations: [
            "Instruments > Points of Interest",
            "Instruments > Time Profiler",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/StartupSignpostLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Instruments > Points of Interest while running Fixed mode",
            steps: [
                "Profile **Fixed** and tap **Run scenario** once per recording.",
                "Identify `SignalLabStartupConfig`, `SignalLabStartupAssets`, and `SignalLabStartupReady` intervals.",
                "Profile **Broken** with the same gesture and note the missing structured intervals.",
                "Confirm matching checksums between modes for the same invocation count.",
                "Add a named signpost around your own app’s heaviest launch closure before optimizing blindly.",
            ],
            validationChecklist: [
                "You can name the three signposted phases and what each represents in this lab.",
                "You can explain why checksums match even when signposts differ.",
            ]
        ),
        catalogSortIndex: 15
    )

    /// Phase 2: Unstructured `Task.detached` ordering vs sequential async work (not the TSan story).
    private static let concurrencyIsolationLab = LabScenario(
        id: "concurrency_isolation",
        title: "Concurrency Isolation Lab",
        summary: "Broken races two detached tasks that log completion order; Fixed runs the same labels sequentially—surface Xcode concurrency issues before Thread Sanitizer.",
        category: .hang,
        difficulty: .intermediate,
        learningGoals: [
            "Separate flaky ordering from data races on shared memory",
            "Read Xcode’s Sendable and isolation warnings as a first-line tool",
            "Prefer structured `async`/`await` when completion order must be deterministic",
        ],
        reproductionSteps: [
            "Open Concurrency Isolation Lab, choose **Broken**, tap **Run scenario** and read the completion log.",
            "Tap **Run scenario** again—`alpha` and `beta` may appear in a different order than the previous run.",
            "Open the Issue navigator and the build log for Sendable / isolation warnings involving the lab’s non-Sendable token.",
            "Switch to **Fixed**, run twice—the log should always read `alpha, beta`.",
            "Contrast with Thread Sanitizer Lab: there two threads mutate one counter without a lock.",
        ],
        hints: [
            "If the bug is \"sometimes A runs before B,\" structured concurrency is often the fix—not TSan.",
            "Thread Sanitizer Lab is for unsynchronized memory access; this lab is for task lifecycle and ordering.",
            "Background Thread UI Lab is about main-actor UI delivery; this lab is about how many detached tasks you launched.",
        ],
        toolRecommendations: [
            "Xcode Issue navigator (Swift concurrency / Sendable)",
            "Swift Structured Concurrency documentation",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/ConcurrencyIsolationLabInvestigationGuide.md (in the repo)",
        ],
        supportsBrokenMode: true,
        supportsFixedMode: true,
        investigationGuide: InvestigationGuide(
            recommendedFirstTool: "Xcode Issue navigator + repeated Broken runs",
            steps: [
                "Run **Broken** three times and screenshot or note the three completion-order strings.",
                "Search warnings for capturing a non-Sendable type inside `Task.detached`.",
                "Run **Fixed** and confirm deterministic `alpha` then `beta`.",
                "Write one sentence: when you would still enable Thread Sanitizer after fixing ordering.",
                "Refactor one real feature from double-`detached` fire-and-forget to a single `async` function.",
            ],
            validationChecklist: [
                "You can explain why completion order changed across Broken runs.",
                "You can state why Thread Sanitizer Lab is not the first tool for that symptom.",
            ]
        ),
        catalogSortIndex: 16
    )
}
