//
//  BackgroundThreadUILabScenarioRunner.swift
//  SignalLab
//
//  Broken: posts a notification from a detached task so SwiftUI observers may run off the main actor.
//  Fixed: posts the same notification from `MainActor.run` after hopping from the detached task.
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

/// Background Thread UI Lab runner — unsafe notification posting vs main-thread delivery.
///
/// ## Concurrency
/// **Broken** `trigger()` uses `Task.detached` to post without a main-queue hop (undefined for UI observers).
/// **Fixed** `trigger()` awaits ``MainActor/run`` before posting so UI updates stay on the main actor.
@MainActor
@Observable
final class BackgroundThreadUILabScenarioRunner: LabScenarioRunning {
    private let scenario: LabScenario

    private(set) var triggerInvocationCount: Int = 0

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
        let message = "Ping run \(run)"

        switch implementationMode {
        case .broken:
            SignalLabLog.backgroundThreadUILab.warning(
                "trigger run=\(run, privacy: .public) mode=broken (notification off main)"
            )
            lastStatusMessage =
                "Posted the lab notification from a detached task with no MainActor hop—watch Xcode for threading/runtime diagnostics."
            Task.detached(priority: .userInitiated) {
                NotificationCenter.default.post(
                    name: BackgroundThreadUILabNotifications.didSignal,
                    object: nil,
                    userInfo: [BackgroundThreadUILabNotifications.messageKey: message]
                )
            }
        case .fixed:
            SignalLabLog.backgroundThreadUILab.info(
                "trigger run=\(run, privacy: .public) mode=fixed (MainActor post)"
            )
            lastStatusMessage = "Posting from MainActor after an off-main hop—safe for UI observers."
            Task.detached(priority: .userInitiated) {
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: BackgroundThreadUILabNotifications.didSignal,
                        object: nil,
                        userInfo: [BackgroundThreadUILabNotifications.messageKey: message]
                    )
                }
            }
        }
    }

    func reset() {
        triggerInvocationCount = 0
        lastStatusMessage = nil
        implementationMode = LabScenarioModePolicy.initialMode(for: scenario)
        SignalLabLog.backgroundThreadUILab.debug("reset")
    }
}
