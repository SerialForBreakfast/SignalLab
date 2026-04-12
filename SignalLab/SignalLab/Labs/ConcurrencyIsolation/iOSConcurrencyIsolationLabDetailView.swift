//
//  iOSConcurrencyIsolationLabDetailView.swift
//  SignalLab
//
//  Concurrency Isolation Lab: unstructured detached races vs sequential MainActor steps.
//

import SwiftUI

/// Detail shell for Concurrency Isolation Lab.
struct iOSConcurrencyIsolationLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: ConcurrencyIsolationLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: ConcurrencyIsolationLabScenarioRunner(scenario: scenario))
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
            Label("Task ordering vs data races", systemImage: "arrow.triangle.branch")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(
                "Broken fires two `Task.detached` hops that append completion labels on the main actor—order can flip between runs. "
                    + "That is not the same story as Thread Sanitizer Lab (shared mutable memory); start with Xcode concurrency "
                    + "warnings and reasoning about structured `async` work."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            if !runner.completionOrder.isEmpty {
                Text("Completion log: \(runner.completionOrder.joined(separator: ", "))")
                    .font(.footnote.monospaced())
                    .foregroundStyle(SignalLabTheme.accent)
                    .accessibilityLabel("Completion order: \(runner.completionOrder.joined(separator: ", "))")
            }

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
        if runner.triggerInvocationCount > 0 {
            Text("Tap Run again in Broken mode and watch whether alpha precedes beta.")
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
