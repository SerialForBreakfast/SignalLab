//
//  BackgroundThreadUILabScenarioRunner.swift
//  SignalLab
//
//  Posts a notification from a detached task so SwiftUI observers may run off the main actor.
//

import Foundation
import Observation
import OSLog

/// Notification name and `userInfo` key for Background Thread UI Lab demos.
enum BackgroundThreadUILabNotifications {
    static let didSignal = Notification.Name("SignalLab.backgroundThreadUILab.didSignal")

    /// `String` payload surfaced by the detail view when a ping arrives.
    static let messageKey = "message"
}

/// Background Thread UI Lab runner — unsafe notification posting from a background thread.
///
/// ## Concurrency
/// `trigger()` uses `DispatchQueue.global` to post without a main-queue hop (undefined for UI observers).
@MainActor
@Observable
final class BackgroundThreadUILabScenarioRunner: LabScenarioRunning {
    private(set) var triggerInvocationCount: Int = 0

    private(set) var lastStatusMessage: String?

    init(scenario _: LabScenario) {}

    func trigger() {
        triggerInvocationCount += 1
        let run = triggerInvocationCount
        let message = "Ping run \(run)"
        SignalLabLog.backgroundThreadUILab.warning(
            "trigger run=\(run, privacy: .public) (notification off main)"
        )
        lastStatusMessage =
            "Posted the lab notification from a detached task with no MainActor hop—watch Xcode for threading/runtime diagnostics."
        DispatchQueue.global(qos: .userInitiated).async {
            NotificationCenter.default.post(
                name: BackgroundThreadUILabNotifications.didSignal,
                object: nil,
                userInfo: [BackgroundThreadUILabNotifications.messageKey: message]
            )
        }
    }

    func reset() {
        triggerInvocationCount = 0
        lastStatusMessage = nil
        SignalLabLog.backgroundThreadUILab.debug("reset")
    }
}
