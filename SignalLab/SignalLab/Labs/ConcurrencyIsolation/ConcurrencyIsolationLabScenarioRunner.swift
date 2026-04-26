//
//  ConcurrencyIsolationLabScenarioRunner.swift
//  SignalLab
//
//  Two `Task.detached` calls race to log completion—order is undefined (unstructured concurrency).
//

import Foundation
import Observation
import OSLog

/// Deliberately **not** `Sendable`—this runner references it from a `@Sendable` detached task so Xcode surfaces isolation issues.
private final class IsolationLabNonSendableToken {
    let tag: String

    init(tag: String) {
        self.tag = tag
    }
}

/// Concurrency Isolation Lab — task ordering and Sendable diagnostics before reaching for Thread Sanitizer.
///
/// ## Concurrency
/// **trigger()** launches two detached tasks that immediately hop to the main actor to append labels;
/// scheduling order is not guaranteed. A separate detached task also reads a non-Sendable token for compiler diagnostics.
/// All UI-visible state is updated on the main actor.
@MainActor
@Observable
final class ConcurrencyIsolationLabScenarioRunner: LabScenarioRunning {
    private(set) var triggerInvocationCount: Int = 0

    /// Completion labels appended from concurrent paths (may appear as `["beta","alpha"]` or `["alpha","beta"]`).
    private(set) var completionOrder: [String] = []

    private(set) var lastStatusMessage: String?

    init(scenario _: LabScenario) {}

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        completionOrder = []

        SignalLabLog.concurrencyIsolationLab.warning(
            "trigger run=\(run, privacy: .public) (unordered detached + non-Sendable capture)"
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
    }

    func reset() {
        triggerInvocationCount = 0
        completionOrder = []
        lastStatusMessage = nil
        SignalLabLog.concurrencyIsolationLab.debug("reset")
    }

    private func appendCompletion(_ label: String) {
        completionOrder.append(label)
    }
}
