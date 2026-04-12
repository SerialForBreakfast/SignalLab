//
//  MainThreadIOLabScenarioRunner.swift
//  SignalLab
//
//  Broken: reads a bundled-size temp blob synchronously on the main actor many times (blocks UI).
//  Fixed: loads the same blob inside `Task.detached` then applies results on the main actor.
//

import Foundation
import Observation
import OSLog

/// Main Thread I/O Lab runner — synchronous disk read on main vs background read.
///
/// ## Concurrency
/// **Broken** `trigger()` performs repeated `Data(contentsOf:)` on the main actor.
/// **Fixed** `trigger()` starts an unstructured `Task` that awaits a detached read, then updates UI state on the main actor.
/// Call ``reset()`` to cancel an in-flight Fixed task.
@MainActor
@Observable
final class MainThreadIOLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    /// Bytes written to the temp blob (single read size per iteration in Broken).
    private let blobByteCount = 256 * 1024

    /// How many full-file reads Broken performs per trigger.
    private let brokenReadIterations = 10

    private var blobFileURL: URL?

    private var processingTask: Task<Void, Never>?

    private(set) var triggerInvocationCount: Int = 0

    /// `true` while Fixed mode is awaiting the detached read.
    private(set) var isReading: Bool = false

    /// Byte length from the last successful Fixed read, if any.
    private(set) var lastReadByteCount: Int?

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
        processingTask?.cancel()
        processingTask = nil

        triggerInvocationCount += 1
        let run = triggerInvocationCount

        switch implementationMode {
        case .broken:
            SignalLabLog.mainThreadIOLab.warning("trigger run=\(run, privacy: .public) mode=broken (sync I/O on main)")
            isReading = true
            lastReadByteCount = nil
            lastStatusMessage = "Reading \(brokenReadIterations)× on the main thread—UI should stutter."
            do {
                let url = try ensureBlobFileURL()
                var total = 0
                for _ in 0..<brokenReadIterations {
                    let data = try Data(contentsOf: url)
                    total += data.count
                }
                lastReadByteCount = total / brokenReadIterations
                lastStatusMessage =
                    "Read \(brokenReadIterations) times (~\(total / 1024) KB total) synchronously on main—contrast with Fixed + Time Profiler."
            } catch {
                lastStatusMessage = "I/O error: \(error.localizedDescription)"
                lastReadByteCount = nil
            }
            isReading = false
            SignalLabLog.mainThreadIOLab.info("broken run finished run=\(run, privacy: .public)")
        case .fixed:
            SignalLabLog.mainThreadIOLab.info("trigger run=\(run, privacy: .public) mode=fixed (detached read)")
            isReading = true
            lastReadByteCount = nil
            lastStatusMessage = "Reading off main thread—scroll probes should stay responsive."
            processingTask = Task { @MainActor in
                do {
                    let url = try self.ensureBlobFileURL()
                    let byteCount = self.blobByteCount
                    let data = try await Task.detached(priority: .userInitiated) {
                        try Data(contentsOf: url)
                    }.value
                    guard !Task.isCancelled else {
                        self.isReading = false
                        self.lastStatusMessage = "Cancelled."
                        return
                    }
                    self.isReading = false
                    self.lastReadByteCount = data.count
                    self.lastStatusMessage =
                        "Loaded \(data.count) bytes off main (expected \(byteCount))—main stayed free for UI work."
                    SignalLabLog.mainThreadIOLab.info("fixed run finished bytes=\(data.count, privacy: .public)")
                } catch {
                    guard !Task.isCancelled else {
                        self.isReading = false
                        return
                    }
                    self.isReading = false
                    self.lastStatusMessage = "I/O error: \(error.localizedDescription)"
                }
            }
        }
    }

    func reset() {
        processingTask?.cancel()
        processingTask = nil
        triggerInvocationCount = 0
        isReading = false
        lastReadByteCount = nil
        lastStatusMessage = nil
        if let url = blobFileURL {
            try? FileManager.default.removeItem(at: url)
            blobFileURL = nil
        }
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
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
