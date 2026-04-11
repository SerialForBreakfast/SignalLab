//
//  HeapGrowthLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Heap Growth Lab runner retention policy on the main actor.
//

import Foundation
import Testing
@testable import SignalLab

struct HeapGrowthLabScenarioRunnerTests {
    @Test @MainActor
    func fixedMode_retainsAtMostSixChunks() {
        guard let scenario = LabCatalog.scenario(id: "heap_growth") else {
            Issue.record("Missing heap_growth scenario")
            return
        }
        let runner = HeapGrowthLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        for _ in 0..<20 {
            runner.trigger()
        }
        #expect(runner.retainedChunkCount == 6)
        #expect(runner.approximateRetainedBytes == 6 * 256 * 1024)
    }

    @Test @MainActor
    func brokenMode_retainsEveryChunk() {
        guard let scenario = LabCatalog.scenario(id: "heap_growth") else {
            Issue.record("Missing heap_growth scenario")
            return
        }
        let runner = HeapGrowthLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .broken
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
        runner.implementationMode = .broken
        runner.trigger()
        runner.reset()
        #expect(runner.retainedChunkCount == 0)
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.implementationMode == .broken)
    }
}
