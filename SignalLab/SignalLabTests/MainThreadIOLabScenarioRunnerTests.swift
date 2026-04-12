//
//  MainThreadIOLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises Main Thread I/O Lab runner (Fixed mode async read; Broken mode is intentionally heavy on main).
//

import Foundation
import Testing
@testable import SignalLab

struct MainThreadIOLabScenarioRunnerTests {
    @Test @MainActor
    func fixedMode_trigger_eventuallyReportsExpectedByteCount() async {
        guard let scenario = LabCatalog.scenario(id: "main_thread_io") else {
            Issue.record("Missing main_thread_io scenario")
            return
        }
        let runner = MainThreadIOLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()

        var observed: Int?
        for _ in 0..<80 {
            if let count = runner.lastReadByteCount {
                observed = count
                break
            }
            try? await Task.sleep(nanoseconds: 25_000_000)
        }
        #expect(observed == 256 * 1024)
        #expect(runner.isReading == false)
    }

    @Test @MainActor
    func brokenMode_trigger_readsOnMainSynchronously() {
        guard let scenario = LabCatalog.scenario(id: "main_thread_io") else {
            Issue.record("Missing main_thread_io scenario")
            return
        }
        let runner = MainThreadIOLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .broken
        runner.trigger()
        #expect(runner.lastReadByteCount == 256 * 1024)
        #expect(runner.isReading == false)
    }

    @Test @MainActor
    func reset_clearsStateAndBlob() async {
        guard let scenario = LabCatalog.scenario(id: "main_thread_io") else {
            Issue.record("Missing main_thread_io scenario")
            return
        }
        let runner = MainThreadIOLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        for _ in 0..<80 {
            if runner.lastReadByteCount != nil { break }
            try? await Task.sleep(nanoseconds: 25_000_000)
        }
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.lastReadByteCount == nil)
        #expect(runner.implementationMode == .broken)
    }
}
