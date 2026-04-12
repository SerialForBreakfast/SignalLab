//
//  ConcurrencyIsolationLabScenarioRunner.swift
//  SignalLab
//
//  Broken: two `Task.detached` calls race to log completion—order is undefined (unstructured concurrency).
//  Fixed: one structured `Task` awaits each MainActor hop in order; optional non-Sendable capture is removed.
//

import Foundation
import Observation
import OSLog

/// Deliberately **not** `Sendable`—Broken mode references it from a `@Sendable` detached task so Xcode surfaces isolation issues.
private final class IsolationLabNonSendableToken {
    let tag: String

    init(tag: String) {
        self.tag = tag
    }
}

/// Concurrency Isolation Lab — task ordering and Sendable diagnostics before reaching for Thread Sanitizer.
///
/// ## Concurrency
/// **Broken** launches two detached tasks that immediately hop to the main actor to append labels; scheduling order is
/// not guaranteed. A separate detached task also reads a non-Sendable token for compiler diagnostics.
/// **Fixed** uses one unstructured `Task` that performs the same appends sequentially on the main actor.
/// All UI-visible state is updated on the main actor.
@MainActor
@Observable
final class ConcurrencyIsolationLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

    /// Completion labels appended from concurrent paths (Broken may appear as `["beta","alpha"]` or `["alpha","beta"]`).
    private(set) var completionOrder: [String] = []

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
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        completionOrder = []

        switch implementationMode {
        case .broken:
            SignalLabLog.concurrencyIsolationLab.warning(
                "trigger run=\(run, privacy: .public) mode=broken (unordered detached + non-Sendable capture)"
            )
            let token = IsolationLabNonSendableToken(tag: "run-\(run)")

            Task.detached {
                await MainActor.run { [weak self] in
                    self?.appendCompletion("alpha")
                }
            }
            Task.detached {
                await MainActor.run { [weak self] in
                    self?.appendCompletion("beta")
                }
            }

            Task.detached {
                _ = token.tag
            }

            lastStatusMessage =
                "Two detached tasks raced to log alpha/beta—check Xcode for Sendable warnings on the token; use Issue navigator before Thread Sanitizer."

        case .fixed:
            SignalLabLog.concurrencyIsolationLab.info("trigger run=\(run, privacy: .public) mode=fixed (sequential)")
            lastStatusMessage = "Running ordered MainActor work…"
            Task { [weak self] in
                await self?.runFixedLabeledSteps(run: run)
            }
        }
    }

    func reset() {
        triggerInvocationCount = 0
        completionOrder = []
        lastStatusMessage = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.concurrencyIsolationLab.debug("reset")
    }

    private func appendCompletion(_ label: String) {
        completionOrder.append(label)
    }

    private func runFixedLabeledSteps(run: Int) async {
        appendCompletion("alpha")
        try? await Task.sleep(nanoseconds: 1_000_000)
        appendCompletion("beta")
        lastStatusMessage =
            "Ordered steps: always alpha then beta (run \(run)). Structured concurrency avoids flaky UI when sequence matters."
    }
}
