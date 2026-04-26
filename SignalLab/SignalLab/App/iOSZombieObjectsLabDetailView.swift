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
            showsImplementationPicker: false,
            topInset: { guidance },
            actionFooter: { footer }
        )
    }

    private var guidance: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Zombie Objects", systemImage: "eye.trianglebadge.exclamationmark")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(
                "The scenario messages an Objective-C object after its last strong reference is gone—crisp with Zombies on, vague otherwise."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            if let message = runner.lastStatusMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .accessibilityLabel(message)
            }

            VStack(alignment: .leading, spacing: 8) {
                LabGuidedDiagnosticLayout.row(
                    title: "1. Enable Zombies",
                    body: "Edit Scheme → Run → Diagnostics → enable Zombie Objects, then run Broken from Xcode."
                )
                LabGuidedDiagnosticLayout.row(
                    title: "2. Contrast with Retain Cycle Lab",
                    body: "Retain cycles keep objects alive; zombies expose messaging after release—opposite failure modes."
                )
                LabGuidedDiagnosticLayout.row(
                    title: "3. Compare messages",
                    body: "Run with Zombies on, then optionally run again with Zombies off to compare how vague the crash becomes."
                )
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        if runner.triggerInvocationCount > 0 {
            Text("Checklist: scheme set, zombie diagnostic captured, then disable Zombies when finished.")
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
        }
    }
}
