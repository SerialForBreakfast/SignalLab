//
//  MainThreadIOLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Main Thread I/O Lab runner (synchronous disk read on the main actor).
//

import Foundation
import Testing
@testable import SignalLab

struct MainThreadIOLabScenarioRunnerTests {
    @Test @MainActor
    func trigger_readsOnMainSynchronously() {
        guard let scenario = LabCatalog.scenario(id: "main_thread_io") else {
            Issue.record("Missing main_thread_io scenario")
            return
        }
        let runner = MainThreadIOLabScenarioRunner(scenario: scenario)
        runner.trigger()
        #expect(runner.lastReadByteCount == 256 * 1024)
        #expect(runner.isReading == false)
    }

    @Test @MainActor
    func reset_clearsStateAndBlob() {
        guard let scenario = LabCatalog.scenario(id: "main_thread_io") else {
            Issue.record("Missing main_thread_io scenario")
            return
        }
        let runner = MainThreadIOLabScenarioRunner(scenario: scenario)
        runner.trigger()
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastReadByteCount == nil)
    }
}
