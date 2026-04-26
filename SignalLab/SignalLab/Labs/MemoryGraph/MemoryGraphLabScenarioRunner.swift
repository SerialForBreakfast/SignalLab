//
//  MemoryGraphLabScenarioRunner.swift
//  SignalLab
//
//  Swift-only Memory Graph fixture: a long-lived store retains a checkout session.
//

import Foundation
import Observation
import OSLog

/// Stable, app-owned Memory Graph root for the beginner ownership-path lesson.
@MainActor
final class MemoryGraphSessionStore {
    static let shared = MemoryGraphSessionStore()

    private(set) var currentSession: MemoryGraphLeakedCheckoutSession?

    private init() {}

    @discardableResult
    func retainLeakedSession(run: Int) -> MemoryGraphLeakedCheckoutSession {
        let session = MemoryGraphLeakedCheckoutSession(identifier: "checkout-\(String(format: "%03d", run))")
        currentSession = session
        return session
    }

    func reset() {
        currentSession = nil
    }
}

/// The learner-facing object to search for in Xcode Memory Graph.
final class MemoryGraphLeakedCheckoutSession {
    let identifier: String
    let cartSnapshot: MemoryGraphCartSnapshot
    let receiptDraft: MemoryGraphReceiptDraft

    init(identifier: String) {
        self.identifier = identifier
        self.cartSnapshot = MemoryGraphCartSnapshot(itemCount: 3, subtotal: Decimal(120))
        self.receiptDraft = MemoryGraphReceiptDraft(title: "Student checkout receipt")
    }
}

/// A named child object that makes the retained session look like real app state.
final class MemoryGraphCartSnapshot {
    let itemCount: Int
    let subtotal: Decimal

    init(itemCount: Int, subtotal: Decimal) {
        self.itemCount = itemCount
        self.subtotal = subtotal
    }
}

/// A second named child object so the graph is a short ownership path, not a generic allocation.
final class MemoryGraphReceiptDraft {
    let title: String

    init(title: String) {
        self.title = title
    }
}

/// Memory Graph Lab runner — retains a checkout session in a long-lived store.
///
/// ## Concurrency
/// Main-actor isolated so the static store and SwiftUI state are mutated from one executor.
@MainActor
@Observable
final class MemoryGraphLabScenarioRunner: LabScenarioRunning {
    private let store: MemoryGraphSessionStore

    private(set) var triggerInvocationCount: Int = 0
    private(set) var lastStatusMessage: String?
    private(set) var retainedSessionIdentifier: String?

    let storeTypeName = "MemoryGraphSessionStore"
    let sessionTypeName = "MemoryGraphLeakedCheckoutSession"
    let cartTypeName = "MemoryGraphCartSnapshot"
    let receiptTypeName = "MemoryGraphReceiptDraft"

    var expectedOwnershipPath: String {
        "\(storeTypeName) -> \(sessionTypeName) -> \(cartTypeName) / \(receiptTypeName)"
    }

    init(scenario _: LabScenario, store: MemoryGraphSessionStore) {
        self.store = store
    }

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        let session = store.retainLeakedSession(run: run)
        retainedSessionIdentifier = session.identifier
        lastStatusMessage =
            "Retained \(session.identifier). In Memory Graph, search for \(sessionTypeName), then find \(storeTypeName) holding it."
        SignalLabLog.memoryGraphLab.info("trigger run=\(run, privacy: .public) retained session")
    }

    func reset() {
        triggerInvocationCount = 0
        retainedSessionIdentifier = nil
        lastStatusMessage = nil
        store.reset()
        SignalLabLog.memoryGraphLab.debug("reset")
    }
}
