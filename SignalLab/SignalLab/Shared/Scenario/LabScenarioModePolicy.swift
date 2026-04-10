//
//  LabScenarioModePolicy.swift
//  SignalLab
//
//  Shared broken/fixed mode defaults and clamping for lab runners.
//

import Foundation

/// Centralizes how runners choose and clamp ``LabImplementationMode`` from ``LabScenario`` flags.
enum LabScenarioModePolicy {
    /// Baseline after reset: prefer Broken when the lab supports teaching the bug first.
    static func initialMode(for scenario: LabScenario) -> LabImplementationMode {
        if scenario.supportsBrokenMode { return .broken }
        if scenario.supportsFixedMode { return .fixed }
        return .broken
    }

    /// Clamps an invalid selection when a lab only supports one side.
    static func clampedMode(
        _ mode: LabImplementationMode,
        supportsBroken: Bool,
        supportsFixed: Bool
    ) -> LabImplementationMode {
        switch mode {
        case .broken where !supportsBroken:
            return supportsFixed ? .fixed : .broken
        case .fixed where !supportsFixed:
            return supportsBroken ? .broken : .fixed
        default:
            return mode
        }
    }
}
