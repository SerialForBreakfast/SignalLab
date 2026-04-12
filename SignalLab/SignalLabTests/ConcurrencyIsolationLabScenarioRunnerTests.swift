//
//  ConcurrencyIsolationLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Concurrency Isolation Lab — Fixed ordering; Broken records both labels.
//

import Testing
@testable import SignalLab

struct ConcurrencyIsolationLabScenarioRunnerTests {
    @Test @MainActor
    func fixedMode_alwaysAppendsAlphaBeforeBeta() async {
        guard let scenario = LabCatalog.scenario(id: "concurrency_isolation") else {
            Issue.record("Missing concurrency_isolation scenario")
            return
        }
        let runner = ConcurrencyIsolationLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()

        for _ in 0..<60 {
            if runner.completionOrder.count == 2 { break }
            try? await Task.sleep(nanoseconds: 25_000_000)
        }
        #expect(runner.completionOrder == ["alpha", "beta"])
        #expect(runner.lastStatusMessage?.contains("alpha") == true)
    }

    @Test @MainActor
    func brokenMode_eventuallyRecordsBothLabels() async {
        guard let scenario = LabCatalog.scenario(id: "concurrency_isolation") else {
            Issue.record("Missing concurrency_isolation scenario")
            return
        }
        let runner = ConcurrencyIsolationLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .broken
        runner.trigger()

        for _ in 0..<80 {
            if runner.completionOrder.count >= 2 { break }
            try? await Task.sleep(nanoseconds: 25_000_000)
        }
        #expect(runner.completionOrder.count == 2)
        #expect(Set(runner.completionOrder) == Set(["alpha", "beta"]))
    }
}
