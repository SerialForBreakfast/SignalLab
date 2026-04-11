//
//  ThreadSanitizerLabScenarioRunner.swift
//  SignalLab
//
//  Broken: main thread and a detached task increment the same counter without synchronization (data race).
//  Fixed: `NSLock` serializes all increments; `DispatchGroup` waits for the background task before reporting.
//

import Dispatch
import Foundation
import Observation
import OSLog

/// Shared counter mutated from the Thread Sanitizer Lab’s concurrent paths.
///
/// This type is marked ``Sendable`` so it can cross `Task.detached` while still modeling shared memory.
/// **Broken** mode intentionally omits external synchronization so Thread Sanitizer can flag the race; **Fixed** mode
/// uses ``NSLock`` around every mutation. Do not reuse this pattern for production code without a real concurrency design.
private final class ThreadSanitizerSharedCounter: @unchecked Sendable {
    var value = 0
}

/// Thread Sanitizer Lab runner — deliberate data race vs lock-serialized increments.
///
/// ## Concurrency
/// Isolated to the main actor for SwiftUI. **Broken** `trigger()` starts a detached task that races the main thread;
/// **Fixed** `trigger()` uses one ``NSLock`` and waits on a ``DispatchGroup`` before reading the final count.
@MainActor
@Observable
final class ThreadSanitizerLabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private let raceIterations = 5_000

    private(set) var triggerInvocationCount: Int = 0

    private(set) var lastStatusMessage: String?

    /// Final merged counter after a **Fixed** run; **Broken** leaves this `nil` (race makes a single read meaningless).
    private(set) var lastMergedCounter: Int?

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
        let iterations = raceIterations

        switch implementationMode {
        case .broken:
            lastMergedCounter = nil
            SignalLabLog.threadSanitizerLab.warning(
                "trigger run=\(run, privacy: .public) mode=broken (racy shared counter; enable Thread Sanitizer)"
            )
            let counter = ThreadSanitizerSharedCounter()
            Task.detached(priority: .userInitiated) {
                for _ in 0..<iterations {
                    counter.value += 1
                }
            }
            for _ in 0..<iterations {
                counter.value += 1
            }
            lastStatusMessage =
                "Main thread finished \(iterations) increments while a detached task mutates the same counter without a lock—enable Thread Sanitizer to catch the race."
        case .fixed:
            SignalLabLog.threadSanitizerLab.info("trigger run=\(run, privacy: .public) mode=fixed (lock-serialized)")
            let counter = ThreadSanitizerSharedCounter()
            let lock = NSLock()
            let group = DispatchGroup()
            group.enter()
            Task.detached(priority: .userInitiated) {
                for _ in 0..<iterations {
                    lock.lock()
                    counter.value += 1
                    lock.unlock()
                }
                group.leave()
            }
            for _ in 0..<iterations {
                lock.lock()
                counter.value += 1
                lock.unlock()
            }
            group.wait()
            lastMergedCounter = counter.value
            let expected = iterations * 2
            lastStatusMessage = "Merged counter \(counter.value) (expected \(expected)) after serializing access with one lock."
        }
    }

    func reset() {
        triggerInvocationCount = 0
        lastStatusMessage = nil
        lastMergedCounter = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.threadSanitizerLab.debug("reset")
    }
}
