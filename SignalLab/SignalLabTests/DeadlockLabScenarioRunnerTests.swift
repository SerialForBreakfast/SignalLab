//
//  DeadlockLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Deadlock Lab runner state on the main actor.
//  Note: trigger() always deadlocks the process — not safe to call from tests.
//

import Foundation
import Testing
@testable import SignalLab

struct DeadlockLabScenarioRunnerTests {
    @Test @MainActor
    func reset_clearsState() {
        guard let scenario = LabCatalog.scenario(id: "deadlock") else {
            Issue.record("Missing deadlock scenario")
            return
        }
        let runner = DeadlockLabScenarioRunner(scenario: scenario)
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastStatusMessage == nil)
    }

    @Test @MainActor
    func initialState_isClean() {
        guard let scenario = LabCatalog.scenario(id: "deadlock") else {
            Issue.record("Missing deadlock scenario")
            return
        }
        let runner = DeadlockLabScenarioRunner(scenario: scenario)
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastStatusMessage == nil)
    }
}
