//
//  RetainCycleLabScenarioRunner.swift
//  SignalLab
//
//  Presents the leak detail sheet and tracks broken/fixed mode for Retain Cycle Lab.
//

import Foundation
import Observation
import OSLog

/// Drives Retain Cycle Lab: **Run scenario** opens a detail sheet whose timer behavior depends on mode.
///
/// ## Concurrency
/// Main-actor isolated for SwiftUI bindings and sheet presentation state.
@MainActor
@Observable
final class RetainCycleLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

    /// When `true`, the detail sheet (and its ``RetainCycleLabDetailHeart``) is on screen.
    var isDetailSheetPresented: Bool = false

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
        isDetailSheetPresented = true
        let run = triggerInvocationCount
        let mode = implementationMode.rawValue
        SignalLabLog.retainCycleLab.info(
            "trigger run=\(run, privacy: .public) mode=\(mode, privacy: .public)—presenting detail sheet"
        )
    }

    func reset() {
        triggerInvocationCount = 0
        isDetailSheetPresented = false
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.retainCycleLab.debug("reset")
    }
}
