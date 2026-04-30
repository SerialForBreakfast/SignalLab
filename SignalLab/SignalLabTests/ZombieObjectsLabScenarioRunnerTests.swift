//
//  ZombieObjectsLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Zombie Objects Lab runner state on the main actor.
//  Note: trigger() always causes a use-after-release trap — not safe to call from tests.
//

import Foundation
import Testing
@testable import SignalLab

struct ZombieObjectsLabScenarioRunnerTests {
    @Test @MainActor
    func reset_clearsState() {
        guard let scenario = LabCatalog.scenario(id: "zombie_objects") else {
            Issue.record("Missing zombie_objects scenario")
            return
        }
        let runner = ZombieObjectsLabScenarioRunner(scenario: scenario)
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastStatusMessage == nil)
    }

    @Test @MainActor
    func initialState_isClean() {
        guard let scenario = LabCatalog.scenario(id: "zombie_objects") else {
            Issue.record("Missing zombie_objects scenario")
            return
        }
        let runner = ZombieObjectsLabScenarioRunner(scenario: scenario)
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastStatusMessage == nil)
    }
}
