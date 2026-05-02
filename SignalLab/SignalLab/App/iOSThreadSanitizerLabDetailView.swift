//
//  iOSThreadSanitizerLabDetailView.swift
//  SignalLab
//
//  Thread Sanitizer Lab: deliberate data race on a shared counter — main thread and detached task, no lock.
//

import SwiftUI

/// Detail shell for Thread Sanitizer — deliberate data race vs serialized access.
struct iOSThreadSanitizerLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: ThreadSanitizerLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: ThreadSanitizerLabScenarioRunner(scenario: scenario))
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
            Text(runner.lastStatusMessage ?? "Enable TSan and inspect the race report.")
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .accessibilityLabel(runner.lastStatusMessage ?? "Enable Thread Sanitizer and inspect the race report.")
        }
    }
}
