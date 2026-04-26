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
/// ``displayItems`` is a **computed** property backed by ``searchQuery``.
/// SwiftUI's `@Observable` tracking registers it as a dependency whenever a view reads
/// ``displayItems``, so the list updates automatically on every keystroke — no
/// explicit `onChange` or extra state needed.
///
/// Every recomputation calls ``CPUHotspotLabSearch/applyBroken(items:query:)``,
/// which re-sorts all 500 items and allocates a `DateFormatter` per item.
///
/// ## Concurrency
/// `@MainActor`-isolated for SwiftUI bindings; the expensive work runs intentionally
/// on the main thread to produce a visible stall (the lesson of the lab).
@MainActor
@Observable
final class CPUHotspotLabScenarioRunner: LabScenarioRunning {
    /// Full unsorted catalog — re-sorted on every search call (Hotspot 1).
    private let items: [CPUHotspotLabItem]

    // MARK: - LabScenarioRunning

    private(set) var triggerInvocationCount: Int = 0

    /// Current search text — bound directly to the search field.
    /// Mutating this property triggers recomputation of ``displayItems`` via `@Observable`.
    var searchQuery: String = ""

    // MARK: - Live results

    /// Filtered events recomputed on every ``searchQuery`` change.
    ///
    /// The body of this computed property is the hot path: SwiftUI's observation
    /// system calls it whenever a dependency changes, so typing one character runs the full
    /// ``CPUHotspotLabSearch/applyBroken(items:query:)`` — sort + DateFormatter × 500 + lowercased × 500.
    var displayItems: [CPUHotspotLabItem] {
        CPUHotspotLabSearch.search(
            items: items,
            query: searchQuery
        )
    }

    // MARK: - Init

    /// Designated initializer — accepts a custom catalog for tests and previews.
    init(scenario _: LabScenario, items: [CPUHotspotLabItem]) {
        self.items = items
    }

    /// Convenience initializer using the built-in 500-item sample catalog.
    convenience init(scenario: LabScenario) {
        self.init(scenario: scenario, items: CPUHotspotLabSampleData.items)
    }

    // MARK: - LabScenarioRunning

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        let query = searchQuery
        let count = displayItems.count
        SignalLabLog.cpuHotspotLab.info(
            "trigger run=\(run, privacy: .public) query='\(query, privacy: .public)' resultCount=\(count, privacy: .public)"
        )
    }

    func reset() {
        triggerInvocationCount = 0
        searchQuery = ""
        SignalLabLog.cpuHotspotLab.debug("reset")
    }
}
