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
        memoryGraphLab,
        hangLab,
        cpuHotspotLab,
        threadPerformanceCheckerLab,
        zombieObjectsLab,
        threadSanitizerLab,
        mallocStackLoggingLab,
        retainCycleLab,
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
        investigationGuide: InvestigationGuide(
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
            "Pass 2: In the Breakpoint navigator (+), add an Exception Breakpoint. In the configuration sheet, confirm Exception is set to **Objective-C** (not Swift Error). Then Build & Run the same scenario again.",
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
        investigationGuide: InvestigationGuide(
            steps: [
                "Run this lab once without adding a breakpoint. Confirm the app keeps running and shows only a generic recovered failure.",
                "Ask the tool-selection question: was there an exception before this generic failure message?",
                "Add an Exception Breakpoint from the Breakpoint navigator. In the sheet that appears, confirm Exception is set to **Objective-C** (not Swift Error) — this lab throws an ObjC exception.",
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
            "Open BreakpointLabDiscountCalculator.swift (use ⌘⇧O → type BreakpointLabDiscount → press Return).",
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
        investigationGuide: InvestigationGuide(
            steps: [
                "Run once without a breakpoint and observe the wrong total.",
                "Add one line breakpoint on the first line inside total(afterDiscountPercent:subtotal:).",
                "Run again and wait for Xcode to pause.",
                "Read discountPercent and subtotal in the paused frame.",
                "Confirm that discountPercent is 5 even though the student order expects 20. Root cause: the caller uses the wrong policy key (\"student\" instead of \"student_discount\"), so the lookup returns nil and falls back to 5%.",
                "Step over once to see discountMultiplier become 0.95 and drive the wrong $114.00 total.",
            ],
            validationChecklist: [
                "You can explain why this bug needs a breakpoint instead of a crash workflow.",
                "You can point to discountPercent as the value that makes the total wrong.",
                "You can explain the wrong total without using conditional or log breakpoints.",
            ]
        ),
        catalogSortIndex: 2
    )

    private static let memoryGraphLab = LabScenario(
        id: "memory_graph",
        title: "Memory Graph Lab",
        summary: "Create one open note, keep it alive, and use Xcode Memory Graph to see which object holds it.",
        category: .memory,
        difficulty: .beginner,
        learningGoals: [
            "Read each Memory Graph arrow as a strong reference that keeps the next object alive",
            "Use the right inspector Backtrace to jump from the retained object to the allocation source line",
            "Explain why the note is still alive without introducing retain-cycle topology yet",
        ],
        reproductionSteps: [
            "Before starting: confirm Malloc Stack Logging is enabled in the Run scheme (Product → Scheme → Edit Scheme → Run → Diagnostics → Memory Management). If you enable it now, Build & Run (⌘R) before continuing.",
            "Run SignalLab from Xcode and open Memory Graph Lab.",
            "Tap Set up lab. The app creates one open note and keeps it in MemoryGraphOpenNoteHolder.",
            "Open Memory Graph with the three-node debug bar button, or use Debug > Debug Workflow > View Memory.",
            "If the left Memory Graph navigator is hidden, show it with Xcode's left sidebar button.",
            "In the left navigator, expand SignalLab, then SignalLab.debug.dylib.",
            "Select MemoryGraphOpenNoteHolder.",
            "Follow the openNote arrow to MemoryGraphOpenNote. Read that arrow as: the holder keeps the note alive.",
            "Select MemoryGraphOpenNote, open the right inspector, and expand Backtrace.",
            "Select the MemoryGraphOpenNote allocation frame and use its jump-to-source button.",
            "Tap Reset, capture Memory Graph again, and confirm openNote no longer points to the note.",
        ],
        hints: [
            "This lab is intentionally not a retain cycle. Learn how to navigate to a live object and read who keeps it alive first.",
            "Use the Memory Graph left navigator. The canvas may initially open on SwiftUI or AttributeGraph objects.",
            "The key target names are MemoryGraphOpenNote and MemoryGraphOpenNoteHolder.",
            "For this lab, an arrow means a strong reference: the object at the tail keeps the object at the arrowhead alive.",
            "If Simulator Memory Graph fails with a LeakAgent / libmalloc initialization error, treat that as an Xcode simulator capture failure, not lab evidence. Use a device capture for this lab when Simulator repeatedly reports this error.",
            "Retain Cycle Lab keeps its existing slug and terminology, but it appears later after this simpler Memory Graph ownership lesson.",
        ],
        toolRecommendations: [
            "Xcode Memory Graph left navigator",
            "Xcode Memory Graph right inspector Backtrace",
            "Backtrace row jump-to-source button: arrow.up.forward.circle",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/MemoryGraphLabInvestigationGuide.md (in the repo)",
        ],
        investigationGuide: InvestigationGuide(
            steps: [
                "Tap Set up lab to create the open note (Malloc Stack Logging must already be enabled — see reproductionSteps).",
                "Open Memory Graph and select MemoryGraphOpenNoteHolder under SignalLab.debug.dylib.",
                "Follow openNote to MemoryGraphOpenNote.",
                "Use the right inspector Backtrace to jump from MemoryGraphOpenNote to the source line that created it.",
                "Tap Reset, capture Memory Graph again, and confirm the holder no longer keeps the note alive.",
            ],
            validationChecklist: [
                "You can read the arrow from MemoryGraphOpenNoteHolder to MemoryGraphOpenNote as a keep-alive reference.",
                "You can use Backtrace to reach the source line that allocated the note.",
                "You can explain what changed after Reset.",
            ]
        ),
        catalogSortIndex: 3
    )

    private static let retainCycleLab = LabScenario(
        id: "retain_cycle",
        title: "Retain Cycle Lab",
        summary: "Use Memory Graph to find a checkout screen that is kept alive by a close-button handler.",
        category: .memory,
        difficulty: .intermediate,
        learningGoals: [
            "Open Memory Graph after the app creates a retained checkout screen",
            "Use the left Memory Graph navigator to select RetainCycleLabCheckoutScreen",
            "Explain the cycle between the checkout screen and its close-button handler",
        ],
        reproductionSteps: [
            "Tap Run scenario once to create the checkout screen example.",
            "In Xcode, open Memory Graph with the debug bar button that looks like three connected nodes, or use Debug > Debug Workflow > View Memory.",
            "If the left Memory Graph navigator is hidden, show it with Xcode's left sidebar button.",
            "In the left navigator, expand SignalLab.debug.dylib and select RetainCycleLabCheckoutScreen.",
            "Confirm it points to RetainCycleLabCloseButtonHandler.",
            "Confirm the close-button handler points back to RetainCycleLabCheckoutScreen.",
        ],
        hints: [
            "The left Memory Graph navigator is the intended path for this lab; the canvas may open on a SwiftUI object first.",
            "Seeing RetainCycleLabCheckoutScreen nested under SignalLab.debug.dylib is expected in this debug build.",
            "If the type list is long, use the Memory Graph search field and type RetainCycleLabCheckoutScreen.",
            "If Memory Graph fails with a LeakAgent / libmalloc initialization error, keep the app running, interact with the lab once more, then try View Memory again. If it repeats, stop and run the app again from Xcode.",
            "Both important boxes are app types: RetainCycleLabCheckoutScreen and RetainCycleLabCloseButtonHandler.",
        ],
        toolRecommendations: [
            "Xcode Memory Graph left navigator",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/RetainCycleLabInvestigationGuide.md (in the repo)",
        ],
        investigationGuide: InvestigationGuide(
            steps: [
                "Tap Run scenario once.",
                "Open Memory Graph with the three-node debug bar button or Debug > Debug Workflow > View Memory.",
                "Show the left Memory Graph navigator if it is hidden.",
                "Expand SignalLab.debug.dylib and select RetainCycleLabCheckoutScreen.",
                "Confirm it points to RetainCycleLabCloseButtonHandler.",
                "Confirm the handler points back to RetainCycleLabCheckoutScreen.",
            ],
            validationChecklist: [
                "You can find the checkout screen from the Memory Graph navigator without relying on the default canvas selection.",
                "You can describe the retaining path in one sentence: checkout screen -> close-button handler -> checkout screen.",
            ]
        ),
        catalogSortIndex: 10
    )

    private static let hangLab = LabScenario(
        id: "hang",
        title: "Hang Lab",
        summary: "See a main-thread freeze from CPU-heavy synchronous work — the classic debugger pause exercise.",
        category: .hang,
        difficulty: .intermediate,
        learningGoals: [
            "Recognize a visible hang",
            "Pause during a freeze and inspect threads",
            "Identify work that must leave the main thread",
        ],
        reproductionSteps: [
            "Tap Run scenario, then immediately try to scroll the horizontal \"Scroll probe\" chips — they stay frozen until processing finishes. The progress spinner never appears either: the main thread was blocked before the UI could paint a single frame.",
            "Tap Run scenario again. The moment the UI freezes, click Pause (⏸) in the Xcode debug bar — you have about 4 seconds.",
            "Xcode opens at frame 0, which is often Swift runtime or system assembly — that is normal. In the debug navigator call stack, scroll down and click the frame labelled HangLabScenarioRunner.trigger() to jump to Swift source. The annotated synchronous call is visible right there.",
        ],
        hints: [
            "Xcode always selects the innermost frame when you pause — that frame is often Swift runtime assembly. Scroll the call stack to HangLabScenarioRunner.trigger() and click it. You land on Thread.sleep(forTimeInterval: 4.0) — the single line blocking the main thread.",
            "Thread.sleep is the starkest form of a main-thread block. The same hang appears from Data(contentsOf:), large JSON decodes, or any other synchronous blocking call on the main thread.",
            "If interaction is merely slow but still responsive, that is CPU Hotspot Lab rather than Hang Lab.",
            "If live-instance counts keep rising after you dismiss a screen but scrolling still works, that is Retain Cycle Lab — not a main-thread hang.",
        ],
        toolRecommendations: [
            "Pause in the debugger",
            "Debug navigator threads",
            "Instruments Time Profiler (supporting)",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/HangLabInvestigationGuide.md (in the repo)",
        ],
        investigationGuide: InvestigationGuide(
            steps: [
                "Tap Run scenario and immediately try to scroll the probe chips — confirm they do not respond during the stall.",
                "Tap Run scenario again. The moment the UI freezes, click Pause (⏸) in the debug bar.",
                "Xcode selects frame 0 automatically — likely Swift runtime assembly. Scroll the call stack and click `HangLabScenarioRunner.trigger()` to jump to Swift source.",
                "You land on `Thread.sleep(forTimeInterval: 4.0)`. Read the comments around it — they explain why any blocking call here starves the run loop.",
                "Confirm the selected thread is Thread 1 (main thread) — that is the run loop thread the hang starves.",
            ],
            validationChecklist: [
                "You can point to `Thread.sleep(forTimeInterval: 4.0)` in `trigger()` and explain why that single line freezes all touches and animations.",
                "You can name two other real-world APIs that would cause the same hang if called from the main thread.",
            ]
        ),
        catalogSortIndex: 4
    )

    private static let cpuHotspotLab = LabScenario(
        id: "cpu_hotspot",
        title: "CPU Hotspot Lab",
        summary: "Search 500 diagnostic events and profile the sluggish keystrokes with Instruments Time Profiler.",
        category: .performance,
        difficulty: .intermediate,
        learningGoals: [
            "Profile a slow-but-responsive interaction with Time Profiler",
            "Identify the hottest functions in the trace by self time",
            "Separate app hotspots (sort, DateFormatter, lowercased) from framework noise",
        ],
        reproductionSteps: [
            "Open CPU Hotspot Lab. Type ‘memory’ or ‘cpu’ in the search field — feel the per-keystroke sluggishness. The UI stays responsive; this is not a freeze.",
            "From Xcode choose Product → Profile (⌘I). Select the Time Profiler template and click Record — this relaunches the app inside Instruments.",
            "In the Instruments-hosted app, navigate to CPU Hotspot Lab and type the same query repeatedly to build up samples. Then click Stop.",
            "In the Call Tree: enable Hide System Libraries (bottom-left checkbox), then click the Self Weight column header. Find `applyBroken`, `sorted`, and `DateFormatter.init` in your app’s frames.",
            "Open `CPUHotspotLabSearch.applyFixed` in source to read the three fixes: pre-sorted input, single shared formatter, and pre-computed search key.",
        ],
        hints: [
            "Three compounding problems per keystroke: a full sort of 1000 items, one DateFormatter allocation per item, and lowercased() called per item per search.",
            "Sort the trace by Self Time and look for your own code before chasing system libraries.",
            "If the UI fully freezes and gestures stop working, that is Hang Lab — CPU Hotspot Lab stays responsive but feels sluggish.",
            "DateFormatter is a heavyweight Objective-C object; creating one inside a tight loop is a classic iOS performance mistake.",
        ],
        toolRecommendations: [
            "Instruments Time Profiler",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/CPUHotspotLabInvestigationGuide.md (in the repo)",
        ],
        investigationGuide: InvestigationGuide(
            steps: [
                "Run the app and type a query — confirm the UI is sluggish but still responds to gestures. This is the symptom to profile.",
                "From Xcode, Product → Profile (⌘I), choose Time Profiler, click Record.",
                "In the Instruments-hosted app, navigate to CPU Hotspot Lab and type the same query several times. Click Stop.",
                "Enable Hide System Libraries, then sort by Self Time. Locate `applyBroken`, `sorted`, and `DateFormatter.init` in your app's frames.",
                "Name all three hotspots: repeated sort of 500 items, one DateFormatter per item per call, and per-call lowercased().",
                "Open `CPUHotspotLabSearch.applyFixed` in source and read the three fixes.",
            ],
            validationChecklist: [
                "You’re done when you can name all three redundant operations in `applyBroken` and explain why the interaction is slow but not frozen.",
                "You can point to at least one hot frame in your code in the trace.",
                "You can explain what `applyFixed` pre-computes to remove each hotspot.",
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
            "Skim Hang Lab first: it blocks the scroll probes while heavy work runs synchronously on the main actor.",
            "In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics, then enable Thread Performance Checker (exact label may vary slightly by Xcode version).",
            "Build and run SignalLab from Xcode, open Hang Lab, tap Run scenario, and try scrolling during the stall.",
            "Watch the Issue navigator or the debug console for a Thread Performance Checker warning tied to main-queue work.",
            "Compare with CPU Hotspot Lab’s sluggish-but-responsive symptom so you do not confuse checker warnings with Time Profiler hotspots.",
        ],
        hints: [
            "This lab is scheme diagnostics, not Hang Lab’s pause-and-read-stack workflow—use both together.",
            "If the UI is merely sluggish but still scrolls, profile with CPU Hotspot Lab instead of expecting a checker storm.",
            "If objects stay alive after dismissal, that is Retain Cycle Lab—checker warnings are about thread misuse, not lifetime.",
        ],
        toolRecommendations: [
            "Xcode scheme → Run → Diagnostics → Thread Performance Checker",
            "Hang Lab for the same workload shape",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/ThreadPerformanceCheckerLabInvestigationGuide.md (in the repo)",
        ],
        investigationGuide: InvestigationGuide(
            steps: [
                "Confirm you can reproduce Hang Lab’s freeze so you have a concrete main-thread story in mind.",
                "Enable Thread Performance Checker in the Run scheme diagnostics and relaunch the app from Xcode.",
                "Trigger the same hang and read the warning Xcode surfaces—note the symbol or queue it cites.",
                "Contrast that evidence with what you learned from pausing during the freeze in Hang Lab.",
                "Optional: after capturing the warning, run Hang Lab again as a sanity check.",
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
            "In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics → enable Zombie Objects (label may vary slightly by Xcode version). Close the editor, then Build & Run (⌘R) — scheme changes only apply after a full relaunch.",
            "Open this lab and tap **Run scenario**—Objective-C messages a deallocated object (`__unsafe_unretained` after the pool drains).",
            "Read the zombie diagnostic text and name the object that was messaged after deallocation.",
            "Optional: run again with Zombies off to compare how vague the failure becomes.",
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
        investigationGuide: InvestigationGuide(
            steps: [
                "Enable Zombie Objects in the Run scheme, close the editor, and Build & Run (⌘R). Then tap Run scenario and read the zombie / deallocated wording.",
                "Identify which type or instance the runtime names as zombie or deallocated.",
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
            "In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics → enable Thread Sanitizer (exact checkbox label may vary). Close the editor, then Build & Run (⌘R) — sanitizers require a full instrumented rebuild.",
            "Open this lab and tap **Run scenario**—main thread and a detached task increment one shared counter without a lock.",
            "Read the sanitizer report: which address or variable, which two threads, and which stack frames implicate your code.",
        ],
        hints: [
            "Hang Lab is synchronous main-thread starvation; TSan is concurrent unsynchronized writes/reads to the same memory.",
            "If results are wrong but a single thread owns the state, use Breakpoint Lab—not this lab.",
            "TSan slows the app; use it when you suspect a race, not for every performance pass.",
            "If the report cites `group.wait` or a semaphore, that is the synchronization point — the race is the unserialized read or write before that barrier.",
        ],
        toolRecommendations: [
            "Xcode scheme → Run → Diagnostics → Thread Sanitizer",
            "Hang Lab and CPU Hotspot Lab (contrast: freeze / cost vs race)",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/ThreadSanitizerLabInvestigationGuide.md (in the repo)",
        ],
        investigationGuide: InvestigationGuide(
            steps: [
                "Enable Thread Sanitizer in the Run scheme, Build & Run (⌘R), then tap Run scenario until Xcode stops with a race report on the shared counter.",
                "Extract: conflicting threads, shared variable, and call sites from the report.",
                "Contrast with an async ordering bug (completion A before B) where TSan stays quiet.",
                "Apply the same serialization idea to your own shared state when you leave the lab.",
            ],
            validationChecklist: [
                "You’re done when you can name the shared state TSan flagged and why two threads conflicted.",
                "You can explain why Breakpoint Lab or Hang Lab would be the wrong diagnostic surface for that symptom.",
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
            "In Xcode: Product → Scheme → Edit Scheme → Run → Diagnostics → enable Malloc Stack Logging (options may include \"Malloc Stack\" or similar by version). Close the editor, then Build & Run (⌘R) — logging only captures stacks from the new process.",
            "Tap **Run scenario**—each tap allocates thousands of fresh row arrays; use Instruments → Allocations (or your guide’s lldb path) to see the allocating stacks.",
            "Run once and capture the row-array allocation stack in Instruments → Allocations.",
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
        investigationGuide: InvestigationGuide(
            steps: [
                "Enable Malloc Stack Logging in the Run scheme and Build & Run (⌘R) — logging only captures stacks from the new process session.",
                "Run once and capture stacks for the row-array allocation hot path in this module.",
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
        summary: "Tell climbing footprint and allocation churn apart from a retain cycle: each run hoards a 256 KB buffer without eviction so footprint climbs without a cycle.",
        category: .memory,
        difficulty: .intermediate,
        learningGoals: [
            "Contrast Memory Graph growth from unbounded caching with Retain Cycle Lab’s cyclic retention",
            "Use Instruments Allocations or memory gauges to see footprint rise without a cycle",
            "Apply a retention policy (cap, eviction, pool) once growth is confirmed",
        ],
        reproductionSteps: [
            "Finish Retain Cycle Lab first so you know what a cycle looks like in Memory Graph.",
            "Open Heap Growth Lab — the in-app chunk counter reads 0 before the first tap. Tap **Run scenario** five times and watch the chunk counter climb. Each run retains another 256 KB buffer that is never evicted.",
            "In Instruments → Allocations, take a heap snapshot after tap 1, then again after tap 5. Compare live bytes between snapshots — you should see ~256 KB added per run with no eviction.",
            "Open Memory Graph and look for HeapGrowthLab objects — there is no reference cycle; the buffer stays alive because the cache holds a strong reference without a cap.",
            "Articulate when you would choose eviction (cap size / LRU) vs fixing a cycle (break the reference) for a production codebase.",
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
        investigationGuide: InvestigationGuide(
            steps: [
                "Watch the in-app chunk counter climb as you tap Run scenario five times.",
                "In Instruments → Allocations, take a heap snapshot before and after — confirm ~256 KB added per run.",
                "Open Memory Graph: no reference cycle exists; confirm HeapGrowthLab objects are held by a linear (non-cyclic) strong reference.",
                "Write one sentence: why this is not Retain Cycle Lab.",
                "Plan a real-world policy: max cache size, LRU eviction, or periodic flush.",
            ],
            validationChecklist: [
                "You can explain why footprint grew without claiming a retain cycle.",
                "You can describe a retention-bound pattern (cap, eviction, or pool) and when it applies in production.",
            ]
        ),
        catalogSortIndex: 11
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
            "Separate deadlock (circular sync wait) from Hang Lab’s timed Thread.sleep block",
        ],
        reproductionSteps: [
            "Launch SignalLab **from Xcode** with the debugger attached.",
            "Open Deadlock Lab and read the warning before tapping Run scenario.",
            "Tap **Run scenario**—the UI should freeze permanently.",
            "Click Pause in the debug bar: the main thread stack should show dispatch_sync / queue wait rather than heavy app compute.",
            "Stop the run in Xcode, then relaunch SignalLab for normal exploration.",
        ],
        hints: [
            "Hang Lab: main thread sleeps (`Thread.sleep`) — the freeze recovers in 4 s. Deadlock Lab: main thread waits on **itself** via `sync` — it never recovers.",
            "Never call `sync` onto a queue you are already executing on.",
            "Fix: replace `DispatchQueue.main.sync { ... }` with `Task { @MainActor in ... }` or inline the work — both avoid the self-wait.",
            "This scenario is intentionally destructive—do not use it in UI tests or screenshots that tap Run.",
        ],
        toolRecommendations: [
            "Debug navigator thread stacks",
            "Pause / continue in Xcode",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/DeadlockLabInvestigationGuide.md (in the repo)",
        ],
        investigationGuide: InvestigationGuide(
            steps: [
                "Run once, then pause—the main thread should be stuck in sync machinery.",
                "Contrast with Hang Lab: there you see `Thread.sleep` and the freeze recovers after 4 s; here the main thread waits on `dispatch_sync` to itself and never resolves.",
                "In your own code, search for `sync` onto `.main` from contexts that might already be main.",
                "Prefer `async`, structured concurrency, or inline work instead of main-on-main sync.",
            ],
            validationChecklist: [
                "You can state in one sentence why `main.sync` from main deadlocks.",
                "You can explain why Deadlock Lab never recovers while Hang Lab’s sleep ends after 4 seconds.",
            ]
        ),
        catalogSortIndex: 12
    )

    /// Phase 2: Posting work that touches UI expectations from a background context.
    private static let backgroundThreadUILab = LabScenario(
        id: "background_thread_ui",
        title: "Background Thread UI Lab",
        summary: "See why UI-facing callbacks should run on the main actor: the runner posts a notification from a detached task without a main actor hop — watch for runtime threading warnings in the console.",
        category: .hang,
        difficulty: .intermediate,
        learningGoals: [
            "Relate notification delivery threads to SwiftUI state updates",
            "Recognize Xcode warnings about publishing or updating UI off the main thread",
            "Prefer MainActor/async patterns when forwarding events to UI",
        ],
        reproductionSteps: [
            "Open this lab and keep the debug console visible.",
            "Tap **Run scenario**—watch the debug console for runtime diagnostics about background-thread updates.",
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
        investigationGuide: InvestigationGuide(
            steps: [
                "Tap Run scenario and capture any threading warning text verbatim.",
                "Trace the path: `Task.detached` → `NotificationCenter.post` → `onReceive` → `@State` mutation on a non-main thread.",
                "Refactor one real callback to `await MainActor.run` or `@MainActor` isolation.",
                "Re-test until warnings disappear for that path.",
            ],
            validationChecklist: [
                "You can explain why posting from a detached task is risky for SwiftUI state.",
                "You can describe the fix pattern (main-queue / MainActor delivery) in one sentence.",
            ]
        ),
        catalogSortIndex: 13
    )

    /// Phase 2: Synchronous file I/O blocking the main thread vs detached load.
    private static let mainThreadIOLab = LabScenario(
        id: "main_thread_io",
        title: "Main Thread I/O Lab",
        summary: "Contrast repeated synchronous `Data(contentsOf:)` on the main thread with an off-main read—same bytes, different responsiveness story than Hang Lab’s timed sleep.",
        category: .hang,
        difficulty: .intermediate,
        learningGoals: [
            "Spot main-thread disk reads as responsiveness bugs",
            "Use scroll probes to feel the main-thread stall during synchronous reads",
            "Choose async I/O or background queues before optimizing algorithms",
        ],
        reproductionSteps: [
            "Open Main Thread I/O Lab and tap **Run scenario**—try to scroll the probe chips while the reads run. The hitch may be brief (~10 synchronous file reads); on fast storage it can be subtle.",
            "**Option A — Pause:** Click Pause in the Xcode debug bar immediately after tapping Run scenario. Inspect the main thread stack for `Data(contentsOf:)` or file-read frames.",
            "**Option B — Time Profiler:** From Xcode choose Product → Profile (⌘I), select Time Profiler, record while tapping Run scenario, then stop and sort by Self Time to see the I/O frames.",
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
        investigationGuide: InvestigationGuide(
            steps: [
                "Tap Run scenario and feel the hitch; Pause and inspect the main thread stack for synchronous file read APIs.",
                "Estimate how many synchronous reads your real feature does per gesture.",
                "Move loads to `Task.detached`, `URLSession`, or async file APIs as appropriate.",
                "Validate with an Instruments Time Profiler pass after the async refactor.",
            ],
            validationChecklist: [
                "You can separate I/O wait from CPU burn on the main thread.",
                "You can point to the API you would change first in a production codebase.",
            ]
        ),
        catalogSortIndex: 14
    )

    /// Phase 2: Scroll jank from expensive per-row SwiftUI chrome vs lighter effects.
    private static let scrollHitchLab = LabScenario(
        id: "scroll_hitch",
        title: "Scroll Hitch Lab",
        summary: "Auto-scroll a long list with heavy per-row compositing and shadows — profile the frame drops with Instruments Core Animation.",
        category: .performance,
        difficulty: .intermediate,
        learningGoals: [
            "Relate scroll hitches to per-row rendering cost, not just CPU algorithms",
            "Use Instruments Core Animation or frame pacing views alongside Time Profiler",
            "Contrast this lab with CPU Hotspot Lab’s keystroke-bound hotspots",
        ],
        reproductionSteps: [
            "Open Scroll Hitch Lab and tap **Run scenario** to auto-scroll the vertical list. Try dragging the horizontal scroll probe chips at the top during the scroll — each row's shadow makes compositing expensive, so frame times may exceed the 16.7 ms budget (60 fps).",
            "From Xcode choose Product → Profile (⌘I). Choose the **Core Animation** template (or **Hangs** / **Animation Hitches** template if your Xcode version provides one) and click Record.",
            "In the Instruments-hosted app, open Scroll Hitch Lab and tap Run scenario while recording. Stop after the scroll completes. Look for frame time spikes or hitch markers in the timeline.",
        ],
        hints: [
            "Each row uses `.compositingGroup()` plus a large shadow—each row becomes an expensive offscreen pass.",
            "CPU Hotspot Lab stays responsive but slow; this lab targets frame drops during scroll.",
            "Hang Lab is a full stop; here the scroll usually continues but unevenly.",
        ],
        toolRecommendations: [
            "Instruments > Core Animation (or scrolling / frame pacing template for your Xcode version)",
            "Instruments > Time Profiler (supporting)",
            "Xcode tooling cheat sheet: Docs/XcodeToolingCheatSheet.md",
            "Long-form write-up: Docs/ScrollHitchLabInvestigationGuide.md (in the repo)",
        ],
        investigationGuide: InvestigationGuide(
            steps: [
                "Tap Run scenario and capture a short Instruments trace covering the scroll.",
                "Look for elevated frame time or compositing cost while rows with heavy shadows are on screen.",
                "Read the SwiftUI row modifiers in `ScrollHitchLabScenarioRunner` — the heavy path uses `.compositingGroup()` plus a large shadow on each row, each of which forces an offscreen compositing pass.",
                "In your own lists, audit `.drawingGroup()`, `.compositingGroup()`, and stacked shadows inside `Lazy` stacks.",
            ],
            validationChecklist: [
                "You can explain one visual effect that makes scrolling more expensive.",
                "You can state how this symptom differs from CPU Hotspot Lab and Hang Lab.",
            ]
        ),
        catalogSortIndex: 15
    )

    /// Phase 2: Same main-thread startup-style phases with vs without `os_signpost` for POI.
    private static let startupSignpostLab = LabScenario(
        id: "startup_signpost",
        title: "Startup Signpost Lab",
        summary: "Simulate blocking launch phases on the main thread and emit `os_signpost` intervals for Instruments Points of Interest.",
        category: .performance,
        difficulty: .intermediate,
        learningGoals: [
            "Record `os_signpost` intervals in Instruments > Points of Interest",
            "Read startup phases as named intervals instead of one anonymous main-thread blob",
            "Understand that signposts annotate work—they do not move it off the main thread",
        ],
        reproductionSteps: [
            "From Xcode, choose Product → Profile (⌘I). In the template picker, choose **Points of Interest** — it may be under the All Templates tab if not visible immediately.",
            "Click Record. In the Instruments-hosted app, open Startup Signpost Lab and tap **Run scenario**. The app may hang briefly while the simulated phases block the main thread — that is expected and is the same mechanism as Hang Lab.",
            "Stop the recording. Look for three named intervals (`SignalLabStartupConfig`, `SignalLabStartupAssets`, `SignalLabStartupReady`) in the Points of Interest track.",
            "Use the checksum in the footer only as a sanity check that the simulated work completed.",
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
        investigationGuide: InvestigationGuide(
            steps: [
                "Profile the lab and tap **Run scenario** once per recording.",
                "Identify `SignalLabStartupConfig`, `SignalLabStartupAssets`, and `SignalLabStartupReady` intervals.",
                "Add a named signpost around your own app’s heaviest launch closure before optimizing blindly.",
            ],
            validationChecklist: [
                "You can name the three signposted phases and what each represents in this lab.",
                "You can explain why signposts annotate work rather than optimize it.",
            ]
        ),
        catalogSortIndex: 16
    )

    /// Phase 2: Unstructured `Task.detached` ordering vs sequential async work (not the TSan story).
    private static let concurrencyIsolationLab = LabScenario(
        id: "concurrency_isolation",
        title: "Concurrency Isolation Lab",
        summary: "Two `Task.detached` hops post completion labels without coordination — completion order can flip between runs and Xcode surfaces isolation warnings.",
        category: .hang,
        difficulty: .intermediate,
        learningGoals: [
            "Separate flaky ordering from data races on shared memory",
            "Read Xcode’s Sendable and isolation warnings as a first-line tool",
            "Prefer structured `async`/`await` when completion order must be deterministic",
        ],
        reproductionSteps: [
            "**Build-time check:** In Xcode, open the Issue navigator. Look for a warning about capturing a non-Sendable type inside `Task.detached` — that is a compile-time isolation signal, not a runtime crash.",
            "**Runtime:** Open Concurrency Isolation Lab and tap **Run scenario** three times. Each run, `alpha` and `beta` may arrive in a different order because each detached task sleeps a random amount before hopping to the main actor.",
            "Contrast with Thread Sanitizer Lab: there two threads mutate one counter without synchronization — a data race, not just ordering surprise.",
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
        investigationGuide: InvestigationGuide(
            steps: [
                "Run the scenario three times and screenshot or note the three completion-order strings.",
                "Search warnings for capturing a non-Sendable type inside `Task.detached`.",
                "Write one sentence: when you would still enable Thread Sanitizer after fixing ordering.",
                "Refactor one real feature from double-`detached` fire-and-forget to a single `async` function.",
            ],
            validationChecklist: [
                "You can explain why completion order changed across runs.",
                "You can state why Thread Sanitizer Lab is not the right diagnostic surface for that symptom.",
            ]
        ),
        catalogSortIndex: 17
    )
}
