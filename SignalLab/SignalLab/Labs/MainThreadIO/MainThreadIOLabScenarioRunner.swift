//
//  MainThreadIOLabScenarioRunner.swift
//  SignalLab
//
//  Reads a bundled-size temp blob synchronously on the main actor many times (blocks UI).
//

import Foundation
import Observation
import OSLog

/// Main Thread I/O Lab runner — synchronous disk read on the main thread.
///
/// ## Concurrency
/// `trigger()` performs repeated `Data(contentsOf:)` on the main actor, blocking UI updates.
@MainActor
@Observable
final class MainThreadIOLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    /// Bytes written to the temp blob (single read size per iteration).
    private let blobByteCount = 256 * 1024

    /// How many full-file reads performed per trigger.
    private let readIterations = 10

    private var blobFileURL: URL?

    private(set) var triggerInvocationCount: Int = 0

    /// `true` while reading is in progress (will not repaint on main thread until done).
    private(set) var isReading: Bool = false

    /// Byte length from the last successful read, if any.
    private(set) var lastReadByteCount: Int?

    private(set) var lastStatusMessage: String?

    init(scenario: LabScenario) {
        self.scenario = scenario
    }

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        SignalLabLog.mainThreadIOLab.warning("trigger run=\(run, privacy: .public) (sync I/O on main)")
        isReading = true
        lastReadByteCount = nil
        lastStatusMessage = "Reading \(readIterations)× on the main thread—UI should stutter."
        do {
            let url = try ensureBlobFileURL()
            var total = 0
            for _ in 0..<readIterations {
                let data = try Data(contentsOf: url)
                total += data.count
            }
            lastReadByteCount = total / readIterations
            lastStatusMessage =
                "Read \(readIterations) times (~\(total / 1024) KB total) synchronously on main—profile with Time Profiler to see the blocking I/O."
        } catch {
            lastStatusMessage = "I/O error: \(error.localizedDescription)"
            lastReadByteCount = nil
        }
        isReading = false
        SignalLabLog.mainThreadIOLab.info("run finished run=\(run, privacy: .public)")
    }

    func reset() {
        triggerInvocationCount = 0
        isReading = false
        lastReadByteCount = nil
        lastStatusMessage = nil
        if let url = blobFileURL {
            try? FileManager.default.removeItem(at: url)
            blobFileURL = nil
        }
        SignalLabLog.mainThreadIOLab.debug("reset")
    }

    private func ensureBlobFileURL() throws -> URL {
        if let existing = blobFileURL, FileManager.default.fileExists(atPath: existing.path) {
            return existing
        }
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent("SignalLabMainThreadIOLab.blob", isDirectory: false)
        let data = Data(repeating: 0x5E, count: blobByteCount)
        try data.write(to: url, options: .atomic)
        blobFileURL = url
        return url
    }
}
