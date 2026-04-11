//
//  iOSLabDetailView.swift
//  SignalLab
//
//  Lab detail routing, shared scaffold, and per-lab runners (Crash, Exception Breakpoint, Breakpoint, Retain Cycle, Hang, CPU Hotspot stub, …).
//

import Observation
import OSLog
import SwiftUI

/// Lab scenario slug used for navigation and runner selection.
enum iOSLabScenarioID {
    /// Crash Lab: unsafe JSON import vs validating import.
    static let crash = "crash"
    /// Exception Breakpoint Lab (`break_on_failure`): compare default crash stop vs exception breakpoint policy.
    static let exceptionBreakpoint = "break_on_failure"
    /// Breakpoint Lab: search + category filter with a deterministic logic bug in Broken mode.
    static let breakpoint = "breakpoint"
    /// Retain Cycle Lab: timer strongly retains detail heart in Broken mode.
    static let retainCycle = "retain_cycle"
    /// Hang Lab: main-thread CPU work vs off-main processing.
    static let hang = "hang"
    /// CPU Hotspot Lab: Time Profiler exercise (`cpu_hotspot`); in-app interaction is still a stub.
    static let cpuHotspot = "cpu_hotspot"
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
        case iOSLabScenarioID.retainCycle:
            iOSRetainCycleLabDetailView(scenario: scenario)
        case iOSLabScenarioID.hang:
            iOSHangLabDetailView(scenario: scenario)
        case iOSLabScenarioID.cpuHotspot:
            iOSCPUHotspotLabDetailView(scenario: scenario)
        default:
            iOSGenericLabDetailView(scenario: scenario)
        }
    }
}

// MARK: - Exception Breakpoint Lab

/// Guided detail shell for comparing Xcode's default crash stop with an exception breakpoint.
struct iOSExceptionBreakpointLabDetailView: View {
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
            topInset: { comparisonPromptSection },
            actionFooter: { guidedRunFooter }
        )
    }

    private var comparisonPromptSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Compare the two stops", systemImage: "flag.2.crossed.fill")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(
                "Run the failure once with no added breakpoint, then again after adding an Exception Breakpoint. "
                    + "This lab is about whether Xcode stops earlier or more clearly, not about line breakpoints for logic bugs."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                comparisonRow(
                    title: "Pass 1: Default stop",
                    body: "Reproduce the failure with no extra breakpoint and note the selected frame, stack, and context."
                )
                comparisonRow(
                    title: "Pass 2: Exception Breakpoint",
                    body: "Add an Exception Breakpoint, run the same failure again, and compare what context you got sooner."
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
        if runner.triggerInvocationCount > 0 {
            Text(
                "Use this guided run as a checklist: compare the default stop with the breakpoint stop, then answer what the breakpoint added."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .accessibilityLabel(
                "Use this guided run as a checklist. Compare the default stop with the breakpoint stop, then answer what the breakpoint added."
            )
        }
    }
}

// MARK: - CPU Hotspot Lab

/// Live searchable-list detail view for CPU Hotspot Lab.
///
/// The search field updates ``CPUHotspotLabScenarioRunner/displayItems`` on every keystroke.
/// In **Broken** mode, each update re-sorts 500 items and allocates a `DateFormatter` per item.
/// In **Fixed** mode, the same update is a single-pass `contains` on pre-computed keys.
/// Profile the interaction in Instruments > Time Profiler to see the difference.
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
                "Profiling tip: start a Time Profiler trace in Instruments, then type in Broken mode to capture the hot path."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .accessibilityLabel(
                "Profiling tip: start a Time Profiler trace in Instruments, then type in Broken mode to capture the hot path."
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
                "Type in Broken mode — notice the lag per keystroke. "
                    + "Switch to Fixed and type the same query. "
                    + "Profile both in Instruments > Time Profiler to see the hot path disappear."
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
        iOSLabDetailScaffold(scenario: scenario, runner: runner, topInset: { EmptyView() }) {
            Group {
                crashImportStatus
            }
        }
    }

    @ViewBuilder
    private var crashImportStatus: some View {
        if runner.triggerInvocationCount == 0 {
            EmptyView()
        } else {
            switch runner.implementationMode {
            case .broken:
                Text(
                    "Broken mode performs an unsafe cast on each JSON row. "
                        + "The sample file includes a row that is missing `count`, which terminates the app. "
                        + "Attach the debugger and re-run to investigate."
                )
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.warning)
                .accessibilityLabel(
                    "Broken mode performs an unsafe cast on each JSON row. The sample file includes a row missing count, which terminates the app. Attach the debugger and re-run to investigate."
                )
            case .fixed:
                if let summary = runner.lastFixedImportSummary {
                    Text(summary)
                        .font(.footnote)
                        .foregroundStyle(SignalLabTheme.success)
                        .accessibilityLabel(summary)
                }
            }
        }
    }
}

// MARK: - Breakpoint Lab

