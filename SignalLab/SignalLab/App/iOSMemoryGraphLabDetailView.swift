//
//  iOSMemoryGraphLabDetailView.swift
//  SignalLab
//
//  Memory Graph Lab: search for one retained checkout session and identify its owner.
//

import SwiftUI

/// Beginner Memory Graph shell with a straight ownership path before Retain Cycle Lab.
struct iOSMemoryGraphLabDetailView: View {
    let scenario: LabScenario
    @State private var runner: MemoryGraphLabScenarioRunner

    init(scenario: LabScenario) {
        self.scenario = scenario
        _runner = State(initialValue: MemoryGraphLabScenarioRunner(scenario: scenario, store: .shared))
    }

    var body: some View {
        iOSLabDetailScaffold(
            scenario: scenario,
            runner: runner,
            topInset: { memoryGraphTopSection },
            actionFooter: { memoryGraphFooter }
        )
    }

    private var memoryGraphTopSection: some View {
        VStack(alignment: .leading, spacing: SignalLabTheme.itemSpacing) {
            Label("Ownership path to find", systemImage: "point.3.connected.trianglepath.dotted")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            MemoryGraphOwnershipPathView(runner: runner)
            MemoryGraphSearchPathView(runner: runner)
        }
    }

    @ViewBuilder
    private var memoryGraphFooter: some View {
        if let message = runner.lastStatusMessage {
            Text(message)
                .font(.footnote)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .accessibilityLabel(message)
        }
    }
}

private struct MemoryGraphOwnershipPathView: View {
    let runner: MemoryGraphLabScenarioRunner

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This lab is not a retain cycle. The first win is a straight owner path:")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SignalLabTheme.secondaryText)

            VStack(alignment: .leading, spacing: 6) {
                Text(runner.storeTypeName)
                Text("-> \(runner.sessionTypeName)")
                Text("-> \(runner.cartTypeName)")
                Text("-> \(runner.receiptTypeName)")
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

private struct MemoryGraphSearchPathView: View {
    let runner: MemoryGraphLabScenarioRunner

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Do this in Xcode")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SignalLabTheme.secondaryText)

            MemoryGraphInstructionRow(
                systemImage: "play.circle",
                title: "Run scenario once",
                detail: "The app creates a checkout session and leaves it in \(runner.storeTypeName)."
            )
            MemoryGraphInstructionRow(
                systemImage: "sidebar.left",
                title: "Open Memory Graph",
                detail: "Use the three-node debug bar button, then show the left navigator if it is hidden."
            )
            MemoryGraphInstructionRow(
                systemImage: "magnifyingglass",
                title: "Search the target name",
                detail: "Search for \(runner.sessionTypeName). Select that app object rather than SwiftUI or AttributeGraph nodes."
            )
            MemoryGraphInstructionRow(
                systemImage: "arrow.right",
                title: "Name the owner",
                detail: "Find \(runner.storeTypeName) holding the session. That is the whole first Memory Graph lesson."
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SignalLabTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct MemoryGraphInstructionRow: View {
    let systemImage: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
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

#Preview {
    NavigationStack {
        if let scenario = LabCatalog.scenario(id: "memory_graph") {
            iOSMemoryGraphLabDetailView(scenario: scenario)
        }
    }
}
