//
//  MemoryGraphLabScenarioRunner.swift
//  SignalLab
//
//  Swift-only Memory Graph fixture: a long-lived store keeps a checkout session alive.
//

import Foundation
import Observation
import OSLog

/// Stable, app-owned Memory Graph root for the beginner keep-alive path lesson.
@MainActor
final class MemoryGraphSessionStore {
    static let shared = MemoryGraphSessionStore()

    private(set) var currentSession: MemoryGraphCheckoutSession?

    private init() {}

    @discardableResult
    func storeCheckoutSession(run: Int) -> MemoryGraphCheckoutSession {
        let session = MemoryGraphCheckoutSession(identifier: "checkout-\(String(format: "%03d", run))")
        currentSession = session
        return session
    }

    func reset() {
        currentSession = nil
    }
}

/// The learner-facing object to search for in Xcode Memory Graph.
final class MemoryGraphCheckoutSession {
    let identifier: String
    let cartSnapshot: MemoryGraphCheckoutCart
    let receiptDraft: MemoryGraphCheckoutReceipt

    init(identifier: String) {
        self.identifier = identifier
        self.cartSnapshot = MemoryGraphCheckoutCart(itemCount: 3, subtotal: Decimal(120))
        self.receiptDraft = MemoryGraphCheckoutReceipt(title: "Student checkout receipt")
    }
}

/// A named child object that makes the retained session look like real app state.
final class MemoryGraphCheckoutCart {
    let itemCount: Int
    let subtotal: Decimal

    init(itemCount: Int, subtotal: Decimal) {
        self.itemCount = itemCount
        self.subtotal = subtotal
    }
}

/// A second named child object so the graph is a short keep-alive path, not a generic allocation.
final class MemoryGraphCheckoutReceipt {
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
    let sessionTypeName = "MemoryGraphCheckoutSession"
    let cartTypeName = "MemoryGraphCheckoutCart"
    let receiptTypeName = "MemoryGraphCheckoutReceipt"

    var expectedOwnershipPath: String {
        "\(storeTypeName) keeps alive -> \(sessionTypeName) keeps alive -> \(cartTypeName) / \(receiptTypeName)"
    }

    init(scenario _: LabScenario, store: MemoryGraphSessionStore) {
        self.store = store
    }

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        let session = store.storeCheckoutSession(run: run)
        retainedSessionIdentifier = session.identifier
        lastStatusMessage =
            "Created \(session.identifier) and saved it in the shared session store. The session stays alive until Reset clears the store."
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
