//
//  iOSLabDetailView.swift
//  SignalLab
//
//  Lab detail routing, shared scaffold, and per-lab runners (MVP + diagnostics + Phase 2 extensions).
//

import Observation
import OSLog
import SwiftUI

/// Lab scenario slug used for navigation and runner selection.
enum iOSLabScenarioID {
    /// Crash Lab: broken-only JSON import crash used to teach the default debugger workflow.
    static let crash = "crash"
    /// Exception Breakpoint Lab (`break_on_failure`): reveal caught Objective-C exceptions before recovery hides context.
    static let exceptionBreakpoint = "break_on_failure"
    /// Breakpoint Lab: search + category filter with a deterministic logic bug.
    static let breakpoint = "breakpoint"
    /// Memory Graph Lab: search for a retained checkout session and identify its owner.
    static let memoryGraph = "memory_graph"
    /// Retain Cycle Lab: checkout screen / close-button handler cycle (later memory lesson).
    static let retainCycle = "retain_cycle"
    /// Hang Lab: main-thread CPU work vs off-main processing.
    static let hang = "hang"
    /// CPU Hotspot Lab: live search + Time Profiler exercise (`cpu_hotspot`).
    static let cpuHotspot = "cpu_hotspot"
    /// Thread Performance Checker Lab: scheme diagnostic walkthrough (`thread_performance_checker`).
    static let threadPerformanceChecker = "thread_performance_checker"
    /// Zombie Objects Lab (`zombie_objects`).
    static let zombieObjects = "zombie_objects"
    /// Thread Sanitizer Lab (`thread_sanitizer`).
    static let threadSanitizer = "thread_sanitizer"
    /// Malloc Stack Logging Lab (`malloc_stack_logging`).
    static let mallocStackLogging = "malloc_stack_logging"
    /// Heap Growth Lab (`heap_growth`) — Phase 2.
    static let heapGrowth = "heap_growth"
    /// Deadlock Lab (`deadlock`) — Phase 2.
    static let deadlock = "deadlock"
    /// Background Thread UI Lab (`background_thread_ui`) — Phase 2.
    static let backgroundThreadUI = "background_thread_ui"
    /// Main Thread I/O Lab (`main_thread_io`) — Phase 2.
    static let mainThreadIO = "main_thread_io"
    /// Scroll Hitch Lab (`scroll_hitch`) — Phase 2.
    static let scrollHitch = "scroll_hitch"
    /// Startup Signpost Lab (`startup_signpost`) — Phase 2.
    static let startupSignpost = "startup_signpost"
    /// Concurrency Isolation Lab (`concurrency_isolation`) — Phase 2.
    static let concurrencyIsolation = "concurrency_isolation"
}

/// Routes to the appropriate detail experience for a scenario.
struct iOSLabDetailView: View {
    let scenario: LabScenario

    var body: some View {
        switch scenario.id {
        case iOSLabScenarioID.crash:
            iOSCrashLabDetailView(scenario: scenario)
        case iOSLabScenarioID.exceptionBreakpoint:
            iOSExceptionBreakpointLabDetailView(scenario: scenario)
        case iOSLabScenarioID.breakpoint:
            iOSBreakpointLabDetailView(scenario: scenario)
        case iOSLabScenarioID.memoryGraph:
            iOSMemoryGraphLabDetailView(scenario: scenario)
        case iOSLabScenarioID.retainCycle:
            iOSRetainCycleLabDetailView(scenario: scenario)
        case iOSLabScenarioID.hang:
            iOSHangLabDetailView(scenario: scenario)
        case iOSLabScenarioID.cpuHotspot:
            iOSCPUHotspotLabDetailView(scenario: scenario)
        case iOSLabScenarioID.threadPerformanceChecker:
            iOSThreadPerformanceCheckerLabDetailView(scenario: scenario)
        case iOSLabScenarioID.zombieObjects:
            iOSZombieObjectsLabDetailView(scenario: scenario)
        case iOSLabScenarioID.threadSanitizer:
            iOSThreadSanitizerLabDetailView(scenario: scenario)
        case iOSLabScenarioID.mallocStackLogging:
            iOSMallocStackLoggingLabDetailView(scenario: scenario)
        case iOSLabScenarioID.heapGrowth:
            iOSHeapGrowthLabDetailView(scenario: scenario)
        case iOSLabScenarioID.deadlock:
            iOSDeadlockLabDetailView(scenario: scenario)
        case iOSLabScenarioID.backgroundThreadUI:
            iOSBackgroundThreadUILabDetailView(scenario: scenario)
        case iOSLabScenarioID.mainThreadIO:
            iOSMainThreadIOLabDetailView(scenario: scenario)
        case iOSLabScenarioID.scrollHitch:
            iOSScrollHitchLabDetailView(scenario: scenario)
        case iOSLabScenarioID.startupSignpost:
            iOSStartupSignpostLabDetailView(scenario: scenario)
        case iOSLabScenarioID.concurrencyIsolation:
            iOSConcurrencyIsolationLabDetailView(scenario: scenario)
        default:
            iOSGenericLabDetailView(scenario: scenario)
        }
    }
}

