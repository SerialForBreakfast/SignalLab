//
//  iOSLabCatalogView.swift
//  SignalLab
//
//  Home screen listing all MVP labs (M0.2.1).
//

import OSLog
import SwiftUI

/// Root catalog of debugging labs.
struct iOSLabCatalogView: View {
    private let scenarios = LabCatalog.scenariosSortedForDisplay

    /// When non-`nil` (e.g. from ``SignalLabLaunchArguments/uitestingScreenshotLabID``), navigates to that lab once on first appear.
    private let initialDeepLinkLabID: String?

    @State private var navigationPath = NavigationPath()

    init(initialDeepLinkLabID: String? = nil) {
        self.initialDeepLinkLabID = initialDeepLinkLabID
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                Section {
                    ForEach(scenarios) { scenario in
                        NavigationLink(value: scenario.id) {
                            iOSLabCatalogRowView(scenario: scenario)
                        }
                        .accessibilityIdentifier("SignalLab.catalog.row.\(scenario.id)")
                    }
                } header: {
                    Text("MVP labs")
                        .accessibilityAddTraits(.isHeader)
                } footer: {
                    Text("Most labs include Broken and Fixed modes; a few diagnostics are Xcode-only checklists.")
                        .foregroundStyle(SignalLabTheme.secondaryText)
                        .accessibilityLabel(
                            "Footer: most labs include broken and fixed modes; some diagnostics are Xcode-only checklists."
                        )
                }
            }
            .accessibilityIdentifier("SignalLab.catalog.list")
            .navigationTitle("SignalLab")
            .navigationDestination(for: String.self) { id in
                Group {
                    if let scenario = LabCatalog.scenario(id: id) {
                        iOSLabDetailView(scenario: scenario)
                            .onAppear {
                                SignalLabLog.catalog.info("Opened lab detail id=\(scenario.id, privacy: .public) title=\(scenario.title, privacy: .public)")
                            }
                    } else {
                        Text("Unknown lab")
                            .foregroundStyle(SignalLabTheme.secondaryText)
                            .accessibilityLabel("Unknown lab identifier")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(SignalLabTheme.background)
            .onAppear {
                SignalLabLog.catalog.info("Catalog list visible—\(scenarios.count, privacy: .public) scenario(s)")
                guard navigationPath.isEmpty,
                      let labID = initialDeepLinkLabID,
                      LabCatalog.scenario(id: labID) != nil
                else { return }
                navigationPath.append(labID)
            }
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(scenario.title), \(scenario.category.displayTitle), \(scenario.difficulty.displayTitle). \(scenario.summary)")
        .accessibilityHint("Opens this lab’s detail and instructions.")
    }
}

#Preview {
    iOSLabCatalogView()
}
