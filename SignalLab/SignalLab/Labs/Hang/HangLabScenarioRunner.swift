//
//  HangLabScenarioRunner.swift
//  SignalLab
//
//  Blocks the main thread with Thread.sleep so the hang is visible in the debugger.
//

import Foundation
import Observation
import OSLog

/// Hang Lab runner — blocks the main thread to demonstrate a UI freeze.
///
/// ## Concurrency
/// The type is main-actor isolated. ``trigger()`` calls `Thread.sleep` synchronously,
/// freezing the UI so learners can pause the debugger and read the blocking line directly.
@MainActor
@Observable
final class HangLabScenarioRunner: LabScenarioRunning {
    private(set) var triggerInvocationCount: Int = 0

    /// `true` while work is in flight (will not repaint until the main thread unblocks).
    private(set) var isProcessingReport: Bool = false

    /// Checksum from the last completed run, if any.
    private(set) var lastReportChecksum: Int?

    /// Human-readable status for the detail UI.
    private(set) var lastStatusMessage: String?

    init(scenario _: LabScenario) {}

    // MARK: - Lab scenario

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        SignalLabLog.hangLab.info("trigger run=\(run, privacy: .public) (main-thread workload)")
        isProcessingReport = true         // neither this nor the line below will render —
        lastStatusMessage = "Processing on main thread…"   // the main thread is blocked before UIKit can commit the frame

        // Blocks the main thread for 4 s — @MainActor means this runs on the run-loop
        // thread, so touches, animations, and repaints are all frozen until it returns.
        // Pause the debugger while the UI is frozen, click this frame in the call stack,
        // and you land right here.
        Thread.sleep(forTimeInterval: 4.0)
        let checksum = run &* 1_000_000_007          // deterministic, varies per run

        isProcessingReport = false
        lastReportChecksum = checksum
        lastStatusMessage = "run \(run) done — checksum \(checksum). "
            + "The spinner never appeared: the main thread was blocked before the UI could paint a single frame."
        SignalLabLog.hangLab.info("run finished checksum=\(checksum, privacy: .public)")
    }

    func reset() {
        triggerInvocationCount = 0
        isProcessingReport = false
        lastReportChecksum = nil
        lastStatusMessage = nil
        SignalLabLog.hangLab.debug("reset")
    }
}
