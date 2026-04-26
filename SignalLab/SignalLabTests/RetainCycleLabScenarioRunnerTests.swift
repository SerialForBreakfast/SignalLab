//
//  RetainCycleLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Runner state for Retain Cycle Lab on the main actor.
//

import Testing
@testable import SignalLab

struct RetainCycleLabScenarioRunnerTests {
    @Test
    func leakingExample_hasTwoObjectCycleWithReadableNames() {
        let checkoutScreen = RetainCycleLabCheckoutScreen.makeLeakingExample()

        #expect(checkoutScreen.title == "Student checkout")
        #expect(checkoutScreen.closeButtonHandler?.buttonTitle == "Close")
        #expect(checkoutScreen.closeButtonHandler?.checkoutScreen === checkoutScreen)
    }

    @Test
    func breakRetainCycleForReset_removesBackReference() {
        let checkoutScreen = RetainCycleLabCheckoutScreen.makeLeakingExample()

        checkoutScreen.breakRetainCycleForReset()

        #expect(checkoutScreen.closeButtonHandler == nil)
    }

    @Test
    func leakingExample_staysAliveAfterLocalReferenceEnds() {
        weak var leakedCheckoutScreen: RetainCycleLabCheckoutScreen?

        do {
            let checkoutScreen = RetainCycleLabCheckoutScreen.makeLeakingExample()
            leakedCheckoutScreen = checkoutScreen
        }

        #expect(leakedCheckoutScreen != nil)
        leakedCheckoutScreen?.breakRetainCycleForReset()
    }

    @Test @MainActor
    func trigger_exposesMemoryGraphSearchTarget() {
        guard let scenario = LabCatalog.scenario(id: "retain_cycle") else {
            Issue.record("Missing retain cycle scenario")
            return
        }
        let runner = RetainCycleLabScenarioRunner(scenario: scenario)

        runner.trigger()

        #expect(runner.triggerInvocationCount == 1)
        #expect(runner.statusMessage.contains("RetainCycleLabCheckoutScreen"))
    }

    @Test @MainActor
    func reset_clearsRunState() {
        guard let scenario = LabCatalog.scenario(id: "retain_cycle") else {
            Issue.record("Missing retain cycle scenario")
            return
        }
        let runner = RetainCycleLabScenarioRunner(scenario: scenario)
        runner.trigger()

        runner.reset()

        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.statusMessage.contains("Run the scenario once"))
    }
}
