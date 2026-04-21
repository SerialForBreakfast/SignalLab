//
//  ExceptionBreakpointLabScenarioRunner.swift
//  SignalLab
//
//  Hides a caught Objective-C exception for Exception Breakpoint Lab.
//

import Foundation
import Observation
import OSLog

/// Runs the Exception Breakpoint Lab scenario.
///
/// This runner intentionally catches an Objective-C exception and shows only a generic app symptom.
/// With an Exception Breakpoint enabled, Xcode should stop at the hidden raise site with readable
/// Objective-C locals in scope.
@MainActor
@Observable
final class ExceptionBreakpointLabScenarioRunner: LabScenarioRunning {
    private(set) var triggerInvocationCount: Int = 0
    private(set) var lastUserVisibleMessage: String?

    var implementationMode: LabImplementationMode {
        didSet {
            if implementationMode != .broken {
                implementationMode = .broken
            }
        }
    }

    init(scenario _: LabScenario) {
        self.implementationMode = .broken
    }

    func trigger() {
        triggerInvocationCount += 1
        lastUserVisibleMessage = ExceptionBreakpointLabRunCaughtSelection() as String
        SignalLabLog.exceptionBreakpointLab.info(
            "trigger run=\(self.triggerInvocationCount, privacy: .public) mode=broken"
        )
    }

    func reset() {
        triggerInvocationCount = 0
        lastUserVisibleMessage = nil
        implementationMode = .broken
        SignalLabLog.exceptionBreakpointLab.debug("reset—back to broken mode")
    }
}
