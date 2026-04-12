//
//  ScrollHitchLabScenarioRunner.swift
//  SignalLab
//
//  Broken: many rows use per-row compositing + heavy shadow so scrolling hitches.
//  Fixed: lighter chrome—same layout, far cheaper rasterization during scroll.
//

import Foundation
import Observation
import OSLog

/// Scroll Hitch Lab runner — drives auto-scroll requests and exposes mode for row styling.
///
/// ## Concurrency
/// Isolated to the main actor for SwiftUI. ``trigger()`` only bumps ``autoScrollNonce`` on the main actor;
/// the detail view performs animated scrolling when that value changes.
@MainActor
@Observable
final class ScrollHitchLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    /// Rows rendered in the scroll probe (enough to require lazy layout work while scrolling).
    let rowCount = 44

    private(set) var triggerInvocationCount: Int = 0

    /// Increments on each ``trigger()`` so the detail view can scroll programmatically.
    private(set) var autoScrollNonce: Int = 0

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
        autoScrollNonce += 1
        let run = triggerInvocationCount
        switch implementationMode {
        case .broken:
            SignalLabLog.scrollHitchLab.info("trigger run=\(run, privacy: .public) mode=broken (heavy row chrome)")
            lastStatusMessage =
                "Auto-scrolling with heavy per-row compositing—expect dropped frames in Instruments > Core Animation."
        case .fixed:
            SignalLabLog.scrollHitchLab.info("trigger run=\(run, privacy: .public) mode=fixed (light chrome)")
            lastStatusMessage =
                "Same scroll with lighter row chrome—compare scrolling frame time vs Broken in Core Animation / Time Profiler."
        }
    }

    func reset() {
        triggerInvocationCount = 0
        autoScrollNonce = 0
        lastStatusMessage = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.scrollHitchLab.debug("reset")
    }
}
