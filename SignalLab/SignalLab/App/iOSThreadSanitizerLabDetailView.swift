//
//  iOSThreadSanitizerLabDetailView.swift
//  SignalLab
//
//  Thread Sanitizer Lab: in-app shared-counter race (Broken) vs lock-serialized increments (Fixed).
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
            topInset: { guidance },
            actionFooter: { footer }
        )
    }

    private var guidance: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Thread Sanitizer", systemImage: "arrow.triangle.branch")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(
                "Broken mode lets the main thread and a detached task increment one counter without a lock. "
                    + "Fixed mode wraps every increment in the same `NSLock` and waits for both sides to finish."
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
                    title: "1. Enable TSan",
                    body: "Edit Scheme → Run → Diagnostics → enable Thread Sanitizer, then run Broken from Xcode (expect slower launches)."
                )
                LabGuidedDiagnosticLayout.row(
                    title: "2. Read the report",
                    body: "When TSan stops, note both stacks and the shared variable; Fixed mode should run clean."
                )
                LabGuidedDiagnosticLayout.row(
                    title: "3. Not Breakpoint / Hang",
                    body: "Wrong branch logic → Breakpoint Lab. Main-thread freeze → Hang Lab. TSan → unsynchronized memory access."
                )
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        if runner.triggerInvocationCount > 0, let merged = runner.lastMergedCounter {
            Text("Last merged counter (Fixed): \(merged)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(SignalLabTheme.success)
                .accessibilityLabel("Last merged counter: \(merged)")
        } else if runner.triggerInvocationCount > 0 {
            Text("Broken runs do not show a merged counter—enable TSan and inspect the race report.")
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
        }
    }
}
