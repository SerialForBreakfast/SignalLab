//
//  ThreadSanitizerLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Thread Sanitizer Lab runner on the main actor (Fixed mode only; Broken mode is racy by design).
//

import Foundation
import Testing
@testable import SignalLab

struct ThreadSanitizerLabScenarioRunnerTests {
    @Test @MainActor
    func fixedMode_trigger_reportsExpectedMergedCounter() {
        guard let scenario = LabCatalog.scenario(id: "thread_sanitizer") else {
            Issue.record("Missing thread_sanitizer scenario")
            return
        }
        let runner = ThreadSanitizerLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        #expect(runner.triggerInvocationCount == 1)
        #expect(runner.lastMergedCounter == 10_000)
        #expect(runner.lastStatusMessage?.contains("10000") == true)
    }

    @Test @MainActor
    func reset_clearsCountersAndStatus() {
        guard let scenario = LabCatalog.scenario(id: "thread_sanitizer") else {
            Issue.record("Missing thread_sanitizer scenario")
            return
        }
        let runner = ThreadSanitizerLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastMergedCounter == nil)
        #expect(runner.lastStatusMessage == nil)
        #expect(runner.implementationMode == .broken)
    }
}
