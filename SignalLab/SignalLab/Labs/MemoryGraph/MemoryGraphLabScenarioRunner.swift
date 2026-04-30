//
//  MemoryGraphLabScenarioRunner.swift
//  SignalLab
//
//  Swift-only Memory Graph fixture: one app object keeps an open note alive.
//

import Foundation
import Observation
import OSLog

/// Stable, app-owned Memory Graph root for the beginner keep-alive path lesson.
@MainActor
final class MemoryGraphOpenNoteHolder {
    static let shared = MemoryGraphOpenNoteHolder()

    private(set) var openNote: MemoryGraphOpenNote?

    private init() {}

    @discardableResult
    func keepOpenNote(run: Int) -> MemoryGraphOpenNote {
        let note = MemoryGraphOpenNote(identifier: "note-\(String(format: "%03d", run))")
        openNote = note
        return note
    }

    func reset() {
        openNote = nil
    }
}

/// The learner-facing object to search for in Xcode Memory Graph.
final class MemoryGraphOpenNote {
    let identifier: String
    let body: MemoryGraphNoteBody
    let autosaveState: MemoryGraphNoteAutosaveState

    init(identifier: String) {
        self.identifier = identifier
        self.body = MemoryGraphNoteBody(text: "Memory Graph practice note")
        self.autosaveState = MemoryGraphNoteAutosaveState(status: "waiting to save")
    }
}

/// A named child object that makes the open note look like real app state.
final class MemoryGraphNoteBody {
    let text: String

    init(text: String) {
        self.text = text
    }
}

/// A second named child object so the graph is a short keep-alive path, not a generic allocation.
final class MemoryGraphNoteAutosaveState {
    let status: String

    init(status: String) {
        self.status = status
    }
}

/// Memory Graph Lab runner — keeps one open note alive from a long-lived holder.
///
/// ## Concurrency
/// Main-actor isolated so the static store and SwiftUI state are mutated from one executor.
@MainActor
@Observable
final class MemoryGraphLabScenarioRunner: LabScenarioRunning {
    private let holder: MemoryGraphOpenNoteHolder

    private(set) var triggerInvocationCount: Int = 0
    private(set) var lastStatusMessage: String?
    private(set) var openNoteIdentifier: String?

    let holderTypeName = "MemoryGraphOpenNoteHolder"
    let noteTypeName = "MemoryGraphOpenNote"
    let bodyTypeName = "MemoryGraphNoteBody"
    let autosaveTypeName = "MemoryGraphNoteAutosaveState"

    var expectedOwnershipPath: String {
        "\(holderTypeName) keeps alive -> \(noteTypeName) keeps alive -> \(bodyTypeName) / \(autosaveTypeName)"
    }

    init(scenario _: LabScenario, holder: MemoryGraphOpenNoteHolder) {
        self.holder = holder
    }

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        let note = holder.keepOpenNote(run: run)
        openNoteIdentifier = note.identifier
        lastStatusMessage =
            "Created \(note.identifier). Memory Graph should show MemoryGraphOpenNoteHolder keeping MemoryGraphOpenNote alive until Reset clears it."
        SignalLabLog.memoryGraphLab.info("trigger run=\(run, privacy: .public) retained open note")
    }

    func reset() {
        triggerInvocationCount = 0
        openNoteIdentifier = nil
        lastStatusMessage = nil
        holder.reset()
        SignalLabLog.memoryGraphLab.debug("reset")
    }
}
