//
//  StubLabScenarioRunner.swift
//  SignalLab
//
//  Default runner until each lab supplies real scenario behavior (M1+).
//

import Foundation
import Observation

/// No-op runner that tracks mode and trigger count for the M0 shell.
///
/// ## Concurrency
/// Type is main-actor isolated (matches ``LabScenarioRunning`` and SwiftUI usage).
@MainActor
@Observable
final class StubLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

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

    /// Creates a runner for catalog/detail use.
    /// - Parameter scenario: Metadata that controls supported modes and reset baseline.
    init(scenario: LabScenario) {
        self.scenario = scenario
        self.implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
    }

    func trigger() {
        triggerInvocationCount += 1
    }

    func reset() {
        triggerInvocationCount = 0
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
    }
}
