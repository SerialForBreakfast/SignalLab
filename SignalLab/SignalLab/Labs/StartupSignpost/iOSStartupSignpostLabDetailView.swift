//
//  iOSStartupSignpostLabDetailView.swift
//  SignalLab
//
//  Startup Signpost Lab: same main-thread phases with vs without `os_signpost` for Instruments POI.
//

import SwiftUI

/// Detail shell for Startup Signpost Lab.
struct iOSStartupSignpostLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: StartupSignpostLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: StartupSignpostLabScenarioRunner(scenario: scenario))
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
            Label("Startup-style main work", systemImage: "gauge.with.dots.needle.67percent")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(
                "Run scenario simulates three sequential CPU-heavy phases on the main thread—like blocking launch work. "
                    + "Broken omits signposts; Fixed emits `os_signpost` intervals you can read in Instruments > Points of Interest."
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

            Label("Instruments tip", systemImage: "waveform.path.ecg")
                .font(.subheadline.weight(.semibold))
            Text(
                "Product → Profile → choose **Points of Interest** (or **Time Profiler** with POI lanes). "
                    + "Record while tapping Run in Fixed mode; you should see three named intervals."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var footer: some View {
        if let checksum = runner.lastChecksum, runner.triggerInvocationCount > 0 {
            Text("Last checksum: \(checksum)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(SignalLabTheme.success)
                .accessibilityLabel("Last run checksum: \(checksum)")
        }
    }
}
