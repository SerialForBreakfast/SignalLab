//
//  CrashLabScenarioRunner.swift
//  SignalLab
//
//  Runs the Crash Lab import: Broken mode crashes on malformed rows; Fixed mode validates and reports.
//

import Foundation
import Observation

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
        let data = CrashLabSampleData.loadData()
        switch implementationMode {
        case .broken:
            _ = CrashImportParser.importLinesAssumingCompleteSchema(data: data)
        case .fixed:
            do {
                let result = try CrashImportParser.importLinesValidatingRecords(data: data)
                lastFixedImportedLineCount = result.lines.count
                let skippedText = result.skippedRecordMessages.joined(separator: " ")
                lastFixedImportSummary =
                    "Imported \(result.lines.count) valid line(s). \(skippedText)"
            } catch {
                lastFixedImportedLineCount = nil
                lastFixedImportSummary = "Import failed: \(error.localizedDescription)"
            }
        }
    }

    func reset() {
        triggerInvocationCount = 0
        lastFixedImportSummary = nil
        lastFixedImportedLineCount = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
    }
}
