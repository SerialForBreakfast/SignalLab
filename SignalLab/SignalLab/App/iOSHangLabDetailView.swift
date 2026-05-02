//
//  iOSHangLabDetailView.swift
//  SignalLab
//
//  Hang Lab: CPU-intensive workload runs synchronously on the main thread, blocking UI.
//

import SwiftUI

/// Hang Lab shell with live processing state and horizontal scroll probes.
struct iOSHangLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: HangLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: HangLabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            topInset: { hangLabTopSection },
            actionFooter: { hangLabActionFooter }
        )
    }

    private var hangLabTopSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {

            // Pre-run instructions — always visible so the learner reads them before tapping Run.
            if !runner.isProcessingReport && runner.triggerInvocationCount == 0 {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Before you tap Run scenario:")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.primary)

                    Text(
                        "The app will freeze for about 4 seconds. Use that window to do two things:\n"
                        + "① Try to scroll the chips below — they won't respond.\n"
                        + "② Click Pause (⏸) in the Xcode debug bar."
                    )
                    .font(.footnote)
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                    Text(
                        "After pausing: Xcode opens at frame 0, which may be Swift runtime assembly — that is normal. "
                        + "Scroll the call stack and click HangLabScenarioRunner.trigger() to jump to Swift source. "
                        + "You land on Thread.sleep(forTimeInterval: 4.0) — the single line blocking the main thread."
                    )
                    .font(.footnote)
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "Before you tap Run scenario: the app will freeze for about 4 seconds. "
                    + "Try to scroll the chips — they won't respond. "
                    + "Then click Pause in the Xcode debug bar. "
                    + "After pausing, Xcode opens at assembly — click HangLabScenarioRunner.trigger() in the call stack to land on Thread.sleep, the blocking line."
                )
            }

            if runner.isProcessingReport {
                ProgressView()
                    .tint(SignalLabTheme.accent)
                    .padding(.vertical, 4)
                    .accessibilityLabel("Processing report")
            }

            if let message = runner.lastStatusMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .accessibilityLabel(message)
            }

            Text("Scroll probe — try dragging while the report runs:")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<24, id: \.self) { index in
                        Text("Probe \(index)")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(SignalLabTheme.cardBackground)
                            .clipShape(Capsule())
                            .accessibilityLabel("Scroll probe \(index)")
                    }
                }
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Horizontal scroll probes — use to test whether the main thread is responsive.")
        }
    }

    @ViewBuilder
    private var hangLabActionFooter: some View {
        if runner.triggerInvocationCount > 0, let checksum = runner.lastReportChecksum {
            Text("Last checksum: \(checksum)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(SignalLabTheme.success)
                .accessibilityLabel("Last checksum: \(checksum)")
        }
    }
}

#Preview {
    NavigationStack {
        if let scenario = LabCatalog.scenario(id: "hang") {
            iOSHangLabDetailView(scenario: scenario)
        }
    }
}
