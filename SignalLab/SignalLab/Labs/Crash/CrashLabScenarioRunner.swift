//
//  CrashLabScenarioRunner.swift
//  SignalLab
//
//  Broken-only import path for Crash Lab.
//

import Foundation
import Observation
import OSLog

/// Drives the Crash Lab import scenario.
///
/// Calls ``CrashImportParser/importLinesAssumingCompleteSchema(jsonText:)`` with a
/// JSON payload that includes a row whose `count` is a string. The unsafe cast terminates the
/// process — by design. Attach the debugger before tapping Run to investigate the crash.
///
/// ## Concurrency
/// Main-actor isolated for SwiftUI bindings; parsing is small enough to stay on the main actor.
@MainActor
@Observable
final class CrashLabScenarioRunner: LabScenarioRunning {
    private(set) var triggerInvocationCount: Int = 0

    // MARK: - Init

    init(scenario _: LabScenario) {}

    // MARK: - LabScenarioRunning

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        SignalLabLog.crashLab.info("trigger run=\(run, privacy: .public)")
        runBrokenImport()
    }

    func reset() {
        triggerInvocationCount = 0
        SignalLabLog.crashLab.debug("reset")
    }

    // MARK: - Broken path (intentional crash)

    private func runBrokenImport() {
        let jsonText = CrashLabSampleData.loadJSONString()
        SignalLabLog.crashLab.warning("Broken import path — expect crash on malformed count")
        _ = CrashImportParser.importLinesAssumingCompleteSchema(jsonText: jsonText)
    }
}
