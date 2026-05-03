//
//  iOSLabCatalogView.swift
//  SignalLab
//
//  Home screen listing all MVP labs (M0.2.1).
//

import OSLog
import SwiftUI

/// Root catalog of debugging labs.
///
/// ## Lab restoration
/// The last-opened lab ID is persisted in `UserDefaults` so the app can reopen directly to that
/// lab after a process restart — e.g. after relaunching under Instruments (⌘I) or after enabling
/// a scheme diagnostic that requires a fresh Build & Run. On next launch the navigation stack is
/// restored automatically; tapping Back returns to the catalog as normal.
///
/// UI-test deep-link launch args take priority over the restored ID so automated screenshot
/// captures are unaffected.
struct iOSLabCatalogView: View {
    private let scenarios = LabCatalog.scenariosSortedForDisplay

    /// When non-`nil` (e.g. from ``SignalLabLaunchArguments/uitestingScreenshotLabID``), navigates
    /// to that lab once on first appear — takes priority over the persisted last-open lab.
    private let initialDeepLinkLabID: String?

    /// Persisted across process restarts (Instruments relaunch, scheme-diagnostic relaunch, etc.).
    /// Written when any lab detail view appears; cleared when the user navigates back to the catalog.
    @AppStorage("SignalLab.lastOpenLabID") private var lastOpenLabID: String = ""

    @State private var navigationPath = NavigationPath()

    /// Guards restoration so it runs at most once per process lifetime.
    ///
    /// SwiftUI calls the catalog list's `onAppear` both on initial launch AND each time the
    /// user pops back from a lab detail view (the list re-enters the viewport). Without this
    /// flag, the pop-back `onAppear` — where `navigationPath` has just become empty again —
    /// would re-trigger restoration and navigate the user straight back into the lab they
    /// intentionally left. `@State` resets each process restart, so Instruments and scheme
    /// relaunches get a fresh restoration attempt on their first `onAppear`.
    @State private var hasPerformedInitialNavigation = false

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
                    Text("Each lab shows only the controls needed for its debugging task.")
                        .foregroundStyle(SignalLabTheme.secondaryText)
                        .accessibilityLabel(
                            "Footer: each lab shows only the controls needed for its debugging task."
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
                                // Persist so a process restart (Instruments, scheme diagnostics)
                                // can restore directly to this lab.
                                lastOpenLabID = id
                                SignalLabLog.catalog.info("Opened lab detail id=\(scenario.id, privacy: .public) title=\(scenario.title, privacy: .public)")
                            }
                            .onDisappear {
                                // User navigated back to the catalog — clear the restore target
                                // so a subsequent normal launch opens at the catalog list.
                                if lastOpenLabID == id {
                                    lastOpenLabID = ""
                                }
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

                // Run at most once per process lifetime. Subsequent onAppear calls are
                // pop-backs from lab detail views, not fresh launches — skip them.
                guard !hasPerformedInitialNavigation else { return }
                hasPerformedInitialNavigation = true

                // UI-test deep link takes priority over persisted state.
                if let labID = initialDeepLinkLabID, LabCatalog.scenario(id: labID) != nil {
                    navigationPath.append(labID)
                    return
                }

                // Restore the last-open lab if the process was killed externally
                // (Instruments ⌘I relaunch, scheme-diagnostic Build & Run, etc.).
                // onDisappear clears lastOpenLabID when the user navigates back normally,
                // so a clean back-tap → relaunch always opens at the catalog.
                if !lastOpenLabID.isEmpty, LabCatalog.scenario(id: lastOpenLabID) != nil {
                    SignalLabLog.catalog.info("Restoring last-open lab id=\(lastOpenLabID, privacy: .public)")
                    navigationPath.append(lastOpenLabID)
                }
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
