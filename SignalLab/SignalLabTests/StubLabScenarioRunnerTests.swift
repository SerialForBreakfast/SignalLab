//
//  StubLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises stub runner state transitions on the main actor.
//

import Foundation
import Testing
@testable import SignalLab

struct StubLabScenarioRunnerTests {
    @Test @MainActor
    func trigger_incrementsCount() {
        guard let scenario = LabCatalog.scenario(id: "crash") else {
            Issue.record("Missing crash scenario")
            return
        }
        let runner = StubLabScenarioRunner(scenario: scenario)
        #expect(runner.triggerInvocationCount == 0)
        runner.trigger()
        runner.trigger()
        #expect(runner.triggerInvocationCount == 2)
    }

    @Test @MainActor
    func reset_clearsCountAndRestoresInitialMode() {
        guard let scenario = LabCatalog.scenario(id: "crash") else {
            Issue.record("Missing crash scenario")
            return
        }
        let runner = StubLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .fixed
        runner.trigger()
        runner.reset()
        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.implementationMode == .broken)
    }

    @Test @MainActor
    func modeClampsToFixedWhenBrokenUnsupported() {
        let scenario = LabScenario(
            id: "test_fixed_only",
            title: "Test",
            summary: "Test",
            category: .crash,
            difficulty: .beginner,
            learningGoals: [],
            reproductionSteps: [],
            hints: [],
            toolRecommendations: [],
            supportsBrokenMode: false,
            supportsFixedMode: true,
            investigationGuide: InvestigationGuide(
                recommendedFirstTool: "None",
                steps: [],
                validationChecklist: []
            ),
            catalogSortIndex: 999
        )
        let runner = StubLabScenarioRunner(scenario: scenario)
        #expect(runner.implementationMode == .fixed)
        runner.implementationMode = .broken
        #expect(runner.implementationMode == .fixed)
    }
}
