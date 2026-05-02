//
//  iOSMainThreadIOLabDetailView.swift
//  SignalLab
//
//  Main Thread I/O Lab: repeated synchronous file reads block the main thread.
//

import SwiftUI

/// Detail shell for Main Thread I/O Lab — scroll probes plus read status.
struct iOSMainThreadIOLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: MainThreadIOLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: MainThreadIOLabScenarioRunner(scenario: scenario))
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
            Label("Disk read path", systemImage: "externaldrive")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(
                "Reads a 256 KB temp file multiple times with `Data(contentsOf:)` on the main thread — the UI stalls while each read completes."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            if runner.isReading {
                ProgressView()
                    .tint(SignalLabTheme.accent)
                    .padding(.vertical, 4)
                    .accessibilityLabel("Reading file")
            }

            if let message = runner.lastStatusMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .accessibilityLabel(message)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<20, id: \.self) { index in
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
            .accessibilityLabel("Horizontal scroll probes — try dragging while the read runs to feel the main thread blocking.")

            Text("Try dragging these chips while the read runs — the main thread is blocked so they will not respond.")
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var footer: some View {
        if let bytes = runner.lastReadByteCount, runner.triggerInvocationCount > 0 {
            Text("Last read size (bytes): \(bytes)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(SignalLabTheme.success)
                .accessibilityLabel("Last read size in bytes: \(bytes)")
        }
    }
}
