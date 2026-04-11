//
//  iOSHeapGrowthLabDetailView.swift
//  SignalLab
//
//  Heap Growth Lab: unbounded chunk retention vs capped ring buffer (Instruments / Memory Graph narrative).
//

import SwiftUI

/// Detail shell for Heap Growth Lab — live byte growth without a retain cycle.
struct iOSHeapGrowthLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: HeapGrowthLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: HeapGrowthLabScenarioRunner(scenario: scenario))
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
            Label("Live footprint", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(
                "Broken mode keeps every 256 KB chunk you allocate—resident size climbs even when nothing forms a cycle. "
                    + "Fixed mode drops the oldest chunks after six so the lab’s buffer stops growing."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            if runner.triggerInvocationCount > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Retained chunks: \(runner.retainedChunkCount)")
                        .font(.subheadline.monospacedDigit())
                    Text("Approx. live bytes: \(runner.approximateRetainedBytes)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(SignalLabTheme.secondaryText)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "Retained chunks \(runner.retainedChunkCount), approximate live bytes \(runner.approximateRetainedBytes)"
                )
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
        if runner.triggerInvocationCount > 0, runner.implementationMode == .fixed {
            Text("Fixed mode should plateau near six chunks—profile Broken vs Fixed in Instruments > Allocations.")
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.success)
        }
    }
}
