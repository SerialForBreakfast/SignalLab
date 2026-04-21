//
//  BreakpointLabScenarioRunner.swift
//  SignalLab
//
//  Owns Breakpoint Lab state and runs the discount calculation.
//

import Foundation
import Observation
import OSLog

/// Runs the Breakpoint Lab discount scenario.
///
/// ## Concurrency
/// Main-actor isolated for SwiftUI bindings; the calculation is tiny and stays on the main actor for MVP.
@MainActor
@Observable
final class BreakpointLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

    let order: BreakpointLabOrder
    let previewResult: BreakpointLabDiscountResult
    private(set) var lastResult: BreakpointLabDiscountResult?

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

    /// Designated initializer for dependency injection.
    init(scenario: LabScenario, order: BreakpointLabOrder) {
        self.scenario = scenario
        self.order = order
        self.previewResult = BreakpointLabDiscountCalculator.calculateStudentOrderTotal(order: order)
        self.implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
    }

    /// Convenience entry point using the built-in student order.
    convenience init(scenario: LabScenario) {
        self.init(scenario: scenario, order: BreakpointLabDiscountCalculator.studentOrder)
    }

    func trigger() {
        triggerInvocationCount += 1
        lastResult = BreakpointLabDiscountCalculator.calculateStudentOrderTotal(order: order)
        let run = triggerInvocationCount
        let mode = implementationMode.rawValue
        let appliedDiscountPercent = lastResult?.appliedDiscountPercent ?? 0
        SignalLabLog.breakpointLab.info(
            "trigger run=\(run, privacy: .public) mode=\(mode, privacy: .public) appliedDiscountPercent=\(appliedDiscountPercent, privacy: .public)"
        )
    }

    func reset() {
        triggerInvocationCount = 0
        lastResult = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.breakpointLab.debug("reset")
    }
}
