//
//  ZombieObjectsLabScenarioRunner.swift
//  SignalLab
//
//  Objective-C `__unsafe_unretained` dangling send after pool drain (trap; clearer with Zombie Objects).
//

import Foundation
import Observation
import OSLog

/// Zombie Objects Lab runner — use-after-release.
///
/// ## Concurrency
/// ``trigger()`` runs on the main actor. It calls into Objective-C that performs undefined behavior
/// if Zombie Objects are off; with Zombies enabled it should stop in the runtime's zombie path
/// instead of a vague `EXC_BAD_ACCESS`.
@MainActor
@Observable
final class ZombieObjectsLabScenarioRunner: LabScenarioRunning {
    private(set) var triggerInvocationCount: Int = 0

    /// Status after a run (this path usually does not return due to the crash).
    private(set) var lastStatusMessage: String?

    init(scenario _: LabScenario) {}

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        lastStatusMessage = nil
        SignalLabLog.zombieObjectsLab.warning(
            "trigger run=\(run, privacy: .public) (use-after-release; enable Zombie Objects in scheme)"
        )
        ZombieObjectsLabTriggerUnsafeUseAfterRelease()
    }

    func reset() {
        triggerInvocationCount = 0
        lastStatusMessage = nil
        SignalLabLog.zombieObjectsLab.debug("reset")
    }
}
