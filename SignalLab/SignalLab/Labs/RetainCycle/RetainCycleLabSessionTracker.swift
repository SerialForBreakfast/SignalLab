//
//  RetainCycleLabSessionTracker.swift
//  SignalLab
//
//  Counts live Retain Cycle Lab detail controllers for a visible leak signal.
//

import Combine
import Foundation
import OSLog

/// Tracks how many ``RetainCycleLabDetailHeart`` instances are currently alive.
///
/// ## Concurrency
/// Main-actor isolated; UI reads ``liveSessionCount`` from SwiftUI. Notifications from
/// ``RetainCycleLabDetailHeart`` `deinit` hop to the main actor asynchronously.
@MainActor
final class RetainCycleLabSessionTracker: ObservableObject {
    /// Shared instance wired by the Retain Cycle Lab UI.
    static let shared = RetainCycleLabSessionTracker()

    /// Number of detail hearts that have been created and not yet deallocated.
    @Published private(set) var liveSessionCount: Int = 0

    private init() {}

    fileprivate func registerSessionStarted() {
        liveSessionCount += 1
        let count = liveSessionCount
        SignalLabLog.retainCycleLab.debug("detail session started—live=\(count, privacy: .public)")
    }

    fileprivate func registerSessionEnded() {
        liveSessionCount = max(0, liveSessionCount - 1)
        let count = liveSessionCount
        SignalLabLog.retainCycleLab.debug("detail session ended—live=\(count, privacy: .public)")
    }

    /// Called from ``RetainCycleLabDetailHeart/init(mode:)`` (may be nonisolated context).
    nonisolated static func notifySessionStarted() {
        Task { @MainActor in
            shared.registerSessionStarted()
        }
    }

    /// Called from ``RetainCycleLabDetailHeart/deinit`` when the heart is actually torn down.
    nonisolated static func notifySessionEnded() {
        Task { @MainActor in
            shared.registerSessionEnded()
        }
    }
}
