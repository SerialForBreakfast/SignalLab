//
//  iOSMallocStackLoggingLabDetailView.swift
//  SignalLab
//
//  Malloc Stack Logging Lab: per-run allocation burst (Broken) vs reused row buffer (Fixed).
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
            topInset: { guidance },
            actionFooter: { footer }
        )
    }

    private var guidance: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Malloc stack logging", systemImage: "square.stack.3d.down.forward")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(
                "Broken mode allocates thousands of fresh string row arrays every run. Fixed mode warms one buffer, then reuses it so "
                    + "steady-state runs should show far fewer allocating call sites in Instruments."
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
                    title: "1. Enable logging",
                    body: "Edit Scheme → Run → Diagnostics → enable Malloc Stack Logging (wording varies by Xcode version)."
                )
                LabGuidedDiagnosticLayout.row(
                    title: "2. Compare modes",
                    body: "Run Broken once, then Fixed twice—second Fixed run should avoid the row-array allocation burst."
                )
                LabGuidedDiagnosticLayout.row(
                    title: "3. Turn it off",
                    body: "Disable after capture—overhead is high compared with everyday debugging."
                )
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        if runner.triggerInvocationCount > 0 {
            let isReuseWin = runner.implementationMode == .fixed && runner.lastFreshRowArraysAllocated == 0
            Text("Last fresh row arrays this run: \(runner.lastFreshRowArraysAllocated)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(isReuseWin ? SignalLabTheme.success : SignalLabTheme.secondaryText)
                .accessibilityLabel("Last fresh row arrays this run: \(runner.lastFreshRowArraysAllocated)")
        }
    }
}
