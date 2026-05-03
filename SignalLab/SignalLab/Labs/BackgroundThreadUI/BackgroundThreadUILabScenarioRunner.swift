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

/// Background Thread UI Lab runner — unsafe notification posting from a detached Swift task.
///
/// ## Concurrency
/// `trigger()` uses `Task.detached` to post `NotificationCenter` events from a non-isolated
/// context — no `@MainActor` hop before posting. Any SwiftUI `onReceive` handler that mutates
/// `@State` directly will execute off the main actor, producing a runtime warning.
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
            "trigger run=\(run, privacy: .public) (notification posted from Task.detached — no MainActor hop)"
        )
        lastStatusMessage =
            "Notification posted from Task.detached with no MainActor hop — watch the Xcode console for a threading/runtime warning."
        // Post from a detached task: no @MainActor isolation, so the notification arrives on
        // whatever thread the Swift concurrency runtime schedules. Any onReceive handler that
        // writes @State directly will update UI state off the main actor.
        Task.detached {
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
