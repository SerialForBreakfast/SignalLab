//
//  BreakpointLabScenarioRunner.swift
//  SignalLab
//
//  Owns search UI state and applies ``BreakpointLabFilter`` on each Run.
//

import Foundation
import Observation
import OSLog

/// Runs the Breakpoint Lab filter scenario (broken vs fixed predicate logic).
///
/// ## Concurrency
/// Main-actor isolated for SwiftUI bindings; filtering is O(n) on a tiny catalog and stays on the main actor for MVP.
@MainActor
@Observable
final class BreakpointLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

    /// Current search text (bound from the text field).
    var searchQuery: String = ""

    /// Optional category filter; `nil` means “all categories”.
    var selectedCategory: BreakpointLabCategory?

    /// Results after the most recent ``trigger()``; empty until first run.
    private(set) var filteredItems: [BreakpointLabItem] = []

    var implementationMode: LabImplementationMode {
        didSet {
            let clamped = LabScenarioModePolicy.clampedMode(
                implementationMode,
                supportsBroken: scenario.supportsBrokenMode,
                supportsFixed: scenario.supportsFixedMode
            )
            if clamped != implementationMode {
                implementationMode = clamped
            }
        }
    }

    /// Full sample catalog (read-only).
    let catalogItems: [BreakpointLabItem]

    /// Designated initializer for dependency injection (custom catalog in tests or previews).
    init(scenario: LabScenario, catalogItems: [BreakpointLabItem]) {
        self.scenario = scenario
        self.catalogItems = catalogItems
        self.implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
    }

    /// Convenience entry point using the built-in sample catalog.
    ///
    /// Uses a separate overload instead of a default parameter so Swift 6 does not evaluate
    /// ``BreakpointLabSampleCatalog/items`` inside a nonisolated default-argument thunk.
    convenience init(scenario: LabScenario) {
        self.init(scenario: scenario, catalogItems: BreakpointLabSampleCatalog.items)
    }

    func trigger() {
        triggerInvocationCount += 1
        let normalized = BreakpointLabFilter.normalizeQuery(searchQuery)
        filteredItems = BreakpointLabFilter.applyCatalogFilter(
            items: catalogItems,
            normalizedQuery: normalized,
            category: selectedCategory,
            mode: implementationMode
        )
        let categoryLabel = selectedCategory.map { $0.rawValue } ?? "all"
        let run = triggerInvocationCount
        let mode = implementationMode.rawValue
        let resultCount = filteredItems.count
        SignalLabLog.breakpointLab.info(
            "trigger run=\(run, privacy: .public) mode=\(mode, privacy: .public) category=\(categoryLabel, privacy: .public) resultCount=\(resultCount, privacy: .public)"
        )
    }

    func reset() {
        triggerInvocationCount = 0
        searchQuery = ""
        selectedCategory = nil
        filteredItems = []
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.breakpointLab.debug("reset")
    }
}
