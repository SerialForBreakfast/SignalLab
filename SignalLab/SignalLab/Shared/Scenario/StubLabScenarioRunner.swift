//
//  StubLabScenarioRunner.swift
//  SignalLab
//
//  Default runner until each lab supplies real scenario behavior (M1+).
//

import Foundation
import Observation
import OSLog

/// No-op runner that tracks trigger count for the M0 shell.
///
/// ## Concurrency
/// Type is main-actor isolated (matches ``LabScenarioRunning`` and SwiftUI usage).
@MainActor
@Observable
final class StubLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

    /// Creates a runner for catalog/detail use.
    /// - Parameter scenario: Metadata for logging.
    init(scenario: LabScenario) {
        self.scenario = scenario
    }

    func trigger() {
        triggerInvocationCount += 1
        let labId = scenario.id
        let run = triggerInvocationCount
        SignalLabLog.scenarioRunner.info(
            "trigger labId=\(labId, privacy: .public) run=\(run, privacy: .public)"
        )
    }

    func reset() {
        triggerInvocationCount = 0
        let labId = scenario.id
        SignalLabLog.scenarioRunner.debug("reset labId=\(labId, privacy: .public)")
    }
}
