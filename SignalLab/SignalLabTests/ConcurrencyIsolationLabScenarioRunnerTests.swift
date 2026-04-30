//
//  ConcurrencyIsolationLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Concurrency Isolation Lab — trigger records both labels via racing detached tasks.
//

import Testing
@testable import SignalLab

struct ConcurrencyIsolationLabScenarioRunnerTests {
    @Test @MainActor
    func trigger_eventuallyRecordsBothLabels() async {
        guard let scenario = LabCatalog.scenario(id: "concurrency_isolation") else {
            Issue.record("Missing concurrency_isolation scenario")
            return
        }
        let runner = ConcurrencyIsolationLabScenarioRunner(scenario: scenario)
        runner.trigger()

        for _ in 0..<80 {
            if runner.completionOrder.count >= 2 { break }
            try? await Task.sleep(nanoseconds: 25_000_000)
        }
        #expect(runner.completionOrder.count == 2)
        #expect(Set(runner.completionOrder) == Set(["alpha", "beta"]))
    }
}
