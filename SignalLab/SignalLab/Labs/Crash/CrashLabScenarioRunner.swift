//
//  CrashLabScenarioRunner.swift
//  SignalLab
//
//  Runs the Crash Lab import: Broken mode crashes on malformed rows; Fixed mode validates and reports.
//

import Foundation
import Observation
import OSLog

/// Drives the Crash Lab import trigger and surfaces Fixed-mode outcomes in the UI.
///
/// ## Concurrency
/// Main-actor isolated like other lab runners; parsing is small enough to stay on the main actor for MVP.
@MainActor
@Observable
final class CrashLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

    /// Summary of the last successful Fixed-mode import (nil until a Fixed run completes).
    private(set) var lastFixedImportSummary: String?

    /// Count of valid lines from the last Fixed-mode import.
    private(set) var lastFixedImportedLineCount: Int?

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
        let mode = implementationMode.rawValue
        SignalLabLog.crashLab.info(
            "trigger run=\(run, privacy: .public) mode=\(mode, privacy: .public)"
        )
        switch implementationMode {
        case .broken:
            runBrokenImport(run: run, mode: mode)
        case .fixed:
            runFixedImport()
        }
    }

    func reset() {
        triggerInvocationCount = 0
        lastFixedImportSummary = nil
        lastFixedImportedLineCount = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        let mode = implementationMode.rawValue
        SignalLabLog.crashLab.debug("reset—back to initial mode=\(mode, privacy: .public)")
    }

    private func runBrokenImport(run: Int, mode: String) {
        let brokenCountText = "three"
        let brokenJSONText = """
        [
          {
            "id": "line-1",
            "name": "Resistor kit",
            "count": 12
          },
          {
            "id": "line-2",
            "name": "Soldering iron stand",
            "count": "\(brokenCountText)"
          }
        ]
        """
        
        SignalLabLog.crashLab.warning(
            "Broken import path run=\(run, privacy: .public) mode=\(mode, privacy: .public)—expect crash if sample contains malformed row"
        )
        _ = CrashImportParser.importLinesAssumingCompleteSchema(jsonText: brokenJSONText)
    }

    private func runFixedImport() {
        let data = CrashLabSampleData.loadData()
        do {
            let result = try CrashImportParser.importLinesValidatingRecords(data: data)
            lastFixedImportedLineCount = result.lines.count
            let skippedText = result.skippedRecordMessages.joined(separator: " ")
            lastFixedImportSummary =
                "Imported \(result.lines.count) valid line(s). \(skippedText)"
            let lineCount = result.lines.count
            let skipCount = result.skippedRecordMessages.count
            SignalLabLog.crashLab.info(
                "Fixed import OK lines=\(lineCount, privacy: .public) skippedMessages=\(skipCount, privacy: .public)"
            )
        } catch {
            lastFixedImportedLineCount = nil
            lastFixedImportSummary = "Import failed: \(error.localizedDescription)"
            SignalLabLog.crashLab.error("Fixed import failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
