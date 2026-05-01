//
//  StartupSignpostLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Startup Signpost Lab — checksum and status message after trigger.
//

import Testing
@testable import SignalLab

struct StartupSignpostLabScenarioRunnerTests {
    @Test @MainActor
    func trigger_producesChecksum() {
        guard let scenario = LabCatalog.scenario(id: "startup_signpost") else {
            Issue.record("Missing startup_signpost scenario")
            return
        }
        let runner = StartupSignpostLabScenarioRunner(scenario: scenario)
        runner.trigger()
        #expect(runner.lastChecksum != nil)
        #expect(runner.triggerInvocationCount == 1)
    }

    @Test @MainActor
    func trigger_statusMentionsPointsOfInterest() {
        guard let scenario = LabCatalog.scenario(id: "startup_signpost") else {
            Issue.record("Missing startup_signpost scenario")
            return
        }
        let runner = StartupSignpostLabScenarioRunner(scenario: scenario)
        runner.trigger()
        let msg = runner.lastStatusMessage ?? ""
        #expect(msg.localizedCaseInsensitiveContains("Points of Interest") || msg.localizedCaseInsensitiveContains("signpost"))
    }
}
