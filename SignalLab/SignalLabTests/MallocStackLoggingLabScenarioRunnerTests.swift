//
//  MallocStackLoggingLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Malloc Stack Logging Lab runner reuse semantics (Fixed mode).
//

import Foundation
import Testing
@testable import SignalLab

struct MallocStackLoggingLabScenarioRunnerTests {
    @Test @MainActor
    func fixedMode_secondTrigger_allocatesNoFreshRowArraysAfterWarmUp() {
        guard let scenario = LabCatalog.scenario(id: "malloc_stack_logging") else {
            Issue.record("Missing malloc_stack_logging scenario")
            return
        }
        let runner = MallocStackLoggingLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        #expect(runner.lastFreshRowArraysAllocated == 2_000)
        runner.trigger()
        #expect(runner.lastFreshRowArraysAllocated == 0)
    }

    @Test @MainActor
    func brokenMode_eachTrigger_allocatesFreshRows() {
        guard let scenario = LabCatalog.scenario(id: "malloc_stack_logging") else {
            Issue.record("Missing malloc_stack_logging scenario")
            return
        }
        let runner = MallocStackLoggingLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .broken
        runner.trigger()
        #expect(runner.lastFreshRowArraysAllocated == 2_000)
        runner.trigger()
        #expect(runner.lastFreshRowArraysAllocated == 2_000)
    }

    @Test @MainActor
    func reset_clearsBufferAndCounters() {
        guard let scenario = LabCatalog.scenario(id: "malloc_stack_logging") else {
            Issue.record("Missing malloc_stack_logging scenario")
            return
        }
        let runner = MallocStackLoggingLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastFreshRowArraysAllocated == 0)
        #expect(runner.lastStatusMessage == nil)
        #expect(runner.implementationMode == .broken)
    }
}
