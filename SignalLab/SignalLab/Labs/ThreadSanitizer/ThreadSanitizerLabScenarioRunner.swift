//
//  ThreadSanitizerLabScenarioRunner.swift
//  SignalLab
//
//  Main thread and a detached task increment the same counter without synchronization (data race).
//

import Dispatch
import Foundation
import Observation
import OSLog

/// Shared counter mutated from the Thread Sanitizer Lab's concurrent paths.
///
/// The lab uses raw shared memory so the broken path can still model a true race under Swift 6's stricter
/// actor-isolation rules.
private final class ThreadSanitizerSharedCounter: @unchecked Sendable {
    private let storage: UnsafeMutablePointer<Int>

    init() {
        storage = .allocate(capacity: 1)
        storage.initialize(to: 0)
    }

    deinit {
        storage.deinitialize(count: 1)
        storage.deallocate()
    }

    var value: Int {
        get { storage.pointee }
        set { storage.pointee = newValue }
    }

    func increment() {
        storage.pointee += 1
    }
}

/// Thread Sanitizer Lab runner — deliberate data race on a shared counter.
///
/// ## Concurrency
/// Isolated to the main actor for SwiftUI. `trigger()` starts a detached task that races the main thread;
/// enable Thread Sanitizer in the scheme to catch the race report.
@MainActor
@Observable
final class ThreadSanitizerLabScenarioRunner: LabScenarioRunning {
    private let raceIterations = 5_000

    private(set) var triggerInvocationCount: Int = 0

    private(set) var lastStatusMessage: String?

    init(scenario _: LabScenario) {}

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        let iterations = raceIterations

        SignalLabLog.threadSanitizerLab.warning(
            "trigger run=\(run, privacy: .public) (racy shared counter; enable Thread Sanitizer)"
        )
        let counter = ThreadSanitizerSharedCounter()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            for _ in 0..<iterations {
                counter.increment()
            }
            group.leave()
        }
        for _ in 0..<iterations {
            counter.increment()
        }
        group.wait()
        lastStatusMessage =
            "Main thread finished \(iterations) increments while a detached task mutates the same counter without a lock—enable Thread Sanitizer to catch the race."
    }

    func reset() {
        triggerInvocationCount = 0
        lastStatusMessage = nil
        SignalLabLog.threadSanitizerLab.debug("reset")
    }
}
