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
            iOSRetainCycleLabSheetView(
                mode: runner.implementationMode,
                sessionName: "Session \(runner.triggerInvocationCount)"
            )
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
                    + "Increases when broken mode retains the session after dismissing the sheet."
            )

            Text(
                "Broken mode stores a completion handler that captures the session strongly. Open and close several times — the counter climbs because each session cannot deallocate. Fixed mode uses [weak self] so sessions are freed when the sheet closes."
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

/// Detail sheet: shows the session name and mode; the retain cycle lives in the session’s stored closure.
private struct iOSRetainCycleLabSheetView: View {
    let mode: LabImplementationMode
    @StateObject private var session: RetainCycleLabSession
    @Environment(\.dismiss) private var dismiss

    init(mode: LabImplementationMode, sessionName: String) {
        self.mode = mode
        _session = StateObject(wrappedValue: RetainCycleLabSession(name: sessionName, mode: mode))
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: SignalLabTheme.sectionSpacing) {
                Text(mode == .broken
                     ? "Broken: handler retains this session"
                     : "Fixed: weak reference breaks the cycle")
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Session name")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SignalLabTheme.secondaryText)
                        .accessibilityAddTraits(.isHeader)
                    Text(session.sessionName)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(SignalLabTheme.accent)
                        .accessibilityLabel("Session name: \(session.sessionName)")
                }

                Text(
                    mode == .broken
                        ? "This session’s completionHandler captures self strongly. Close this sheet — the live-session counter above will not drop because the session cannot deallocate."
                        : "This session’s completionHandler uses [weak self]. Close this sheet — the session deallocates and the live-session counter drops."
                )
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(SignalLabTheme.horizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(SignalLabTheme.background)
            .navigationTitle("Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .accessibilityHint("Dismisses the session sheet.")
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
