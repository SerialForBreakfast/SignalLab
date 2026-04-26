//
//  StartupSignpostLabScenarioRunner.swift
//  SignalLab
//
//  Same main-thread startup phases wrapped in `os_signpost` intervals for the Points of Interest instrument.
//

import Foundation
import Observation
import OSLog
import os.signpost

/// Shared subsystem string for Points of Interest signposts (filter in Console / Instruments).
private let startupSignpostSubsystem = Bundle.main.bundleIdentifier ?? "com.showblender.SignalLab"

/// Log handle for Points of Interest — category name matches the template Xcode expects for POI signposts.
private let startupPointsOfInterestLog = OSLog(subsystem: startupSignpostSubsystem, category: "PointsOfInterest")

/// Startup Signpost Lab runner — deterministic CPU phases wrapped in signpost intervals.
///
/// ## Concurrency
/// Isolated to the main actor. ``trigger()`` runs synchronous CPU work on the main thread with
/// `os_signpost` begin/end pairs so learners can see named intervals in Instruments > Points of Interest.
@MainActor
@Observable
final class StartupSignpostLabScenarioRunner: LabScenarioRunning {
    private(set) var triggerInvocationCount: Int = 0

    /// Stable checksum from the last run.
    private(set) var lastChecksum: Int?

    private(set) var lastStatusMessage: String?

    init(scenario _: LabScenario) {}

    func trigger() {
        triggerInvocationCount += 1
        let seed = triggerInvocationCount
        SignalLabLog.startupSignpostLab.info("trigger run=\(seed, privacy: .public) (os_signpost)")
        lastStatusMessage = "Running same phases with os_signpost—record with Instruments > Points of Interest."
        let checksum = Self.runPhases(seed: seed, signpostsEnabled: true)
        lastChecksum = checksum
        lastStatusMessage =
            "Phased work finished (checksum \(checksum)). Points of Interest should show SignalLabStartupConfig / Assets / Ready intervals."
    }

    func reset() {
        triggerInvocationCount = 0
        lastChecksum = nil
        lastStatusMessage = nil
        SignalLabLog.startupSignpostLab.debug("reset")
    }

    /// Runs three CPU phases; wraps each in a signpost interval named for the POI instrument.
    private static func runPhases(seed: Int, signpostsEnabled: Bool) -> Int {
        var accumulator = seed &* 13
        accumulator &+= runPhase(
            name: "SignalLabStartupConfig",
            signpostsEnabled: signpostsEnabled,
            iterations: 120_000
        )
        accumulator &+= runPhase(
            name: "SignalLabStartupAssets",
            signpostsEnabled: signpostsEnabled,
            iterations: 180_000
        )
        accumulator &+= runPhase(
            name: "SignalLabStartupReady",
            signpostsEnabled: signpostsEnabled,
            iterations: 90_000
        )
        return accumulator
    }

    private static func runPhase(name: StaticString, signpostsEnabled: Bool, iterations: Int) -> Int {
        let signpostID = OSSignpostID(log: startupPointsOfInterestLog)
        if signpostsEnabled {
            os_signpost(.begin, log: startupPointsOfInterestLog, name: name, signpostID: signpostID)
        }
        defer {
            if signpostsEnabled {
                os_signpost(.end, log: startupPointsOfInterestLog, name: name, signpostID: signpostID)
            }
        }
        return burnCPU(iterations: iterations)
    }

    private static func burnCPU(iterations: Int) -> Int {
        var x = 1
        for _ in 0..<iterations {
            x = x &* 1103515245 &+ 12345
        }
        return x
    }
}
