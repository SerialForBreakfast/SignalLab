//
//  DeadlockLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Deadlock Lab runner on the main actor (Fixed mode only; Broken mode deadlocks the process).
//

import Foundation
import Testing
@testable import SignalLab

struct DeadlockLabScenarioRunnerTests {
    @Test @MainActor
    func fixedMode_trigger_completesWithMessage() {
        guard let scenario = LabCatalog.scenario(id: "deadlock") else {
            Issue.record("Missing deadlock scenario")
            return
        }
        let runner = DeadlockLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        #expect(runner.triggerInvocationCount == 1)
        #expect(runner.lastStatusMessage?.contains("main queue") == true)
    }

    @Test @MainActor
    func reset_clearsState() {
        guard let scenario = LabCatalog.scenario(id: "deadlock") else {
            Issue.record("Missing deadlock scenario")
            return
        }
        let runner = DeadlockLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastStatusMessage == nil)
        #expect(runner.implementationMode == .broken)
    }
}
