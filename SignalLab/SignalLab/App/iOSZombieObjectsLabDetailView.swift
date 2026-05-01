//
//  iOSZombieObjectsLabDetailView.swift
//  SignalLab
//
//  Zombie Objects Lab: in-app use-after-release (Broken) vs safe pool use (Fixed), plus scheme guidance.
//

import SwiftUI

/// Detail shell for Zombie Objects — in-app repro plus Xcode diagnostics.
struct iOSZombieObjectsLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: ZombieObjectsLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: ZombieObjectsLabScenarioRunner(scenario: scenario))
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
            Text(runner.lastStatusMessage ?? "Capture the zombie diagnostic, then disable Zombies when finished.")
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .accessibilityLabel(
                    runner.lastStatusMessage ?? "Capture the zombie diagnostic, then disable Zombies when finished."
                )
        }
    }
}
