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
    @Test func scenariosSortedForDisplay_hasEighteenCurrentScenarios() {
        let sorted = LabCatalog.scenariosSortedForDisplay
        #expect(sorted.count == 18)
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
        for id in [
            "crash", "break_on_failure", "breakpoint", "memory_graph", "hang", "cpu_hotspot",
            "thread_performance_checker", "zombie_objects", "thread_sanitizer", "malloc_stack_logging",
            "retain_cycle", "heap_growth", "deadlock", "background_thread_ui", "main_thread_io",
            "scroll_hitch", "startup_signpost", "concurrency_isolation",
        ] {
            let found = LabCatalog.scenario(id: id)
            #expect(found != nil)
            #expect(found?.id == id)
        }
    }

    /// Locked curriculum order (`LabRefinement.md` task 1).
    @Test func scenariosSortedForDisplay_matchesLockedCurriculumSlugs() {
        let ids = LabCatalog.scenariosSortedForDisplay.map(\.id)
        #expect(ids == [
            "crash", "break_on_failure", "breakpoint", "memory_graph", "hang", "cpu_hotspot",
            "thread_performance_checker", "zombie_objects", "thread_sanitizer", "malloc_stack_logging",
            "retain_cycle", "heap_growth", "deadlock", "background_thread_ui", "main_thread_io",
            "scroll_hitch", "startup_signpost", "concurrency_isolation",
        ])
    }

    @Test func breakpointLabMetadata_teachesLineBreakpointDiscountScenario() {
        guard let scenario = LabCatalog.scenario(id: "breakpoint") else {
            Issue.record("Missing breakpoint scenario")
            return
        }

        #expect(scenario.supportsBrokenMode)
        #expect(!scenario.supportsFixedMode)
        #expect(scenario.summary.contains("wrong discount calculation"))
        #expect(scenario.investigationGuide.recommendedFirstTool.contains("BreakpointLabDiscountCalculator"))
        #expect(!scenario.reproductionSteps.joined(separator: " ").contains("filter"))
        #expect(!scenario.reproductionSteps.joined(separator: " ").contains("Fixed mode"))
    }
}
