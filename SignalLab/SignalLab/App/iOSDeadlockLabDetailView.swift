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
                "Broken calls `DispatchQueue.main.sync` while already on the main thread—the run never finishes. "
                    + "Pause in Xcode or force-quit. Fixed does the same work inline without waiting on yourself."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            Text(
                "Warning: Broken mode freezes the app. Run it only when SignalLab is launched from Xcode with the debugger attached."
            )
            .font(.footnote.weight(.semibold))
            .foregroundStyle(SignalLabTheme.warning)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(
                "Warning. Broken mode freezes the app. Run only when launched from Xcode with the debugger attached."
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
        if runner.triggerInvocationCount > 0, runner.implementationMode == .fixed {
            Text("Fixed path completed—Hang Lab covers CPU stalls; this lab is about threads waiting on each other (here, main vs main).")
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.success)
        }
    }
}
