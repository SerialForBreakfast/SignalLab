//
//  BreakpointLabScenarioRunner.swift
//  SignalLab
//
//  Owns search UI state and applies ``BreakpointLabFilter`` on each Run.
//

import Foundation
import Observation

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

    init(scenario: LabScenario, catalogItems: [BreakpointLabItem] = BreakpointLabSampleCatalog.items) {
        self.scenario = scenario
        self.catalogItems = catalogItems
        self.implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
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
    }

    func reset() {
        triggerInvocationCount = 0
        searchQuery = ""
        selectedCategory = nil
        filteredItems = []
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
    }
}
