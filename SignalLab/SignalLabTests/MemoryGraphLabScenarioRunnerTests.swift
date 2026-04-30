//
//  MemoryGraphLabScenarioRunnerTests.swift
//  SignalLabTests
//
//  Exercises the Swift-only Memory Graph ownership fixture.
//

import Testing
@testable import SignalLab

struct MemoryGraphLabScenarioRunnerTests {
    @Test @MainActor
    func trigger_retainsCheckoutSessionInStore() {
        guard let scenario = LabCatalog.scenario(id: "memory_graph") else {
            Issue.record("Missing memory_graph scenario")
            return
        }
        let store = MemoryGraphSessionStore.shared
        store.reset()
        let runner = MemoryGraphLabScenarioRunner(scenario: scenario, store: store)

        runner.trigger()

        #expect(runner.triggerInvocationCount == 1)
        #expect(store.currentSession != nil)
        #expect(store.currentSession?.identifier == "checkout-001")
        #expect(store.currentSession?.cartSnapshot.itemCount == 3)
        #expect(store.currentSession?.receiptDraft.title == "Student checkout receipt")
        #expect(runner.lastStatusMessage?.contains("stays alive until Reset clears the store") == true)

        store.reset()
    }

    @Test @MainActor
    func reset_clearsStore() {
        guard let scenario = LabCatalog.scenario(id: "memory_graph") else {
            Issue.record("Missing memory_graph scenario")
            return
        }
        let store = MemoryGraphSessionStore.shared
        store.reset()
        let runner = MemoryGraphLabScenarioRunner(scenario: scenario, store: store)
        runner.trigger()

        runner.reset()

        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.retainedSessionIdentifier == nil)
        #expect(runner.lastStatusMessage == nil)
        #expect(store.currentSession == nil)
    }
}
