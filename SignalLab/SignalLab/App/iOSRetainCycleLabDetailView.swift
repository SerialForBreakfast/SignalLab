//
//  iOSRetainCycleLabDetailView.swift
//  SignalLab
//
//  Retain Cycle Lab: Memory Graph navigator + two-object ownership loop.
//

import SwiftUI

/// Retain Cycle Lab shell with Memory Graph–oriented reproduction steps.
struct iOSRetainCycleLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: RetainCycleLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: RetainCycleLabScenarioRunner(scenario: scenario))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            showsImplementationPicker: false,
            showsResetButton: false,
            showsGuidanceSections: false,
            topInset: { retainCycleTopSection },
            actionFooter: { EmptyView() }
        )
    }

    private var retainCycleTopSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Expected Memory Graph shape", systemImage: "point.3.connected.trianglepath.dotted")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            RetainCycleShapeView()
            RetainCycleStatusView(message: runner.statusMessage)
            MemoryGraphPathView()
        }
    }

}

private struct RetainCycleShapeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The bug is one loop between two app objects:")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SignalLabTheme.secondaryText)

            VStack(alignment: .leading, spacing: 6) {
                Text("RetainCycleLabCheckoutScreen")
                Text("-> RetainCycleLabCloseButtonHandler")
                Text("-> RetainCycleLabCheckoutScreen")
            }
            .font(.system(.caption, design: .monospaced).weight(.semibold))
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SignalLabTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}

private struct RetainCycleStatusView: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "info.circle")
            .font(.caption)
            .foregroundStyle(SignalLabTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct MemoryGraphPathView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Do this in Xcode")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SignalLabTheme.secondaryText)

            MemoryGraphPathRow(
                icon: AnyView(MemoryGraphToolbarIcon().frame(width: 22, height: 22)),
                title: "Open Memory Graph",
                detail: "Use the three-node debug bar button or Debug > Debug Workflow > View Memory."
            )
            MemoryGraphPathRow(
                icon: AnyView(Image(systemName: "sidebar.left")),
                title: "Show the left navigator",
                detail: "If it is hidden, click the left sidebar button in the Memory Graph window."
            )
            MemoryGraphPathRow(
                icon: AnyView(Image(systemName: "scope")),
                title: "Select the checkout screen",
                detail: "Expand SignalLab.debug.dylib, then select RetainCycleLabCheckoutScreen."
            )
            MemoryGraphPathRow(
                icon: AnyView(Image(systemName: "arrow.triangle.2.circlepath")),
                title: "Look for the cycle",
                detail: "The checkout screen should point to RetainCycleLabCloseButtonHandler, which points back to the checkout screen."
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SignalLabTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "In Xcode, open Memory Graph. Show the left navigator if it is hidden. Expand SignalLab debug dylib, then select RetainCycleLabCheckoutScreen. It should point to RetainCycleLabCloseButtonHandler, which points back to the checkout screen."
        )
    }
}

private struct MemoryGraphPathRow: View {
    let icon: AnyView
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            icon
                .foregroundStyle(SignalLabTheme.accent)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(SignalLabTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
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

#Preview {
    NavigationStack {
        if let scenario = LabCatalog.scenario(id: "retain_cycle") {
            iOSRetainCycleLabDetailView(scenario: scenario)
        }
    }
}
