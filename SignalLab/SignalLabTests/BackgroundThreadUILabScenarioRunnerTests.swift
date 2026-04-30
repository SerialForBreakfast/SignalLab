//
//  BackgroundThreadUILabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Background Thread UI Lab runner scheduling.
//

import Foundation
import Testing
@testable import SignalLab

struct BackgroundThreadUILabScenarioRunnerTests {
    @Test @MainActor
    func trigger_setsStatusMessage() {
        guard let scenario = LabCatalog.scenario(id: "background_thread_ui") else {
            Issue.record("Missing background_thread_ui scenario")
            return
        }
        let runner = BackgroundThreadUILabScenarioRunner(scenario: scenario)
        runner.trigger()
        #expect(runner.triggerInvocationCount == 1)
        #expect(runner.lastStatusMessage != nil)
    }

    @Test @MainActor
    func reset_clearsRunnerState() {
        guard let scenario = LabCatalog.scenario(id: "background_thread_ui") else {
            Issue.record("Missing background_thread_ui scenario")
            return
        }
        let runner = BackgroundThreadUILabScenarioRunner(scenario: scenario)
        runner.trigger()
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastStatusMessage == nil)
    }
}
