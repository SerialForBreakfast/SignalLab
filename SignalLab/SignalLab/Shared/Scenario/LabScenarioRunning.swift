//
//  LabScenarioRunning.swift
//  SignalLab
//
//  Abstraction for trigger/reset, shared by the lab detail shell.
//

import Foundation

/// Capabilities every lab exposes to the shared detail UI.
///
/// ## Concurrency
/// The app target uses main-actor isolation by default. Implementations are expected to run on
/// the main actor so SwiftUI bindings and button handlers do not cross isolation boundaries.
/// Future heavy work should hop off the main actor inside the lab module, not in this protocol.
@MainActor
protocol LabScenarioRunning: AnyObject {
    /// How many times ``trigger()`` completed successfully (for UI feedback and tests).
    var triggerInvocationCount: Int { get }
    /// Runs the scenario action (import, search, load, etc.).
    func trigger()
    /// Returns UI and counters to a known baseline.
    func reset()
}
