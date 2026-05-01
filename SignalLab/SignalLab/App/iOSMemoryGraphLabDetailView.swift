//
//  iOSMemoryGraphLabDetailView.swift
//  SignalLab
//
//  Memory Graph Lab: navigate to one open note and identify what keeps it alive.
//

import SwiftUI

/// Beginner Memory Graph shell with standard scaffold guidance before Retain Cycle Lab.
struct iOSMemoryGraphLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: MemoryGraphLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: MemoryGraphLabScenarioRunner(scenario: scenario, holder: .shared))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            showsResetButton: true,
            runButtonTitle: "Set up lab",
            runButtonAccessibilityHint: "Creates the open note used for the Memory Graph capture.",
            topInset: { EmptyView() },
            actionFooter: { memoryGraphFooter }
        )
    }

    @ViewBuilder
    private var memoryGraphFooter: some View {
        if let message = runner.lastStatusMessage {
            Text(message)
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .accessibilityLabel(message)
        }
    }
}

#Preview {
    NavigationStack {
        if let scenario = LabCatalog.scenario(id: "memory_graph") {
            iOSMemoryGraphLabDetailView(scenario: scenario)
        }
    }
}
