//
//  CPUHotspotLabScenarioRunner.swift
//  SignalLab
//
//  Observable runner for CPU Hotspot Lab — drives the live search field.
//

import Foundation
import Observation
import OSLog

/// Drives the CPU Hotspot Lab search interaction.
///
/// ## Architecture
///
/// ``displayItems`` is a **computed** property backed by ``searchQuery`` and ``implementationMode``.
/// SwiftUI's `@Observable` tracking registers both as dependencies whenever a view reads
/// ``displayItems``, so the list updates automatically on every keystroke or mode switch — no
/// explicit `onChange` or extra state needed.
///
/// In **Broken** mode the recomputation calls ``CPUHotspotLabSearch/applyBroken(items:query:)``
/// on every change, which re-sorts all 500 items and allocates a `DateFormatter` per item.
/// In **Fixed** mode the same recomputation calls ``CPUHotspotLabSearch/applyFixed(sortedItems:query:)``
/// which is a single-pass `contains` on pre-computed keys.
///
/// ## Concurrency
/// `@MainActor`-isolated for SwiftUI bindings; the expensive Broken-mode work runs intentionally
/// on the main thread to produce a visible stall (the lesson of the lab).
@MainActor
@Observable
final class CPUHotspotLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    /// Full unsorted catalog — passed to Broken mode, which re-sorts on every search call.
    private let items: [CPUHotspotLabItem]

    /// Catalog sorted once at init time (by priority desc, then timestamp desc).
    /// Passed to Fixed mode, which skips the sort entirely.
    private let sortedItems: [CPUHotspotLabItem]

    // MARK: - LabScenarioRunning

    var implementationMode: LabImplementationMode {
        didSet {
            let clamped = LabScenarioModePolicy.clampedMode(
                implementationMode,
                supportsBroken: scenario.supportsBrokenMode,
                supportsFixed: scenario.supportsFixedMode
            )
            if clamped != implementationMode { implementationMode = clamped }
        }
    }

    private(set) var triggerInvocationCount: Int = 0

    /// Current search text — bound directly to the search field.
    /// Mutating this property triggers recomputation of ``displayItems`` via `@Observable`.
    var searchQuery: String = ""

    // MARK: - Live results

    /// Filtered events recomputed on every ``searchQuery`` or ``implementationMode`` change.
    ///
    /// The body of this computed property is the hot path in Broken mode: SwiftUI's observation
    /// system calls it whenever a dependency changes, so typing one character runs the full
    /// ``CPUHotspotLabSearch/applyBroken(items:query:)`` — sort + DateFormatter × 500 + lowercased × 500.
    var displayItems: [CPUHotspotLabItem] {
        CPUHotspotLabSearch.search(
            items: items,
            sortedItems: sortedItems,
            query: searchQuery,
            mode: implementationMode
        )
    }

    // MARK: - Init

    /// Designated initializer — accepts a custom catalog for tests and previews.
    init(scenario: LabScenario, items: [CPUHotspotLabItem]) {
        self.scenario = scenario
        self.items = items
        self.sortedItems = items.sorted { lhs, rhs in
            if lhs.priority != rhs.priority { return lhs.priority > rhs.priority }
            return lhs.timestamp > rhs.timestamp
        }
        self.implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
    }

    /// Convenience initializer using the built-in 500-item sample catalog.
    convenience init(scenario: LabScenario) {
        self.init(scenario: scenario, items: CPUHotspotLabSampleData.items)
    }

    // MARK: - LabScenarioRunning

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        let mode = implementationMode.rawValue
        let query = searchQuery
        let count = displayItems.count
        SignalLabLog.cpuHotspotLab.info(
            "trigger run=\(run, privacy: .public) mode=\(mode, privacy: .public) query='\(query, privacy: .public)' resultCount=\(count, privacy: .public)"
        )
    }

    func reset() {
        triggerInvocationCount = 0
        searchQuery = ""
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.cpuHotspotLab.debug("reset")
    }
}
