//
//  ZombieObjectsLabScenarioRunner.swift
//  SignalLab
//
//  Broken: Objective-C `__unsafe_unretained` dangling send after pool drain (trap; clearer with Zombie Objects).
//  Fixed: same object messaged only while alive inside one autorelease pool.
//

import Foundation
import Observation
import OSLog

/// Zombie Objects Lab runner — use-after-release vs safe pool-scoped messaging.
///
/// ## Concurrency
/// ``trigger()`` runs on the main actor. **Broken** mode calls into Objective-C that performs undefined behavior
/// if Zombie Objects are off; with Zombies enabled it should stop in the runtime’s zombie path instead of a vague `EXC_BAD_ACCESS`.
@MainActor
@Observable
final class ZombieObjectsLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

    /// Status after **Fixed** runs; **Broken** usually does not return.
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
            SignalLabLog.zombieObjectsLab.warning(
                "trigger run=\(run, privacy: .public) mode=broken (use-after-release; enable Zombie Objects in scheme)"
            )
            ZombieObjectsLabTriggerUnsafeUseAfterRelease()
        case .fixed:
            SignalLabLog.zombieObjectsLab.info("trigger run=\(run, privacy: .public) mode=fixed (safe pool-scoped use)")
            ZombieObjectsLabTriggerSafeUse()
            lastStatusMessage = "Safe path: the object was only messaged while still alive inside the autorelease pool."
        }
    }

    func reset() {
        triggerInvocationCount = 0
        lastStatusMessage = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.zombieObjectsLab.debug("reset")
    }
}
