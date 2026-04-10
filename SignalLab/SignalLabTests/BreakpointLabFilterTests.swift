//
//  BreakpointLabFilterTests.swift
//  SignalLabTests
//
//  Business rules for Breakpoint Lab filtering (broken vs fixed).
//

import Foundation
import Testing
@testable import SignalLab

struct BreakpointLabFilterTests {
    private let electronicsSwiftQuery = "Swift"

    @Test func brokenMode_ignoresNameWhenCategorySelected() {
        let items = BreakpointLabSampleCatalog.items
        let result = BreakpointLabFilter.applyCatalogFilter(
            items: items,
            normalizedQuery: electronicsSwiftQuery,
            category: .electronics,
            mode: .broken
        )
        let electronicsOnly = items.filter { $0.category == .electronics }
        #expect(result == electronicsOnly)
        #expect(result.count > 0)
    }

    @Test func fixedMode_intersectsCategoryAndName() {
        let items = BreakpointLabSampleCatalog.items
        let result = BreakpointLabFilter.applyCatalogFilter(
            items: items,
            normalizedQuery: electronicsSwiftQuery,
            category: .electronics,
            mode: .fixed
        )
        #expect(result.isEmpty)
    }

    @Test func fixedMode_nameOnly_matchesBooks() {
        let items = BreakpointLabSampleCatalog.items
        let result = BreakpointLabFilter.applyCatalogFilter(
            items: items,
            normalizedQuery: "Swift",
            category: nil,
            mode: .fixed
        )
        #expect(result.count == 1)
        #expect(result.first?.id == "1")
    }
}
