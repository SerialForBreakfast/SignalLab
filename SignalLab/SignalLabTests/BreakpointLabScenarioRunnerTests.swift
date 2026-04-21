//
//  BreakpointLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Runner state for Breakpoint Lab on the main actor.
//

import Foundation
import Testing
@testable import SignalLab

struct BreakpointLabScenarioRunnerTests {
    @Test @MainActor
    func trigger_exposesWrongStudentDiscountResult() {
        guard let scenario = LabCatalog.scenario(id: "breakpoint") else {
            Issue.record("Missing breakpoint scenario")
            return
        }
        let runner = BreakpointLabScenarioRunner(scenario: scenario)
        runner.implementationMode = .broken
        runner.trigger()

        #expect(runner.triggerInvocationCount == 1)
        #expect(runner.lastResult?.customerType == .student)
        #expect(runner.lastResult?.expectedDiscountPercent == 20)
        #expect(runner.lastResult?.appliedDiscountPercent == 5)
        #expect(runner.lastResult?.actualTotal == 114)
    }

    @Test @MainActor
    func reset_clearsInputsAndResults() {
        guard let scenario = LabCatalog.scenario(id: "breakpoint") else {
            Issue.record("Missing breakpoint scenario")
            return
        }
        let runner = BreakpointLabScenarioRunner(scenario: scenario)
        runner.trigger()
        runner.reset()

        #expect(runner.lastResult == nil)
        #expect(runner.triggerInvocationCount == 0)
    }
}
