//
//  HangLabScenarioRunner.swift
//  SignalLab
//
//  Runs ``HangLabWorkload/simulateReportProcessing`` on the main actor (UI freeze).
//

import Foundation
import Observation
import OSLog

/// Hang Lab runner — blocks the main thread with a CPU-intensive workload.
///
/// ## Concurrency
/// The type is main-actor isolated. ``trigger()`` performs work synchronously on the main actor,
/// freezing the UI so learners can pause the debugger and find the blocking frame.
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

    func trigger() {
        triggerInvocationCount += 1
        let seed = triggerInvocationCount
        SignalLabLog.hangLab.info("trigger run=\(seed, privacy: .public) (main-thread workload)")
        isProcessingReport = true
        lastStatusMessage = "Processing on main thread…"
        let checksum = HangLabWorkload.simulateReportProcessing(seed: seed)
        isProcessingReport = false
        lastReportChecksum = checksum
        lastStatusMessage = "Report ready. Checksum \(checksum). (Notice: the spinner never appeared — the main thread was blocked and could not paint UI updates until work finished.)"
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
