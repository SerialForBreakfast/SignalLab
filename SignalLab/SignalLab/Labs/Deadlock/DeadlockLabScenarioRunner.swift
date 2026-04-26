//
//  DeadlockLabScenarioRunner.swift
//  SignalLab
//
//  `DispatchQueue.main.sync` from the main thread — classic self-deadlock (debugger pause / force-quit).
//

import Dispatch
import Foundation
import Observation
import OSLog

/// Deadlock Lab runner — main-queue self-deadlock.
///
/// ## Concurrency
/// `trigger()` calls `DispatchQueue.main.sync` from a `@MainActor` context, which deadlocks the process.
/// Do not invoke from unit tests or unattended automation.
@MainActor
@Observable
final class DeadlockLabScenarioRunner: LabScenarioRunning {
    private(set) var triggerInvocationCount: Int = 0

    private(set) var lastStatusMessage: String?

    init(scenario _: LabScenario) {}

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        lastStatusMessage = nil
        SignalLabLog.deadlockLab.warning(
            "trigger run=\(run, privacy: .public) (main.sync from main — deadlock)"
        )
        DispatchQueue.main.sync {
            // Never reached: main is blocked waiting on work scheduled onto the same queue.
        }
    }

    func reset() {
        triggerInvocationCount = 0
        lastStatusMessage = nil
        SignalLabLog.deadlockLab.debug("reset")
    }
}