// MARK: - Exception Breakpoint Lab

/// Guided detail shell for revealing a caught Objective-C exception with an exception breakpoint.
struct iOSExceptionBreakpointLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: ExceptionBreakpointLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: ExceptionBreakpointLabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            showsResetButton: false,
            topInset: { comparisonPromptSection },
            actionFooter: { guidedRunFooter }
        )
    }

    private var comparisonPromptSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Reveal the hidden exception", systemImage: "flag.2.crossed.fill")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(
                "Run once without an Exception Breakpoint: the app catches the Objective-C exception and only shows a generic failure. "
                    + "That simulates a recovery layer that protects the app but drops the useful table and row details. "
                    + "Run again with an Exception Breakpoint: Xcode should stop at the hidden raise site before that context is swallowed."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                comparisonRow(
                    title: "Pass 1: No debugger stop",
                    body: "Run without an Exception Breakpoint. The app keeps running and only reports a vague selection failure."
                )
                comparisonRow(
                    title: "Why try this tool?",
                    body: "A vague recovered failure is a clue, not proof. Try an Exception Breakpoint to test whether an Objective-C exception happened before the generic message."
                )
                comparisonRow(
                    title: "Pass 2: Exception Breakpoint",
                    body: "Run again and look for the hidden raise frame with brokenTableName, brokenRowID, and exceptionReason."
                )
                comparisonRow(
                    title: "Name the value",
                    body: "The breakpoint is useful because it turns a vague recovered failure into the exact table, row, and exception reason."
                )
            }
        }
    }

    @ViewBuilder
    private func comparisonRow(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(body)
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SignalLabTheme.horizontalPadding / 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SignalLabTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var guidedRunFooter: some View {
        if let message = runner.lastUserVisibleMessage {
            Text(
                "\(message) Add an Exception Breakpoint and run again to stop before this message hides the cause."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .accessibilityLabel(
                "\(message) Add an Exception Breakpoint and run again to stop before this message hides the cause."
            )
        }
    }
}

// MARK: - Thread Performance Checker Lab

/// Guided detail shell for enabling Xcode’s Thread Performance Checker after Hang Lab context.
///
/// There is no in-app Broken/Fixed pair—the exercise is entirely in Xcode (scheme diagnostics + Hang Lab reproduction).
struct iOSThreadPerformanceCheckerLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: StubLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: StubLabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            topInset: { schemeDiagnosticSection },
            actionFooter: { checklistFooter }
        )
    }

    private var schemeDiagnosticSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Scheme diagnostic", systemImage: "checkerboard.shield")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(
                "Hang Lab proves a freeze by pausing the debugger. Thread Performance Checker asks Xcode to surface "
                    + "the same class of main-thread problem as a runtime warning—without relying on that pause alone."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                LabGuidedDiagnosticLayout.row(
                    title: "1. Enable the checker",
                    body: "Edit Scheme → Run → Diagnostics → turn on Thread Performance Checker, then build and run from Xcode."
                )
                LabGuidedDiagnosticLayout.row(
                    title: "2. Reuse Hang Lab",
                    body: "Open Hang Lab, tap Run scenario, scroll during the stall—watch Issue navigator / console for the warning."
                )
                LabGuidedDiagnosticLayout.row(
                    title: "3. Compare tools",
                    body: "This is not Time Profiler (CPU Hotspot Lab) and not Memory Graph—stay focused on thread misuse evidence."
                )
            }
        }
    }

    @ViewBuilder
    private var checklistFooter: some View {
        if runner.triggerInvocationCount > 0 {
            Text(
                "Tap counts as a checklist tick: enable the scheme diagnostic, reproduce the Hang Lab freeze, capture what Xcode reported."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .accessibilityLabel(
                "Tap counts as a checklist tick. Enable the scheme diagnostic, reproduce the Hang Lab freeze, capture what Xcode reported."
            )
        }
    }
}

