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
    func trigger_keepsOpenNoteInHolder() {
        guard let scenario = LabCatalog.scenario(id: "memory_graph") else {
            Issue.record("Missing memory_graph scenario")
            return
        }
        let holder = MemoryGraphOpenNoteHolder.shared
        holder.reset()
        let runner = MemoryGraphLabScenarioRunner(scenario: scenario, holder: holder)

        runner.trigger()

        #expect(runner.triggerInvocationCount == 1)
        #expect(holder.openNote != nil)
        #expect(holder.openNote?.identifier == "note-001")
        #expect(holder.openNote?.body.text == "Memory Graph practice note")
        #expect(holder.openNote?.autosaveState.status == "waiting to save")
        #expect(runner.lastStatusMessage?.contains("keeping MemoryGraphOpenNote alive") == true)

        holder.reset()
    }

    @Test @MainActor
    func reset_clearsHolder() {
        guard let scenario = LabCatalog.scenario(id: "memory_graph") else {
            Issue.record("Missing memory_graph scenario")
            return
        }
        let holder = MemoryGraphOpenNoteHolder.shared
        holder.reset()
        let runner = MemoryGraphLabScenarioRunner(scenario: scenario, holder: holder)
        runner.trigger()

        runner.reset()

        #expect(runner.triggerInvocationCount == 0)
        #expect(runner.openNoteIdentifier == nil)
        #expect(runner.lastStatusMessage == nil)
        #expect(holder.openNote == nil)
    }
}
