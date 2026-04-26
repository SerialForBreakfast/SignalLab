//
//  MallocStackLoggingLabScenarioRunner.swift
//  SignalLab
//
//  Allocates thousands of fresh row arrays each run — allocation hot path for Instruments / malloc stacks.
//

import Foundation
import Observation
import OSLog

/// Malloc Stack Logging Lab runner — allocation burst on each trigger.
///
/// ## Concurrency
/// Main-actor isolated. Work is CPU-bound allocation on the main thread so the UI remains easy to correlate with
/// Instruments captures; keep runs bounded by ``rowCount``.
@MainActor
@Observable
final class MallocStackLoggingLabScenarioRunner: LabScenarioRunning {
    private let rowCount = 2_000
    private let columnCount = 32

    private(set) var triggerInvocationCount: Int = 0

    private(set) var lastStatusMessage: String?

    /// Row arrays created during the last trigger.
    private(set) var lastFreshRowArraysAllocated: Int = 0

    init(scenario _: LabScenario) {}

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        let rowsAllocated = rowCount
        SignalLabLog.mallocStackLoggingLab.warning(
            "trigger run=\(run, privacy: .public) (fresh row arrays \(rowsAllocated, privacy: .public))"
        )
        var fresh: [[String]] = []
        fresh.reserveCapacity(rowCount)
        for rowIndex in 0..<rowCount {
            fresh.append((0..<columnCount).map { _ in "r\(rowIndex)" })
        }
        lastFreshRowArraysAllocated = fresh.count
        let checksum = Self.checksum(for: fresh)
        lastStatusMessage =
            "Allocated \(fresh.count) fresh row arrays (checksum mix \(checksum))—enable Malloc Stack Logging and capture who allocated this path."
    }

    func reset() {
        triggerInvocationCount = 0
        lastStatusMessage = nil
        lastFreshRowArraysAllocated = 0
        SignalLabLog.mallocStackLoggingLab.debug("reset")
    }

    private static func checksum(for rows: [[String]]) -> Int {
        var mix = 0
        for row in rows {
            for cell in row {
                mix ^= cell.utf8.count
            }
        }
        return mix
    }
}
