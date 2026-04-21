//
//  HangLabScenarioRunner.swift
//  SignalLab
//
//  Broken: runs ``HangLabWorkload/simulateReportProcessing`` on the main actor (UI freeze).
//  Fixed: runs the same work inside `Task.detached` then updates UI on the main actor.
//

import Foundation
import Observation
import OSLog

/// Hang Lab runner controlling main-thread vs background execution of the same workload.
///
/// ## Concurrency
/// The type is main-actor isolated. **Broken** `trigger()` performs work synchronously on the main actor.
/// **Fixed** `trigger()` starts an unstructured `Task` that awaits ``Task/detached`` work, then mutates UI state
/// back on the main actor. Call ``reset()`` to cancel an in-flight Fixed task. Cancellation is best-effort for MVP.
@MainActor
@Observable
final class HangLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

    /// `true` while a Fixed-mode job is in flight (Broken mode may not paint this before blocking).
    private(set) var isProcessingReport: Bool = false

    /// Checksum from the last completed run, if any.
    private(set) var lastReportChecksum: Int?

    /// Human-readable status for the detail UI.
    private(set) var lastStatusMessage: String?

    private var processingTask: Task<Void, Never>?

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
        processingTask?.cancel()
        processingTask = nil

        triggerInvocationCount += 1
        let seed = triggerInvocationCount

        switch implementationMode {
        case .broken:
            SignalLabLog.hangLab.info("trigger run=\(seed, privacy: .public) mode=broken (main-thread workload)")
            isProcessingReport = true
            lastStatusMessage = "Processing on main thread…"
            let checksum = HangLabWorkload.simulateReportProcessing(seed: seed)
            isProcessingReport = false
            lastReportChecksum = checksum
            lastStatusMessage = "Report ready. Checksum \(checksum). (Notice: the spinner never appeared — the main thread was blocked and could not paint UI updates until work finished.)"
            SignalLabLog.hangLab.info("broken run finished checksum=\(checksum, privacy: .public)")
        case .fixed:
            SignalLabLog.hangLab.info("trigger run=\(seed, privacy: .public) mode=fixed (detached workload)")
            isProcessingReport = true
            lastReportChecksum = nil
            lastStatusMessage = "Processing off main thread—you should still be able to scroll."
            processingTask = Task { @MainActor in
                let checksum = await Task.detached(priority: .userInitiated) {
                    HangLabWorkload.simulateReportProcessing(seed: seed)
                }.value
                guard !Task.isCancelled else {
                    self.isProcessingReport = false
                    self.lastStatusMessage = "Cancelled."
                    SignalLabLog.hangLab.debug("fixed run cancelled seed=\(seed, privacy: .public)")
                    return
                }
                self.isProcessingReport = false
                self.lastReportChecksum = checksum
                self.lastStatusMessage = "Report ready (background). Checksum \(checksum)."
                SignalLabLog.hangLab.info("fixed run finished checksum=\(checksum, privacy: .public)")
            }
        }
    }

    func reset() {
        processingTask?.cancel()
        processingTask = nil
        triggerInvocationCount = 0
        isProcessingReport = false
        lastReportChecksum = nil
        lastStatusMessage = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.hangLab.debug("reset")
    }
}
