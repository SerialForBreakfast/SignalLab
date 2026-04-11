//
//  ZombieObjectsLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Zombie Objects Lab runner on the main actor (Fixed mode only; Broken mode traps the process).
//

import Foundation
import Testing
@testable import SignalLab

struct ZombieObjectsLabScenarioRunnerTests {
    @Test @MainActor
    func fixedMode_trigger_setsStatusMessage() {
        guard let scenario = LabCatalog.scenario(id: "zombie_objects") else {
            Issue.record("Missing zombie_objects scenario")
            return
        }
        let runner = ZombieObjectsLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        #expect(runner.triggerInvocationCount == 1)
        #expect(runner.lastStatusMessage?.contains("autorelease pool") == true)
    }

    @Test @MainActor
    func reset_clearsStatusAndRestoresInitialMode() {
        guard let scenario = LabCatalog.scenario(id: "zombie_objects") else {
            Issue.record("Missing zombie_objects scenario")
            return
        }
        let runner = ZombieObjectsLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastStatusMessage == nil)
        #expect(runner.implementationMode == .broken)
    }
}
