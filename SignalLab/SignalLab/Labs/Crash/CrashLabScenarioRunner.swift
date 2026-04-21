//
//  CrashLabScenarioRunner.swift
//  SignalLab
//
//  Runs the Crash Lab import as a broken-only debugger exercise.
//

import Foundation
import Observation
import OSLog

/// Drives the Crash Lab import trigger as a broken-only debugger exercise.
///
/// ## Concurrency
/// Main-actor isolated like other lab runners; parsing is small enough to stay on the main actor for MVP.
@MainActor
@Observable
final class CrashLabScenarioRunner: LabScenarioRunning {
    private(set) var triggerInvocationCount: Int = 0

    var implementationMode: LabImplementationMode {
        didSet {
            if implementationMode != .broken {
                implementationMode = .broken
            }
        }
    }

    init(scenario _: LabScenario) {
        self.implementationMode = .broken
    }

    func trigger() {
        triggerInvocationCount += 1
        SignalLabLog.crashLab.info(
            "trigger run=\(self.triggerInvocationCount, privacy: .public) mode=broken"
        )
        runBrokenImport()
    }

    func reset() {
        triggerInvocationCount = 0
        implementationMode = .broken
        SignalLabLog.crashLab.debug("reset—back to broken mode")
    }

    private func runBrokenImport() {
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

        SignalLabLog.crashLab.warning("Broken import path — expect crash on malformed count")
        _ = CrashImportParser.importLinesAssumingCompleteSchema(jsonText: brokenJSONText)
    }
}
