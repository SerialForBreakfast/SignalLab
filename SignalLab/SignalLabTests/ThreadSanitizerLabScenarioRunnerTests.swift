//
//  ThreadSanitizerLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Thread Sanitizer Lab runner state on the main actor.
//  Note: trigger() races a shared counter — not safe to assert a specific counter value from tests.
//

import Foundation
import Testing
@testable import SignalLab

struct ThreadSanitizerLabScenarioRunnerTests {
    @Test @MainActor
    func reset_clearsCountersAndStatus() {
        guard let scenario = LabCatalog.scenario(id: "thread_sanitizer") else {
            Issue.record("Missing thread_sanitizer scenario")
            return
        }
        let runner = ThreadSanitizerLabScenarioRunner(scenario: scenario)
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastStatusMessage == nil)
    }

    @Test @MainActor
    func initialState_isClean() {
        guard let scenario = LabCatalog.scenario(id: "thread_sanitizer") else {
            Issue.record("Missing thread_sanitizer scenario")
            return
        }
        let runner = ThreadSanitizerLabScenarioRunner(scenario: scenario)
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastStatusMessage == nil)
    }
}
