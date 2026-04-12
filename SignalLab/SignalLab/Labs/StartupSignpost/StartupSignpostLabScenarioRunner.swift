//
//  StartupSignpostLabScenarioRunner.swift
//  SignalLab
//
//  Broken: simulates multi-phase main-thread startup work with no signposts (harder to read in Instruments).
//  Fixed: same work wrapped in `os_signpost` intervals for the Points of Interest instrument.
//

import Foundation
import Observation
import OSLog
import os.signpost

/// Shared subsystem string for Points of Interest signposts (filter in Console / Instruments).
private let startupSignpostSubsystem = Bundle.main.bundleIdentifier ?? "com.showblender.SignalLab"

/// Log handle for Points of Interest — category name matches the template Xcode expects for POI signposts.
private let startupPointsOfInterestLog = OSLog(subsystem: startupSignpostSubsystem, category: "PointsOfInterest")

/// Startup Signpost Lab runner — deterministic CPU phases with optional signpost intervals.
///
/// ## Concurrency
/// Isolated to the main actor. **Broken** and **Fixed** both run synchronous CPU work on the main thread during
/// ``trigger()`` so learners can contrast Instruments timelines; Fixed additionally emits `os_signpost` begin/end pairs.
@MainActor
@Observable
final class StartupSignpostLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

    /// Stable checksum from the last run (same work in both modes).
    private(set) var lastChecksum: Int?

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
        let seed = triggerInvocationCount

        switch implementationMode {
        case .broken:
            SignalLabLog.startupSignpostLab.warning("trigger run=\(seed, privacy: .public) mode=broken (no signposts)")
            lastStatusMessage = "Running phased startup work on main—no signposts; use Time Profiler only."
            let checksum = Self.runPhases(seed: seed, signpostsEnabled: false)
            lastChecksum = checksum
            lastStatusMessage =
                "Phased work finished (checksum \(checksum)). No POI signposts—open Instruments > Points of Interest to see nothing structured."
        case .fixed:
            SignalLabLog.startupSignpostLab.info("trigger run=\(seed, privacy: .public) mode=fixed (os_signpost)")
            lastStatusMessage = "Running same phases with os_signpost—record with Instruments > Points of Interest."
            let checksum = Self.runPhases(seed: seed, signpostsEnabled: true)
            lastChecksum = checksum
            lastStatusMessage =
                "Phased work finished (checksum \(checksum)). Points of Interest should show SignalLabStartupConfig / Assets / Ready intervals."
        }
    }

    func reset() {
        triggerInvocationCount = 0
        lastChecksum = nil
        lastStatusMessage = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.startupSignpostLab.debug("reset")
    }

    /// Runs three CPU phases; optionally wraps each in a signpost interval named for the POI instrument.
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
