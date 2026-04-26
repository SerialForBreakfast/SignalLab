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
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0
    private weak var leakedCheckoutScreen: RetainCycleLabCheckoutScreen?

    var statusMessage: String {
        guard triggerInvocationCount > 0 else {
            return "Run the scenario once, then open Memory Graph."
        }
        return "Created one checkout screen. In Memory Graph, search for RetainCycleLabCheckoutScreen."
    }

    var implementationMode: LabImplementationMode {
        didSet {
            let clamped = LabScenarioModePolicy.clampedMode(
                implementationMode,
                supportsBroken: scenario.supportsBrokenMode,
                supportsFixed: scenario.supportsFixedMode
            )
            if clamped != implementationMode {
                implementationMode = clamped
            }
        }
    }

    init(scenario: LabScenario) {
        self.scenario = scenario
        self.implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
    }

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
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.retainCycleLab.debug("reset")
    }
}