// MARK: - CPU Hotspot Lab

/// Live searchable-list detail view for CPU Hotspot Lab.
///
/// The search field updates ``CPUHotspotLabScenarioRunner/displayItems`` on every keystroke.
/// Each update re-sorts 500 items and allocates a `DateFormatter` per item — deliberate hotspots
/// for learners to discover via Instruments > Time Profiler.
struct iOSCPUHotspotLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: CPUHotspotLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: CPUHotspotLabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            topInset: { hotspotInteractiveSection },
            actionFooter: { hotspotRunFooter }
        )
    }

    // MARK: - Footer

    @ViewBuilder
    private var hotspotRunFooter: some View {
        if runner.triggerInvocationCount > 0 {
            Text(
                "Profiling tip: start a Time Profiler trace in Instruments, then type in the search field to capture the hot path."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .accessibilityLabel(
                "Profiling tip: start a Time Profiler trace in Instruments, then type in the search field to capture the hot path."
            )
        }
    }

    // MARK: - Interactive section

    @ViewBuilder
    private var hotspotInteractiveSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Live search", systemImage: "magnifyingglass")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(
                "Type a query — notice the lag per keystroke. "
                    + "Profile in Instruments > Time Profiler to see the hot path."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            TextField("Filter events…", text: $runner.searchQuery)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier("CPUHotspotLab.searchField")
                .accessibilityHint("Filters diagnostic events by name, category, or timestamp. Results update live on every keystroke.")

            if runner.searchQuery.isEmpty {
                Text("\(runner.displayItems.count) events loaded — type to filter.")
                    .font(.footnote)
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .accessibilityLabel("\(runner.displayItems.count) events loaded. Type to filter.")
            } else {
                eventResultsSection
            }
        }
    }

    // MARK: - Results list

    @ViewBuilder
    private var eventResultsSection: some View {
        let results = runner.displayItems
        let displayed = results.prefix(50)

        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Text(results.isEmpty ? "No matching events." : "\(results.count) matching events")
                .font(.subheadline.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(results.isEmpty ? "No matching events." : "\(results.count) matching events")

            if !displayed.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(displayed.enumerated()), id: \.element.id) { index, item in
                        eventRow(item: item)
                        if index < displayed.count - 1 {
                            Divider()
                                .background(SignalLabTheme.background)
                        }
                    }
                }
                .padding(SignalLabTheme.horizontalPadding / 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SignalLabTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier("CPUHotspotLab.resultsList")

                if results.count > 50 {
                    Text("Showing first 50 of \(results.count) matches.")
                        .font(.caption)
                        .foregroundStyle(SignalLabTheme.secondaryText)
                        .accessibilityLabel("Showing first 50 of \(results.count) matching events.")
                }
            }
        }
    }

    @ViewBuilder
    private func eventRow(item: CPUHotspotLabItem) -> some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(item.formattedTimestamp)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(SignalLabTheme.secondaryText)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 3) {
                Text(item.category)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(SignalLabTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text("P\(item.priority)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(item.priority >= 4 ? SignalLabTheme.warning : SignalLabTheme.secondaryText)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(item.name), \(item.category), priority \(item.priority), \(item.formattedTimestamp)"
        )
    }
}

// MARK: - Generic (stub runner)

