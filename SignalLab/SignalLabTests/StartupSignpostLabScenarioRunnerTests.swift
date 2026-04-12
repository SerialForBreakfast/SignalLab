//
//  StartupSignpostLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Startup Signpost Lab — checksum parity and Fixed-mode status mentions POI/signpost.
//

import Testing
@testable import SignalLab

struct StartupSignpostLabScenarioRunnerTests {
    @Test @MainActor
    func brokenAndFixed_produceMatchingChecksumForSameRunIndex() {
        guard let scenario = LabCatalog.scenario(id: "startup_signpost") else {
            Issue.record("Missing startup_signpost scenario")
            return
        }
        let brokenRunner = StartupSignpostLabScenarioRunner(scenario: scenario)
        brokenRunner.implementationMode = .broken
        brokenRunner.trigger()
        let brokenChecksum = brokenRunner.lastChecksum

        let fixedRunner = StartupSignpostLabScenarioRunner(scenario: scenario)
        fixedRunner.implementationMode = .fixed
        fixedRunner.trigger()
        let fixedChecksum = fixedRunner.lastChecksum

        #expect(brokenChecksum == fixedChecksum)
        #expect(brokenChecksum != nil)
    }

    @Test @MainActor
    func fixedMode_statusMentionsPointsOfInterest() {
        guard let scenario = LabCatalog.scenario(id: "startup_signpost") else {
            Issue.record("Missing startup_signpost scenario")
            return
        }
        let runner = StartupSignpostLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        let msg = runner.lastStatusMessage ?? ""
        #expect(msg.localizedCaseInsensitiveContains("Points of Interest") || msg.localizedCaseInsensitiveContains("signpost"))
    }
}
