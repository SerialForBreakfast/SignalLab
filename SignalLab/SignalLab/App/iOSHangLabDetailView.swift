//
//  iOSHangLabDetailView.swift
//  SignalLab
//
//  Hang Lab: Broken blocks the main thread; Fixed keeps the UI responsive during the same workload.
//

import SwiftUI

/// Hang Lab shell with live processing state and scroll-friendly layout for Fixed mode.
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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<24, id: \.self) { index in
                        Text("Scroll probe \(index)")
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
            .accessibilityLabel("Horizontal scroll probes—use to test whether the main thread is responsive.")

            Text(
                "Try scrolling the chips horizontally. In Broken mode they do not move while the report runs; in Fixed mode they keep tracking your finger."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
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
