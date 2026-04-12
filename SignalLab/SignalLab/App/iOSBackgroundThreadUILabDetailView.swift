//
//  iOSBackgroundThreadUILabDetailView.swift
//  SignalLab
//
//  Background Thread UI Lab: `onReceive` updates state from notifications posted off-main (Broken) vs on-main (Fixed).
//

import SwiftUI

/// Detail shell for Background Thread UI Lab — notification delivery thread vs UI updates.
struct iOSBackgroundThreadUILabDetailView: View {
    let scenario: LabScenario
    @State private var runner: BackgroundThreadUILabScenarioRunner
    @State private var lastObservedPing: String = ""

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: BackgroundThreadUILabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            topInset: { topSection },
            actionFooter: { footer }
        )
        .onReceive(NotificationCenter.default.publisher(for: BackgroundThreadUILabNotifications.didSignal)) { note in
            let text = (note.userInfo?[BackgroundThreadUILabNotifications.messageKey] as? String) ?? ""
            lastObservedPing = text
        }
    }

    private var topSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Notification → SwiftUI", systemImage: "bolt.horizontal.circle")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(
                "The runner posts the same notification in both modes. Broken delivers from a detached task; Fixed hops to the main actor first. "
                    + "This view updates `lastObservedPing` inside `onReceive`—watch for threading warnings when that handler runs off-main."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            if !lastObservedPing.isEmpty {
                Text("Last observed ping: \(lastObservedPing)")
                    .font(.footnote.monospaced())
                    .foregroundStyle(SignalLabTheme.accent)
                    .accessibilityLabel("Last observed ping: \(lastObservedPing)")
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
            Text("Tip: compare console output for Broken vs Fixed after each Run scenario.")
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
        }
    }
}
