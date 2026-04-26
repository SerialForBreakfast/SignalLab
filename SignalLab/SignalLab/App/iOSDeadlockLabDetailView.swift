//
//  iOSDeadlockLabDetailView.swift
//  SignalLab
//
//  Deadlock Lab: main-queue `sync` from main (Broken) vs safe inline work (Fixed).
//

import SwiftUI

/// Detail shell for Deadlock Lab — textbook main-thread self-deadlock.
struct iOSDeadlockLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: DeadlockLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: DeadlockLabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            showsImplementationPicker: false,
            topInset: { topSection },
            actionFooter: { footer }
        )
    }

    private var topSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Main-queue deadlock", systemImage: "arrow.triangle.merge")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(
                "This scenario calls `DispatchQueue.main.sync` while already on the main thread—the run never finishes. "
                    + "Pause in Xcode to inspect the wait, then stop and relaunch the app."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            Text(
                "Warning: Run scenario freezes the app. Run it only when SignalLab is launched from Xcode with the debugger attached."
            )
            .font(.footnote.weight(.semibold))
            .foregroundStyle(SignalLabTheme.warning)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(
                "Warning. Run scenario freezes the app. Run only when launched from Xcode with the debugger attached."
            )

            if let message = runner.lastStatusMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .accessibilityLabel(message)
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        EmptyView()
    }
}