/// Detail shell for labs that have not yet shipped scenario behavior.
struct iOSGenericLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: StubLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: StubLabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        iOSLabDetailScaffold(scenario: scenario, runner: runner, topInset: { EmptyView() }) {
            Group {
                if runner.triggerInvocationCount > 0 {
                    Text(
                        "Scenario ran \(runner.triggerInvocationCount) time(s). "
                            + "Interactive behavior for this lab ships in a later milestone."
                    )
                    .font(.footnote)
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .accessibilityLabel(
                        "Scenario ran \(runner.triggerInvocationCount) times. Interactive behavior ships in a later milestone."
                    )
                }
            }
        }
    }
}

// MARK: - Crash Lab

/// Crash Lab detail shell with real import trigger behavior.
struct iOSCrashLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: CrashLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: CrashLabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            showsResetButton: false,
            topInset: { crashPromptSection }
        ) {
            Group {
                crashImportStatus
            }
        }
    }

    private var crashPromptSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("What to learn", systemImage: "scope")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 8) {
                LabGuidedDiagnosticLayout.row(
                    title: "1. Read the highlighted line",
                    body: "Xcode stops on the strict decode inside CrashImportParser. That is the failed assumption."
                )
                LabGuidedDiagnosticLayout.row(
                    title: "2. Read the console message",
                    body: "Look for \"Expected to decode Int but found a string instead.\" It tells you the bad field and type."
                )
                LabGuidedDiagnosticLayout.row(
                    title: "3. Move up one caller frame",
                    body: "Open runBrokenImport() and inspect brokenCountText plus brokenJSONText. That is the payoff for traversing the stack."
                )
            }
        }
    }

    @ViewBuilder
    private var crashImportStatus: some View {
        if runner.triggerInvocationCount > 0 {
            Text(
                "Crash Lab is intentionally broken-only. The value is the stopped debugger state: highlighted line, console message, then brokenCountText and brokenJSONText one caller frame up."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .accessibilityLabel(
                "Crash Lab is intentionally broken only. The value is the stopped debugger state: highlighted line, console message, then brokenCountText and brokenJSONText one caller frame up."
            )
        }
    }
}

// MARK: - Breakpoint Lab

/// Breakpoint Lab: one readable discount result for line-breakpoint practice.
struct iOSBreakpointLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: BreakpointLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: BreakpointLabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            topInset: { breakpointInteractiveSection },
            actionFooter: { breakpointRunStatusFooter }
        )
    }

    @ViewBuilder
    private var breakpointRunStatusFooter: some View {
        if runner.triggerInvocationCount > 0 {
            let message = runner.triggerInvocationCount == 1
                ? "The app completed normally, but the total is wrong: the student order received 5% off instead of 20%."
                : "Run count: \(runner.triggerInvocationCount). Use the breakpoint stop to inspect discountPercent and subtotal."
            Text(message)
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .accessibilityLabel(message)
        }
    }

    @ViewBuilder
    private var breakpointInteractiveSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Try this", systemImage: "hand.point.up.left.fill")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(
                "Run the scenario, then set one line breakpoint in the discount calculator to see which value made the total wrong."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                breakpointOrderRow(
                    title: "Order subtotal",
                    value: BreakpointLabDiscountCalculator.currencyText(runner.previewResult.orderSubtotal)
                )
                breakpointOrderRow(title: "Customer type", value: runner.previewResult.customerType.displayTitle)
                breakpointOrderRow(title: "Expected discount", value: "\(runner.previewResult.expectedDiscountPercent)%")
                breakpointOrderRow(title: "Actual discount", value: "\(runner.previewResult.appliedDiscountPercent)%")
                breakpointOrderRow(
                    title: "Expected total",
                    value: BreakpointLabDiscountCalculator.currencyText(runner.previewResult.expectedTotal)
                )
                breakpointOrderRow(
                    title: "Actual total",
                    value: BreakpointLabDiscountCalculator.currencyText(runner.previewResult.actualTotal)
                )
            }
            .padding(SignalLabTheme.horizontalPadding / 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SignalLabTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .accessibilityIdentifier("BreakpointLab.orderPanel")

            if let result = runner.lastResult {
                Text(result.statusMessage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SignalLabTheme.warning)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("BreakpointLab.statusMessage")
            }
        }
    }

    private func breakpointOrderRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(SignalLabTheme.secondaryText)
            Spacer(minLength: 12)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Shared scaffold