/// Breakpoint Lab: search + category controls with filter results after each Run.
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
            Text(
                "Ran filter \(runner.triggerInvocationCount) time(s). "
                    + "Compare result counts between Broken and Fixed for the same inputs."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .accessibilityLabel(
                "Ran filter \(runner.triggerInvocationCount) times. Compare result counts between Broken and Fixed for the same inputs."
            )
        }
    }

    @ViewBuilder
    private var breakpointInteractiveSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Try this", systemImage: "hand.point.up.left.fill")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(
                "Pick Electronics, type Swift in search, tap Run scenario. "
                    + "Broken mode lists every electronics item (query ignored). Fixed mode returns no rows."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            TextField("Search by name", text: $runner.searchQuery)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier("BreakpointLab.searchField")
                .accessibilityHint("Filters catalog items by name when you run the scenario.")

            Picker("Category", selection: $runner.selectedCategory) {
                Text("All categories").tag(Optional<BreakpointLabCategory>.none)
                ForEach(BreakpointLabCategory.allCases) { cat in
                    Text(cat.displayTitle).tag(Optional(cat))
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("BreakpointLab.categoryPicker")
            .accessibilityHint("Choose a category to combine with search when you run the scenario.")

            if !runner.filteredItems.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Matching rows (\(runner.filteredItems.count))")
                        .font(.subheadline.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    ForEach(runner.filteredItems) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text(item.category.displayTitle)
                                .font(.caption)
                                .foregroundStyle(SignalLabTheme.secondaryText)
                        }
                        .font(.subheadline)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.name), category \(item.category.displayTitle)")
                    }
                }
                .padding(SignalLabTheme.horizontalPadding / 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SignalLabTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier("BreakpointLab.resultsList")
            } else if runner.triggerInvocationCount > 0 {
                Text("No rows match the current filters.")
                    .font(.footnote)
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .accessibilityLabel("No rows match the current filters.")
            }
        }
    }
}

// MARK: - Shared scaffold

/// Reusable layout for catalog metadata, mode picker, actions, and investigation content.
struct iOSLabDetailScaffold<Runner: LabScenarioRunning & Observable, Footer: View, Top: View>: View {
    let scenario: LabScenario
    @Bindable var runner: Runner
    @ViewBuilder var topInset: () -> Top
    @ViewBuilder var actionFooter: () -> Footer

    init(
        scenario: LabScenario,
        runner: Runner,
        @ViewBuilder topInset: @escaping () -> Top,
        @ViewBuilder actionFooter: @escaping () -> Footer
    ) {
        self.scenario = scenario
        self.runner = runner
        self.topInset = topInset
        self.actionFooter = actionFooter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SignalLabTheme.sectionSpacing) {
                header
                topInset()
                iOSLabImplementationModePicker(
                    mode: $runner.implementationMode,
                    supportsBrokenMode: scenario.supportsBrokenMode,
                    supportsFixedMode: scenario.supportsFixedMode
                )
                actions
                actionFooter()
                bulletSection(title: "Learning goals", items: scenario.learningGoals, symbol: "target")
                bulletSection(title: "Reproduction", items: scenario.reproductionSteps, symbol: "arrow.triangle.turn.up.right.diamond.fill")
                bulletSection(title: "Suggested tools", items: scenario.toolRecommendations, symbol: "wrench.and.screwdriver.fill")
                bulletSection(title: "Hints", items: scenario.hints, symbol: "lightbulb.fill")
                investigationSection
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
            if slug == iOSLabScenarioID.exceptionBreakpoint {
                SignalLabLog.exceptionBreakpointLab.info("Exception Breakpoint Lab detail visible")
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
                .accessibilityHint("Runs this lab’s scenario using the selected implementation mode.")

                Button {
                    runner.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("LabDetail.reset")
                .accessibilityHint("Clears run state and restores the default broken-or-fixed selection for this lab.")
            }
        }
    }

    private func bulletSection(title: String, items: [String], symbol: String) -> some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label(title, systemImage: symbol)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .padding(.top, 6)
                        .foregroundStyle(SignalLabTheme.accent)
                        .accessibilityHidden(true)
                    Text(item)
                        .font(.body)
                        .foregroundStyle(SignalLabTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityLabel("Step \(index + 1) of \(items.count): \(item)")
            }
        }
        .padding(SignalLabTheme.horizontalPadding / 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SignalLabTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityIdentifier("LabDetail.section.\(title.replacingOccurrences(of: " ", with: ""))")
    }

    private var investigationSection: some View {
        let guide = scenario.investigationGuide
        return VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Investigation guide", systemImage: "map.fill")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text("Start with: \(guide.recommendedFirstTool)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SignalLabTheme.accent)
                .accessibilityAddTraits(.isHeader)
            bulletSection(title: "Steps", items: guide.steps, symbol: "list.bullet.clipboard")
            bulletSection(title: "Validate", items: guide.validationChecklist, symbol: "checkmark.circle")
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
