//
//  DeadlockLabScenarioRunner.swift
//  SignalLab
//
//  Broken: `DispatchQueue.main.sync` from the main thread—classic self-deadlock (debugger pause / force-quit).
//  Fixed: perform work inline on the main actor without synchronously waiting on the same queue.
//

import Dispatch
import Foundation
import Observation
import OSLog

/// Deadlock Lab runner — main-queue self-deadlock vs safe main-actor work.
///
/// ## Concurrency
/// **Broken** `trigger()` calls `DispatchQueue.main.sync` from a `@MainActor` context, which deadlocks the process.
/// **Fixed** `trigger()` avoids that pattern. Do not invoke Broken mode from unit tests or unattended automation.
@MainActor
@Observable
final class DeadlockLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

    private(set) var lastStatusMessage: String?

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
        let run = triggerInvocationCount

        switch implementationMode {
        case .broken:
            lastStatusMessage = nil
            SignalLabLog.deadlockLab.warning(
                "trigger run=\(run, privacy: .public) mode=broken (main.sync from main — deadlock)"
            )
            DispatchQueue.main.sync {
                // Never reached: main is blocked waiting on work scheduled onto the same queue.
            }
        case .fixed:
            SignalLabLog.deadlockLab.info("trigger run=\(run, privacy: .public) mode=fixed (no main sync)")
            let checksum = run &* 31 &+ 7
            lastStatusMessage =
                "Completed run \(run) on the main actor without `dispatch_sync` to the main queue (checksum \(checksum))."
        }
    }

    func reset() {
        triggerInvocationCount = 0
        lastStatusMessage = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.deadlockLab.debug("reset")
    }
}
