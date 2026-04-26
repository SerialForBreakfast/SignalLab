//
//  CrashLabScenarioRunner.swift
//  SignalLab
//
//  Broken and fixed import paths for Crash Lab.
//

import Foundation
import Observation
import OSLog

/// Drives the Crash Lab import scenario.
///
/// ## Modes
/// - **Broken:** Calls ``CrashImportParser/importLinesAssumingCompleteSchema(jsonText:)`` with a
///   JSON payload that includes a row whose `count` is a string. The unsafe cast terminates the
///   process — by design. Attach the debugger before tapping Run to investigate the crash.
/// - **Fixed:** Calls ``CrashImportParser/importLinesValidatingRecords(data:)`` with the same
///   payload. Valid rows are imported and the malformed row is skipped with an explanation.
///
/// ## Concurrency
/// Main-actor isolated for SwiftUI bindings; parsing is small enough to stay on the main actor.
@MainActor
@Observable
final class CrashLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

    var implementationMode: LabImplementationMode {
        didSet {
            let clamped = LabScenarioModePolicy.clampedMode(
                implementationMode,
                supportsBroken: scenario.supportsBrokenMode,
                supportsFixed: scenario.supportsFixedMode
            )
            if clamped != implementationMode { implementationMode = clamped }
        }
    }

    // MARK: - Fixed mode outcome

    /// Number of successfully imported lines after the most recent Fixed-mode trigger.
    /// `nil` until Fixed mode has been run at least once, and after ``reset()``.
    private(set) var lastFixedImportedLineCount: Int?

    /// Human-readable import summary after the most recent Fixed-mode trigger.
    /// Includes skipped-row explanations so learners can see which records were rejected.
    /// `nil` until Fixed mode has been run at least once, and after ``reset()``.
    private(set) var lastFixedImportSummary: String?

    // MARK: - Init

    init(scenario: LabScenario) {
        self.scenario = scenario
        self.implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
    }

    // MARK: - LabScenarioRunning

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        let mode = implementationMode.rawValue
        SignalLabLog.crashLab.info("trigger run=\(run, privacy: .public) mode=\(mode, privacy: .public)")

        switch implementationMode {
        case .broken:
            runBrokenImport()
        case .fixed:
            runFixedImport()
        }
    }

    func reset() {
        triggerInvocationCount = 0
        lastFixedImportedLineCount = nil
        lastFixedImportSummary = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.crashLab.debug("reset")
    }

    // MARK: - Broken path (intentional crash)

    private func runBrokenImport() {
        let jsonText = CrashLabSampleData.loadJSONString()
        SignalLabLog.crashLab.warning("Broken import path — expect crash on malformed count")
        _ = CrashImportParser.importLinesAssumingCompleteSchema(jsonText: jsonText)
    }

    // MARK: - Fixed path (validating)

    private func runFixedImport() {
        let data = CrashLabSampleData.loadData()
        do {
            let result = try CrashImportParser.importLinesValidatingRecords(data: data)
            lastFixedImportedLineCount = result.lines.count

            var parts: [String] = ["Imported \(result.lines.count) line\(result.lines.count == 1 ? "" : "s")."]
            parts += result.skippedRecordMessages
            lastFixedImportSummary = parts.joined(separator: " ")

            let count = result.lines.count
            let skipped = result.skippedRecordMessages.count
            SignalLabLog.crashLab.info(
                "fixed import imported=\(count, privacy: .public) skipped=\(skipped, privacy: .public)"
            )
        } catch {
            lastFixedImportedLineCount = 0
            lastFixedImportSummary = "Import failed: \(error.localizedDescription)"
            SignalLabLog.crashLab.error("fixed import threw: \(error, privacy: .public)")
        }
    }
}
