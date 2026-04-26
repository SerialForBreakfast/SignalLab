//
//  HeapGrowthLabScenarioRunner.swift
//  SignalLab
//
//  Appends a large `Data` chunk every run — live bytes climb without a retain cycle.
//

import Foundation
import Observation
import OSLog

/// Heap Growth Lab runner — unbounded retention.
///
/// ## Concurrency
/// Main-actor isolated. Each trigger allocates one `Data` chunk synchronously on the main thread
/// (intentionally simple for Instruments Memory / Allocations exercises). Reset clears retained storage.
@MainActor
@Observable
final class HeapGrowthLabScenarioRunner: LabScenarioRunning {
    /// Size of each synthetic "session buffer" chunk (bytes).
    private let chunkByteCount = 256 * 1024

    private var retainedChunks: [Data] = []

    private(set) var triggerInvocationCount: Int = 0

    private(set) var lastStatusMessage: String?

    /// Number of `Data` chunks currently retained in this runner (drives live byte estimate).
    private(set) var retainedChunkCount: Int = 0

    /// Approximate live bytes (`retainedChunkCount * chunkByteCount`).
    private(set) var approximateRetainedBytes: Int = 0

    init(scenario _: LabScenario) {}

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        let chunk = Data(count: chunkByteCount)
        SignalLabLog.heapGrowthLab.warning("trigger run=\(run, privacy: .public) (append chunk)")
        retainedChunks.append(chunk)
        refreshMetrics()
        let kb = approximateRetainedBytes / 1024
        lastStatusMessage =
            "Retained chunk \(retainedChunkCount) (~\(kb) KB live). "
            + "Memory Graph may show growth without a cycle—contrast with Retain Cycle Lab."
    }

    func reset() {
        triggerInvocationCount = 0
        retainedChunks = []
        refreshMetrics()
        lastStatusMessage = nil
        SignalLabLog.heapGrowthLab.debug("reset")
    }

    private func refreshMetrics() {
        retainedChunkCount = retainedChunks.count
        approximateRetainedBytes = retainedChunkCount * chunkByteCount
    }
}
