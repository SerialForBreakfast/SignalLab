//
//  BreakpointLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Runner state for Breakpoint Lab on the main actor.
//

import Foundation
import Testing
@testable import SignalLab

struct BreakpointLabScenarioRunnerTests {
    @Test @MainActor
    func trigger_updatesFilteredItemsForBrokenElectronicsAndSwiftQuery() {
        guard let scenario = LabCatalog.scenario(id: "breakpoint") else {
            Issue.record("Missing breakpoint scenario")
            return
        }
        let runner = BreakpointLabScenarioRunner(scenario: scenario)
        runner.searchQuery = "Swift"
        runner.selectedCategory = .electronics
        runner.implementationMode = .broken
        runner.trigger()
        #expect(runner.triggerInvocationCount == 1)
        let expected = BreakpointLabSampleCatalog.items.filter { $0.category == .electronics }
        #expect(runner.filteredItems == expected)
    }

    @Test @MainActor
    func reset_clearsInputsAndResults() {
        guard let scenario = LabCatalog.scenario(id: "breakpoint") else {
            Issue.record("Missing breakpoint scenario")
            return
        }
        let runner = BreakpointLabScenarioRunner(scenario: scenario)
        runner.searchQuery = "x"
        runner.selectedCategory = .books
        runner.trigger()
        runner.reset()
        #expect(runner.searchQuery.isEmpty)
        #expect(runner.selectedCategory == nil)
        #expect(runner.filteredItems.isEmpty)
        #expect(runner.triggerInvocationCount == 0)
    }
}
