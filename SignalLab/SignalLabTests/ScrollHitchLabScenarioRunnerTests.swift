//
//  ScrollHitchLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Scroll Hitch Lab runner — auto-scroll nonce and mode messaging.
//

import Testing
@testable import SignalLab

struct ScrollHitchLabScenarioRunnerTests {
    @Test @MainActor
    func trigger_incrementsInvocationAndAutoScrollNonce() {
        guard let scenario = LabCatalog.scenario(id: "scroll_hitch") else {
            Issue.record("Missing scroll_hitch scenario")
            return
        }
        let runner = ScrollHitchLabScenarioRunner(scenario: scenario)
        #expect(runner.autoScrollNonce == 0)
        runner.trigger()
        #expect(runner.triggerInvocationCount == 1)
        #expect(runner.autoScrollNonce == 1)
        #expect(runner.lastStatusMessage?.contains("compositing") == true)
        runner.implementationMode = .fixed
        runner.trigger()
        #expect(runner.autoScrollNonce == 2)
        #expect(runner.lastStatusMessage?.contains("lighter") == true)
    }

    @Test @MainActor
    func reset_restoresDefaults() {
        guard let scenario = LabCatalog.scenario(id: "scroll_hitch") else {
            Issue.record("Missing scroll_hitch scenario")
            return
        }
        let runner = ScrollHitchLabScenarioRunner(scenario: scenario)
        runner.trigger()
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.autoScrollNonce == 0)
        #expect(runner.lastStatusMessage == nil)
    }
}
