//
//  HeapGrowthLabScenarioRunner.swift
//  SignalLab
//
//  Broken: append a large `Data` chunk every run—live bytes climb without a retain cycle (contrast with Retain Cycle Lab).
//  Fixed: ring buffer caps retained chunks so steady-state footprint plateaus.
//

import Foundation
import Observation
import OSLog

/// Heap Growth Lab runner — unbounded retention vs bounded ring buffer.
///
/// ## Concurrency
/// Main-actor isolated. Each trigger allocates one `Data` chunk synchronously on the main thread (intentionally simple for
/// Instruments Memory / Allocations exercises). Reset clears retained storage.
@MainActor
@Observable
final class HeapGrowthLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    /// Size of each synthetic "session buffer" chunk (bytes).
    private let chunkByteCount = 256 * 1024

    /// Maximum chunks kept in **Fixed** mode (oldest dropped when exceeded).
    private let maxRetainedChunksInFixedMode = 6

    private var retainedChunks: [Data] = []

    private(set) var triggerInvocationCount: Int = 0

    private(set) var lastStatusMessage: String?

    /// Number of `Data` chunks currently retained in this runner (drives live byte estimate).
    private(set) var retainedChunkCount: Int = 0

    /// Approximate live bytes (`retainedChunkCount * chunkByteCount`).
    private(set) var approximateRetainedBytes: Int = 0

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
        let chunk = Data(count: chunkByteCount)

        switch implementationMode {
        case .broken:
            SignalLabLog.heapGrowthLab.warning("trigger run=\(run, privacy: .public) mode=broken (append chunk)")
            retainedChunks.append(chunk)
            refreshMetrics()
            let kb = approximateRetainedBytes / 1024
            lastStatusMessage =
                "Retained chunk \(retainedChunkCount) (~\(kb) KB live). "
                + "Memory Graph may show growth without a cycle—contrast with Retain Cycle Lab."
        case .fixed:
            SignalLabLog.heapGrowthLab.info("trigger run=\(run, privacy: .public) mode=fixed (ring buffer)")
            retainedChunks.append(chunk)
            while retainedChunks.count > maxRetainedChunksInFixedMode {
                retainedChunks.removeFirst()
            }
            refreshMetrics()
            let capKb = maxRetainedChunksInFixedMode * chunkByteCount / 1024
            lastStatusMessage =
                "Ring buffer holds at most \(maxRetainedChunksInFixedMode) chunks (~\(capKb) KB cap). Current: \(retainedChunkCount) chunks."
        }
    }

    func reset() {
        triggerInvocationCount = 0
        retainedChunks = []
        refreshMetrics()
        lastStatusMessage = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.heapGrowthLab.debug("reset")
    }

    private func refreshMetrics() {
        retainedChunkCount = retainedChunks.count
        approximateRetainedBytes = retainedChunkCount * chunkByteCount
    }
}
