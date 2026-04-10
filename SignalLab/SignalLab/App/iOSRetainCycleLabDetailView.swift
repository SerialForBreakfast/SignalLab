//
//  iOSRetainCycleLabDetailView.swift
//  SignalLab
//
//  Retain Cycle Lab: live session counter + sheet with timer-based leak (Broken) vs teardown (Fixed).
//

import SwiftUI

/// Retain Cycle Lab shell with Memory Graph–oriented reproduction steps.
struct iOSRetainCycleLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: RetainCycleLabScenarioRunner
    @ObservedObject private var sessionTracker = RetainCycleLabSessionTracker.shared

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: RetainCycleLabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        @Bindable var runnerBinding = runner
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            topInset: { retainCycleTopSection },
            actionFooter: { retainCycleActionFooter }
        )
        .sheet(isPresented: $runnerBinding.isDetailSheetPresented) {
            iOSRetainCycleLabSheetView(mode: runner.implementationMode)
        }
    }

    private var retainCycleTopSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Leak signal", systemImage: "waveform.path.ecg")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            HStack(spacing: 12) {
                Image(systemName: "cpu")
                    .foregroundStyle(SignalLabTheme.accent)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live detail sessions")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SignalLabTheme.secondaryText)
                    Text("\(sessionTracker.liveSessionCount)")
                        .font(.title2.monospacedDigit().weight(.semibold))
                        .foregroundStyle(
                            sessionTracker.liveSessionCount > 1 ? SignalLabTheme.warning : SignalLabTheme.secondaryText
                        )
                }
            }
            .padding(SignalLabTheme.horizontalPadding / 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SignalLabTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "Live detail sessions: \(sessionTracker.liveSessionCount). "
                    + "Increases when broken mode retains detail after dismissing the sheet."
            )

            Text(
                "Broken mode keeps a repeating timer that strongly retains the detail controller after you dismiss the sheet—open and close several times and watch this counter climb. Fixed mode invalidates the timer when the sheet goes away."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var retainCycleActionFooter: some View {
        if runner.triggerInvocationCount > 0 {
            Text(
                "Opened detail \(runner.triggerInvocationCount) time(s). "
                    + "Dismiss the sheet each time before opening again to stack leaked sessions in Broken mode."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .accessibilityLabel(
                "Opened detail \(runner.triggerInvocationCount) times. Dismiss the sheet each time before opening again to stack leaked sessions in Broken mode."
            )
        }
    }
}

/// Detail sheet: ticking timer + explanation; Fixed mode stops the timer in `onDisappear`.
private struct iOSRetainCycleLabSheetView: View {
    let mode: LabImplementationMode
    @StateObject private var heart: RetainCycleLabDetailHeart
    @Environment(\.dismiss) private var dismiss

    init(mode: LabImplementationMode) {
        self.mode = mode
        _heart = StateObject(wrappedValue: RetainCycleLabDetailHeart(mode: mode))
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: SignalLabTheme.sectionSpacing) {
                Text(mode == .broken ? "Broken: timer retains this screen" : "Fixed: timer stops on dismiss")
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)

                Text("Timer ticks (visible activity)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .accessibilityAddTraits(.isHeader)
                Text("\(heart.tickCount)")
                    .font(.largeTitle.monospacedDigit().weight(.bold))
                    .foregroundStyle(SignalLabTheme.accent)
                    .accessibilityLabel("Timer tick count: \(heart.tickCount)")

                Text(
                    mode == .broken
                        ? "The timer’s closure captures this object strongly. After you close the sheet, the instance stays alive and the live-session counter above does not drop."
                        : "When this sheet disappears, the timer is invalidated so this object can deallocate and the live-session counter decreases."
                )
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(SignalLabTheme.horizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(SignalLabTheme.background)
            .navigationTitle("Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .accessibilityHint("Dismisses the detail sheet.")
                }
            }
            .onDisappear {
                if mode == .fixed {
                    heart.stopTimerForTeardown()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        if let scenario = LabCatalog.scenario(id: "retain_cycle") {
            iOSRetainCycleLabDetailView(scenario: scenario)
        }
    }
}
