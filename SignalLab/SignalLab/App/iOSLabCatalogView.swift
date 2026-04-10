//
//  iOSLabCatalogView.swift
//  SignalLab
//
//  Home screen listing all MVP labs (M0.2.1).
//

import SwiftUI

/// Root catalog of debugging labs.
struct iOSLabCatalogView: View {
    private let scenarios = LabCatalog.scenariosSortedForDisplay

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(scenarios) { scenario in
                        NavigationLink(value: scenario.id) {
                            iOSLabCatalogRowView(scenario: scenario)
                        }
                    }
                } header: {
                    Text("MVP labs")
                } footer: {
                    Text("Each lab ships with Broken and Fixed modes for side-by-side learning.")
                        .foregroundStyle(SignalLabTheme.secondaryText)
                }
            }
            .navigationTitle("SignalLab")
            .navigationDestination(for: String.self) { id in
                if let scenario = LabCatalog.scenario(id: id) {
                    iOSLabDetailView(scenario: scenario)
                } else {
                    Text("Unknown lab")
                        .foregroundStyle(SignalLabTheme.secondaryText)
                }
            }
            .scrollContentBackground(.hidden)
            .background(SignalLabTheme.background)
        }
        .tint(SignalLabTheme.accent)
        .preferredColorScheme(.dark)
    }
}

/// Single row in the lab catalog list.
private struct iOSLabCatalogRowView: View {
    let scenario: LabScenario

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(scenario.title)
                    .font(.headline)
                Spacer()
                Text(scenario.difficulty.displayTitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(SignalLabTheme.secondaryText)
            }
            Text(scenario.category.displayTitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(SignalLabTheme.accent)
            Text(scenario.summary)
                .font(.subheadline)
                .foregroundStyle(SignalLabTheme.secondaryText)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
        .listRowBackground(SignalLabTheme.cardBackground)
    }
}

#Preview {
    iOSLabCatalogView()
}
