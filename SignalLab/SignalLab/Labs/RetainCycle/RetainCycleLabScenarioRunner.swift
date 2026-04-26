//
//  RetainCycleLabScenarioRunner.swift
//  SignalLab
//
//  Creates a small object graph for Retain Cycle Lab.
//

import Foundation
import Observation
import OSLog

/// Drives Retain Cycle Lab: **Run scenario** creates one checkout object graph for Memory Graph.
///
/// ## Concurrency
/// Main-actor isolated for SwiftUI bindings and sheet presentation state.
@MainActor
@Observable
final class RetainCycleLabScenarioRunner: LabScenarioRunning {
    private(set) var triggerInvocationCount: Int = 0
    private weak var leakedCheckoutScreen: RetainCycleLabCheckoutScreen?

    var statusMessage: String {
        guard triggerInvocationCount > 0 else {
            return "Run the scenario once, then open Memory Graph."
        }
        return "Created one checkout screen. In Memory Graph, search for RetainCycleLabCheckoutScreen."
    }

    init(scenario _: LabScenario) {}

    func trigger() {
        triggerInvocationCount += 1
        leakedCheckoutScreen?.breakRetainCycleForReset()
        let checkoutScreen = RetainCycleLabCheckoutScreen.makeLeakingExample()
        leakedCheckoutScreen = checkoutScreen
        let run = triggerInvocationCount
        SignalLabLog.retainCycleLab.info(
            "trigger run=\(run, privacy: .public)—created checkout retain cycle"
        )
    }

    func reset() {
        triggerInvocationCount = 0
        leakedCheckoutScreen?.breakRetainCycleForReset()
        leakedCheckoutScreen = nil
        SignalLabLog.retainCycleLab.debug("reset")
    }
}
