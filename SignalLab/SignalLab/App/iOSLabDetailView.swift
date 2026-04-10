//
//  iOSLabDetailView.swift
//  SignalLab
//
//  Lab detail routing, shared scaffold, and per-lab runners (Crash Lab + generic stub).
//

import Observation
import SwiftUI

/// Lab scenario slug used for navigation and runner selection.
enum iOSLabScenarioID {
    /// Crash Lab: unsafe JSON import vs validating import.
    static let crash = "crash"
}

/// Routes to the appropriate detail experience for a scenario.
struct iOSLabDetailView: View {
    let scenario: LabScenario

    var body: some View {
        switch scenario.id {
        case iOSLabScenarioID.crash:
            iOSCrashLabDetailView(scenario: scenario)
        default:
            iOSGenericLabDetailView(scenario: scenario)
        }
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
        iOSLabDetailScaffold(scenario: scenario, runner: runner) {
            Group {
                if runner.triggerInvocationCount > 0 {
                    Text(
                        "Scenario ran \(runner.triggerInvocationCount) time(s). "
                            + "Interactive behavior for this lab ships in a later milestone."
                    )
                    .font(.footnote)
                    .foregroundStyle(SignalLabTheme.secondaryText)
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
        iOSLabDetailScaffold(scenario: scenario, runner: runner) {
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
            case .fixed:
                if let summary = runner.lastFixedImportSummary {
                    Text(summary)
                        .font(.footnote)
                        .foregroundStyle(SignalLabTheme.success)
                }
            }
        }
    }
}

// MARK: - Shared scaffold

/// Reusable layout for catalog metadata, mode picker, actions, and investigation content.
private struct iOSLabDetailScaffold<Runner: LabScenarioRunning & Observable, Footer: View>: View {
    let scenario: LabScenario
    @Bindable var runner: Runner
    @ViewBuilder var actionFooter: () -> Footer

    init(
        scenario: LabScenario,
        runner: Runner,
        @ViewBuilder actionFooter: @escaping () -> Footer
    ) {
        self.scenario = scenario
        self.runner = runner
        self.actionFooter = actionFooter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SignalLabTheme.sectionSpacing) {
                header
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
        .background(SignalLabTheme.background)
        .navigationTitle(scenario.title)
        .navigationBarTitleDisplayMode(.inline)
        .tint(SignalLabTheme.accent)
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
        }
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

                Button {
                    runner.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func bulletSection(title: String, items: [String], symbol: String) -> some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label(title, systemImage: symbol)
                .font(.headline)
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .padding(.top, 6)
                        .foregroundStyle(SignalLabTheme.accent)
                    Text(item)
                        .font(.body)
                        .foregroundStyle(SignalLabTheme.secondaryText)
                }
            }
        }
        .padding(SignalLabTheme.horizontalPadding / 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SignalLabTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var investigationSection: some View {
        let guide = scenario.investigationGuide
        return VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Investigation guide", systemImage: "map.fill")
                .font(.headline)
            Text("Start with: \(guide.recommendedFirstTool)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SignalLabTheme.accent)
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

#Preview("Generic") {
    NavigationStack {
        if let scenario = LabCatalog.scenario(id: "breakpoint") {
            iOSLabDetailView(scenario: scenario)
        }
    }
}
