//
//  CrashLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Crash Lab runner state on the main actor.
//  Note: trigger() always crashes the process — not safe to call from tests.
//

import Foundation
import Testing
@testable import SignalLab

struct CrashLabScenarioRunnerTests {
    @Test @MainActor
    func reset_clearsInvocationCount() {
        guard let scenario = LabCatalog.scenario(id: "crash") else {
            Issue.record("Missing crash scenario")
            return
        }
        let runner = CrashLabScenarioRunner(scenario: scenario)
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
    }

    @Test @MainActor
    func initialState_isClean() {
        guard let scenario = LabCatalog.scenario(id: "crash") else {
            Issue.record("Missing crash scenario")
            return
        }
        let runner = CrashLabScenarioRunner(scenario: scenario)
        #expect(runner.triggerInvocationCount == 0)
    }
}
