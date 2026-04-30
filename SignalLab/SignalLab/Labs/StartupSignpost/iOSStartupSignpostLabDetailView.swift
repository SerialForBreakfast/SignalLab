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
            topInset: { EmptyView() },
            actionFooter: { footer }
        )
    }

    @ViewBuilder
    private var footer: some View {
        if runner.triggerInvocationCount > 0 {
            VStack(alignment: .leading, spacing: 4) {
                if let message = runner.lastStatusMessage {
                    Text(message)
                        .accessibilityLabel(message)
                }
                if let checksum = runner.lastChecksum {
                    Text("Last checksum: \(checksum)")
                        .monospacedDigit()
                        .foregroundStyle(SignalLabTheme.success)
                        .accessibilityLabel("Last run checksum: \(checksum)")
                }
            }
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
        }
    }
}