/// Reusable layout for catalog metadata, actions, and investigation content.
struct iOSLabDetailScaffold<Runner: LabScenarioRunning & Observable, Footer: View, Top: View>: View {
    let scenario: LabScenario
    @Bindable var runner: Runner
    let showsResetButton: Bool
    let showsGuidanceSections: Bool
    @ViewBuilder var topInset: () -> Top
    @ViewBuilder var actionFooter: () -> Footer

    init(
        scenario: LabScenario,
        runner: Runner,
        showsResetButton: Bool = false,
        showsGuidanceSections: Bool = true,
        @ViewBuilder topInset: @escaping () -> Top,
        @ViewBuilder actionFooter: @escaping () -> Footer
    ) {
        self.scenario = scenario
        self.runner = runner
        self.showsResetButton = showsResetButton
        self.showsGuidanceSections = showsGuidanceSections
        self.topInset = topInset
        self.actionFooter = actionFooter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SignalLabTheme.sectionSpacing) {
                header
                topInset()
                actions
                actionFooter()
                if showsGuidanceSections {
                    goalsSection
                    workflowSection
                    toolsAndHintsSection
                }
            }
            .padding(.horizontal, SignalLabTheme.horizontalPadding)
            .padding(.vertical, SignalLabTheme.sectionSpacing)
        }
        .accessibilityIdentifier("SignalLab.detail.\(scenario.id)")
        .background(SignalLabTheme.background)
        .navigationTitle(scenario.title)
        .navigationBarTitleDisplayMode(.inline)
        .tint(SignalLabTheme.accent)
        .onAppear {
            let slug = scenario.id
            SignalLabLog.labDetail.info("Lab scaffold appeared id=\(slug, privacy: .public)")
            switch slug {
            case iOSLabScenarioID.exceptionBreakpoint:
                SignalLabLog.exceptionBreakpointLab.info("Exception Breakpoint Lab detail visible")
            case iOSLabScenarioID.threadPerformanceChecker:
                SignalLabLog.threadPerformanceCheckerLab.info("Thread Performance Checker Lab detail visible")
            case iOSLabScenarioID.zombieObjects:
                SignalLabLog.zombieObjectsLab.info("Zombie Objects Lab detail visible")
            case iOSLabScenarioID.threadSanitizer:
                SignalLabLog.threadSanitizerLab.info("Thread Sanitizer Lab detail visible")
            case iOSLabScenarioID.mallocStackLogging:
                SignalLabLog.mallocStackLoggingLab.info("Malloc Stack Logging Lab detail visible")
            case iOSLabScenarioID.heapGrowth:
                SignalLabLog.heapGrowthLab.info("Heap Growth Lab detail visible")
            case iOSLabScenarioID.deadlock:
                SignalLabLog.deadlockLab.info("Deadlock Lab detail visible")
            case iOSLabScenarioID.backgroundThreadUI:
                SignalLabLog.backgroundThreadUILab.info("Background Thread UI Lab detail visible")
            case iOSLabScenarioID.mainThreadIO:
                SignalLabLog.mainThreadIOLab.info("Main Thread I/O Lab detail visible")
            case iOSLabScenarioID.scrollHitch:
                SignalLabLog.scrollHitchLab.info("Scroll Hitch Lab detail visible")
            case iOSLabScenarioID.startupSignpost:
                SignalLabLog.startupSignpostLab.info("Startup Signpost Lab detail visible")
            case iOSLabScenarioID.concurrencyIsolation:
                SignalLabLog.concurrencyIsolationLab.info("Concurrency Isolation Lab detail visible")
            default:
                break
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            HStack(spacing: 8) {
                Text(scenario.category.displayTitle)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(SignalLabTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Text(scenario.difficulty.displayTitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(SignalLabTheme.secondaryText)
            }
            Text(scenario.summary)
                .font(.body)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(scenario.category.displayTitle), \(scenario.difficulty.displayTitle). \(scenario.summary)"
        )
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            HStack(spacing: 12) {
                Button {
                    runner.trigger()
                } label: {
                    Label("Run scenario", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(SignalLabTheme.accent)
                .accessibilityIdentifier("LabDetail.runScenario")
                .accessibilityHint("Runs this lab’s scenario.")

                if showsResetButton {
                    Button {
                        runner.reset()
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("LabDetail.reset")
                    .accessibilityHint("Clears run state and restores the default state for this lab.")
                }
            }
        }
    }

    private var goalsSection: some View {
        compactSection(title: "Goals", symbol: "target") {
            VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
                listRows(items: scenario.learningGoals, numbered: false, symbol: "circle.fill")
            }
        }
    }

    private var workflowSection: some View {
        let guide = scenario.investigationGuide
        return compactSection(title: "Workflow", symbol: "map.fill") {
            VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start with")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SignalLabTheme.secondaryText)
                        .textCase(.uppercase)
                    Text(guide.recommendedFirstTool)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SignalLabTheme.accent)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                listRows(items: guide.steps, numbered: true, symbol: "circle.fill")

                if !guide.validationChecklist.isEmpty {
                    Divider()
                    Label("Done when", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SignalLabTheme.secondaryText)
                        .accessibilityAddTraits(.isHeader)
                    listRows(items: guide.validationChecklist, numbered: false, symbol: "checkmark")
                }
            }
        }
    }

    private var toolsAndHintsSection: some View {
        compactSection(title: "Tools & hints", symbol: "wrench.and.screwdriver.fill") {
            VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
                Label("Tools", systemImage: "wrench.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .accessibilityAddTraits(.isHeader)
                listRows(items: scenario.toolRecommendations, numbered: false, symbol: "circle.fill")

                if !scenario.hints.isEmpty {
                    Divider()
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
                            listRows(items: scenario.hints, numbered: false, symbol: "lightbulb.fill")
                        }
                        .padding(.top, 6)
                    } label: {
                        Label("Hints", systemImage: "lightbulb.fill")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(SignalLabTheme.secondaryText)
                }
            }
        }
    }

    private func compactSection<Content: View>(
        title: String,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label(title, systemImage: symbol)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .padding(SignalLabTheme.horizontalPadding / 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SignalLabTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityIdentifier("LabDetail.section.\(title.replacingOccurrences(of: " ", with: ""))")
    }

    @ViewBuilder
    private func listRows(items: [String], numbered: Bool, symbol: String) -> some View {
        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
            HStack(alignment: .top, spacing: 8) {
                if numbered {
                    Text("\(index + 1).")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SignalLabTheme.accent)
                        .frame(width: 22, alignment: .trailing)
                        .accessibilityHidden(true)
                } else {
                    Image(systemName: symbol)
                        .font(.system(size: symbol == "circle.fill" ? 6 : 11, weight: .semibold))
                        .padding(.top, symbol == "circle.fill" ? 6 : 3)
                        .frame(width: 16)
                        .foregroundStyle(SignalLabTheme.accent)
                        .accessibilityHidden(true)
                }
                Text(item)
                    .font(.body)
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityLabel(numbered ? "Step \(index + 1) of \(items.count): \(item)" : item)
        }
    }
}

#Preview("Crash") {
    NavigationStack {
        if let scenario = LabCatalog.scenario(id: iOSLabScenarioID.crash) {
            iOSLabDetailView(scenario: scenario)
        }
    }
}

#Preview("Breakpoint") {
    NavigationStack {
        if let scenario = LabCatalog.scenario(id: iOSLabScenarioID.breakpoint) {
            iOSLabDetailView(scenario: scenario)
        }
    }
}

#Preview("Generic stub") {
    NavigationStack {
        if let scenario = LabCatalog.scenario(id: "retain_cycle") {
            iOSLabDetailView(scenario: scenario)
        }
    }
}

#Preview("CPU Hotspot") {
    NavigationStack {
        if let scenario = LabCatalog.scenario(id: iOSLabScenarioID.cpuHotspot) {
            iOSLabDetailView(scenario: scenario)
        }
    }
}

#Preview("Thread Performance Checker") {
    NavigationStack {
        if let scenario = LabCatalog.scenario(id: iOSLabScenarioID.threadPerformanceChecker) {
            iOSLabDetailView(scenario: scenario)
        }
    }
}
