//
//  iOSRetainCycleLabDetailView.swift
//  SignalLab
//
//  Retain Cycle Lab: live checkout session counter + closure-based lifetime bug.
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
                checkoutName: "Checkout \(runner.triggerInvocationCount)"
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
                    Text("Live checkout sessions")
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
                "Live checkout sessions: \(sessionTracker.liveSessionCount). "
                    + "Increases when broken mode retains the checkout session after dismissing the sheet."
            )

            Text("Run scenario opens a checkout session. Close it after each run. The counter should return to zero; if it keeps climbing, use Memory Graph to find what still owns the closed checkout sessions.")
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            MemoryGraphButtonHintView()

            MemoryGraphSearchTargetView()
        }
    }

    @ViewBuilder
    private var retainCycleActionFooter: some View {
        if runner.triggerInvocationCount > 0 {
            Text(
                "Opened checkout \(runner.triggerInvocationCount) time(s). "
                    + "Close the sheet each time before opening again to stack leaked checkout sessions in Broken mode."
            )
            .font(.footnote)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .accessibilityLabel(
                "Opened checkout \(runner.triggerInvocationCount) times. Close the sheet each time before opening again to stack leaked checkout sessions in Broken mode."
            )
        }
    }
}

private struct MemoryGraphButtonHintView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            MemoryGraphToolbarIcon()
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)

            Text("Memory Graph button: three connected nodes. Menu path: Debug > Debug Workflow > View Memory.")
                .font(.caption)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SignalLabTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Memory Graph button: three connected nodes. Menu path: Debug, Debug Workflow, View Memory.")
    }
}

private struct MemoryGraphSearchTargetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Memory Graph search")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SignalLabTheme.secondaryText)
            Text("RetainCycleLabCheckoutSession")
                .font(.callout.monospaced().weight(.semibold))
                .foregroundStyle(SignalLabTheme.accent)
            Text("Type this exact class name into the Memory Graph search field. The matching node is the closed checkout session that should have gone away.")
                .font(.caption)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SignalLabTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Memory Graph search: RetainCycleLabCheckoutSession. Type this exact class name into the Memory Graph search field.")
    }
}

private struct MemoryGraphToolbarIcon: View {
    var body: some View {
        Canvas { context, size in
            let points = [
                CGPoint(x: size.width * 0.28, y: size.height * 0.30),
                CGPoint(x: size.width * 0.28, y: size.height * 0.72),
                CGPoint(x: size.width * 0.72, y: size.height * 0.50),
            ]
            var path = Path()
            path.move(to: points[0])
            path.addLine(to: points[2])
            path.move(to: points[1])
            path.addLine(to: points[2])
            context.stroke(path, with: .color(SignalLabTheme.secondaryText), lineWidth: 1.4)

            for point in points {
                let rect = CGRect(x: point.x - 2.8, y: point.y - 2.8, width: 5.6, height: 5.6)
                context.stroke(Path(ellipseIn: rect), with: .color(SignalLabTheme.secondaryText), lineWidth: 1.4)
            }
        }
    }
}

/// Detail sheet: shows the checkout name and mode; the retain cycle lives in the checkout session’s stored closure.
private struct iOSRetainCycleLabSheetView: View {
    let mode: LabImplementationMode
    @StateObject private var checkoutSession: RetainCycleLabCheckoutSession
    @Environment(\.dismiss) private var dismiss

    init(mode: LabImplementationMode, checkoutName: String) {
        self.mode = mode
        _checkoutSession = StateObject(wrappedValue: RetainCycleLabCheckoutSession(name: checkoutName, mode: mode))
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: SignalLabTheme.sectionSpacing) {
                Text(mode == .broken
                     ? "Broken: watch after close"
                     : "Fixed: should deallocate")
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Checkout session")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SignalLabTheme.secondaryText)
                        .accessibilityAddTraits(.isHeader)
                    Text(checkoutSession.checkoutName)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(SignalLabTheme.accent)
                        .accessibilityLabel("Checkout session: \(checkoutSession.checkoutName)")
                }

                Text(
                    mode == .broken
                        ? "Close this checkout, then watch whether the live checkout sessions counter returns to zero."
                        : "Close this checkout. The live checkout sessions counter should return to zero after dismissal."
                )
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(SignalLabTheme.horizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(SignalLabTheme.background)
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .accessibilityHint("Dismisses the checkout session sheet.")
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
