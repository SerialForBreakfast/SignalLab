//
//  ScrollHitchLabScenarioRunner.swift
//  SignalLab
//
//  Many rows use per-row compositing + heavy shadow so scrolling hitches.
//

import Foundation
import Observation
import OSLog

/// Scroll Hitch Lab runner — drives auto-scroll requests with heavy per-row chrome.
///
/// ## Concurrency
/// Isolated to the main actor for SwiftUI. ``trigger()`` only bumps ``autoScrollNonce`` on the main actor;
/// the detail view performs animated scrolling when that value changes.
@MainActor
@Observable
final class ScrollHitchLabScenarioRunner: LabScenarioRunning {
    /// Rows rendered in the scroll probe (enough to require lazy layout work while scrolling).
    let rowCount = 44

    private(set) var triggerInvocationCount: Int = 0

    /// Increments on each ``trigger()`` so the detail view can scroll programmatically.
    private(set) var autoScrollNonce: Int = 0

    private(set) var lastStatusMessage: String?

    init(scenario _: LabScenario) {}

    func trigger() {
        triggerInvocationCount += 1
        autoScrollNonce += 1
        let run = triggerInvocationCount
        SignalLabLog.scrollHitchLab.info("trigger run=\(run, privacy: .public) (heavy row chrome)")
        lastStatusMessage =
            "Auto-scrolling with heavy per-row compositing—expect dropped frames in Instruments > Core Animation."
    }

    func reset() {
        triggerInvocationCount = 0
        autoScrollNonce = 0
        lastStatusMessage = nil
        SignalLabLog.scrollHitchLab.debug("reset")
    }
}
