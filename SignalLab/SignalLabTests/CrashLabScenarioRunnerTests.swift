//
//  CrashLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Crash Lab runner state on the main actor (Fixed mode only; Broken mode crashes the process).
//

import Foundation
import Testing
@testable import SignalLab

struct CrashLabScenarioRunnerTests {
    @Test @MainActor
    func fixedMode_trigger_updatesSummaryAndLineCount() {
        guard let scenario = LabCatalog.scenario(id: "crash") else {
            Issue.record("Missing crash scenario")
            return
        }
        let runner = CrashLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        #expect(runner.triggerInvocationCount == 1)
        #expect(runner.lastFixedImportedLineCount == 1)
        #expect(runner.lastFixedImportSummary?.contains("line-2") == true)
    }

    @Test @MainActor
    func reset_clearsImportOutcome() {
        guard let scenario = LabCatalog.scenario(id: "crash") else {
            Issue.record("Missing crash scenario")
            return
        }
        let runner = CrashLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastFixedImportSummary == nil)
        #expect(runner.lastFixedImportedLineCount == nil)
        #expect(runner.implementationMode == .broken)
    }
}
