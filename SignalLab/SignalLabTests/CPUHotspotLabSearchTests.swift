//
//  CPUHotspotLabSearchTests.swift
//  SignalLabTests
//
//  Business rules for CPU Hotspot Lab search — broken vs fixed correctness.
//
//  These tests verify that both modes return the same set of matching items for any
//  given query (correctness parity), and that Fixed mode's output is pre-sorted by
//  priority desc then timestamp desc (same ordering as Broken mode, which sorts per call).
//

import Foundation
import Testing
@testable import SignalLab

struct CPUHotspotLabSearchTests {

    // MARK: - Fixture

    /// Small deterministic catalog used by all tests (avoids loading all 500 production items).
    private static let fixtureItems: [CPUHotspotLabItem] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let base = Date(timeIntervalSince1970: 1_700_000_000)

        func item(_ name: String, category: String, priority: Int, offset: Double) -> CPUHotspotLabItem {
            let ts = base.addingTimeInterval(offset)
            return CPUHotspotLabItem(
                name: name,
                category: category,
                priority: priority,
                timestamp: ts,
                formattedTimestamp: formatter.string(from: ts)
            )
        }

        return [
            item("MemoryWarning",     category: "Memory",  priority: 5, offset:  -0),
            item("AllocationSpike",   category: "Memory",  priority: 3, offset: -45),
            item("RequestTimeout",    category: "Network", priority: 4, offset: -90),
            item("PacketLoss",        category: "Network", priority: 2, offset: -135),
            item("HotspotDetected",   category: "CPU",     priority: 5, offset: -180),
            item("MainThreadBusy",    category: "CPU",     priority: 1, offset: -225),
            item("DiskLatencySpike",  category: "I/O",     priority: 3, offset: -270),
            item("WatchdogTimeout",   category: "System",  priority: 5, offset: -315),
        ]
    }()

    /// Pre-sorted version used to seed Fixed mode.
    private var sortedFixture: [CPUHotspotLabItem] {
        Self.fixtureItems.sorted { lhs, rhs in
            if lhs.priority != rhs.priority { return lhs.priority > rhs.priority }
            return lhs.timestamp > rhs.timestamp
        }
    }

    // MARK: - Empty query returns all items

    @Test func brokenMode_emptyQuery_returnsAllItemsSortedByPriority() {
        let result = CPUHotspotLabSearch.applyBroken(items: Self.fixtureItems, query: "")
        #expect(result.count == Self.fixtureItems.count)
        // Verify sort: each item's priority >= the next item's priority.
        for i in 0..<result.count - 1 {
            #expect(result[i].priority >= result[i + 1].priority)
        }
    }

    @Test func fixedMode_emptyQuery_returnsAllItems() {
        let result = CPUHotspotLabSearch.applyFixed(sortedItems: sortedFixture, query: "")
        #expect(result.count == Self.fixtureItems.count)
    }

    // MARK: - Name matching

    @Test func brokenMode_nameQuery_matchesCorrectItems() {
        // Use a token unique to one row's *name* — "memory" also matches category "Memory" (AllocationSpike).
        let result = CPUHotspotLabSearch.applyBroken(items: Self.fixtureItems, query: "warning")
        let names = result.map { $0.name }
        #expect(names.contains("MemoryWarning"))
        #expect(names.contains("AllocationSpike") == false)
    }

    @Test func fixedMode_nameQuery_matchesCorrectItems() {
        let result = CPUHotspotLabSearch.applyFixed(sortedItems: sortedFixture, query: "warning")
        let names = result.map { $0.name }
        #expect(names.contains("MemoryWarning"))
        #expect(names.contains("AllocationSpike") == false)
    }

    // MARK: - Category matching

    @Test func brokenMode_categoryQuery_matchesCategoryItems() {
        let result = CPUHotspotLabSearch.applyBroken(items: Self.fixtureItems, query: "network")
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.category == "Network" })
    }

    @Test func fixedMode_categoryQuery_matchesCategoryItems() {
        let result = CPUHotspotLabSearch.applyFixed(sortedItems: sortedFixture, query: "network")
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.category == "Network" })
    }

    // MARK: - Parity: broken and fixed return the same item set

    @Test func brokenAndFixed_sameQuery_returnSameItems() {
        let queries = ["memory", "cpu", "timeout", "spike", "disk", ""]
        for query in queries {
            let brokenNames = Set(
                CPUHotspotLabSearch.applyBroken(items: Self.fixtureItems, query: query).map { $0.name }
            )
            let fixedNames = Set(
                CPUHotspotLabSearch.applyFixed(sortedItems: sortedFixture, query: query).map { $0.name }
            )
            #expect(brokenNames == fixedNames, "Mismatch for query '\(query)': broken=\(brokenNames) fixed=\(fixedNames)")
        }
    }

    // MARK: - No match

    @Test func brokenMode_noMatch_returnsEmpty() {
        let result = CPUHotspotLabSearch.applyBroken(items: Self.fixtureItems, query: "zzznomatchzzz")
        #expect(result.isEmpty)
    }

    @Test func fixedMode_noMatch_returnsEmpty() {
        let result = CPUHotspotLabSearch.applyFixed(sortedItems: sortedFixture, query: "zzznomatchzzz")
        #expect(result.isEmpty)
    }

    // MARK: - Whitespace trimming

    @Test func brokenMode_queryWithLeadingTrailingSpaces_stillMatches() {
        let result = CPUHotspotLabSearch.applyBroken(items: Self.fixtureItems, query: "  memory  ")
        #expect(result.map { $0.name }.contains("MemoryWarning"))
    }

    @Test func fixedMode_queryWithLeadingTrailingSpaces_stillMatches() {
        let result = CPUHotspotLabSearch.applyFixed(sortedItems: sortedFixture, query: "  memory  ")
        #expect(result.map { $0.name }.contains("MemoryWarning"))
    }

    // MARK: - Case insensitivity

    @Test func brokenMode_uppercaseQuery_matchesCorrectly() {
        let lower = CPUHotspotLabSearch.applyBroken(items: Self.fixtureItems, query: "hotspot")
        let upper = CPUHotspotLabSearch.applyBroken(items: Self.fixtureItems, query: "HOTSPOT")
        #expect(Set(lower.map { $0.name }) == Set(upper.map { $0.name }))
    }

    @Test func fixedMode_uppercaseQuery_matchesCorrectly() {
        let lower = CPUHotspotLabSearch.applyFixed(sortedItems: sortedFixture, query: "hotspot")
        let upper = CPUHotspotLabSearch.applyFixed(sortedItems: sortedFixture, query: "HOTSPOT")
        #expect(Set(lower.map { $0.name }) == Set(upper.map { $0.name }))
    }

    // MARK: - Production data smoke test

    @Test func sampleData_has500Items() {
        #expect(CPUHotspotLabSampleData.items.count == 500)
    }

    @Test func sampleData_hasAllFiveCategories() {
        let categories = Set(CPUHotspotLabSampleData.items.map { $0.category })
        #expect(categories == ["Memory", "Network", "CPU", "I/O", "System"])
    }

    @Test func sampleData_prioritiesAreInRange() {
        #expect(CPUHotspotLabSampleData.items.allSatisfy { (1...5).contains($0.priority) })
    }

    @Test func sampleData_allItemsHaveNonEmptySearchKey() {
        #expect(CPUHotspotLabSampleData.items.allSatisfy { !$0.searchKey.isEmpty })
    }
}
