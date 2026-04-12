//
//  iOSScrollHitchLabDetailView.swift
//  SignalLab
//
//  Scroll Hitch Lab: programmatic scroll through many rows; Broken applies expensive SwiftUI chrome per row.
//

import SwiftUI

/// Detail shell for Scroll Hitch Lab — vertical scroll stress plus horizontal scroll probes.
struct iOSScrollHitchLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: ScrollHitchLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: ScrollHitchLabScenarioRunner(scenario: scenario))
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
            Label("Scroll frame pacing", systemImage: "chart.xyaxis.line")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(
                "Tap Run scenario to auto-scroll this list. Broken gives each row its own compositing group plus a large shadow—"
                    + "a common recipe for scroll jank. Fixed keeps the same information density with cheaper effects."
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

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(0..<runner.rowCount, id: \.self) { index in
                            scrollHitchRow(index: index)
                                .id("scrollHitch.row.\(index)")
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(minHeight: 220, maxHeight: 280)
                .onChange(of: runner.autoScrollNonce) { _, _ in
                    let last = runner.rowCount - 1
                    withAnimation(.easeInOut(duration: 1.1)) {
                        proxy.scrollTo("scrollHitch.row.\(last)", anchor: .bottom)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Vertical scroll list for scroll hitch exercise.")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<16, id: \.self) { index in
                        Text("Probe \(index)")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(SignalLabTheme.cardBackground)
                            .clipShape(Capsule())
                            .accessibilityLabel("Horizontal scroll probe \(index)")
                    }
                }
            }
            .padding(.vertical, 4)
            .accessibilityLabel("Horizontal scroll probes—use during auto-scroll to feel hitch vs smooth.")

            Text("CPU Hotspot Lab is about algorithmic cost per keystroke; this lab is about how expensive each row is while scrolling.")
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func scrollHitchRow(index: Int) -> some View {
        let base = HStack {
            Text("Row \(index)")
                .font(.subheadline.weight(.medium))
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(SignalLabTheme.secondaryText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SignalLabTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))

        switch runner.implementationMode {
        case .broken:
            base
                .compositingGroup()
                .shadow(color: .black.opacity(0.45), radius: 14, x: 0, y: 8)
        case .fixed:
            base
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
        }
    }

    @ViewBuilder
    private var footer: some View {
        if runner.triggerInvocationCount > 0 {
            Text("Runs: \(runner.triggerInvocationCount)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(SignalLabTheme.secondaryText)
                .accessibilityLabel("Scenario runs: \(runner.triggerInvocationCount)")
        }
    }
}
