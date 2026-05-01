//
//  StubLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises stub runner state transitions on the main actor.
//

import Foundation
import Testing
@testable import SignalLab

struct StubLabScenarioRunnerTests {
    @Test @MainActor
    func trigger_incrementsCount() {
        guard let scenario = LabCatalog.scenario(id: "crash") else {
            Issue.record("Missing crash scenario")
            return
        }
        let runner = StubLabScenarioRunner(scenario: scenario)
        #expect(runner.triggerInvocationCount == 0)
        runner.trigger()
        runner.trigger()
        #expect(runner.triggerInvocationCount == 2)
    }

    @Test @MainActor
    func reset_clearsCount() {
        guard let scenario = LabCatalog.scenario(id: "crash") else {
            Issue.record("Missing crash scenario")
            return
        }
        let runner = StubLabScenarioRunner(scenario: scenario)
        runner.trigger()
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
    }
}
