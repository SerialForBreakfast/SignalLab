//
//  LabCatalogTests.swift
//  SignalLabTests
//
//  Validates catalog ordering, cardinality, and identifier uniqueness.
//

import Foundation
import Testing
@testable import SignalLab

struct LabCatalogTests {
    @Test func scenariosSortedForDisplay_hasFiveMVPScenarios() {
        let sorted = LabCatalog.scenariosSortedForDisplay
        #expect(sorted.count == 5)
    }

    @Test func scenariosSortedForDisplay_matchesCatalogSortIndexOrder() {
        let sorted = LabCatalog.scenariosSortedForDisplay
        let indices = sorted.map(\.catalogSortIndex)
        #expect(indices == indices.sorted())
    }

    @Test func scenarioIds_areUnique() {
        let ids = LabCatalog.scenarios.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func scenario_lookupRoundTripsKnownSlugs() {
        for id in ["crash", "breakpoint", "retain_cycle", "hang", "cpu_hotspot"] {
            let found = LabCatalog.scenario(id: id)
            #expect(found != nil)
            #expect(found?.id == id)
        }
    }
}
