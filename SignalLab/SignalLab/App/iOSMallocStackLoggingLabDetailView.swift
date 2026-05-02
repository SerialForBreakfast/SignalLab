//
//  iOSMallocStackLoggingLabDetailView.swift
//  SignalLab
//
//  Malloc Stack Logging Lab: per-run fresh row-array allocation burst.
//

import SwiftUI

/// Detail shell for Malloc Stack Logging — allocation-heavy path vs reuse.
struct iOSMallocStackLoggingLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: MallocStackLoggingLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: MallocStackLoggingLabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            topInset: { EmptyView() },
            actionFooter: { footer }
        )
    }

    @ViewBuilder
    private var footer: some View {
        if runner.triggerInvocationCount > 0 {
            VStack(alignment: .leading, spacing: 4) {
                if let message = runner.lastStatusMessage {
                    Text(message)
                        .accessibilityLabel(message)
                }
                Text("Last fresh row arrays this run: \(runner.lastFreshRowArraysAllocated)")
                    .monospacedDigit()
                    .accessibilityLabel("Last fresh row arrays this run: \(runner.lastFreshRowArraysAllocated)")
            }
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
        }
    }
}
