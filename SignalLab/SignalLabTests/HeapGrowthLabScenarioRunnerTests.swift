//
//  HeapGrowthLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Heap Growth Lab runner retention behavior on the main actor.
//

import Foundation
import Testing
@testable import SignalLab

struct HeapGrowthLabScenarioRunnerTests {
    @Test @MainActor
    func eachTrigger_retainsEveryChunk() {
        guard let scenario = LabCatalog.scenario(id: "heap_growth") else {
            Issue.record("Missing heap_growth scenario")
            return
        }
        let runner = HeapGrowthLabScenarioRunner(scenario: scenario)
        runner.trigger()
        runner.trigger()
        runner.trigger()
        #expect(runner.retainedChunkCount == 3)
        #expect(runner.approximateRetainedBytes == 3 * 256 * 1024)
    }

    @Test @MainActor
    func reset_clearsRetention() {
        guard let scenario = LabCatalog.scenario(id: "heap_growth") else {
            Issue.record("Missing heap_growth scenario")
            return
        }
        let runner = HeapGrowthLabScenarioRunner(scenario: scenario)
        runner.trigger()
        runner.reset()
        #expect(runner.retainedChunkCount == 0)
        #expect(runner.triggerInvocationCount == 0)
    }
}
