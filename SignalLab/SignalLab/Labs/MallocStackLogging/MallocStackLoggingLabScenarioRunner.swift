//
//  MallocStackLoggingLabScenarioRunner.swift
//  SignalLab
//
//  Broken: allocates thousands of fresh row arrays each run (allocation hot path for Instruments / malloc stacks).
//  Fixed: reuses one buffer after warm-up so steady-state runs avoid a per-trigger allocation burst.
//

import Foundation
import Observation
import OSLog

/// Malloc Stack Logging Lab runner — allocation burst vs reused row storage.
///
/// ## Concurrency
/// Main-actor isolated. Work is CPU-bound allocation on the main thread so the UI remains easy to correlate with
/// Instruments captures; keep runs bounded by ``rowCount``.
@MainActor
@Observable
final class MallocStackLoggingLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private let rowCount = 2_000
    private let columnCount = 32

    private var reusableRows: [[String]] = []

    private(set) var triggerInvocationCount: Int = 0

    private(set) var lastStatusMessage: String?

    /// Row arrays created during the last trigger (`Broken` ≈ ``rowCount`` each time; `Fixed` is zero after warm-up).
    private(set) var lastFreshRowArraysAllocated: Int = 0

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

        switch implementationMode {
        case .broken:
            let rowsAllocated = rowCount
            SignalLabLog.mallocStackLoggingLab.warning(
                "trigger run=\(run, privacy: .public) mode=broken (fresh row arrays \(rowsAllocated, privacy: .public))"
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
        case .fixed:
            SignalLabLog.mallocStackLoggingLab.info("trigger run=\(run, privacy: .public) mode=fixed (reuse buffer)")
            let didWarm = reusableRows.count != rowCount
            if didWarm {
                reusableRows = (0..<rowCount).map { rowIndex in
                    (0..<columnCount).map { _ in "r\(rowIndex)" }
                }
            }
            lastFreshRowArraysAllocated = didWarm ? rowCount : 0
            let checksum = Self.checksum(for: reusableRows)
            lastStatusMessage =
                didWarm
                ? "Warmed reusable buffer (\(rowCount) rows, checksum mix \(checksum)); next runs should show far fewer new row allocations."
                : "Reused \(rowCount) existing rows (checksum mix \(checksum))—contrast with Broken mode’s per-run allocation burst."
        }
    }

    func reset() {
        triggerInvocationCount = 0
        lastStatusMessage = nil
        lastFreshRowArraysAllocated = 0
        reusableRows = []
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
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
